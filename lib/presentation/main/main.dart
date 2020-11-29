import 'package:chat_app/presentation/bottom_navigation/bottom_navigation_page.dart';
import 'package:chat_app/presentation/main/main_bak.dart';
import 'package:chat_app/presentation/main/main_model.dart';
import 'package:chat_app/presentation/root/root_page.dart';
import 'package:chat_app/presentation/signin/signin_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MainModel>(
      create: (_) => MainModel(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: RootPage(),
        routes: <String, WidgetBuilder>{
          // '/login': (BuildContext context) => SignUpPage(),
          '/login': (BuildContext context) => SignInPage(),
          '/home': (BuildContext context) => BottomNavigationPage(),
        },
      ),
    );
  }
}
