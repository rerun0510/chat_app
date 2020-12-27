import 'package:chat_app/presentation/my/my_model.dart';
import 'package:chat_app/presentation/my_name_edit/my_name_edit.page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyPage extends StatelessWidget {
  MyPage(this.textEditingController);
  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MyModel>(
      create: (_) => MyModel(),
      child: Consumer<MyModel>(
        builder: (context, model, child) {
          return model.isLoading
              ? Container(
                  child: model.isLoading
                      ? Container(
                          color: Colors.grey.withOpacity(0.8),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : null)
              : Scaffold(
                  appBar: AppBar(
                    leading: Container(),
                    title: Text('プロフィール'),
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
                  body: Container(
                    color: Colors.white10,
                    child: SafeArea(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              // 背景設定
                              await model.showImagePickerBackground();
                            },
                            child: Stack(
                              children: [
                                Container(
                                  height: 230,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: NetworkImage(
                                          model.currentUser.backgroundImage,
                                        ),
                                        fit: BoxFit.cover),
                                  ),
                                  child: Center(
                                    child: GestureDetector(
                                      onTap: () async {
                                        // アイコン設定
                                        await model.showImagePickerIcon();
                                      },
                                      child: Stack(
                                        children: [
                                          ClipOval(
                                            child: Container(
                                              color: Colors.white,
                                              child: model.currentUser
                                                          .imageURL !=
                                                      null
                                                  ? Image.network(
                                                      model
                                                          .currentUser.imageURL,
                                                      errorBuilder: (context,
                                                          object, stackTrace) {
                                                        return Icon(
                                                          Icons.account_circle,
                                                          size: 50,
                                                        );
                                                      },
                                                      width: 120,
                                                      height: 120,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Icon(
                                                      Icons.account_circle,
                                                      size: 50,
                                                    ),
                                            ),
                                          ),
                                          Positioned(
                                            right: 0,
                                            bottom: 0,
                                            child: cameraIcon(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 15,
                                  bottom: 20,
                                  child: cameraIcon(),
                                )
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 0.5,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () async {
                                    // 名前編集画面へ遷移
                                    textEditingController.text =
                                        model.currentUser.name;
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MyNameEditPage(
                                          textEditingController,
                                        ),
                                      ),
                                    );
                                    await model.reload();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          width: 0.5,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    width: MediaQuery.of(context).size.width,
                                    margin: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                    padding: EdgeInsets.fromLTRB(0, 15, 15, 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '名前',
                                              style: TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              model.currentUser.name,
                                              style: TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.grey,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.fromLTRB(15, 15, 0, 15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'メールアドレス',
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        model.currentUser.email,
                                        style: TextStyle(
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
        },
      ),
    );
  }

  Widget cameraIcon() {
    return Container(
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
    );
  }
}
