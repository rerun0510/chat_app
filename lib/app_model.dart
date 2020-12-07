import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppModel extends ChangeNotifier {
  User user;

  void setUser(User currentUser) {
    user = currentUser;
    notifyListeners();
  }
}
