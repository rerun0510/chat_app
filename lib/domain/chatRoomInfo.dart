import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomInfo {
  ChatRoomInfo(DocumentSnapshot doc) {
    roomId = doc.id;
    resentMessage = doc['resentMessage'];
    updateAt = doc['updateAt'].toDate();
    roomRef = doc['roomRef'];
    unread = doc['unread'];
    visible = doc['visible'];
  }

  String roomId;
  String resentMessage;
  DateTime updateAt;
  DocumentReference roomRef;
  num unread;
  bool visible;
  String roomName;
  String imageURL;
}
