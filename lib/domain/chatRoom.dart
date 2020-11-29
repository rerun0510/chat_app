import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  ChatRoom(DocumentSnapshot doc) {
    this.roomId = doc.id;
    roomName = doc['roomName'];
    groupFlg = doc['groupFlg'];
    imageURL = doc['imageURL'];
    member = doc['member'];
    messages = doc['messages'];
  }

  String roomId;
  String roomName;
  bool groupFlg;
  String imageURL;
  DocumentReference member;
  DocumentReference messages;
}
