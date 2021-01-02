import 'package:chat_app/domain/chatRoomInfo.dart';
import 'package:chat_app/presentation/talk/talk_page.dart';
import 'package:chat_app/presentation/talk_list/talk_list_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TalkListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TalkListModel>(
      create: (_) => TalkListModel(),
      child: Scaffold(
        body: Container(
          color: Colors.white10,
          child: Consumer<TalkListModel>(
            builder: (context, model, child) {
              return model.isLoading
                  ? Container(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : ListView.builder(
                      itemCount: model.chatRoomInfoList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final ChatRoomInfo chatRoomInfo =
                            model.chatRoomInfoList[index];
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () async {
                            // トーク画面に遷移
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TalkPage(chatRoomInfo),
                              ),
                            );
                          },
                          child: Container(
                            height: 100,
                            padding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    // アイコン
                                    Container(
                                      padding: EdgeInsets.all(2),
                                      width: 75,
                                      // color: Colors.yellow,
                                      child: ClipOval(
                                        child: Container(
                                          width: 75,
                                          height: 75,
                                          color: Colors.white,
                                          child: chatRoomInfo.imageURL != null
                                              ? Image.network(
                                                  chatRoomInfo.imageURL,
                                                  width: 75,
                                                  height: 75,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context,
                                                      object, stackTrace) {
                                                    return Icon(
                                                        Icons.account_circle,
                                                        size: 75);
                                                  },
                                                )
                                              : Icon(Icons.account_circle,
                                                  size: 75),
                                        ),
                                      ),
                                    ),
                                    // 名前 ＋ メッセージ
                                    Container(
                                      // color: Colors.red,
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      padding: EdgeInsets.only(
                                        left: 10,
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              chatRoomInfo.roomName != null
                                                  ? chatRoomInfo.roomName
                                                  : '',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              chatRoomInfo.resentMessage,
                                              style: TextStyle(
                                                fontSize: 13,
                                                // color: Colors.black54,
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
                                Container(
                                  // color: Colors.green,
                                  height: 100,
                                  padding: EdgeInsets.all(2),
                                  width:
                                      MediaQuery.of(context).size.width * 0.2,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 20,
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          _fromAtNow(chatRoomInfo.updateAt),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w300,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.centerRight,
                                        height: 50,
                                        child: chatRoomInfo.unread != 0
                                            ? Container(
                                                width: 40,
                                                height: 40,
                                                child: ClipOval(
                                                  child: Container(
                                                    color: Colors.blue,
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      chatRoomInfo.unread > 999
                                                          ? '999+'
                                                          : chatRoomInfo.unread
                                                              .toInt()
                                                              .toString(),
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 13,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : null,
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
      ),
    );
  }

  String _fromAtNow(DateTime date) {
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
