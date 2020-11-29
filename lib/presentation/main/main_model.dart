import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainModel extends ChangeNotifier {
  User user;

  void setUser(User currentUser) {
    user = currentUser;
    notifyListeners();
  }
}
