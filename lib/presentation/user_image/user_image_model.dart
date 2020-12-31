import 'dart:io';

import 'package:chat_app/domain/users.dart';
import 'package:chat_app/repository/current_user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class UserImageModel extends ChangeNotifier {
  UserImageModel(String id, bool isMe, bool isGroup, bool isIcon) {
    _init(id, isMe, isGroup, isIcon);
  }

  Users currentUser;
  bool isLoading = false;
  String url;
  File file;

  startLoading() {
    isLoading = true;
    notifyListeners();
  }

  endLoading() {
    isLoading = false;
    notifyListeners();
  }

  _init(String id, bool isMe, bool isGroup, bool isIcon) async {
    this.startLoading();
    try {
      // currentUser取得
      this.currentUser = await fetchCurrentUser();
      if (isMe) {
        // CurrentUserの情報を設定
        this.url = isIcon
            ? this.currentUser.imageURL
            : this.currentUser.backgroundImage;
      } else if (isGroup) {
        // groupsIdで情報を取得
        await _fetchGroupInfo(id, isIcon);
      } else {
        // usersIdで情報を取得
        await _fetchFriendInfo(id, isIcon);
      }
    } catch (e) {
      print(e);
      throw ('エラーが発生しました');
    } finally {
      endLoading();
      notifyListeners();
    }
  }

  /// グループ情報を取得
  Future _fetchGroupInfo(String id, bool isIcon) async {
    final doc =
        await FirebaseFirestore.instance.collection('groups').doc(id).get();
    this.url = isIcon ? doc['imageURL'] : doc['backgroundImage'];
  }

  /// ユーザー情報を取得
  Future _fetchFriendInfo(String id, bool isIcon) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(id).get();
    this.url = isIcon ? doc['imageURL'] : doc['backgroundImage'];
  }

  Future showImagePickerIcon() async {
    startLoading();
    final picker = ImagePicker();
    final pickerFile = await picker.getImage(source: ImageSource.gallery);
    this.file = File(pickerFile.path);
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
    this.url = this.currentUser.imageURL;
    endLoading();
    notifyListeners();
  }

  Future showImagePickerBackground() async {
    startLoading();
    final picker = ImagePicker();
    final pickerFile = await picker.getImage(source: ImageSource.gallery);
    this.file = File(pickerFile.path);
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
    this.url = this.currentUser.backgroundImage;
    endLoading();
    notifyListeners();
  }

  Future<String> _uploadImageIcon() async {
    String uid = this.currentUser.userId;
    final storage = FirebaseStorage.instance;
    TaskSnapshot snapshot =
        await storage.ref().child("users/$uid/ProfileIcon").putFile(this.file);
    final String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> _uploadImageBackground() async {
    String uid = this.currentUser.userId;
    final storage = FirebaseStorage.instance;
    TaskSnapshot snapshot = await storage
        .ref()
        .child("users/$uid/BackgroundImage")
        .putFile(this.file);
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
