import 'package:chat_app/domain/chatRoom.dart';
import 'package:chat_app/domain/chatRoomInfo.dart';
import 'package:chat_app/domain/messages.dart';
import 'package:chat_app/domain/users.dart';
import 'package:chat_app/presentation/talk/talk_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TalkPage extends StatelessWidget {
  TalkPage({this.chatRoomInfo, this.users});

  final ChatRoomInfo chatRoomInfo;
  final Users users;
  final messageAreaController = TextEditingController();

  GlobalKey globalKey = GlobalKey();

  _chatBubble(TalkModel model, Messages messages, BuildContext context,
      bool isMe, bool isSameUser, bool isAnotherDay) {
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
                              ]),
                          child: Text(
                            fromAtNow(messages.createdAt),
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
                  GestureDetector(
                    onLongPress: () async {
                      // RenderBox box =
                      //     globalKey.currentContext.findRenderObject();
                      // print("ウィジェットのサイズ :${box.size}");
                      // print("ウィジェットの位置 :${box.localToGlobal(Offset.zero)}");
                      int selected = await showMenu(
                        position:
                            RelativeRect.fromLTRB(60.0, 40.0, 100.0, 100.0),
                        context: context,
                        items: [
                          PopupMenuItem(
                            value: 0,
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                Text('編集'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 1,
                            child: Row(
                              children: [
                                Icon(Icons.delete),
                                Text('削除'),
                              ],
                            ),
                          ),
                        ],
                      );
                      if (selected == 0) {
                        await updateMessage(messages, model, context);
                      } else if (selected == 1) {
                        await deleteMessage(messages, model, context);
                      }
                    },
                    child: Container(
                      alignment: Alignment.topRight,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.80,
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
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    } else {
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
                            fromAtNow(messages.createdAt),
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
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.80,
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
                          color: Colors.black54,
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
              !isSameUser
                  ? Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                blurRadius: 5,
                              )
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 15,
                            backgroundImage: NetworkImage(
                              'https://lh3.googleusercontent.com/a-/AOh14GiuniKkAaWf6ljNRUQD6Wszn8MVEznIOA-e26n9jg=s88-c-k-c0x00ffffff-no-rj-mo',
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          // message.createdAt.toString(),
                          'ユーザーネーム',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black45,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : Container(
                      child: null,
                    ),
            ],
          ),
        ],
      );
    }
  }

  _sendMessageArea(TalkModel model, BuildContext context) {
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
                await sendMessage(model, context);
                messageAreaController.clear();
                model.setMessage('');
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String prevUserId;
    String prevDate;
    return ChangeNotifierProvider<TalkModel>(
      create: (_) => TalkModel()..fetchMessages(chatRoomInfo),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(chatRoomInfo.roomName),
        ),
        body: Consumer<TalkModel>(
          builder: (context, model, child) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    // reverse: true,
                    padding: EdgeInsets.all(20),
                    itemCount: model.messages.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Messages messages = model.messages[index];
                      final bool isMe =
                          model.messages[index].userId == users.userId;
                      final bool isSameUser =
                          prevUserId == model.messages[index].userId;
                      prevUserId = model.messages[index].userId;

                      final String date = DateFormat('yyyy/MM/dd')
                          .format(model.messages[index].createdAt);
                      final bool isAnotherDay = date != prevDate;
                      prevDate = date;

                      return _chatBubble(model, messages, context, isMe,
                          isSameUser, isAnotherDay);
                    },
                  ),
                ),
                _sendMessageArea(model, context),
              ],
            );
          },
        ),
      ),
    );
  }

  Future sendMessage(TalkModel model, BuildContext context) async {
    try {
      await model.sendMessage(chatRoomInfo.roomId, users.userId);
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

  Future updateMessage(
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

  Future deleteMessage(
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

  String fromAtNow(DateTime date) {
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
}
