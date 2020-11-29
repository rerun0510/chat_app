import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  Users(DocumentSnapshot doc) {
    userId = doc.id;
    name = doc['name'];
    imageURL = doc['imageURL'];
  }

  String userId;
  String name;
  String imageURL;
}
