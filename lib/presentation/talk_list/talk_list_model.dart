import 'package:chat_app/domain/chatRoom.dart';
import 'package:chat_app/domain/chatRoomInfo.dart';
import 'package:chat_app/domain/member.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TalkListModel extends ChangeNotifier {
  List<ChatRoomInfo> chatRoomInfoList = [];
  List<ChatRoom> chatRoomList = [];

  Future fetchTalkList(String userId) async {
    final snapshot = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('chatRoomInfo')
        .orderBy('updateAt', descending: true)
        .snapshots();
    snapshot.listen((snapshot) {
      final docs = snapshot.docs;
      final chatRoomInfoList = docs.map((doc) => ChatRoomInfo(doc)).toList();
      this.chatRoomInfoList = chatRoomInfoList;

      for (int i = 0; i < this.chatRoomInfoList.length; i++) {
        final snapshots = this.chatRoomInfoList[i].roomRef.snapshots();
        snapshots.listen((snapshot) {
          final doc = snapshot.data();
          if (doc['groupFlg']) {
            // グループチャットの場合
            this.chatRoomInfoList[i].roomName = doc['roomName'];
            this.chatRoomInfoList[i].imageURL = doc['imageURL'];
          } else {
            // 個人チャットの場合
            final snapshots = this
                .chatRoomInfoList[i]
                .roomRef
                .collection('member')
                .snapshots();
            snapshots.listen((snapshot) {
              final docs = snapshot.docs;
              final memberList = docs.map((doc) => Member(doc)).toList();
              for (int j = 0; j < memberList.length; j++) {
                if (memberList[j].userId != userId) {
                  final snapshot = memberList[j].usersRef.snapshots();
                  snapshot.listen((snapshot) {
                    final doc = snapshot.data();
                    this.chatRoomInfoList[i].roomName = doc['name'];
                    this.chatRoomInfoList[i].imageURL = doc['imageURL'];
                  });
                }
              }
              notifyListeners();
            });
          }
        });
      }
    });
  }
}
