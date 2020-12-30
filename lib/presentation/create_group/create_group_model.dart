import 'dart:io';

import 'package:chat_app/domain/myGroups.dart';
import 'package:chat_app/domain/users.dart';
import 'package:chat_app/repository/current_user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class CreateGroupModel extends ChangeNotifier {
  CreateGroupModel(List<Map> selectedMyFriends) {
    _init(selectedMyFriends);
  }

  Users currentUser;
  List<Map> selectedMyFriends = [];
  bool isLoading = false;
  bool clearBtnFlg = false;
  String groupName = '';
  File imageFile;
  File backgroundImage;
  MyGroups myGroups;

  _init(List<Map> selectedMyFriends) async {
    this.startLoading();
    try {
      // デフォルトアイコンの設定
      this.imageFile =
          await getImageFileFromAssets('resources/group_young_world.png');
      // 背景初期設定
      this.backgroundImage =
          await getImageFileFromAssets('resources/mountain_00001.jpg');

      // currentUser取得
      this.currentUser = await fetchCurrentUser();
      final ref = FirebaseFirestore.instance
          .collection('users')
          .doc(this.currentUser.userId);

      // 選択したフレンドリストの先頭に自分を追加
      this.selectedMyFriends = selectedMyFriends.reversed.toList();
      this.selectedMyFriends.add({
        'userId': this.currentUser.userId,
        'usersName': this.currentUser.name,
        'imageURL': this.currentUser.imageURL,
        'usersRef': ref,
        'check': true,
      });
      this.selectedMyFriends = this.selectedMyFriends.reversed.toList();
    } catch (e) {
      print(e);
      throw ('エラーが発生しました');
    } finally {
      endLoading();
      notifyListeners();
    }
  }

  startLoading() {
    isLoading = true;
    notifyListeners();
  }

  endLoading() {
    isLoading = false;
    notifyListeners();
  }

  void checkClearBtn() {
    if (this.groupName.length != 0) {
      this.clearBtnFlg = true;
    } else {
      this.clearBtnFlg = false;
    }
    notifyListeners();
  }

  void clearGroupName() {
    this.groupName = '';
    clearBtnFlg = false;
    notifyListeners();
  }

  /// 端末のテンポラリに画像を保存
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

  /// ImagePicker
  Future showImagePicker() async {
    final picker = ImagePicker();
    final pickerFile = await picker.getImage(source: ImageSource.gallery);
    imageFile = File(pickerFile.path);
    notifyListeners();
  }

  /// FirebaseStorageへのアップロード
  /// imageURLを返却
  Future<String> _uploadImage(String groupId) async {
    final storage = FirebaseStorage.instance;
    TaskSnapshot snapshot = await storage
        .ref()
        .child("groups/$groupId/ProfileIcon")
        .putFile(imageFile);
    final String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> _uploadBackgroundImage(String groupId) async {
    final storage = FirebaseStorage.instance;
    TaskSnapshot snapshot = await storage
        .ref()
        .child("groups/$groupId/BackgroundImage")
        .putFile(this.backgroundImage);
    final String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  /// グループを作成する
  Future createGroup() async {
    this.startLoading();
    try {
      // groups生成
      final groupsRef =
          await FirebaseFirestore.instance.collection('groups').add({
        'groupName': this.groupName,
        'memberCnt': this.selectedMyFriends.length,
      });

      // imageURLを追加
      await groupsRef.update({
        'imageURL': await _uploadImage(groupsRef.id),
        'backgroundImage': await _uploadBackgroundImage(groupsRef.id),
      });

      // groups/member 追加
      for (Map selected in this.selectedMyFriends) {
        await groupsRef.collection('member').doc(selected['userId']).set({
          'usersRef': selected['usersRef'],
        });
      }

      // '/chatRoom/(ルームID)'を新規作成
      final roomRef =
          await FirebaseFirestore.instance.collection('chatRoom').add({
        'groupFlg': true,
        'groupId': groupsRef.id,
      });

      // '/chatRoom/(ルームID)/member/'を定義
      final roomMemberRef = roomRef.collection('member');
      // メンバーを追加
      for (Map selected in this.selectedMyFriends) {
        await roomMemberRef.doc(selected['userId']).set({
          'usersRef': selected['usersRef'],
        });
      }

      // '/users/(ユーザーID)/chatRoomInfo/(ルームID)/'へデータを追加
      String initResentMessage = '';
      for (Map selected in this.selectedMyFriends) {
        final chatRoomInfoRef =
            selected['usersRef'].collection('chatRoomInfo').doc(roomRef.id);
        await chatRoomInfoRef.set({
          'roomRef': roomRef,
          'resentMessage': initResentMessage,
          'updateAt': Timestamp.now(),
          'visible': true,
        });
      }

      // '/users/(ユーザーID)/groups/'にグループ情報を追加
      for (Map selected in this.selectedMyFriends) {
        bool memberFlg = false;
        // 自分自身の場合は、memberFlg: true
        if (selected['userId'] == this.currentUser.userId) {
          memberFlg = true;
        }
        final DocumentReference myGroupsRef =
            selected['usersRef'].collection('groups').doc(groupsRef.id);
        await myGroupsRef.set(
          {
            'groupsRef': groupsRef,
            'chatRoomInfoRef':
                selected['usersRef'].collection('chatRoomInfo').doc(roomRef.id),
            'memberFlg': memberFlg,
          },
        );
        // ユーザー画面遷移用のmyGroupsを設定
        if (memberFlg) {
          final myGroupsDoc = await myGroupsRef.get();
          this.myGroups = MyGroups(myGroupsDoc);
          final groupsDoc = await this.myGroups.groupsRef.get();
          this.myGroups.groupsName = groupsDoc['groupName'];
          this.myGroups.imageURL = groupsDoc['imageURL'];
          this.myGroups.backgroundImage = groupsDoc['backgroundImage'];
        }
      }
    } catch (e) {
      print(e);
      throw ('エラーが発生しました');
    } finally {
      endLoading();
      notifyListeners();
    }
  }
}
