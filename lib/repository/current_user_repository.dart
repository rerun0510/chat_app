import 'package:chat_app/domain/users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future fetchCurrentUser() async {
  try {
    // 自分のユーザー情報を取得
    final FirebaseAuth auth = FirebaseAuth.instance;
    final firebaseUser = auth.currentUser;
    final ref =
        FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid);
    final doc = await ref.get();
    return Users(doc);
  } catch (e) {
    print('error:${e.toString()}');
  }
  return null;
}
