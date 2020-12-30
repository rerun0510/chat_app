import 'package:chat_app/domain/chatRoomInfo.dart';
import 'package:chat_app/domain/messages.dart';
import 'package:chat_app/domain/myFriends.dart';
import 'package:chat_app/domain/users.dart';
import 'package:chat_app/presentation/talk/talk_model.dart';
import 'package:chat_app/presentation/user/user_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TalkPage extends StatelessWidget {
  TalkPage(this.chatRoomInfo);
  final ChatRoomInfo chatRoomInfo;
  final messageAreaController = TextEditingController();
  final GlobalKey globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    bool isSameUser;
    bool isAnotherDay;
    bool isAnotherTime;
    return ChangeNotifierProvider<TalkModel>(
      create: (_) => TalkModel(chatRoomInfo),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: Text(chatRoomInfo.roomName),
          ),
          body: Container(
            color: Colors.white10,
            child: Consumer<TalkModel>(
              builder: (context, model, child) {
                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        reverse: true,
                        padding: EdgeInsets.all(20),
                        itemCount: model.messages.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Messages messages = model.messages[index];

                          final bool isMe = model.messages[index].userId ==
                              model.currentUser.userId;

                          if (index < model.messages.length - 1) {
                            // 次のデータと比較する
                            isSameUser = messages.userId ==
                                model.messages[index + 1].userId;
                            isAnotherDay = DateFormat('yyyy/MM/dd')
                                    .format(messages.createdAt) !=
                                DateFormat('yyyy/MM/dd').format(
                                    model.messages[index + 1].createdAt);
                            isAnotherTime = DateFormat('HH:mm')
                                    .format(messages.createdAt) !=
                                DateFormat('HH:mm').format(
                                    model.messages[index + 1].createdAt);
                            if (isAnotherTime) {
                              // 日付を跨いで連投した場合はアイコンを再表示
                              isSameUser = false;
                            }
                          } else {
                            // 次のデータが存在しない場合
                            isSameUser = false;
                            isAnotherDay = true;
                            isAnotherTime = true;
                          }

                          return _chatBubble(model, messages, context, isMe,
                              isSameUser, isAnotherDay, index);
                        },
                      ),
                    ),
                    _sendMessageArea(model, context),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// チャットバブル
  Widget _chatBubble(TalkModel model, Messages messages, BuildContext context,
      bool isMe, bool isSameUser, bool isAnotherDay, int index) {
    if (isMe) {
      return Column(
        children: [
          Column(
            children: [
              Container(
                child: isAnotherDay
                    ? Container(
                        alignment: Alignment.topCenter,
                        child: Container(
                          padding: EdgeInsets.fromLTRB(10, 3, 10, 3),
                          margin: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 2,
                              )
                            ],
                          ),
                          child: Text(
                            _fromAtNow(messages.createdAt),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    : null,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.all(6),
                    child: Text(
                      DateFormat('HH:mm').format(messages.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ),
                  // GestureDetector(
                  // behavior: HitTestBehavior.opaque,
                  //   onLongPress: () async {
                  //     // RenderBox box =
                  //     //     globalKey.currentContext.findRenderObject();
                  //     // print("ウィジェットのサイズ :${box.size}");
                  //     // print("ウィジェットの位置 :${box.localToGlobal(Offset.zero)}");
                  //     int selected = await showMenu(
                  //       position:
                  //           RelativeRect.fromLTRB(60.0, 40.0, 100.0, 100.0),
                  //       context: context,
                  //       items: [
                  //         PopupMenuItem(
                  //           value: 0,
                  //           child: Row(
                  //             children: [
                  //               Icon(Icons.edit),
                  //               Text('編集'),
                  //             ],
                  //           ),
                  //         ),
                  //         PopupMenuItem(
                  //           value: 1,
                  //           child: Row(
                  //             children: [
                  //               Icon(Icons.delete),
                  //               Text('削除'),
                  //             ],
                  //           ),
                  //         ),
                  //       ],
                  //     );
                  //     if (selected == 0) {
                  //       await _updateMessage(messages, model, context);
                  //     } else if (selected == 1) {
                  //       await _deleteMessage(messages, model, context);
                  //     }
                  //   },
                  //   child: Container(
                  Container(
                    alignment: Alignment.topRight,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.70,
                      ),
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                            )
                          ]),
                      child: Text(
                        messages.message,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // ),
                ],
              ),
            ],
          ),
        ],
      );
    } else {
      final imageURL = _getUserImage(model.usersList, messages.userId);
      return Column(
        children: [
          Column(
            children: [
              Container(
                child: isAnotherDay
                    ? Container(
                        alignment: Alignment.topCenter,
                        child: Container(
                          padding: EdgeInsets.fromLTRB(10, 3, 10, 3),
                          margin: EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 2,
                                )
                              ]),
                          child: Text(
                            _fromAtNow(messages.createdAt),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    : null,
              ),
              !isSameUser
                  ? Row(
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () async {
                            // ユーザー画面に遷移
                            MyFriends myFriend =
                                await model.getUserPageInfo(messages.userId);
                            await showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) => UserPage(
                                null,
                                myFriend,
                                true,
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  blurRadius: 5,
                                )
                              ],
                            ),
                            child: ClipOval(
                              child: Container(
                                color: Colors.white,
                                child: imageURL != null
                                    ? Image.network(
                                        imageURL,
                                        width: 35,
                                        height: 35,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, object, stackTrace) {
                                          return Icon(Icons.account_circle,
                                              size: 35);
                                        },
                                      )
                                    : Icon(Icons.account_circle, size: 35),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          _getUserName(model.usersList, messages.userId),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : Container(
                      child: null,
                    ),
              Row(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.70,
                      ),
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                            )
                          ]),
                      child: Text(
                        messages.message,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(6),
                    child: Text(
                      DateFormat('HH:mm').format(messages.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    }
  }

  /// メッセージ入力ボックス
  Widget _sendMessageArea(TalkModel model, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      height: 70,
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.photo_camera_outlined),
            iconSize: 25,
            color: Theme.of(context).primaryColor,
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.insert_photo_outlined),
            iconSize: 25,
            color: Theme.of(context).primaryColor,
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              textInputAction: TextInputAction.newline,
              controller: messageAreaController,
              decoration: InputDecoration.collapsed(
                hintText: 'Send a message..',
              ),
              textCapitalization: TextCapitalization.sentences,
              onChanged: (text) {
                model.setMessage(text);
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            iconSize: 25,
            color: model.message.isNotEmpty
                ? Theme.of(context).primaryColor
                : Colors.grey,
            onPressed: () async {
              if (model.message.isNotEmpty) {
                messageAreaController.clear();
                await _sendMessage(model, context);
                model.setMessage('');
              }
            },
          ),
        ],
      ),
    );
  }

  /// メッセージ送信
  Future _sendMessage(TalkModel model, BuildContext context) async {
    try {
      await model.sendMessage(chatRoomInfo.roomId, model.currentUser.userId);
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(e.toString()),
            actions: [
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future _updateMessage(
      Messages messages, TalkModel model, BuildContext context) async {
    String updateMessage = messages.message;
    try {
      final messageEditingController =
          TextEditingController(text: updateMessage);
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text('メッセージを更新します。'),
            content: TextField(
              controller: messageEditingController,
              decoration: InputDecoration.collapsed(
                hintText: 'Send a message..',
              ),
              textCapitalization: TextCapitalization.sentences,
              onChanged: (text) {
                updateMessage = text;
                updateMessage.isEmpty
                    ? model.setUpdateFlg(false)
                    : model.setUpdateFlg(true);
              },
            ),
            actions: <Widget>[
              // ボタン領域
              FlatButton(
                child: Text("Cancel"),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text("OK"),
                onPressed: model.updateFlg
                    ? () async {
                        await model.updateMessage(
                            chatRoomInfo.roomId, messages, updateMessage);
                        Navigator.pop(context);
                      }
                    : null,
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(e.toString()),
            actions: [
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future _deleteMessage(
      Messages messages, TalkModel model, BuildContext context) async {
    try {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return AlertDialog(
            content: Text("メッセージを削除します。"),
            actions: <Widget>[
              // ボタン領域
              FlatButton(
                child: Text("Cancel"),
                onPressed: () async {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text("OK"),
                onPressed: () async {
                  await model.deleteMessage(chatRoomInfo.roomId, messages);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(e.toString()),
            actions: [
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  String _fromAtNow(DateTime date) {
    final Duration difference = DateTime.now().difference(date);
    final int sec = difference.inSeconds;
    final String thisYear = DateFormat('yyyy').format(DateTime.now());
    final String year = DateFormat('yyyy').format(date);

    if (sec >= 60 * 60 * 24) {
      if (difference.inDays == 1) {
        return '昨日';
      } else {
        if (thisYear != year) {
          return DateFormat('yyyy/MM/dd(E)').format(date);
        } else {
          return DateFormat('MM/dd(E)').format(date);
        }
      }
    } else {
      return '今日';
    }
  }

  String _getUserName(List<Users> usersList, String userId) {
    for (Users users in usersList) {
      if (users.userId == userId) {
        return users.name;
      }
    }
    return '';
  }

  String _getUserImage(List<Users> usersList, String userId) {
    for (Users users in usersList) {
      if (users.userId == userId) {
        return users.imageURL;
      }
    }
    return '';
  }
}
