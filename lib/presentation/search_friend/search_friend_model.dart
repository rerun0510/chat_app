import 'package:chat_app/domain/chatRoomInfo.dart';
import 'package:chat_app/domain/users.dart';
import 'package:chat_app/repository/current_user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchFriendModel extends ChangeNotifier {
  SearchFriendModel() {
    _init();
  }

  Users currentUser;
  Users users;
  String email = '';
  bool clearBtnFlg = false;
  bool isSearchLoading = false;
  bool isAddLoading = false;
  bool searchedFlg = false;
  bool isAlreadyFriend = false;
  bool isAddedFlg = false;
  ChatRoomInfo chatRoomInfo;

  Future _init() async {
    // currentUser取得
    this.currentUser = await fetchCurrentUser();
  }

  void startSearchLoading() {
    this.isSearchLoading = true;
    notifyListeners();
  }

  void endSearchLoading() {
    this.isSearchLoading = false;
    notifyListeners();
  }

  void startAddLoading() {
    this.isAddLoading = true;
    notifyListeners();
  }

  void endAddLoading() {
    this.isAddLoading = false;
    notifyListeners();
  }

  void clearEmail() {
    this.email = '';
    this.clearBtnFlg = false;
    notifyListeners();
  }

  void checkClearBtn() {
    if (this.email.length != 0) {
      this.clearBtnFlg = true;
    } else {
      this.clearBtnFlg = false;
    }
    notifyListeners();
  }

  /// 友達を検索する
  Future searchFriend() async {
    this.searchedFlg = true;
    startSearchLoading();

    this.isAddedFlg = false;
    this.chatRoomInfo = null;

    try {
      // ユーザー情報を取得
      final docs = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: this.email)
          .get();
      // emailは一意のキーとなっている前提
      if (docs.size != 0) {
        this.users = Users(docs.docs[0]);
        // 既に友達に追加されているかを確認
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(this.currentUser.userId)
            .collection('friends')
            .doc(this.users.userId)
            .get();
        if (doc.exists && doc['friendFlg']) {
          isAlreadyFriend = true;
          // 検索後のトーク画面遷移用
          final chatRoomInfoRef = doc['chatRoomInfoRef'];
          await setChatRoomInfo(chatRoomInfoRef);
        } else {
          isAlreadyFriend = false;
        }
      } else {
        this.users = null;
      }
    } catch (e) {
      print(e);
      throw ('エラーが発生しました');
    } finally {
      endSearchLoading();
    }
  }

  /// 友達に追加する
  Future addFriend() async {
    startAddLoading();

    this.isAddedFlg = false;
    this.chatRoomInfo = null;

    try {
      // 自分と相手の'/users/(UserId)'を定義
      final usersRef = FirebaseFirestore.instance
          .collection('users')
          .doc(this.currentUser.userId);
      final friendUsersRef =
          FirebaseFirestore.instance.collection('users').doc(this.users.userId);

      // 登録相手の友達情報に自分が存在するかを確認
      final friendRef =
          friendUsersRef.collection('friends').doc(this.currentUser.userId);
      final createRoomFlg = await friendRef.get();

      if (!createRoomFlg.exists) {
        // 存在しない場合(相互に友達登録されていない)は新規でchatRoomを作成

        // '/chatRoom/(ルームID)'を新規作成
        final roomRef =
            await FirebaseFirestore.instance.collection('chatRoom').add({
          'groupFlg': false,
          'groupId': '',
        });

        // '/chatRoom/(ルームID)/member/'を定義
        final roomMemberRef = roomRef.collection('member');
        // 自分と相手を追加
        await roomMemberRef.doc(this.currentUser.userId).set({
          'usersRef': usersRef,
        });
        await roomMemberRef.doc(this.users.userId).set({
          'usersRef': friendUsersRef,
        });

        // '/users/(ユーザーID)/chatRoomInfo/(ルームID)/'へデータを追加
        String initResentMessage = '';
        final chatRoomInfoRef =
            usersRef.collection('chatRoomInfo').doc(roomRef.id);
        await chatRoomInfoRef.set({
          'roomRef': roomRef,
          'resentMessage': initResentMessage,
          'updateAt': Timestamp.now(),
          'visible': true,
        });
        await friendUsersRef.collection('chatRoomInfo').doc(roomRef.id).set({
          'roomRef': roomRef,
          'resentMessage': initResentMessage,
          'updateAt': Timestamp.now(),
          'visible': false,
        });

        // '/users/(自分のユーザーID)/friend/'に登録相手のユーザー情報を追加
        await usersRef.collection('friends').doc(this.users.userId).set(
          {
            'usersRef': friendUsersRef,
            'chatRoomInfoRef':
                usersRef.collection('chatRoomInfo').doc(roomRef.id),
            'friendFlg': true,
          },
        );

        // '/users/(相手のユーザーID)/friend/'に自分のユーザー情報を追加(friendFlg=false)
        await friendUsersRef
            .collection('friends')
            .doc(this.currentUser.userId)
            .set({
          'usersRef': usersRef,
          'chatRoomInfoRef':
              friendUsersRef.collection('chatRoomInfo').doc(roomRef.id),
          'friendFlg': false,
        });

        // 登録完了後のトーク画面遷移用のchatRoomInfoを設定
        await setChatRoomInfo(chatRoomInfoRef);
      } else {
        // 相手が既に自分を友達登録している場合
        // '/users/(自分のユーザーID)/friend/'に登録相手のユーザー情報を追加
        await usersRef.collection('friends').doc(this.users.userId).update(
          {
            'friendFlg': true,
          },
        );

        // '/chatRoom/(ルームID)'を取得
        final doc = await friendRef.get();
        final roomId = doc['chatRoomInfoRef'].id;
        final chatRoomInfoRef = usersRef.collection('chatRoomInfo').doc(roomId);

        // chatRoomInfoのVisibleを更新
        // メッセージの有無で更新方法を分岐
        final snapshot = await FirebaseFirestore.instance
            .collection('chatRoom')
            .doc(roomId)
            .collection('messages')
            .get();
        if (snapshot.docs.length == 0) {
          await chatRoomInfoRef.update({
            'updateAt': Timestamp.now(),
            'visible': true,
          });
        } else {
          await chatRoomInfoRef.update({
            'visible': true,
          });
        }

        // 登録完了後のトーク画面遷移用
        await setChatRoomInfo(chatRoomInfoRef);
      }
      isAlreadyFriend = true;
      isAddedFlg = true;
      notifyListeners();
    } catch (e) {
      print(e);
      throw ('エラーが発生しました');
    } finally {
      endAddLoading();
    }
  }

  /// トーク画面遷移用のchatRoomInfoを設定
  Future setChatRoomInfo(DocumentReference chatRoomInfoRef) async {
    this.chatRoomInfo = ChatRoomInfo(await chatRoomInfoRef.get());
    this.chatRoomInfo.roomName = this.users.name;
    this.chatRoomInfo.imageURL = this.users.imageURL;
  }
}
