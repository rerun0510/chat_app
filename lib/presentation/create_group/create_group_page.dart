import 'package:chat_app/presentation/create_group/create_group_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateGroupPage extends StatelessWidget {
  CreateGroupPage(this.selectedMyFriends, this.groupNameController);
  final List<Map> selectedMyFriends;
  final TextEditingController groupNameController;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CreateGroupModel>(
      create: (_) => CreateGroupModel(this.selectedMyFriends),
      child: Consumer<CreateGroupModel>(builder: (context, model, child) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {
                  groupNameController.clear();
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.arrow_back_ios),
              ),
              title: Text('プロフィールを設定'),
              actions: [
                FlatButton(
                  onPressed: model.groupName.length == 0
                      ? null
                      : () async {
                          await model.createGroup();
                          // user_page遷移用にMyGroupsを返却
                          Navigator.of(context, rootNavigator: true)
                              .pop(model.myGroups);
                        },
                  child: Text(
                    '作成',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: model.groupName.length == 0
                          ? Colors.grey
                          : Colors.white,
                    ),
                  ),
                )
              ],
            ),
            body: model.isLoading
                ? Container(
                    color: Colors.grey.withOpacity(0.8),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // グループ情報入力フォーム
                      _inputForm(model),
                      // ヘッダー
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.fromLTRB(20, 2, 0, 2),
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              width: 1,
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        ),
                        child: Text('メンバー'),
                      ),
                      // メンバーリスト

                      _memberList(context, model),
                    ],
                  ),
          ),
        );
      }),
    );
  }

  /// グループ情報入力フォーム
  Widget _inputForm(CreateGroupModel model) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: Colors.grey.withOpacity(0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              // todo 写真登録
              await model.showImagePicker();
            },
            child: Stack(
              children: [
                Container(
                  child: ClipOval(
                    child: model.imageFile != null
                        ? Image.file(
                            model.imageFile,
                            fit: BoxFit.cover,
                            height: 100,
                            width: 100,
                          )
                        : Icon(
                            Icons.group,
                            size: 80,
                          ),
                  ),
                ),
                Positioned(
                  left: 60,
                  top: 65,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.grey,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(
                      height: 30,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.photo_camera_outlined,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'グループ名',
                ),
                controller: groupNameController,
                onChanged: (text) {
                  model.groupName = text;
                  model.checkClearBtn();
                },
              ),
            ),
          ),
          Container(
            child: model.clearBtnFlg
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      groupNameController.clear();
                      model.clearGroupName();
                    },
                  )
                : Container(),
          ),
        ],
      ),
    );
  }

  /// メンバーリスト
  Widget _memberList(BuildContext context, CreateGroupModel model) {
    return Expanded(
      child: GridView.count(
        crossAxisCount: 3,
        scrollDirection: Axis.vertical,
        children: List.generate(
          model.selectedMyFriends.length,
          (index) {
            return Expanded(
              flex: 2,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(2),
                    child: ClipOval(
                      child: model.selectedMyFriends[index]['imageURL'] != null
                          ? Image.network(
                              model.selectedMyFriends[index]['imageURL'],
                              errorBuilder: (context, object, stackTrace) {
                                return Icon(
                                  Icons.account_circle,
                                  size: 60,
                                );
                              },
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            )
                          : Icon(
                              Icons.account_circle,
                              size: 60,
                            ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(2),
                    child: Text(
                      model.selectedMyFriends[index]['usersName'] != null
                          ? model.selectedMyFriends[index]['usersName']
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
            );
          },
        ),
      ),
    );
  }
}
