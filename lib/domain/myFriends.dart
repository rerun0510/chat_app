import 'package:cloud_firestore/cloud_firestore.dart';

class MyFriends {
  MyFriends(DocumentSnapshot doc) {
    usersId = doc.id;
    usersRef = doc['usersRef'];
    chatRoomInfoRef = doc['chatRoomInfoRef'];
    friendFlg = doc['friendFlg'];
  }

  String usersId;
  DocumentReference usersRef;
  DocumentReference chatRoomInfoRef;
  bool friendFlg;
  String usersName;
  String imageURL;
}
