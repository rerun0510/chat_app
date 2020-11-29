import 'package:cloud_firestore/cloud_firestore.dart';

class Messages {
  Messages(DocumentSnapshot doc) {
    userId = doc['userId'];
    messageId = doc.id;
    message = doc['message'];
    messageType = doc['messageType'];
    createdAt = doc['createdAt'].toDate();
  }

  String userId;
  String messageId;
  String message;
  String messageType;
  DateTime createdAt;
}
