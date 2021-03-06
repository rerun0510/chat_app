import 'package:chat_app/domain/chatRoom.dart';
import 'package:chat_app/domain/chatRoomInfo.dart';
import 'package:chat_app/domain/member.dart';
import 'package:chat_app/domain/users.dart';
import 'package:chat_app/repository/current_user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TalkListModel extends ChangeNotifier {
  TalkListModel() {
    _init();
  }

  Users currentUser;
  List<ChatRoomInfo> chatRoomInfoList = [];
  List<ChatRoom> chatRoomList = [];
  bool isLoading = false;

  Future _init() async {
    this.startLoading();
    try {
      // currentUser取得
      this.currentUser = await fetchCurrentUser();
      await fetchTalkList();
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

  Future fetchTalkList() async {
    final snapshot = FirebaseFirestore.instance
        .collection('users')
        .doc(this.currentUser.userId)
        .collection('chatRoomInfo')
        .where('visible', isEqualTo: true)
        .orderBy('updateAt', descending: true)
        .snapshots();
    snapshot.listen((snapshot) {
      final docs = snapshot.docs;
      final chatRoomInfoList = docs.map((doc) => ChatRoomInfo(doc)).toList();
      this.chatRoomInfoList = chatRoomInfoList;

      for (int i = 0; i < this.chatRoomInfoList.length; i++) {
        final snapshots = chatRoomInfoList[i].roomRef.snapshots();
        snapshots.listen((snapshot) {
          final doc = snapshot.data();
          if (doc['groupFlg']) {
            // グループチャットの場合
            // groupsからgroupNameとimageURLを取得
            final groupInfo = FirebaseFirestore.instance
                .collection('groups')
                .doc(doc['groupId'])
                .snapshots();
            groupInfo.listen((snapshot) {
              final doc = snapshot.data();
              this.chatRoomInfoList[i].roomName = doc['groupName'];
              this.chatRoomInfoList[i].imageURL = doc['imageURL'];
              notifyListeners();
            });
          } else {
            // 個人チャットの場合
            // chatRoom/roomId/memberのusersRefからUsersを参照し、
            // nameとimageURLを取得
            final snapshots = this
                .chatRoomInfoList[i]
                .roomRef
                .collection('member')
                .snapshots();
            snapshots.listen((snapshot) {
              final docs = snapshot.docs;
              final memberList = docs.map((doc) => Member(doc)).toList();
              for (Member member in memberList) {
                if (member.userId != this.currentUser.userId) {
                  final snapshot = member.usersRef.snapshots();
                  snapshot.listen((snapshot) {
                    final doc = snapshot.data();
                    this.chatRoomInfoList[i].roomName = doc['name'];
                    this.chatRoomInfoList[i].imageURL = doc['imageURL'];
                    notifyListeners();
                  });
                }
              }
              notifyListeners();
            });
          }
          notifyListeners();
        });
      }
      notifyListeners();
    });
  }
}
