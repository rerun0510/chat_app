import 'package:chat_app/presentation/bottom_navigation/bottom_navigation_page.dart';
import 'package:chat_app/presentation/signup/signup_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({this.currentUser});
  final User currentUser;
  @override
  Widget build(BuildContext context) {
    final textEditingController = TextEditingController();

    return ChangeNotifierProvider<SignUpModel>(
      create: (_) => SignUpModel(),
      child: Consumer<SignUpModel>(
        builder: (context, model, child) {
          return Stack(
            children: [
              Scaffold(
                body: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: SafeArea(
                    child: SingleChildScrollView(
                      reverse: true,
                      child: Container(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(35),
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    child: Text(
                                      'アカウントを新規登録',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 30,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    child: Text(
                                      'プロフィールに登録した名前と写真は、サービス上で公開されます。',
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 50,
                                  ),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () async {
                                      // todo 写真登録
                                      await model.showImagePicker();
                                    },
                                    child: Container(
                                      child: ClipOval(
                                        child: model.imageFile != null
                                            ? Image.file(
                                                model.imageFile,
                                                height: 180,
                                                width: 180,
                                              )
                                            : Icon(
                                                Icons.account_circle,
                                                size: 180,
                                              ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 50,
                                  ),
                                  TextField(
                                    controller: textEditingController,
                                    onChanged: (text) {
                                      model.name = text;
                                      model.checkSignUpBtn();
                                    },
                                  ),
                                  RaisedButton(
                                    child: Text('登録する'),
                                    onPressed: model.isSignUpFlg
                                        ? () async {
                                            model.startLoading();
                                            await model.signUp(currentUser);
                                            model.endLoading();
                                            await Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    BottomNavigationPage(),
                                              ),
                                            );
                                          }
                                        : null,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                child: model.isLoading
                    ? Container(
                        color: Colors.grey.withOpacity(0.7),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : null,
              ),
            ],
          );
        },
      ),
    );
  }
}
