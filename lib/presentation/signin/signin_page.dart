import 'package:chat_app/presentation/bottom_navigation/bottom_navigation_page.dart';
import 'package:chat_app/presentation/signin/signin_model.dart';
import 'package:chat_app/presentation/signup/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatelessWidget {
  final bool debug = false;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SignInModel>(
      create: (_) => SignInModel(),
      child: Scaffold(
        body: Consumer<SignInModel>(
          builder: (context, model, child) {
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 180,
                        ),
                        Container(
                          width: 150,
                          height: 150,
                          padding: const EdgeInsets.all(20),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            clipBehavior: Clip.hardEdge,
                            child: Image.asset('resources/img_app_icon.jpeg'),
                          ),
                        ),
                        Container(
                          child: Text(
                            'Simple Chatへようこそ',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 30,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 50,
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
                  ),
                ),
                Container(
                    child: model.isLoading
                        ? Container(
                            color: Colors.grey.withOpacity(0.8),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : null)
              ],
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
              builder: (context) => BottomNavigationPage(),
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
