import 'package:chat_app/domain/users.dart';
import 'package:chat_app/repository/current_user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RootModel extends ChangeNotifier {
  RootModel() {
    _init();
  }

  User user;
  Users currentUser;

  bool isLoading = false;

  Future _init() async {
    this.startLoading();
    try {
      getUser();
      if (user != null) {
        // currentUser取得
        this.currentUser = await fetchCurrentUser();
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

  startLoading() {
    isLoading = true;
    notifyListeners();
  }

  endLoading() {
    isLoading = false;
    notifyListeners();
  }
}
