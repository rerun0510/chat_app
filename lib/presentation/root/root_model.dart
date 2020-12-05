import 'package:chat_app/domain/users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class RootModel extends ChangeNotifier {
  User user;
  Users users;

  RootModel() {
    _init();
  }

  bool isLoading = false;

  Future _init() async {
    // packageの初期化処理
    await Firebase.initializeApp();

    this.startLoading();
    try {
      getUser();
      if (user != null) {
        await fetchUsers();
      }
    } catch (e) {
      print(e);
      throw ('エラーが発生しました');
    } finally {
      endLoading();
      notifyListeners();
    }
  }

  void getUser() {
    user = FirebaseAuth.instance.currentUser;
  }

  Future fetchUsers() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    this.users = Users(doc);
  }

  startLoading() {
    isLoading = true;
    notifyListeners();
  }

  endLoading() {
    isLoading = false;
    notifyListeners();
  }
}
