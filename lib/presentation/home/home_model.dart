import 'package:chat_app/domain/myFriends.dart';
import 'package:chat_app/domain/myGroups.dart';
import 'package:chat_app/domain/users.dart';
import 'package:chat_app/repository/current_user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeModel extends ChangeNotifier {
  HomeModel() {
    _init();
  }

  Users currentUser;
  List<MyGroups> myGroupsList = [];
  List<MyFriends> myFriendsList = [];
  bool isLoading = false;

  Future _init() async {
    this.startLoading();
    try {
      // currentUser取得
      this.currentUser = await fetchCurrentUser();
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(this.currentUser.userId)
          .get();
      this.currentUser = Users(doc);

      await fetchHomeInfo();
    } catch (e) {
      print(e);
      throw ('エラーが発生しました');
    } finally {
      endLoading();
      notifyListeners();
    }
  }

  startLoading() {
    isLoading = true;
    notifyListeners();
  }

  endLoading() {
    isLoading = false;
    notifyListeners();
  }

  Future fetchHomeInfo() async {
    // グループリスト取得
    fetchGroups();
    // 友達リスト取得
    fetchFriends();
  }

  /// グループリスト取得
  void fetchGroups() {
    final groups = FirebaseFirestore.instance
        .collection('users')
        .doc(this.currentUser.userId)
        .collection('groups')
        .snapshots();
    groups.listen((snapshot) {
      final docs = snapshot.docs;
      final myGroupsList = docs.map((doc) => MyGroups(doc)).toList();
      this.myGroupsList = myGroupsList;

      for (int i = 0; i < this.myGroupsList.length; i++) {
        final snapshots = this.myGroupsList[i].groupsRef.snapshots();
        snapshots.listen((snapshot) {
          final doc = snapshot.data();
          this.myGroupsList[i].groupsName = doc['groupName'];
          this.myGroupsList[i].imageURL = doc['imageURL'];
          notifyListeners();
        });
      }
      notifyListeners();
    });
  }

  /// 友達リスト取得
  void fetchFriends() {
    final friends = FirebaseFirestore.instance
        .collection('users')
        .doc(this.currentUser.userId)
        .collection('friends')
        .where('friendFlg', isEqualTo: true)
        .snapshots();
    friends.listen((snapshot) {
      final docs = snapshot.docs;
      final myFriendsList = docs.map((doc) => MyFriends(doc)).toList();
      this.myFriendsList = myFriendsList;

      for (int i = 0; i < this.myFriendsList.length; i++) {
        final snapshots = this.myFriendsList[i].usersRef.snapshots();
        snapshots.listen((snapshot) {
          final doc = snapshot.data();
          this.myFriendsList[i].usersName = doc['name'];
          this.myFriendsList[i].imageURL = doc['imageURL'];
          notifyListeners();
        });
      }
      notifyListeners();
    });
  }
}
