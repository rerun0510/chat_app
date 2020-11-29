import 'package:chat_app/domain/chatRoomInfo.dart';
import 'package:chat_app/domain/users.dart';
import 'package:chat_app/presentation/talk/talk_page.dart';
import 'package:chat_app/presentation/talk_list/talk_list_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TalkListPage extends StatelessWidget {
  TalkListPage({this.users});
  final Users users;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TalkListModel>(
      create: (_) => TalkListModel()..fetchTalkList(users.userId),
      child: Scaffold(
        appBar: AppBar(
          title: Text('トーク'),
        ),
        body: Consumer<TalkListModel>(
          builder: (context, model, child) {
            return ListView.builder(
              itemCount: model.chatRoomInfoList.length,
              itemBuilder: (BuildContext context, int index) {
                final ChatRoomInfo chatRoomInfo = model.chatRoomInfoList[index];
                return GestureDetector(
                  onTap: () async {
                    // トーク画面に遷移
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TalkPage(chatRoomInfo: chatRoomInfo, users: users),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2),
                          decoration: chatRoomInfo.unread
                              ? BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(40)),
                                  border: Border.all(
                                    width: 2,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                    ),
                                  ],
                                )
                              : BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                          child: CircleAvatar(
                            radius: 35,
                            backgroundImage: NetworkImage(
                              chatRoomInfo.imageURL,
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.65,
                          padding: EdgeInsets.only(
                            left: 20,
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    chatRoomInfo.roomName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    fromAtNow(chatRoomInfo.updateAt),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  chatRoomInfo.resentMessage,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String fromAtNow(DateTime date) {
    final Duration difference = DateTime.now().difference(date);
    final int sec = difference.inSeconds;
    final String thisYear = DateFormat('yyyy').format(DateTime.now());
    final String year = DateFormat('yyyy').format(date);

    if (thisYear != year) {
      return DateFormat('yyyy/MM/dd').format(date);
    } else if (sec >= 60 * 60 * 24 * 7) {
      return DateFormat('MM/dd').format(date);
    } else if (sec >= 60 * 60 * 24) {
      return DateFormat('E').format(date);
    } else {
      return DateFormat('HH:mm').format(date);
    }
  }
}
