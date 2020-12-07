import 'package:cloud_firestore/cloud_firestore.dart';

class MyGroups {
  MyGroups(DocumentSnapshot doc) {
    groupsId = doc.id;
    groupsRef = doc['groupsRef'];
    chatRoomInfoRef = doc['chatRoomInfoRef'];
  }

  String groupsId;
  DocumentReference groupsRef;
  DocumentReference chatRoomInfoRef;
  String groupsName;
  String imageURL;
}
