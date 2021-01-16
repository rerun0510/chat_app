import 'package:chat_app/domain/myFriends.dart';
import 'package:chat_app/domain/myGroups.dart';
import 'package:chat_app/presentation/member/member_page.dart';
import 'package:chat_app/presentation/my/my_page.dart';
import 'package:chat_app/presentation/user/user_model.dart';
import 'package:chat_app/presentation/user_image/user_image_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserPage extends StatelessWidget {
  UserPage(this.myGroups, this.myFriends, this.talkPageFlg, this.memberPageFlg);

  final MyFriends myFriends;
  final MyGroups myGroups;
  final bool talkPageFlg;
  final bool memberPageFlg;

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
                : GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      // 画像表示画面に遷移
                      await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => UserImagePage(
                            model.id, model.isMe, model.isGroup, false),
                      );
                      // 画像変更後のリロード
                      if (model.isMe) {
                        await model.reload();
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(model.backgroundImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: SafeArea(
                        child: Container(
                          // padding: EdgeInsets.fromLTRB(2, 40, 2, 0),
                          child: Center(
                            child: Column(
                              children: [
                                // AppBar
                                _appBar(model, controller, context),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.1,
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.4,
                                  child: Column(
                                    children: [
                                      // アイコン
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: GestureDetector(
                                          onTap: () async {
                                            // 画像表示画面に遷移
                                            await showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              builder: (context) =>
                                                  UserImagePage(
                                                      model.id,
                                                      model.isMe,
                                                      model.isGroup,
                                                      true),
                                            );
                                            // 画像変更後のリロード
                                            if (model.isMe) {
                                              await model.reload();
                                            }
                                          },
                                          behavior: HitTestBehavior.opaque,
                                          child:
                                              _userImage(model.imageURL, 125.0),
                                        ),
                                      ),
                                      // 名前
                                      Container(
                                        alignment: Alignment.center,
                                        width:
                                            MediaQuery.of(context).size.width *
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
                                      // メンバーアイコン
                                      Container(
                                        child: myGroups != null
                                            ? _memberIcon(model, context)
                                            : null,
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
                    // await showModalBottomSheet(
                    //   context: context,
                    //   isScrollControlled: true,
                    //   // builder: (context) => Container(
                    //   //   height: MediaQuery.of(context).size.height * 0.9,
                    //   //   child: Navigator(
                    //   //     onGenerateRoute: (context) => MaterialPageRoute(
                    //   //       builder: (context) => MyPage(controller),
                    //   //     ),
                    //   //   ),
                    //   // ),
                    //   builder: (context) => MaterialApp(
                    //     home: MyPage(controller),
                    //   ),
                    // );
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyPage(controller),
                          //以下を追加
                          fullscreenDialog: true,
                        ));
                    // プロフィール再表示
                    await model.reload();
                  },
                  icon: Icon(
                    Icons.settings,
                    color: Colors.white,
                  ),
                )
              : null,
        ),
      ],
    );
  }

  /// ユーザーのアイコン
  Widget _userImage(String imageURL, double size) {
    return ClipOval(
      child: Container(
        color: Colors.white,
        child: imageURL != ''
            ? Image.network(
                imageURL,
                errorBuilder: (context, object, stackTrace) {
                  return Icon(
                    Icons.account_circle,
                    size: size,
                  );
                },
                width: size,
                height: size,
                fit: BoxFit.cover,
              )
            : Icon(
                Icons.account_circle,
                size: size,
              ),
      ),
    );
  }

  /// メンバーアイコン
  Widget _memberIcon(UserModel model, BuildContext context) {
    final cnt = model.memberIcon.length;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        // メンバー画面に遷移
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MemberPage(this.myGroups.groupsId),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.only(top: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.only(right: 5, left: 5),
              child: _userImage(model.memberIcon[0], 35),
            ),
            Container(
              child: cnt > 1
                  ? Container(
                      padding: EdgeInsets.only(right: 5, left: 5),
                      child: _userImage(model.memberIcon[1], 35),
                    )
                  : null,
            ),
            Container(
              child: cnt > 2
                  ? Container(
                      padding: EdgeInsets.only(right: 5, left: 5),
                      child: _userImage(model.memberIcon[2], 35),
                    )
                  : null,
            ),
            Container(
              child: cnt > 3
                  ? Container(
                      padding: EdgeInsets.only(right: 5, left: 5),
                      child: _userImage(model.memberIcon[3], 35),
                    )
                  : null,
            ),
            Container(
              margin: EdgeInsets.only(right: 5, left: 5),
              height: 35,
              decoration: BoxDecoration(
                color: Colors.lightBlue,
                border: Border.all(color: Colors.lightBlue),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                margin: EdgeInsets.only(right: 15, left: 15),
                alignment: Alignment.center,
                child: Text(
                  '${model.memberCnt.toString()} >',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Btn
  Widget _btn(UserModel model, BuildContext context) {
    return model.isMe
        ? Container()
        : model.isGroup
            ? Row(
                children: [
                  model.isMember
                      ? _talkBtn(model, context)
                      : _joinGroupBtn(model),
                ],
              )
            : Row(
                children: [
                  model.isFriend
                      ? _talkBtn(model, context)
                      : _addFriendBtn(model),
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
              // Navigator.of(context).pop();
              // if (this.talkPageFlg) {
              //   // トーク画面 → ユーザー画面 → トーク画面で遷移が行われている場合２回popする
              //   Navigator.of(context).pop();
              //   Navigator.of(context, rootNavigator: true);
              // } else if (this.memberPageFlg) {
              //   // メンバー画面 → ユーザー画面 → トーク画面で遷移が行われている場合３回popする
              //   // Navigator.of(context).pop();
              //   // Navigator.of(context).pop();
              //   Navigator.of(context, rootNavigator: true);
              // }
              // Navigator.of(context, rootNavigator: true);
              // Navigator.of(context).pop();
              // トーク画面に遷移
              Navigator.of(context, rootNavigator: true)
                  .pop(model.chatRoomInfo);
              // await Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => TalkPage(model.chatRoomInfo),
              //   ),
              // );
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
  Widget _addFriendBtn(UserModel model) {
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

  /// JoinGroupBtn
  Widget _joinGroupBtn(UserModel model) {
    return Expanded(
      child: Column(
        children: [
          IconButton(
            icon: Icon(
              Icons.group_add,
              color: Colors.white,
              size: 35,
            ),
            onPressed: () async {
              // グループに参加
              // model.addFriend(myFriends);
              print('Join');
            },
          ),
          Text(
            'JOIN',
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
