import 'package:chat_app/domain/users.dart';
import 'package:chat_app/presentation/home/home_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  HomePage({this.users});
  final Users users;
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeModel>(
      create: (_) => HomeModel()..fetchHomeInfo(users),
      child: Scaffold(
        appBar: AppBar(
          title: Text('ホーム'),
        ),
        body: Consumer<HomeModel>(
          builder: (context, model, child) {
            return Center(
              child: Column(
                children: [
                  Text(users.name),
                  Text(users.userId),
                  Text(model.groupsList.length != 0
                      ? model.groupsList[0].groupName
                      : ''),
                  Text(model.usersList.length != 0
                      ? model.usersList[0].name
                      : ''),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
