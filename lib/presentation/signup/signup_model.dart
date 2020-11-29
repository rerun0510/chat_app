import 'dart:io';

import 'package:chat_app/domain/users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SignUpModel extends ChangeNotifier {
  String name;
  File imageFile;
  bool isLoading = false;
  Users users;

  startLoading() {
    isLoading = true;
    notifyListeners();
  }

  endLoading() {
    isLoading = false;
    notifyListeners();
  }

  Future showImagePicker() async {
    final picker = ImagePicker();
    final pickerFile = await picker.getImage(source: ImageSource.gallery);
    imageFile = File(pickerFile.path);
    notifyListeners();
  }

  Future signUp(User currentUser) async {
    if (name.isEmpty) {
      throw ('名前を入力してください。');
    }
    final imageURL = await _uploadImage(currentUser);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .set(
      {
        'name': name,
        'imageURL': imageURL,
        'email': currentUser.email,
      },
    );

    // FirestoreからUsersを取得
    final docs = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    this.users = Users(docs);
  }

  Future<String> _uploadImage(User currentUser) async {
    String uid = currentUser.uid;
    final storage = FirebaseStorage.instance;
    TaskSnapshot snapshot =
        await storage.ref().child("users/$uid/ProfileIcon").putFile(imageFile);
    final String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}
