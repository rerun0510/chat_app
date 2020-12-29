import 'package:chat_app/domain/myFriends.dart';
import 'package:chat_app/domain/users.dart';
import 'package:chat_app/repository/current_user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddFriendModel extends ChangeNotifier {
  AddFriendModel() {
    _init();
  }

  Users currentUser;
  bool isLoading = false;
  List<MyFriends> myFriends = [];

  void _init() async {
    _startLoading();
    try {
      // currentUser取得
      this.currentUser = await fetchCurrentUser();
      await fetchMayBeFriend();
    } catch (e) {
      print(e);
      throw ('エラーが発生しました');
    } finally {
      _endLoading();
    }
  }

  void _startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void _endLoading() {
    isLoading = false;
    notifyListeners();
  }

  // 知り合いかも一覧取得
  Future fetchMayBeFriend() async {
    final docs = await FirebaseFirestore.instance
        .collection('users')
        .doc(this.currentUser.userId)
        .collection('friends')
        .where('friendFlg', isEqualTo: false)
        .get();
    final myFriends = docs.docs.map((doc) => MyFriends(doc)).toList();

    for (int i = 0; i < myFriends.length; i++) {
      final doc = await myFriends[i].usersRef.get();
      myFriends[i].usersName = doc['name'];
      myFriends[i].imageURL = doc['imageURL'];
      myFriends[i].backgroundImage = doc['backgroundImage'];
    }

    this.myFriends = myFriends;

    notifyListeners();
  }

  /// 友達追加
  Future addFriend(MyFriends myFriend) async {
    // フレンドフラグの更新
    await FirebaseFirestore.instance
        .collection('users')
        .doc(this.currentUser.userId)
        .collection('friends')
        .doc(myFriend.usersId)
        .update(
      {
        'friendFlg': true,
      },
    );

    // トーク一覧に表示
    await myFriend.chatRoomInfoRef.update(
      {
        'visible': true,
      },
    );

    // 知り合いかも一覧再表示
    await fetchMayBeFriend();
  }
}
