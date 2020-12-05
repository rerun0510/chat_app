import 'package:cloud_firestore/cloud_firestore.dart';

class MyFriends {
  MyFriends(DocumentSnapshot doc) {
    usersId = doc.id;
    usersRef = doc['usersRef'];
  }

  String usersId;
  DocumentReference usersRef;
  String usersName;
  String imageURL;
}
