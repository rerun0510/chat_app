import 'package:chat_app/presentation/bottom_navigation/bottom_navigation_page.dart';
import 'package:chat_app/presentation/signin/signin_model.dart';
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
      child: Stack(
        children: [
          Scaffold(
            body: Consumer<SignUpModel>(
              builder: (context, model, child) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Container(
                        // color: Colors.red,
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.10,
                        ),
                      ),
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
                              onTap: () async {
                                // todo 写真登録
                                await model.showImagePicker();
                              },
                              child: Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 2,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                    )
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 80,
                                  backgroundImage: model.imageFile != null
                                      ? FileImage(model.imageFile)
                                      : NetworkImage(
                                          'https://lh3.googleusercontent.com/a-/AOh14GiuniKkAaWf6ljNRUQD6Wszn8MVEznIOA-e26n9jg=s88-c-k-c0x00ffffff-no-rj-mo',
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
                              },
                            ),
                            RaisedButton(
                              child: Text('登録する'),
                              onPressed: () async {
                                model.startLoading();
                                await model.signUp(currentUser);
                                model.endLoading();
                                await Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BottomNavigationPage(
                                      model.users,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          Consumer<SignUpModel>(
            builder: (context, model, child) {
              return model.isLoading
                  ? Container(
                      color: Colors.grey.withOpacity(0.7),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
