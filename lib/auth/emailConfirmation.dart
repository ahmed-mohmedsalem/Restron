import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Confi extends StatefulWidget {
  const Confi({super.key});
  @override
  State<Confi> createState() => _ConfiState();
}

class _ConfiState extends State<Confi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              'Email verification',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          elevation: 0.0,
          backgroundColor: Theme.of(context).primaryColorDark,
        ),
        body: Container(
          color: Theme.of(context).primaryColorLight,
          child: Column(
            children: [
              Container(
                height: 80,
              ),
              RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).primaryColorDark,
                      ),
                      children: [
                        const TextSpan(
                            text: 'We send verification link to your email ',
                            style: TextStyle(height: 1.5)),
                        TextSpan(
                            text: 'moha*****@gmail.com ',
                            style: TextStyle(
                                fontSize: 20,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                                height: 1.5)),
                        const TextSpan(
                            text: ',you can check your inbox than click next',
                            style: TextStyle(height: 1.5)),
                      ])),
              Container(
                height: 80,
              ),
              InkWell(
                onTap: () {
                  FirebaseAuth.instance.currentUser!.sendEmailVerification();
                },
                child: const Center(
                  child: Text.rich(TextSpan(children: [
                    TextSpan(
                      text: "I  didn't received the code?",
                      style: TextStyle(
                          color: Color.fromARGB(255, 66, 77, 34),
                          fontSize: 16,
                          fontWeight: FontWeight.w400),
                    ),
                    TextSpan(
                      text: " Send again",
                      style: TextStyle(
                          color: Color.fromARGB(255, 194, 133, 64),
                          fontSize: 16,
                          fontWeight: FontWeight.w400),
                    )
                  ])),
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: FloatingActionButton(
                      backgroundColor: Theme.of(context).primaryColor,
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed("login");
                      },
                      child: Text(
                        'Next',
                        style: TextStyle(
                            color: Theme.of(context).primaryColorLight),
                      ),
                    )),
              )
            ],
          ),
        ));
  }
}
