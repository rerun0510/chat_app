import 'package:chat_app/domain/users.dart';
import 'package:chat_app/repository/current_user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BottomNavigationModel extends ChangeNotifier {
  BottomNavigationModel() {
    _init();
  }

  Users currentUser;
  int _currentIndex = 0;
  int talkNotification = 0;
  int homeNotification = 0;

  Future _init() async {
    try {
      // currentUser取得
      this.currentUser = await fetchCurrentUser();
      fetchNotification();
    } catch (e) {
      print(e);
      throw ('エラーが発生しました');
    } finally {
      notifyListeners();
    }
  }

  get currentIndex => _currentIndex;

  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  /// 通知件数の取得
  void fetchNotification() {
    final snapshots = FirebaseFirestore.instance
        .collection('users')
        .doc(this.currentUser.userId)
        .collection('chatRoomInfo')
        .snapshots();
    snapshots.listen((snapshot) {
      final docs = snapshot.docs;
      final unreadList = docs.map((doc) => doc['unread'].toInt()).toList();
      int unreadCnt = 0;
      for (int unread in unreadList) {
        unreadCnt += unread;
      }
      this.talkNotification = unreadCnt;
      notifyListeners();
    });
  }
}
