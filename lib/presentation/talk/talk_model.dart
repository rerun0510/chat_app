import 'package:chat_app/domain/chatRoomInfo.dart';
import 'package:chat_app/domain/member.dart';
import 'package:chat_app/domain/messages.dart';
import 'package:chat_app/domain/users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TalkModel extends ChangeNotifier {
  List<Messages> messages = [];
  List<Member> memberList = [];
  List<Users> usersList = [];
  String message = '';
  bool updateFlg = true;

  Future fetchMessages(ChatRoomInfo chatRoomInfo) async {
    final members = await chatRoomInfo.roomRef.collection('member').get();
    final docs = members.docs;
    final memberList = docs.map((doc) => Member(doc)).toList();
    this.memberList = memberList;

    for (Member member in memberList) {
      final doc = await member.usersRef.get();
      this.usersList.add(Users(doc));
    }

    final snapshots = chatRoomInfo.roomRef
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots();
    snapshots.listen((snapshot) {
      final docs = snapshot.docs;
      // todo ソートする
      final messageList = docs.map((doc) => Messages(doc)).toList();
      messageList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      this.messages = messageList;
      notifyListeners();
    });
  }

  void setMessage(String text) {
    message = text;
    notifyListeners();
  }

  void setUpdateFlg(bool updateFlg) {
    this.updateFlg = updateFlg;
    notifyListeners();
  }

  Future sendMessage(String roomId, String userId) async {
    if (message.isEmpty) {
      throw ('メッセージを入力してください。');
    }

    Timestamp createdAt = Timestamp.now();

    await FirebaseFirestore.instance
        .collection('chatRoom')
        .doc(roomId)
        .collection('messages')
        .add(
      {
        'userId': userId,
        'message': message,
        'messageType': 'text',
        'createdAt': createdAt,
      },
    );

    for (Member member in this.memberList) {
      final document = member.usersRef.collection('chatRoomInfo').doc(roomId);
      await document.update(
        {
          'updateAt': createdAt,
          'resentMessage': message,
          'visible': true,
        },
      );
    }
  }

  Future updateMessage(
      String roomId, Messages messages, String updateMessage) async {
    if (messages.message.isEmpty) {
      throw ('メッセージを入力してください');
    }

    final document = FirebaseFirestore.instance
        .collection('chatRoom')
        .doc(roomId)
        .collection('messages')
        .doc(messages.messageId);
    await document.update(
      {
        'message': updateMessage,
      },
    );

    // TODO
    // 最新のメッセージが編集された場合のresentMessage更新
  }

  Future deleteMessage(String roomId, Messages messages) async {
    await FirebaseFirestore.instance
        .collection('chatRoom')
        .doc(roomId)
        .collection('messages')
        .doc(messages.messageId)
        .delete();

    // TODO
    // 最新メッセージが削除された場合のresentMessage更新
  }
}
