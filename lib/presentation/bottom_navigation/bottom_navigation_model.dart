import 'package:flutter/material.dart';

class BottomNavigationModel extends ChangeNotifier {
  Future init() async {
    notifyListeners();
  }

  int _currentIndex = 0;

  get currentIndex => _currentIndex;

  set currentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
