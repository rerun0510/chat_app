import 'dart:async';

import 'package:chat_app/domain/chatRoomInfo.dart';
import 'package:chat_app/domain/member.dart';
import 'package:chat_app/domain/messages.dart';
import 'package:chat_app/domain/myFriends.dart';
import 'package:chat_app/domain/users.dart';
import 'package:chat_app/repository/current_user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TalkModel extends ChangeNotifier {
  TalkModel(ChatRoomInfo chatRoomInfo) {
    _init(chatRoomInfo);
  }

  List<Messages> messages = [];
  List<Member> memberList = [];
  List<Users> usersList = [];
  String message = '';
  bool updateFlg = true;
  bool groupFlg = false;
  Users currentUser;
  ChatRoomInfo chatRoomInfo;
  StreamSubscription<QuerySnapshot> messageListeners;
  StreamSubscription<DocumentSnapshot> chatRoomInfoListeners;
  StreamSubscription<QuerySnapshot> unreadMessageListeners;

  Future _init(ChatRoomInfo chatRoomInfo) async {
    // currentUser取得
    this.currentUser = await fetchCurrentUser();
    this.chatRoomInfo = chatRoomInfo;
    await fetchGroupFlg();
    await fetchMessages();
  }

  // サブスクリプションのキャンセル
  void subscriptionCancel() {
    messageListeners.cancel();
    chatRoomInfoListeners.cancel();
    unreadMessageListeners.cancel();
  }

  /// groupFlgの取得
  Future fetchGroupFlg() async {
    final doc = await this.chatRoomInfo.roomRef.get();
    this.groupFlg = doc['groupFlg'];
  }

  /// メッセージ取得
  Future fetchMessages() async {
    final chatRoomInfoRef = FirebaseFirestore.instance
        .collection('users')
        .doc(this.currentUser.userId)
        .collection('chatRoomInfo')
        .doc(this.chatRoomInfo.roomId);
    final members = await this.chatRoomInfo.roomRef.collection('member').get();
    final docs = members.docs;
    final memberList = docs.map((doc) => Member(doc)).toList();
    this.memberList = memberList;

    for (Member member in memberList) {
      final doc = await member.usersRef.get();
      this.usersList.add(Users(doc));
    }

    final messageSnapshots = this
        .chatRoomInfo
        .roomRef
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots();
    this.messageListeners = messageSnapshots.listen((snapshot) {
      // メッセージ受信
      final docs = snapshot.docs;
      final messageList = docs.map((doc) => Messages(doc)).toList();
      messageList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      this.messages = messageList;
      notifyListeners();
    });

    // 未読数の更新
    final chatRoomInfoSnapshots = chatRoomInfoRef.snapshots();
    this.chatRoomInfoListeners = chatRoomInfoSnapshots.listen((snapshot) {
      snapshot.reference.update({
        'unread': 0,
      });
    });
    // 未読メッセージを既読に更新
    final unreadMessageSnapshots =
        chatRoomInfoRef.collection('unreadMessage').snapshots();
    this.unreadMessageListeners =
        unreadMessageSnapshots.listen((snapshot) async {
      final docs = snapshot.docs;
      final messageRefList = docs.map((doc) => doc['messageRef']).toList();
      for (DocumentReference messageRef in messageRefList) {
        // 既読更新
        await messageRef.update({
          'read': FieldValue.increment(1.0),
        });
        await messageRef
            .collection('member')
            .doc(this.currentUser.userId)
            .update({
          'read': true,
        });
        // 既読更新後に、未読メッセージから削除
        await chatRoomInfoRef
            .collection('unreadMessage')
            .doc(messageRef.id)
            .delete();
      }
    });
  }

  void setMessage(String text) {
    this.message = text;
    notifyListeners();
  }

  void setUpdateFlg(bool updateFlg) {
    this.updateFlg = updateFlg;
    notifyListeners();
  }

  /// メッセージ送信
  Future sendMessage() async {
    if (this.message.isEmpty) {
      throw ('メッセージを入力してください。');
    }

    // 先にメッセージボックスの初期化を反映
    notifyListeners();

    final createdAt = Timestamp.now();

    final messageRef = await FirebaseFirestore.instance
        .collection('chatRoom')
        .doc(this.chatRoomInfo.roomId)
        .collection('messages')
        .add({
      'userId': this.currentUser.userId,
      'message': message,
      'messageType': 'text',
      'createdAt': createdAt,
      'read': 0,
    });

    for (Member member in this.memberList) {
      // 既読情報を追加
      final bool read = member.userId == this.currentUser.userId ? true : false;
      final unreadRef = messageRef.collection('member').doc(member.userId);
      await unreadRef.set({
        'read': read,
      });

      // 最新のメッセージ情報を更新
      final document = member.usersRef
          .collection('chatRoomInfo')
          .doc(this.chatRoomInfo.roomId);
      await document.update({
        'updateAt': createdAt,
        'resentMessage': message,
        'visible': true,
        'unread': read ? 0 : FieldValue.increment(1.0),
      });

      // 未読メッセージの追加(自分以外)
      if (!read) {
        await document
            .collection('unreadMessage')
            .doc(messageRef.id)
            .set({'messageRef': messageRef});
      }
    }
  }

  /// メッセージ更新（未実装）
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
    await document.update({
      'message': updateMessage,
    });

    // TODO
    // 最新のメッセージが編集された場合のresentMessage更新
  }

  /// メッセージ削除（未実装）
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

  /// ユーザーページ遷移用の情報取得
  Future<MyFriends> getUserPageInfo(String userId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(this.currentUser.userId)
        .collection('friends')
        .doc(userId)
        .get();
    MyFriends myFriend;
    if (doc.exists) {
      myFriend = MyFriends(doc);
    } else {
      // 友達仮追加
      myFriend = await _provAddFriend(userId);
    }
    final usersDoc = await myFriend.usersRef.get();
    myFriend.usersName = usersDoc['name'];
    myFriend.imageURL = usersDoc['imageURL'];
    myFriend.backgroundImage = usersDoc['backgroundImage'];

    return myFriend;
  }

  /// 友達仮追加
  Future<MyFriends> _provAddFriend(String userId) async {
    // 自分と相手の'/users/(UserId)'を定義
    final usersRef = FirebaseFirestore.instance
        .collection('users')
        .doc(this.currentUser.userId);
    final friendUsersRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

    // chatRoomを新規作成
    final roomRef =
        await FirebaseFirestore.instance.collection('chatRoom').add({
      'groupFlg': false,
      'groupId': '',
    });

    // '/chatRoom/(ルームID)/member/'を定義
    final roomMemberRef = roomRef.collection('member');
    // 自分と相手を追加
    await roomMemberRef.doc(this.currentUser.userId).set({
      'usersRef': usersRef,
    });
    await roomMemberRef.doc(userId).set({
      'usersRef': friendUsersRef,
    });

    // '/users/(ユーザーID)/chatRoomInfo/(ルームID)/'へデータを追加
    String initResentMessage = '';
    final chatRoomInfoRef = usersRef.collection('chatRoomInfo').doc(roomRef.id);
    await chatRoomInfoRef.set({
      'roomRef': roomRef,
      'resentMessage': initResentMessage,
      'updateAt': Timestamp.now(),
      'visible': true,
      'unread': 0
    });
    await friendUsersRef.collection('chatRoomInfo').doc(roomRef.id).set({
      'roomRef': roomRef,
      'resentMessage': initResentMessage,
      'updateAt': Timestamp.now(),
      'visible': false,
      'unread': 0,
    });

    // '/users/(自分のユーザーID)/friend/'に登録相手のユーザー情報を追加(friendFlg=false)
    await usersRef.collection('friends').doc(userId).set({
      'usersRef': friendUsersRef,
      'chatRoomInfoRef': usersRef.collection('chatRoomInfo').doc(roomRef.id),
      'friendFlg': false,
    });

    // '/users/(相手のユーザーID)/friend/'に自分のユーザー情報を追加(friendFlg=false)
    await friendUsersRef
        .collection('friends')
        .doc(this.currentUser.userId)
        .set({
      'usersRef': usersRef,
      'chatRoomInfoRef':
          friendUsersRef.collection('chatRoomInfo').doc(roomRef.id),
      'friendFlg': false,
    });

    final doc = await usersRef.collection('friends').doc(userId).get();
    return MyFriends(doc);
  }
}
