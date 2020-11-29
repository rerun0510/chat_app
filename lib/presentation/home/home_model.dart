import 'package:chat_app/domain/groups.dart';
import 'package:chat_app/domain/myFriends.dart';
import 'package:chat_app/domain/myGroups.dart';
import 'package:chat_app/domain/users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeModel extends ChangeNotifier {
  List<Groups> groupsList = [];
  List<Users> usersList = [];

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

      for (MyGroups myGroups in myGroupsList) {
        final snapshots = myGroups.groupsRef.snapshots();
        snapshots.listen((snapshot) {
          this.groupsList.add(Groups(snapshot));
          notifyListeners();
        });
      }
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

      for (MyFriends myFriends in myFriendsList) {
        final snapshots = myFriends.usersRef.snapshots();
        snapshots.listen((snapshot) {
          usersList.add(Users(snapshot));
          notifyListeners();
        });
      }
    });
  }
}
