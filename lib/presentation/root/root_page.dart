import 'package:chat_app/domain/users.dart';
import 'package:chat_app/presentation/bottom_navigation/bottom_navigation_page.dart';
import 'package:chat_app/presentation/root/root_model.dart';
import 'package:chat_app/presentation/signin/signin_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class RootPage extends StatelessWidget {
  final bool debug = false;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RootModel>(
      create: (_) => RootModel(),
      child: Stack(
        children: [
          Scaffold(
            body: Consumer<RootModel>(
              builder: (context, model, child) {
                // loginCheck(model, context);
                return model.isLoading
                    ? Container(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : _convertPage(model.currentUser);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _convertPage(Users currentUser) {
    if (currentUser == null) {
      return SignInPage();
    } else {
      if (debug) {
        return SignInPage();
      } else {
        return BottomNavigationPage();
      }
    }
  }
}
