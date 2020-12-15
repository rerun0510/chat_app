import 'package:chat_app/domain/myFriends.dart';
import 'package:chat_app/presentation/add_friend/add_friend_model.dart';
import 'package:chat_app/presentation/search_friend/search_friend_page.dart';
import 'package:chat_app/presentation/selectFriends/select_friends_page.dart';
import 'package:chat_app/presentation/user/user_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddFriendPage extends StatelessWidget {
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
                                            SearchFriendPage(),
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
                                        builder: (context) =>
                                            SelectFriendsPage(),
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
  //
  // /// 検索ボックス
  // Widget _searchBox(TextEditingController controller, SearchFriendModel model,
  //     BuildContext context) {
  //   return Container(
  //     padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
  //     decoration: BoxDecoration(
  //       border: Border.all(
  //         width: 1,
  //         color: Colors.grey,
  //       ),
  //     ),
  //     child: Row(
  //       children: [
  //         Expanded(
  //           flex: 8,
  //           child: TextField(
  //             decoration: InputDecoration(
  //               border: InputBorder.none,
  //               hintText: 'メールアドレスで検索',
  //             ),
  //             controller: controller,
  //             onChanged: (text) {
  //               model.email = text;
  //               model.checkClearBtn();
  //             },
  //           ),
  //         ),
  //         Expanded(
  //           flex: 1,
  //           child: model.clearBtnFlg
  //               ? IconButton(
  //                   icon: Icon(
  //                     Icons.clear,
  //                     color: Colors.grey,
  //                   ),
  //                   onPressed: () {
  //                     print(model.email);
  //                     controller.clear();
  //                     model.clearEmail();
  //                   },
  //                 )
  //               : Container(),
  //         ),
  //         Expanded(
  //           flex: 1,
  //           child: IconButton(
  //             icon: Icon(
  //               Icons.search,
  //               color: model.email.isNotEmpty
  //                   ? Theme.of(context).primaryColor
  //                   : Colors.grey,
  //             ),
  //             onPressed: model.email.isNotEmpty
  //                 ? () async {
  //                     await model.searchFriend(users);
  //                   }
  //                 : null,
  //           ),
  //         )
  //       ],
  //     ),
  //   );
  // }
  //
  // /// ユーザーのアイコン
  // Widget _userImage(SearchFriendModel model, BuildContext context) {
  //   return ClipOval(
  //     child: model.users.imageURL != null
  //         ? Image.network(
  //             model.users.imageURL,
  //             errorBuilder: (context, object, stackTrace) {
  //               return Icon(
  //                 Icons.account_circle,
  //                 size: 125,
  //               );
  //             },
  //             width: 125,
  //             height: 125,
  //             fit: BoxFit.cover,
  //           )
  //         : Icon(
  //             Icons.account_circle,
  //             size: 125,
  //           ),
  //   );
  // }
  //
  // /// 友達追加ボタン
  // Widget _addFriendBtn(SearchFriendModel model, BuildContext context) {
  //   return Container(
  //     child: Padding(
  //       padding: const EdgeInsets.all(8.0),
  //       child: ButtonTheme(
  //         minWidth: 150,
  //         height: 40,
  //         child: RaisedButton(
  //           color: Theme.of(context).primaryColor,
  //           textColor: Colors.white,
  //           child: Text(
  //             '友達登録',
  //             style: TextStyle(
  //               fontSize: 16,
  //             ),
  //           ),
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //           onPressed: () async {
  //             await model.addFriend(users);
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  // }
  //
  // /// トーク画面遷移ボタン（未実装）
  // Widget _talkBtn(SearchFriendModel model, BuildContext context) {
  //   return Container(
  //     child: Padding(
  //       padding: const EdgeInsets.all(8.0),
  //       child: ButtonTheme(
  //         minWidth: 150,
  //         height: 40,
  //         child: RaisedButton(
  //           color: Theme.of(context).primaryColor,
  //           textColor: Colors.white,
  //           child: Text(
  //             'トーク',
  //             style: TextStyle(
  //               fontSize: 16,
  //             ),
  //           ),
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //           onPressed: () async {
  //             // TODO トーク画面へ遷移
  //             Navigator.of(context).pop();
  //             await Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                 builder: (context) => TalkPage(
  //                   model.chatRoomInfo,
  //                   users,
  //                 ),
  //               ),
  //             );
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
