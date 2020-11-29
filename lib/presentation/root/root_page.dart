import 'package:chat_app/presentation/bottom_navigation/bottom_navigation_page.dart';
import 'package:chat_app/presentation/root/root_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class RootPage extends StatelessWidget {
  bool debug = false;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RootModel>(
      create: (_) => RootModel()..getUser(),
      child: Stack(
        children: [
          Scaffold(
            body: Consumer<RootModel>(
              builder: (context, model, child) {
                loginCheck(model, context);
                return Center(
                  child: Container(
                    child: Text('Loading...'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future loginCheck(RootModel model, BuildContext context) async {
    try {
      if (model.user == null) {
        await Navigator.pushReplacementNamed(
          context,
          '/login',
        );
      } else {
        await model.fetchUsers();
        if (debug) {
          await Navigator.pushReplacementNamed(
            context,
            '/login',
          );
        } else {
          await Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BottomNavigationPage(users: model.users),
            ),
          );
        }
      }
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
}
