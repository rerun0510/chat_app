import 'package:chat_app/domain/myFriends.dart';
import 'package:chat_app/domain/myGroups.dart';
import 'package:chat_app/presentation/my/my_page.dart';
import 'package:chat_app/presentation/talk/talk_page.dart';
import 'package:chat_app/presentation/user/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserPage extends StatelessWidget {
  UserPage(this.myGroups, this.myFriends);

  final MyFriends myFriends;
  final MyGroups myGroups;

  @override
  Widget build(BuildContext context) {
    final TextEditingController textEditingController = TextEditingController();
    ;
    return ChangeNotifierProvider<UserModel>(
      create: (_) => UserModel(myGroups, myFriends),
      child: Consumer<UserModel>(
        builder: (context, model, child) {
          return Stack(
            children: [
              Scaffold(
                body: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(model.backgroundImage),
                        fit: BoxFit.cover),
                  ),
                  child: SafeArea(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(2, 50, 2, 0),
                      child: Center(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () =>
                                      Navigator.of(context, rootNavigator: true)
                                          .pop(),
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.white,
                                  ),
                                ),
                                Container(
                                  child: model.isMe
                                      ? IconButton(
                                          onPressed: () async {
                                            await showModalBottomSheet(
                                              context: context,
                                              builder: (context) => Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.9,
                                                child: MyPage(
                                                    textEditingController),
                                              ),
                                              isScrollControlled: true,
                                            );
                                            // プロフィール再表示
                                            await model.reload();
                                          },
                                          icon: Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                          ),
                                        )
                                      : null,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.25,
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.3,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: _userImage(model),
                                  ),
                                  Text(
                                    model.name != null ? model.name : '',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
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
                                                  Icons.textsms_outlined,
                                                  color: Colors.white,
                                                ),
                                                onPressed: () async {
                                                  // トーク画面に遷移
                                                  Navigator.of(context,
                                                          rootNavigator: false)
                                                      .pop();
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          TalkPage(model
                                                              .chatRoomInfo),
                                                    ),
                                                  );
                                                },
                                              ),
                                              Text(
                                                'TALK',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
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
          );
        },
      ),
    );
  }

  /// ユーザーのアイコン
  Widget _userImage(UserModel model) {
    return ClipOval(
      child: Container(
        color: Colors.white,
        child: model.imageURL != ''
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
      ),
    );
  }
}
