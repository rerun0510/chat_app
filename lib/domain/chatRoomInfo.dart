import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomInfo {
  ChatRoomInfo(DocumentSnapshot doc) {
    roomId = doc.id;
    resentMessage = doc['resentMessage'];
    updateAt = doc['updateAt'].toDate();
    roomRef = doc['roomRef'];
    unread = true;
  }

  String roomId;
  String resentMessage;
  DateTime updateAt;
  DocumentReference roomRef;
  bool unread;
  String roomName;
  String imageURL;
}
