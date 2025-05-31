import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:restron1/auth/accountType.dart';
import 'package:restron1/auth/cPassword.dart';
import 'package:restron1/auth/changePassword.dart';
import 'package:restron1/auth/login.dart';
import 'package:restron1/auth/request.dart';
import 'package:restron1/auth/signup.dart';
import 'package:restron1/edit/editMenu.dart';
import 'package:restron1/edit/editTables.dart';
import 'package:restron1/edit/employees.dart';
import 'package:restron1/home.dart';
import 'package:restron1/auth/emailConfirmation.dart';
import 'package:restron1/makeOrder/sMeals.dart';
import 'package:restron1/makeOrder/sTable.dart';
import 'package:restron1/settings/menu.dart';
import 'package:restron1/splashPage.dart';
import 'package:restron1/settings/statistics.dart';
import 'package:restron1/tables.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage messageId) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // ignore: unused_label
  options:
  FirebaseOptions(
      apiKey: dotenv.env['apiKey']!,
      appId: dotenv.env['appId']!,
      messagingSenderId: dotenv.env['messagingSenderId']!,
      projectId: dotenv.env['projectId']!);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('................User is currently signed out!');
      } else {
        print('.................User is signed in!');
      }
    });
    super.initState();
  }

  User? user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: Color.fromARGB(255, 194, 133, 64),
          primaryColorDark: Color.fromARGB(255, 66, 77, 34),
          primaryColorLight: Color.fromARGB(255, 236, 232, 202),
          cardColor: Colors.white,
          shadowColor: Color.fromARGB(65, 194, 133, 64),
          indicatorColor: Color.fromARGB(0, 255, 255, 255),
          textSelectionTheme: const TextSelectionThemeData(
              selectionHandleColor: Color.fromARGB(255, 194, 133, 64))),
      home: FirebaseAuth.instance.currentUser == null ? Login() : Splash(),
      routes: {
        "signup": (context) => Signup(),
        "login": (context) => Login(),
        "home": (context) => Home(),
        "emailConfi": (context) => Confi(),
        "accountType": (context) => Accounttype(),
        "request": (context) => Request(),
        "splash": (context) => Splash(),
        "forgotPassword": (context) => Password(),
        "tables": (context) => Tables(),
        "selectTable": (context) => SelectTable(),
        "selectMeals": (context) => SelectMeals(),
        "editTables": (context) => EditTables(),
        "editMenu": (context) => EditMenu(),
        "employees": (context) => Employees(),
        "statistics": (context) => Statistics(),
        "changePassword": (context) => ChangePassword(),
        "menu": (context) => Menu()
      },
    );
  }
}
