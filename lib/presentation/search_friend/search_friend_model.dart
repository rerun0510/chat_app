import 'package:chat_app/domain/users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchFriendModel extends ChangeNotifier {
  Users users;
  String email = '';
  bool clearBtnFlg = false;
  bool isSearchLoading = false;
  bool isAddLoading = false;
  bool searchedFlg = false;
  bool isAlreadyFriend = false;

  startSearchLoading() {
    this.isSearchLoading = true;
    notifyListeners();
  }

  endSearchLoading() {
    this.isSearchLoading = false;
    notifyListeners();
  }

  startAddLoading() {
    this.isAddLoading = true;
    notifyListeners();
  }

  endAddLoading() {
    this.isAddLoading = false;
    notifyListeners();
  }

  void clearEmail() {
    this.email = '';
    clearBtnFlg = false;
    notifyListeners();
  }

  void checkClearBtn() {
    if (this.email.length != 0) {
      this.clearBtnFlg = true;
    } else {
      this.clearBtnFlg = false;
    }
    notifyListeners();
  }

  Future searchFriend(Users users) async {
    this.searchedFlg = true;
    startSearchLoading();
    try {
      // ユーザー情報を取得
      final docs = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: this.email)
          .get();
      // emailは一意のキーとなっている前提
      if (docs.size != 0) {
        this.users = Users(docs.docs[0]);
      } else {
        this.users = null;
      }

      // 既に友達に追加されているかを確認
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(users.userId)
          .collection('friends')
          .doc(this.users.userId)
          .get();
      if (doc.exists) {
        isAlreadyFriend = true;
      } else {
        isAlreadyFriend = false;
      }
    } catch (e) {
      print(e);
      throw ('エラーが発生しました');
    } finally {
      endSearchLoading();
    }
  }

  Future addFriend(Users users) async {
    startAddLoading();
    try {
      final doc =
          FirebaseFirestore.instance.collection('users').doc(this.users.userId);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(users.userId)
          .collection('friends')
          .doc(this.users.userId)
          .set(
        {
          'usersRef': doc,
        },
      );
    } catch (e) {
      print(e);
    } finally {
      endAddLoading();
    }
  }
}
