import 'package:chat_app/domain/myFriends.dart';
import 'package:chat_app/domain/myGroups.dart';
import 'package:chat_app/domain/users.dart';
import 'package:chat_app/presentation/talk/talk_page.dart';
import 'package:chat_app/presentation/user/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserPage extends StatelessWidget {
  UserPage(this.users, this.myGroups, this.myFriends);

  final Users users;
  final MyFriends myFriends;
  final MyGroups myGroups;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserModel>(
      create: (_) => UserModel(users, myGroups, myFriends),
      child: Consumer<UserModel>(
        builder: (context, model, child) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.9,
            child: Stack(
              children: [
                Container(
                  child: Scaffold(
                    appBar: AppBar(
                      leading: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.clear,
                        ),
                      ),
                      title: Text(model.name),
                      actions: model.isMe
                          ? [
                              IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: Icon(
                                  Icons.edit,
                                ),
                              ),
                            ]
                          : [],
                    ),
                    body: Container(
                      padding: EdgeInsets.all(2),
                      child: Center(
                        child: Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.25,
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.3,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: _userImage(model, context),
                                  ),
                                  Text(
                                    model.name != null ? model.name : '',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.15,
                              child: model.isMe
                                  ? Container()
                                  : Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                    Icons.textsms_outlined),
                                                onPressed: () async {
                                                  // トーク画面に遷移
                                                  Navigator.of(context).pop();
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          TalkPage(
                                                        model.chatRoomInfo,
                                                        users,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              Text('TALK'),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                    child: model.isLoading
                        ? Container(
                            color: Colors.grey.withOpacity(0.8),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : null),
              ],
            ),
          );
        },
      ),
    );
  }

  /// ユーザーのアイコン
  Widget _userImage(UserModel model, BuildContext context) {
    return ClipOval(
      child: model.imageURL != null
          ? Image.network(
              model.imageURL,
              errorBuilder: (context, object, stackTrace) {
                return Icon(
                  Icons.account_circle,
                  size: 125,
                );
              },
              width: 125,
              height: 125,
              fit: BoxFit.cover,
            )
          : Icon(
              Icons.account_circle,
              size: 125,
            ),
    );
  }
}
