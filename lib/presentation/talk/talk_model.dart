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
  Users currentUser;

  Future _init(ChatRoomInfo chatRoomInfo) async {
    // currentUser取得
    this.currentUser = await fetchCurrentUser();
    fetchMessages(chatRoomInfo);
  }

  /// メッセージ取得
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
    this.message = text;
    notifyListeners();
  }

  void setUpdateFlg(bool updateFlg) {
    this.updateFlg = updateFlg;
    notifyListeners();
  }

  /// メッセージ送信
  Future sendMessage(String roomId, String userId) async {
    if (this.message.isEmpty) {
      throw ('メッセージを入力してください。');
    }

    // 先にメッセージボックスの初期化を反映
    notifyListeners();

    final createdAt = Timestamp.now();

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
    await document.update(
      {
        'message': updateMessage,
      },
    );

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
    final roomRef = await FirebaseFirestore.instance.collection('chatRoom').add(
      {
        'groupFlg': false,
        'groupId': '',
      },
    );

    // '/chatRoom/(ルームID)/member/'を定義
    final roomMemberRef = roomRef.collection('member');
    // 自分と相手を追加
    await roomMemberRef.doc(this.currentUser.userId).set(
      {
        'usersRef': usersRef,
      },
    );
    await roomMemberRef.doc(userId).set(
      {
        'usersRef': friendUsersRef,
      },
    );

    // '/users/(ユーザーID)/chatRoomInfo/(ルームID)/'へデータを追加
    String initResentMessage = '';
    final chatRoomInfoRef = usersRef.collection('chatRoomInfo').doc(roomRef.id);
    await chatRoomInfoRef.set(
      {
        'roomRef': roomRef,
        'resentMessage': initResentMessage,
        'updateAt': Timestamp.now(),
        'visible': true,
      },
    );
    await friendUsersRef.collection('chatRoomInfo').doc(roomRef.id).set(
      {
        'roomRef': roomRef,
        'resentMessage': initResentMessage,
        'updateAt': Timestamp.now(),
        'visible': false,
      },
    );

    // '/users/(自分のユーザーID)/friend/'に登録相手のユーザー情報を追加(friendFlg=false)
    await usersRef.collection('friends').doc(userId).set(
      {
        'usersRef': friendUsersRef,
        'chatRoomInfoRef': usersRef.collection('chatRoomInfo').doc(roomRef.id),
        'friendFlg': false,
      },
    );

    // '/users/(相手のユーザーID)/friend/'に自分のユーザー情報を追加(friendFlg=false)
    await friendUsersRef.collection('friends').doc(this.currentUser.userId).set(
      {
        'usersRef': usersRef,
        'chatRoomInfoRef':
            friendUsersRef.collection('chatRoomInfo').doc(roomRef.id),
        'friendFlg': false,
      },
    );

    final doc = await usersRef.collection('friends').doc(userId).get();
    return MyFriends(doc);
  }
}
