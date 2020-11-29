import 'package:cloud_firestore/cloud_firestore.dart';

class Member {
  Member(DocumentSnapshot doc) {
    userId = doc.id;
    usersRef = doc['usersRef'];
  }

  String userId;
  DocumentReference usersRef;
}
