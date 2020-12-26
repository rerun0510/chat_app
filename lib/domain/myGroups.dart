import 'package:cloud_firestore/cloud_firestore.dart';

class MyGroups {
  MyGroups(DocumentSnapshot doc) {
    groupsId = doc.id;
    groupsRef = doc['groupsRef'];
    chatRoomInfoRef = doc['chatRoomInfoRef'];
    memberFlg = doc['memberFlg'];
  }

  String groupsId;
  DocumentReference groupsRef;
  DocumentReference chatRoomInfoRef;
  bool memberFlg;
  String groupsName;
  String imageURL;
  String backgroundImage;
}
