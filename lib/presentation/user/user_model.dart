import 'package:chat_app/domain/chatRoomInfo.dart';
import 'package:chat_app/domain/member.dart';
import 'package:chat_app/domain/myFriends.dart';
import 'package:chat_app/domain/myGroups.dart';
import 'package:chat_app/domain/users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserModel extends ChangeNotifier {
  bool isLoading = false;
  String name = '';
  String imageURL = '';
  bool isMe = false;

  ChatRoomInfo chatRoomInfo;

  UserModel(Users users, MyGroups myGroups, MyFriends myFriends) {
    _init(users, myGroups, myFriends);
  }

  Future _init(Users users, MyGroups myGroups, MyFriends myFriends) async {
    startLoading();
    if (myGroups != null) {
      this.name = myGroups.groupsName;
      this.imageURL = myGroups.imageURL;
      fetchChatRoomInfo(myGroups.chatRoomInfoRef, users);
    } else if (myFriends != null) {
      this.name = myFriends.usersName;
      this.imageURL = myFriends.imageURL;
      fetchChatRoomInfo(myFriends.chatRoomInfoRef, users);
    } else {
      this.name = users.name;
      this.imageURL = users.imageURL;
      this.isMe = true;
    }
    endLoading();
  }

  void startLoading() {
    isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    isLoading = false;
    notifyListeners();
  }

  Future fetchChatRoomInfo(
      DocumentReference chatRoomInfoRef, Users users) async {
    final doc = await chatRoomInfoRef.get();
    this.chatRoomInfo = ChatRoomInfo(doc);

    final snapshots = this.chatRoomInfo.roomRef.snapshots();
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
          this.chatRoomInfo.roomName = doc['groupName'];
          this.chatRoomInfo.imageURL = doc['imageURL'];
        });
      } else {
        // 個人チャットの場合
        // chatRoom/roomId/memberのusersRefからUsersを参照し、
        // nameとimageURLを取得
        final snapshots =
            this.chatRoomInfo.roomRef.collection('member').snapshots();
        snapshots.listen((snapshot) {
          final docs = snapshot.docs;
          final memberList = docs.map((doc) => Member(doc)).toList();
          for (Member member in memberList) {
            if (member.userId != users.userId) {
              final snapshot = member.usersRef.snapshots();
              snapshot.listen((snapshot) {
                final doc = snapshot.data();
                this.chatRoomInfo.roomName = doc['name'];
                this.chatRoomInfo.imageURL = doc['imageURL'];
              });
            }
          }
        });
      }
    });
  }
}
