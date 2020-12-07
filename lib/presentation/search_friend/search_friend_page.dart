import 'package:chat_app/domain/users.dart';
import 'package:chat_app/presentation/search_friend/search_friend_model.dart';
import 'package:chat_app/presentation/talk/talk_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchFriendPage extends StatelessWidget {
  SearchFriendPage(this.users);

  final Users users;

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return ChangeNotifierProvider<SearchFriendModel>(
      create: (_) => SearchFriendModel(),
      child: Consumer<SearchFriendModel>(
        builder: (context, model, child) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.9,
            child: Stack(
              children: [
                Container(
                  child: Scaffold(
                    appBar: AppBar(
                      leading: Container(),
                      title: Text('友達検索'),
                      actions: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.clear,
                          ),
                        ),
                      ],
                    ),
                    body: Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 30,
                          ),
                          _searchBox(controller, model, context),
                          SizedBox(
                            height: 80,
                          ),
                          Center(
                            child: model.searchedFlg
                                ? model.isSearchLoading
                                    ? Container(
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      )
                                    : model.users != null
                                        ? Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child:
                                                    _userImage(model, context),
                                              ),
                                              Text(
                                                model.users.name != null
                                                    ? model.users.name
                                                    : '',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Container(
                                                child: model.users.userId !=
                                                        users.userId
                                                    ? model.isAlreadyFriend
                                                        ? Column(
                                                            children: [
                                                              Text(model
                                                                      .isAddedFlg
                                                                  ? '新しい友達とトークしよう！'
                                                                  : '友達に登録済みです。'),
                                                              _talkBtn(model,
                                                                  context),
                                                            ],
                                                          )
                                                        : _addFriendBtn(
                                                            model, context)
                                                    : Text(
                                                        '自分自身を追加することはできません。'),
                                              ),
                                            ],
                                          )
                                        : Text(
                                            '入力したメールアドレスのユーザーは存在しません。',
                                            style: TextStyle(
                                              fontSize: 15,
                                            ),
                                          )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                    child: model.isAddLoading
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

  /// 検索ボックス
  Widget _searchBox(TextEditingController controller, SearchFriendModel model,
      BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Colors.grey,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 8,
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'メールアドレスで検索',
              ),
              controller: controller,
              onChanged: (text) {
                model.email = text;
                model.checkClearBtn();
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: model.clearBtnFlg
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      print(model.email);
                      controller.clear();
                      model.clearEmail();
                    },
                  )
                : Container(),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: Icon(
                Icons.search,
                color: model.email.isNotEmpty
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
              onPressed: model.email.isNotEmpty
                  ? () async {
                      await model.searchFriend(users);
                    }
                  : null,
            ),
          )
        ],
      ),
    );
  }

  /// ユーザーのアイコン
  Widget _userImage(SearchFriendModel model, BuildContext context) {
    return ClipOval(
      child: model.users.imageURL != null
          ? Image.network(
              model.users.imageURL,
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
    );
  }

  /// 友達追加ボタン
  Widget _addFriendBtn(SearchFriendModel model, BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ButtonTheme(
          minWidth: 150,
          height: 40,
          child: RaisedButton(
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
            child: Text(
              '友達登録',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            onPressed: () async {
              await model.addFriend(users);
            },
          ),
        ),
      ),
    );
  }

  /// トーク画面遷移ボタン（未実装）
  Widget _talkBtn(SearchFriendModel model, BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ButtonTheme(
          minWidth: 150,
          height: 40,
          child: RaisedButton(
            color: Theme.of(context).primaryColor,
            textColor: Colors.white,
            child: Text(
              'トーク',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            onPressed: () async {
              // TODO トーク画面へ遷移
              Navigator.of(context).pop();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TalkPage(
                    model.chatRoomInfo,
                    users,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
