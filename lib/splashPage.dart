import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  User? user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await FirebaseAuth.instance.currentUser?.reload();
      if (!FirebaseAuth.instance.currentUser!.emailVerified) {
        Navigator.of(context).pushReplacementNamed("confi");
        return;
      } else {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          DocumentSnapshot doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get() as DocumentSnapshot<Object?>;
          if (doc.exists) {
            var userData = doc.data() as Map<String, dynamic>;
            if (userData['accounttype'] == null) {
              Navigator.of(context).pushReplacementNamed("accountType");
              return;
            } else {
              if (userData['accounttype'] == '') {
                Navigator.of(context).pushReplacementNamed("request");
                return;
              } else {
                Navigator.of(context).pushReplacementNamed("home");
              }
            }
          } else {
            Navigator.of(context).pushReplacementNamed("accountType");
            return;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).primaryColorDark,
          backgroundColor: Theme.of(context).primaryColorLight,
        ),
      ),
    );
  }
}
