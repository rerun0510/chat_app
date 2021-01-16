import 'package:chat_app/domain/myFriends.dart';
import 'package:chat_app/domain/users.dart';
import 'package:chat_app/presentation/member/member_model.dart';
import 'package:chat_app/presentation/user/user_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MemberPage extends StatelessWidget {
  MemberPage(this.groupsId);
  final String groupsId;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MemberModel>(
      create: (_) => MemberModel(groupsId),
      child: Consumer<MemberModel>(
        builder: (context, model, child) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.arrow_back_ios),
              ),
              title: Text('メンバー'),
              // actions: [
              //   FlatButton(
              //     onPressed: () async {
              //       // await Navigator.push(
              //       //   context,
              //       //   MaterialPageRoute(
              //       //     builder: (context) => CreateGroupPage(
              //       //       model.selectedMyFriends,
              //       //       groupNameController,
              //       //     ),
              //       //   ),
              //       // );
              //     },
              //     child: Text(
              //       '次へ',
              //       style: TextStyle(
              //         fontSize: 18,
              //         fontWeight: FontWeight.w500,
              //         color: Colors.white,
              //       ),
              //     ),
              //   )
              // ],
            ),
            body: Container(
              child: model.isLoading
                  ? Container(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Container(
                      child: SingleChildScrollView(
                        child: _memberList(model),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  /// ヘッダー
  Widget _header(int count, bool memberFlg) {
    final String text = memberFlg ? 'メンバー' : '招待中';
    return Container(
      padding: EdgeInsets.fromLTRB(30, 10, 20, 5),
      child: Text(
        '$text $count',
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 友達の招待
  Widget _inviteFriends(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {},
      child: Container(
        padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
        child: ListTile(
          title: Container(
            width: MediaQuery.of(context).size.width * 0.65,
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2),
                  child: ClipOval(
                    child: Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey.withOpacity(0.5),
                      child: Icon(
                        Icons.add,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    '友達の招待',
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
        ),
      ),
    );
  }

  /// メンバー(招待中)リスト
  Widget _memberList(MemberModel model) {
    final List<Users> members = model.members;
    final List<Users> inviteMembers = model.inviteMembers;
    final int headerCnt = inviteMembers.length == 0 ? 2 : 3;
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: members.length + inviteMembers.length + headerCnt,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          // ヘッダー (メンバー)
          return _header(members.length, true);
        } else if (index == 1) {
          // 友達の招待
          return _inviteFriends(context);
        } else if (headerCnt == 3 && index == members.length + 2) {
          // ヘッダー (招待中)
          return _header(inviteMembers.length, false);
        } else {
          Users member;
          if (index <= members.length + 1) {
            // メンバー
            member = members[index - 2];
          } else {
            // 招待中
            member = inviteMembers[index - members.length - 3];
          }
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              MyFriends friend;
              if (member.userId != model.currentUser.userId) {
                friend = await model.fetchFriend(member.userId);
              }
              // ユーザー画面に遷移
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserPage(null, friend, false, true),
                  fullscreenDialog: true,
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 2, 10, 2),
              child: ListTile(
                title: Container(
                  width: MediaQuery.of(context).size.width * 0.65,
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(2),
                        child: ClipOval(
                          child: Container(
                            color: Colors.white,
                            child: member.imageURL != null
                                ? Image.network(
                                    member.imageURL,
                                    errorBuilder:
                                        (context, object, stackTrace) {
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
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          member.name != null ? member.name : '',
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
              ),
            ),
          );
        }
      },
    );
  }
}
