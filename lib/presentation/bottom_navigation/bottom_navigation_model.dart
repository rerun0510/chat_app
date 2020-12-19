import 'package:chat_app/domain/users.dart';
import 'package:chat_app/repository/current_user_repository.dart';
import 'package:flutter/material.dart';

class BottomNavigationModel extends ChangeNotifier {
  BottomNavigationModel() {
    _init();
  }
  Users currentUser;

  Future _init() async {
    this.currentUser = await fetchCurrentUser();
    notifyListeners();
  }

  int _currentIndex = 0;

  get currentIndex => _currentIndex;

  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
