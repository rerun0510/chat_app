import 'package:chat_app/presentation/user_image/user_image_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserImagePage extends StatelessWidget {
  UserImagePage(this.id, this.isMe, this.isGroup, this.isIcon);
  final String id;
  final bool isMe;
  final bool isGroup;
  final bool isIcon;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserImageModel>(
      create: (_) =>
          UserImageModel(this.id, this.isMe, this.isGroup, this.isIcon),
      child: Consumer<UserImageModel>(
        builder: (context, model, child) {
          return Scaffold(
            body: model.isLoading
                ? Container(
                    color: Colors.grey.withOpacity(0.8),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Stack(
                    children: [
                      Container(
                        child: this.isIcon
                            ? _iconImage(model.url, context)
                            : _backgroundImage(model.url, context),
                      ),
                      SafeArea(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(2, 40, 2, 0),
                          child: _appBar(model, context),
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  /// AppBar
  Widget _appBar(UserImageModel model, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.clear,
            color: Colors.white,
          ),
        ),
        Container(
          // 自分のプロフィールの場合は編集ボタンを設置
          child: this.isMe
              ? GestureDetector(
                  onTap: () async {
                    if (this.isIcon) {
                      await model.showImagePickerIcon();
                    } else {
                      await model.showImagePickerBackground();
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 15, top: 5),
                    height: 35,
                    decoration: BoxDecoration(
                      // color: Colors.lightBlue,
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      margin: EdgeInsets.only(right: 10, left: 10),
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          Icon(
                            Icons.photo_camera_outlined,
                            color: Colors.white,
                          ),
                          Text(
                            ' 編集',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : Container(
                  child: null,
                  height: 1,
                ),
        ),
      ],
    );
  }

  /// IconImage
  Widget _iconImage(String url, BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.black,
          child: Center(
            child: Container(
              height: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white,
                image: DecorationImage(
                  image: NetworkImage(url),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// BackgroundImage
  Widget _backgroundImage(String url, BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(url),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }
}
