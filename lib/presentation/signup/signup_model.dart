import 'dart:io';
import 'dart:math' as math;

import 'package:chat_app/domain/users.dart';
import 'package:chat_app/repository/current_user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class SignUpModel extends ChangeNotifier {
  SignUpModel() {
    _init();
  }

  Future _init() async {
    try {
      // アイコン初期設定
      final random = math.Random().nextInt(2);
      if (random == 0) {
        this.imageFile =
            await getImageFileFromAssets('resources/pose_pien_uruuru_man.png');
      } else {
        this.imageFile = await getImageFileFromAssets(
            'resources/pose_pien_uruuru_woman.png');
      }
      // 背景初期設定
      this.backgroundImage =
          await getImageFileFromAssets('resources/mountain_00001.jpg');
    } catch (e) {
      print(e);
      throw ('エラーが発生しました');
    } finally {
      notifyListeners();
    }
  }

  String name;
  File imageFile;
  File backgroundImage;
  bool isLoading = false;
  Users currentUser;

  bool isSignUpFlg = false;

  startLoading() {
    isLoading = true;
    notifyListeners();
  }

  endLoading() {
    isLoading = false;
    notifyListeners();
  }

  void checkSignUpBtn() {
    if (this.name.length != 0) {
      this.isSignUpFlg = true;
    } else {
      this.isSignUpFlg = false;
    }
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
    final backgroundImage = await _uploadBackgroundImage(currentUser);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .set(
      {
        'name': name,
        'imageURL': imageURL,
        'backgroundImage': backgroundImage,
        'email': currentUser.email,
      },
    );

    // currentUser取得
    this.currentUser = await fetchCurrentUser();
  }

  Future<String> _uploadImage(User currentUser) async {
    String uid = currentUser.uid;
    final storage = FirebaseStorage.instance;
    TaskSnapshot snapshot = await storage
        .ref()
        .child("users/$uid/ProfileIcon")
        .putFile(this.imageFile);
    final String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> _uploadBackgroundImage(User currentUser) async {
    String uid = currentUser.uid;
    final storage = FirebaseStorage.instance;
    TaskSnapshot snapshot = await storage
        .ref()
        .child("users/$uid/BackgroundImage")
        .putFile(this.backgroundImage);
    final String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load(path);
    final tmp = await getTemporaryDirectory();
    final tmpPath = tmp.path;
    Directory('$tmpPath/resources').create();
    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }
}
