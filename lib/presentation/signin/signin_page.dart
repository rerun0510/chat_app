import 'package:chat_app/presentation/bottom_navigation/bottom_navigation_page.dart';
import 'package:chat_app/presentation/signin/signin_model.dart';
import 'package:chat_app/presentation/signup/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatelessWidget {
  bool debug = false;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SignInModel>(
      create: (_) => SignInModel(),
      child: Scaffold(
        body: Consumer<SignInModel>(
          builder: (context, model, child) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // mainAxisAlignment: MainAxisAlignment.center,
                  Container(
                    color: Colors.red,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.70,
                    ),
                  ),
                  RaisedButton(
                    child: Text('Googleアカウントでログイン'),
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    onPressed: () async {
                      await model.signInWithGoogle();
                      await accountCheck(model, context);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future accountCheck(SignInModel model, BuildContext context) async {
    try {
      if (model.users == null) {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SignUpPage(
              currentUser: model.currentUser,
            ),
          ),
        );
      } else {
        if (debug) {
          await Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SignUpPage(
                currentUser: model.currentUser,
              ),
            ),
          );
        } else {
          await Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BottomNavigationPage(
                users: model.users,
              ),
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
