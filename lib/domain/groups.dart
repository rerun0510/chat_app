import 'package:cloud_firestore/cloud_firestore.dart';

class Groups {
  Groups(DocumentSnapshot doc) {
    groupsId = doc.id;
    groupName = doc['groupName'];
    imageURL = doc['imageURL'];
    backgroundImage = doc['backgroundImage'];
  }

  String groupsId;
  String groupName;
  String imageURL;
  String backgroundImage;
}
