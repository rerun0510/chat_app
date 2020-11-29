import 'package:chat_app/domain/chatRoom.dart';
import 'package:chat_app/domain/chatRoomInfo.dart';
import 'package:chat_app/domain/member.dart';
import 'package:chat_app/domain/messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TalkModel extends ChangeNotifier {
  List<Messages> messages = [];
  List<Member> memberList;
  String message = '';
  bool updateFlg = true;

  Future fetchMessages(ChatRoomInfo chatRoomInfo) async {
    final members = chatRoomInfo.roomRef.collection('member').snapshots();
    members.listen((snapshot) {
      final docs = snapshot.docs;
      final memberList = docs.map((doc) => Member(doc)).toList();
      this.memberList = memberList;
      notifyListeners();
    });

    final snapshots = chatRoomInfo.roomRef
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots();
    snapshots.listen((snapshot) {
      final docs = snapshot.docs;
      final messageList = docs.map((doc) => Messages(doc)).toList();
      this.messages = messageList;
      notifyListeners();
    });
  }

  setMessage(String text) {
    message = text;
    notifyListeners();
  }

  setUpdateFlg(bool updateFlg) {
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

    for (Member member in memberList) {
      final document = member.usersRef.collection('chatRoomInfo').doc(roomId);
      await document.update(
        {
          'updateAt': createdAt,
          'resentMessage': message,
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
