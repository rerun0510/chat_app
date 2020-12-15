import 'package:chat_app/domain/users.dart';
import 'package:chat_app/presentation/add_friend/add_friend_page.dart';
import 'package:chat_app/presentation/search_friend/search_friend_page.dart';
import 'package:flutter/material.dart';

class HomePageAppBar {
  Widget getAppBar(BuildContext context, Users users) {
    return AppBar(
      title: Text('ホーム'),
      actions: [
        IconButton(
          onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => Container(
                    height: MediaQuery.of(context).size.height * 0.9,
                    child: Navigator(
                      onGenerateRoute: (context) => MaterialPageRoute(
                        builder: (context) => AddFriendPage(),
                      ),
                    ),
                  )),
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
