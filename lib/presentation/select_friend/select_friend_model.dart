import 'package:chat_app/domain/users.dart';
import 'package:chat_app/repository/current_user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SelectFriendModel extends ChangeNotifier {
  SelectFriendModel() {
    _init();
  }

  List<Map> myFriends = [];
  List<Map> selectedMyFriends = [];
  bool isLoading = false;
  Users currentUser;

  startLoading() {
    isLoading = true;
    notifyListeners();
  }

  endLoading() {
    isLoading = false;
    notifyListeners();
  }

  Future _init() async {
    this.startLoading();
    try {
      // currentUser取得
      this.currentUser = await fetchCurrentUser();

      await fetchFriends();
    } catch (e) {
      print(e);
      throw ('エラーが発生しました');
    } finally {
      endLoading();
      notifyListeners();
    }
  }

  Future fetchFriends() async {
    final friends = await FirebaseFirestore.instance
        .collection('users')
        .doc(this.currentUser.userId)
        .collection('friends')
        .where('friendFlg', isEqualTo: true)
        .get();

    final myFriends = friends.docs
        .map((doc) => {
              'userId': doc.id,
              'usersRef': doc['usersRef'],
              'chatRoomInfoRef': doc['chatRoomInfoRef'],
              'friendFlg': doc['friendFlg'],
              'check': false,
            })
        .toList();
    this.myFriends = myFriends;

    for (int i = 0; i < this.myFriends.length; i++) {
      final doc = await this.myFriends[i]['usersRef'].get();
      this.myFriends[i]['usersName'] = doc['name'];
      this.myFriends[i]['imageURL'] = doc['imageURL'];
    }
  }

  void check(bool value, int index) {
    this.myFriends[index]['check'] = value;
    if (value) {
      // 追加（チェックON）
      this.selectedMyFriends.add((this.myFriends[index]));
    } else {
      // 削除（チェックOFF）
      final userId = this.myFriends[index]['userId'];
      for (int i = 0; i < this.selectedMyFriends.length; i++) {
        if (userId == this.selectedMyFriends[i]['userId']) {
          this.selectedMyFriends.removeAt(i);
          break;
        }
      }
    }
    notifyListeners();
  }

  void removeMember(String userId) {
    for (int i = 0; i < this.selectedMyFriends.length; i++) {
      if (userId == this.selectedMyFriends[i]['userId']) {
        this.selectedMyFriends.removeAt(i);
        break;
      }
    }
    for (int i = 0; i < this.myFriends.length; i++) {
      if (userId == this.myFriends[i]['userId']) {
        this.myFriends[i]['check'] = false;
        break;
      }
    }
    notifyListeners();
  }
}
