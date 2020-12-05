import 'package:chat_app/domain/myFriends.dart';
import 'package:chat_app/domain/myGroups.dart';
import 'package:chat_app/domain/users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeModel extends ChangeNotifier {
  List<MyGroups> myGroupsList = [];
  List<MyFriends> myFriendsList = [];

  bool isLoading = false;

  HomeModel(Users users) {
    _init(users);
  }

  Future _init(Users users) async {
    this.startLoading();
    try {
      await fetchHomeInfo(users);
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

  Future fetchHomeInfo(Users users) async {
    // グループリスト取得
    final groups = FirebaseFirestore.instance
        .collection('users')
        .doc(users.userId)
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

    // 友達リスト取得
    final friends = FirebaseFirestore.instance
        .collection('users')
        .doc(users.userId)
        .collection('friends')
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
