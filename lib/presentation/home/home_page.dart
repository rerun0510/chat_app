import 'package:chat_app/domain/users.dart';
import 'package:chat_app/presentation/home/home_model.dart';
import 'package:chat_app/presentation/user/user_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeModel>(
      create: (_) => HomeModel(),
      child: Scaffold(
        body: Container(
          color: Colors.white10,
          child: Consumer<HomeModel>(
            builder: (context, model, child) {
              final int groupsCnt = model.myGroupsList.length;
              final int friendsCnt = model.myFriendsList.length;
              return model.isLoading
                  ? Container(
                      color: Colors.grey.withOpacity(0.8),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Container(
                      color: Colors.white10,
                      child: ListView(
                        children: [
                          Container(
                            child: _myAccount(model, context),
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
      ),
    );
  }

  _myAccount(HomeModel model, BuildContext context) {
    Users users = model.currentUser;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        // ユーザー画面に遷移
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => UserPage(null, null, false),
        );
        await model.reload();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        child: Row(
          children: [
            // ユーザーのアイコン
            _userImage(users.imageURL, 55.0),
            Container(
              width: MediaQuery.of(context).size.width * 0.65,
              padding: EdgeInsets.only(
                left: 20,
              ),
              child: Text(
                users.name != '' ? users.name : '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
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
                builder: (context) => UserPage(group, null, false),
              );
            },
            contentPadding: EdgeInsets.fromLTRB(20, 5, 20, 5),
            leading: _userImage(group.imageURL, 50.0),
            title: Container(
              width: MediaQuery.of(context).size.width * 0.65,
              child: Text(
                group.groupsName != '' ? group.groupsName : '',
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
                builder: (context) => UserPage(null, friend, false),
              );
            },
            contentPadding: EdgeInsets.fromLTRB(20, 5, 20, 5),
            leading: _userImage(friend.imageURL, 50.0),
            title: Container(
              width: MediaQuery.of(context).size.width * 0.65,
              child: Text(
                friend.usersName != '' ? friend.usersName : '',
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

  /// ユーザーのアイコン
  Widget _userImage(String imageURL, double size) {
    return Container(
      padding: EdgeInsets.all(2),
      child: ClipOval(
        child: Container(
          color: Colors.white,
          child: imageURL != ''
              ? Image.network(
                  imageURL,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (context, object, stackTrace) {
                    return Icon(Icons.account_circle, size: size);
                  },
                )
              : Icon(Icons.account_circle, size: size),
        ),
      ),
    );
  }
}
