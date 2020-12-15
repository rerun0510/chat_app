import 'package:chat_app/domain/users.dart';
import 'package:chat_app/presentation/home/home_model.dart';
import 'package:chat_app/presentation/user/user_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  HomePage({this.users});
  final Users users;

  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeModel>(
      create: (_) => HomeModel(),
      child: Scaffold(
        body: Consumer<HomeModel>(
          builder: (context, model, child) {
            final int groupsCnt = model.myGroupsList.length;
            final int friendsCnt = model.myFriendsList.length;
            return model.isLoading
                ? Container(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Container(
                    child: ListView(
                      children: [
                        Container(
                          child: _myAccount(users, context),
                        ),
                        ExpansionTile(
                          initiallyExpanded: false,
                          title: Row(
                            children: [
                              Icon(Icons.group),
                              Text(' グループ $groupsCnt')
                            ],
                          ),
                          children: _groupListTile(model, context),
                        ),
                        ExpansionTile(
                          initiallyExpanded: false,
                          title: Row(
                            children: [
                              Icon(Icons.person),
                              Text(' 友達 $friendsCnt'),
                            ],
                          ),
                          children: _friendListTile(model, context),
                        ),
                      ],
                    ),
                  );
          },
        ),
      ),
    );
  }

  _myAccount(Users users, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // ユーザー画面に遷移
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => UserPage(null, null),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2),
              child: ClipOval(
                child: users.imageURL != null
                    ? Image.network(
                        users.imageURL,
                        errorBuilder: (context, object, stackTrace) {
                          return Icon(
                            Icons.account_circle,
                            size: 55,
                          );
                        },
                        width: 55,
                        height: 55,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.account_circle,
                        size: 55,
                      ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.65,
              padding: EdgeInsets.only(
                left: 20,
              ),
              child: Text(
                users.name != null ? users.name : '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ListTile> _groupListTile(HomeModel model, BuildContext context) {
    final groups = model.myGroupsList;
    return groups
        .map(
          (group) => ListTile(
            onTap: () async {
              // ユーザー画面に遷移
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => UserPage(group, null),
              );
            },
            contentPadding: EdgeInsets.fromLTRB(20, 5, 20, 5),
            leading: Container(
              padding: EdgeInsets.all(2),
              child: ClipOval(
                child: group.imageURL != null
                    ? Image.network(
                        group.imageURL,
                        errorBuilder: (context, object, stackTrace) {
                          return Icon(
                            Icons.account_circle,
                            size: 50,
                          );
                        },
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.account_circle,
                        size: 50,
                      ),
              ),
            ),
            title: Container(
              width: MediaQuery.of(context).size.width * 0.65,
              child: Text(
                group.groupsName != null ? group.groupsName : '',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        )
        .toList();
  }

  List<ListTile> _friendListTile(HomeModel model, BuildContext context) {
    final friends = model.myFriendsList;
    return friends
        .map(
          (friend) => ListTile(
            onTap: () async {
              // ユーザー画面に遷移
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => UserPage(null, friend),
              );
            },
            contentPadding: EdgeInsets.fromLTRB(20, 5, 20, 5),
            leading: Container(
              padding: EdgeInsets.all(2),
              child: ClipOval(
                child: friend.imageURL != null
                    ? Image.network(
                        friend.imageURL,
                        errorBuilder: (context, object, stackTrace) {
                          return Icon(
                            Icons.account_circle,
                            size: 50,
                          );
                        },
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : Icon(
                        Icons.account_circle,
                        size: 50,
                      ),
              ),
            ),
            title: Container(
              width: MediaQuery.of(context).size.width * 0.65,
              child: Text(
                friend.usersName != null ? friend.usersName : '',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        )
        .toList();
  }
}
