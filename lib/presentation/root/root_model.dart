import 'package:chat_app/domain/users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RootModel extends ChangeNotifier {
  User user;
  Users users;

  Future getUser() async {
    user = FirebaseAuth.instance.currentUser;
    // notifyListeners();
  }

  Future fetchUsers() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    this.users = Users(doc);
    // notifyListeners();
  }
}
