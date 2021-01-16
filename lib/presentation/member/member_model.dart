import 'package:chat_app/domain/myFriends.dart';
import 'package:chat_app/domain/users.dart';
import 'package:chat_app/repository/current_user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class MemberModel extends ChangeNotifier {
  MemberModel(String groupsId) {
    _init(groupsId);
  }
  bool isLoading = false;
  List<Users> members = [];
  List<Users> inviteMembers = [];
  Users currentUser;

  startLoading() {
    isLoading = true;
    notifyListeners();
  }

  endLoading() {
    isLoading = false;
    notifyListeners();
  }

  Future _init(String groupsId) async {
    this.startLoading();
    try {
      // currentUser取得
      this.currentUser = await fetchCurrentUser();
      await fetchMembers(groupsId);
      await fetchInviteMembers(groupsId);
    } catch (e) {
      print(e);
      throw ('エラーが発生しました');
    } finally {
      endLoading();
      notifyListeners();
    }
  }

  /// メンバー取得
  Future fetchMembers(String groupsId) async {
    final currentUserRef = FirebaseFirestore.instance
        .collection('users')
        .doc(this.currentUser.userId);
    final docs = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupsId)
        .collection('member')
        .where('memberFlg', isEqualTo: true)
        .where('usersRef', isNotEqualTo: currentUserRef)
        .get();
    final usersRefList = docs.docs.map((doc) => doc['usersRef']).toList();

    // 先頭にCurrentUserを追加
    this.members.add(this.currentUser);

    for (DocumentReference usersRef in usersRefList) {
      final DocumentSnapshot doc = await usersRef.get();
      this.members.add(Users(doc));
    }
  }

  /// メンバー取得
  Future fetchInviteMembers(String groupsId) async {
    final currentUserRef = FirebaseFirestore.instance
        .collection('users')
        .doc(this.currentUser.userId);
    final docs = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupsId)
        .collection('member')
        .where('memberFlg', isEqualTo: false)
        .where('usersRef', isNotEqualTo: currentUserRef)
        .get();
    final usersRefList = docs.docs.map((doc) => doc['usersRef']).toList();

    for (DocumentReference usersRef in usersRefList) {
      final DocumentSnapshot doc = await usersRef.get();
      this.inviteMembers.add(Users(doc));
    }
  }

  /// 友達情報取得
  Future<MyFriends> fetchFriend(String userId) async {
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
      'unread': 0,
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
