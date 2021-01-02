import 'package:chat_app/presentation/bottom_navigation/bottom_navigation_model.dart';
import 'package:chat_app/presentation/home/home_page.dart';
import 'package:chat_app/presentation/home/home_page_appBar.dart';
import 'package:chat_app/presentation/talk_list/talk_list_page.dart';
import 'package:chat_app/presentation/talk_list/talk_list_page_appBar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomNavigationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BottomNavigationModel>(
      create: (_) => BottomNavigationModel(),
      child: Consumer<BottomNavigationModel>(builder: (context, model, child) {
        return Scaffold(
          appBar: _topPageAppBar(context),
          body: _topPageBody(context),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.white,
            currentIndex: model.currentIndex,
            onTap: (index) {
              model.currentIndex = index;
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'HOME',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 40,
                      child: Icon(Icons.textsms_outlined),
                    ),
                    Positioned(
                      right: 5,
                      top: 2,
                      child: Container(
                        child: model.talkNotification != 0
                            ? Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 20,
                                  minHeight: 20,
                                ),
                                child: Text(
                                  model.talkNotification > 999
                                      ? '999+'
                                      : model.talkNotification.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
                label: 'TALK',
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _topPageBody(BuildContext context) {
    final model = Provider.of<BottomNavigationModel>(context);
    final currentIndex = model.currentIndex;
    return Stack(
      children: [
        _tabPage(currentIndex, 0, HomePage()),
        _tabPage(currentIndex, 1, TalkListPage()),
      ],
    );
  }

  Widget _tabPage(int currentIndex, int tabIndex, StatelessWidget page) {
    return Visibility(
      visible: currentIndex == tabIndex,
      maintainState: true,
      child: page,
    );
  }

  AppBar _topPageAppBar(BuildContext context) {
    final model = Provider.of<BottomNavigationModel>(context);
    final currentIndex = model.currentIndex;
    AppBar appBar;
    switch (currentIndex) {
      case 0:
        appBar = HomePageAppBar().getAppBar(context);
        break;
      case 1:
        appBar = TalkListPageAppBar().getAppBar();
        break;
    }
    return appBar;
  }
}
