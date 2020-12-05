import 'package:cloud_firestore/cloud_firestore.dart';

class MyGroups {
  MyGroups(DocumentSnapshot doc) {
    groupsId = doc.id;
    groupsRef = doc['groupsRef'];
  }

  String groupsId;
  DocumentReference groupsRef;
  String groupsName;
  String imageURL;
}
