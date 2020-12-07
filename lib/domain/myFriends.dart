import 'package:cloud_firestore/cloud_firestore.dart';

class MyFriends {
  MyFriends(DocumentSnapshot doc) {
    usersId = doc.id;
    usersRef = doc['usersRef'];
    chatRoomInfoRef = doc['chatRoomInfoRef'];
  }

  String usersId;
  DocumentReference usersRef;
  DocumentReference chatRoomInfoRef;
  String usersName;
  String imageURL;
}
