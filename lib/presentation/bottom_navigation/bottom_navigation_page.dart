import 'package:chat_app/domain/users.dart';
import 'package:chat_app/presentation/bottom_navigation/bottom_navigation_model.dart';
import 'package:chat_app/presentation/home/home_page.dart';
import 'package:chat_app/presentation/talk_list/talk_list_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomNavigationPage extends StatelessWidget {
  List<Widget> _pageList = <Widget>[
    TalkListPage(),
    HomePage(),
  ];

  BottomNavigationPage({this.users});
  final Users users;
  @override
  Widget build(BuildContext context) {
    _pageList[0] = HomePage(users: users);
    _pageList[1] = TalkListPage(users: users);
    return ChangeNotifierProvider<BottomNavigationModel>(
      create: (_) => BottomNavigationModel()..init(),
      child: Consumer<BottomNavigationModel>(builder: (context, model, child) {
        return Scaffold(
          // appBar: AppBar(
          //   title: Text(''),
          // ),
          // body: _pageList[model.currentIndex],
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
                icon: Icon(Icons.textsms_outlined),
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
        _tabPage(currentIndex, 0, HomePage(users: users)),
        _tabPage(currentIndex, 1, TalkListPage(users: users)),
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
}
