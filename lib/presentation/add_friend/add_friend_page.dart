import 'package:chat_app/domain/myFriends.dart';
import 'package:chat_app/presentation/add_friend/add_friend_model.dart';
import 'package:chat_app/presentation/search_friend/search_friend_page.dart';
import 'package:chat_app/presentation/select_friend/select_friends_page.dart';
import 'package:chat_app/presentation/user/user_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddFriendPage extends StatelessWidget {
  AddFriendPage(this.emailController, this.groupNameController);
  final TextEditingController emailController;
  final TextEditingController groupNameController;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AddFriendModel>(
      create: (_) => AddFriendModel(),
      child: Consumer<AddFriendModel>(
        builder: (context, model, child) {
          final listCount = model.myFriends.length;
          return Container(
            child: Stack(
              children: [
                Container(
                  child: Scaffold(
                    appBar: AppBar(
                      leading: Container(),
                      title: Text('友達追加'),
                      actions: [
                        IconButton(
                          onPressed: () =>
                              Navigator.of(context, rootNavigator: true).pop(),
                          icon: Icon(
                            Icons.clear,
                          ),
                        ),
                      ],
                    ),
                    body: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: FlatButton(
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SearchFriendPage(emailController),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.search,
                                        size: 35,
                                      ),
                                      Text('検索'),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: FlatButton(
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SelectFriendPage(
                                            groupNameController),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.group_add,
                                        size: 35,
                                      ),
                                      Text('グループ作成'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                          child: Text(
                            '知り合いかも？ $listCount',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _mayByFriendList(model.myFriends),
                        ),
                      ],
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

  Widget _mayByFriendList(List<MyFriends> myFriends) {
    return ListView.builder(
      itemCount: myFriends.length,
      itemBuilder: (context, index) {
        final myFriend = myFriends[index];
        return Container(
          child: ListTile(
            onTap: () async {
              // ユーザー画面に遷移
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => UserPage(null, myFriend),
              );
            },
            contentPadding: EdgeInsets.fromLTRB(20, 5, 20, 5),
            leading: Container(
              padding: EdgeInsets.all(2),
              child: ClipOval(
                child: myFriend.imageURL != null
                    ? Image.network(
                        myFriend.imageURL,
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
                myFriend.usersName != null ? myFriend.usersName : '',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            trailing: IconButton(
              onPressed: () async {},
              icon: Icon(
                Icons.person_add,
                color: Colors.grey,
              ),
            ),
          ),
        );
      },
    );
  }
}
