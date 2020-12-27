import 'package:chat_app/domain/users.dart';
import 'package:chat_app/repository/current_user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyNameEditModel extends ChangeNotifier {
  MyNameEditModel() {
    _init();
  }

  Users currentUser;
  bool isLoading = false;
  bool isUpdateFlg = true;
  String name;

  _init() async {
    this.startLoading();
    try {
      // currentUser取得
      this.currentUser = await fetchCurrentUser();
      this.name = this.currentUser.name;
    } catch (e) {
      print(e);
      throw ('エラーが発生しました');
    } finally {
      endLoading();
      notifyListeners();
    }
  }

  startLoading() {
    this.isLoading = true;
    notifyListeners();
  }

  endLoading() {
    this.isLoading = false;
    notifyListeners();
  }

  void checkUpdateBtn() {
    if (this.name.length != 0) {
      this.isUpdateFlg = true;
    } else {
      this.isUpdateFlg = false;
    }
    notifyListeners();
  }

  /// ユーザー名更新
  Future updateName() async {
    this.startLoading();
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(this.currentUser.userId)
          .update(
        {
          'name': this.name,
        },
      );
    } catch (e) {
      print(e);
      throw ('エラーが発生しました');
    } finally {
      endLoading();
      notifyListeners();
    }
  }
}
