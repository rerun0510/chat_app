import 'package:chat_app/domain/users.dart';
import 'package:chat_app/presentation/search_friend/search_friend_page.dart';
import 'package:flutter/material.dart';

class HomePageAppBar {
  Widget getAppBar(BuildContext context, Users users) {
    return AppBar(
      title: Text('ホーム'),
      actions: [
        IconButton(
          onPressed: () async {
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => SearchFriendPage(users),
            );
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
