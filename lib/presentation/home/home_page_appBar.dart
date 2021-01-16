import 'package:chat_app/domain/chatRoomInfo.dart';
import 'package:chat_app/domain/myGroups.dart';
import 'package:chat_app/presentation/add_friend/add_friend_page.dart';
import 'package:chat_app/presentation/talk/talk_page.dart';
import 'package:chat_app/presentation/user/user_page.dart';
import 'package:flutter/material.dart';

class HomePageAppBar {
  Widget getAppBar(BuildContext context) {
    final emailController = TextEditingController();
    final groupNameController = TextEditingController();
    return AppBar(
      title: Text('ホーム'),
      actions: [
        IconButton(
          onPressed: () async {
            final result = await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => Container(
                height: MediaQuery.of(context).size.height * 0.9,
                child: Navigator(
                  onGenerateRoute: (context) => MaterialPageRoute(
                    builder: (context) =>
                        AddFriendPage(emailController, groupNameController),
                  ),
                ),
              ),
            );
            // search_friend_pageからのtalk_pageへの遷移
            if (result.runtimeType == ChatRoomInfo) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TalkPage(result),
                ),
              );
            }
            // create_group_pageからのuser_pageへの遷移
            if (result.runtimeType == MyGroups) {
              final userPageResult = await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => MaterialApp(
                  home: UserPage(result, null, false, false),
                ),
              );
              // トーク画面へ遷移
              if (userPageResult.runtimeType == ChatRoomInfo) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TalkPage(userPageResult),
                  ),
                );
              }
            }
          },
          padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
          icon: Icon(
            Icons.person_add,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
