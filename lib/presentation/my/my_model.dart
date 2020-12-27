import 'dart:io';

import 'package:chat_app/domain/users.dart';
import 'package:chat_app/repository/current_user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class MyModel extends ChangeNotifier {
  MyModel() {
    _init();
  }

  Users currentUser;
  bool isLoading = false;
  File iconFile;
  File backgroundFile;

  _init() async {
    this.startLoading();
    try {
      // currentUser取得
      this.currentUser = await fetchCurrentUser();
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

  Future showImagePickerIcon() async {
    final picker = ImagePicker();
    final pickerFile = await picker.getImage(source: ImageSource.gallery);
    this.iconFile = File(pickerFile.path);
    final imageURL = await _uploadImageIcon();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(this.currentUser.userId)
        .update(
      {
        'imageURL': imageURL,
      },
    );

    // currentUser取得
    this.currentUser = await fetchCurrentUser();
    notifyListeners();
  }

  Future showImagePickerBackground() async {
    startLoading();
    final picker = ImagePicker();
    final pickerFile = await picker.getImage(source: ImageSource.gallery);
    this.backgroundFile = File(pickerFile.path);
    final backgroundImage = await _uploadImageBackground();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(this.currentUser.userId)
        .update(
      {
        'backgroundImage': backgroundImage,
      },
    );
    // currentUser取得
    this.currentUser = await fetchCurrentUser();
    endLoading();
    notifyListeners();
  }

  Future<String> _uploadImageIcon() async {
    String uid = this.currentUser.userId;
    final storage = FirebaseStorage.instance;
    TaskSnapshot snapshot = await storage
        .ref()
        .child("users/$uid/ProfileIcon")
        .putFile(this.iconFile);
    final String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> _uploadImageBackground() async {
    String uid = this.currentUser.userId;
    final storage = FirebaseStorage.instance;
    TaskSnapshot snapshot = await storage
        .ref()
        .child("users/$uid/BackgroundImage")
        .putFile(this.backgroundFile);
    final String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  /// プロフィール再表示
  Future reload() async {
    try {
      // currentUser取得
      this.currentUser = await fetchCurrentUser();
    } catch (e) {
      print(e);
      throw ('エラーが発生しました');
    } finally {
      endLoading();
      notifyListeners();
    }
  }
}
