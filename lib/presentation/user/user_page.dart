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
    final TextEditingController controller = TextEditingController();

    return ChangeNotifierProvider<UserModel>(
      create: (_) => UserModel(myGroups, myFriends),
      child: Consumer<UserModel>(
        builder: (context, model, child) {
          return Scaffold(
            body: model.isLoading
                ? Container(
                    color: Colors.grey.withOpacity(0.8),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(model.backgroundImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: SafeArea(
                      child: Container(
                        padding: EdgeInsets.fromLTRB(2, 40, 2, 0),
                        child: Center(
                          child: Column(
                            children: [
                              // AppBar
                              _appBar(model, controller, context),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.25,
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.3,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: _userImage(model),
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      width: MediaQuery.of(context).size.width *
                                          0.7,
                                      child: Text(
                                        model.name != null ? model.name : '',
                                        style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.15,
                                child: _btn(model, context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  /// AppBar
  Widget _appBar(
      UserModel model, TextEditingController controller, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          icon: Icon(
            Icons.clear,
            color: Colors.white,
          ),
        ),
        Container(
          // 自分のプロフィールの場合は編集ボタンを設置
          child: model.isMe
              ? IconButton(
                  onPressed: () async {
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => Container(
                        height: MediaQuery.of(context).size.height * 0.9,
                        child: Navigator(
                          onGenerateRoute: (context) => MaterialPageRoute(
                            builder: (context) => MyPage(controller),
                          ),
                        ),
                      ),
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

  /// Btn
  Widget _btn(UserModel model, BuildContext context) {
    return model.isMe
        ? Container()
        : Row(
            children: [
              model.isFriend
                  ? _talkBtn(model, context)
                  : _addFriendBtn(model, context),
            ],
          );
  }

  /// TalkBtn
  Widget _talkBtn(UserModel model, BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          IconButton(
            icon: Icon(
              Icons.textsms_outlined,
              color: Colors.white,
              size: 35,
            ),
            onPressed: () async {
              // トーク画面に遷移
              Navigator.of(context, rootNavigator: false).pop();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TalkPage(model.chatRoomInfo),
                ),
              );
            },
          ),
          Text(
            'TALK',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// AddFriendBtn
  Widget _addFriendBtn(UserModel model, BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          IconButton(
            icon: Icon(
              Icons.person_add,
              color: Colors.white,
              size: 35,
            ),
            onPressed: () async {
              // トーク画面に遷移
              model.addFriend(myFriends);
            },
          ),
          Text(
            'ADD',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
