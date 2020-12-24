import 'package:chat_app/presentation/create_group/create_group_page.dart';
import 'package:chat_app/presentation/select_friend/select_friend_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectFriendPage extends StatelessWidget {
  SelectFriendPage(this.groupNameController);
  final TextEditingController groupNameController;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SelectFriendModel>(
      create: (_) => SelectFriendModel(),
      child: Consumer<SelectFriendModel>(builder: (context, model, child) {
        final int friendsCnt = model.myFriends.length;
        final int selectCnt = model.selectedMyFriends.length;
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.arrow_back_ios),
            ),
            title: selectCnt == 0 ? Text('友達を選択') : Text('選択中 $selectCnt'),
            actions: [
              FlatButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateGroupPage(
                          model.selectedMyFriends, groupNameController),
                    ),
                  );
                },
                child: Text(
                  '次へ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
          body: Container(
            child: model.isLoading
                ? Container(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(30, 10, 20, 5),
                          child: Text(
                            '友達 $friendsCnt',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                              itemCount: model.myFriends.length,
                              itemBuilder: (BuildContext context, int index) {
                                final Map friend = model.myFriends[index];
                                return Container(
                                  padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        width: 1,
                                        color: Colors.grey.withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                  child: CheckboxListTile(
                                    title: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.65,
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(2),
                                            child: ClipOval(
                                              child: friend['imageURL'] != null
                                                  ? Image.network(
                                                      friend['imageURL'],
                                                      errorBuilder: (context,
                                                          object, stackTrace) {
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
                                          Container(
                                            padding: EdgeInsets.all(10),
                                            child: Text(
                                              friend['usersName'] != null
                                                  ? friend['usersName']
                                                  : '',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    value: friend['check'],
                                    onChanged: (bool value) {
                                      model.check(value, index);
                                    },
                                  ),
                                );
                              }),
                        ),
                      ],
                    ),
                  ),
          ),
          bottomSheet: model.selectedMyFriends.length == 0
              ? null
              : Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  color: Colors.grey.withOpacity(0.2),
                  height: 120,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: model.selectedMyFriends.length,
                      itemBuilder: (BuildContext context, int index) {
                        final Map selectedFriend =
                            model.selectedMyFriends[index];
                        return Stack(
                          children: [
                            Container(
                              width: 80,
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(2),
                                    child: ClipOval(
                                      child: selectedFriend['imageURL'] != null
                                          ? Image.network(
                                              selectedFriend['imageURL'],
                                              errorBuilder: (context, object,
                                                  stackTrace) {
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
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    child: Text(
                                      selectedFriend['usersName'] != null
                                          ? selectedFriend['usersName']
                                          : '',
                                      style: TextStyle(
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              left: 20,
                              child: SizedBox(
                                height: 30,
                                child: RaisedButton(
                                  child: Icon(
                                    Icons.clear,
                                    size: 16,
                                  ),
                                  color: Colors.white,
                                  shape: const CircleBorder(
                                    side: BorderSide(
                                      color: Colors.black,
                                      width: 1,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                  onPressed: () {
                                    model
                                        .removeMember(selectedFriend['userId']);
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                ),
        );
      }),
    );
  }
}
