import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Password extends StatefulWidget {
  const Password({super.key});
  @override
  State<Password> createState() => _PasswordState();
}

class _PasswordState extends State<Password> {
  TextEditingController Email = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Theme.of(context).primaryColorLight,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios),
            color: Theme.of(context).primaryColor,
          )),
      body: Container(
          padding: const EdgeInsets.all(25),
          color: Theme.of(context).primaryColorLight,
          child: Center(
            child: Column(
              children: [
                Container(
                  height: 50,
                ),
                Text(
                  'Change Password ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Container(
                  height: 15,
                ),
                RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).primaryColorDark,
                        ),
                        children: const [
                          TextSpan(
                              text:
                                  'We will send you email to change your password ',
                              style: TextStyle(height: 1.5)),
                          TextSpan(
                              text:
                                  'enter your email,than you can check your inbox',
                              style: TextStyle(height: 1.5)),
                        ])),
                Container(
                  height: 50,
                ),
                TextFormField(
                  controller: Email,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    hintStyle: TextStyle(
                        fontSize: 16, color: Color.fromARGB(55, 0, 0, 0)),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(35)),
                        borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 194, 133, 64), width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(35)),
                    ),
                    filled: true,
                    fillColor: Color.fromARGB(255, 255, 253, 245),
                    prefixIcon: Icon(
                        size: 20.0,
                        Icons.email,
                        color: Color.fromARGB(255, 194, 133, 64)),
                  ),
                  cursorColor: Theme.of(context).primaryColor,
                  cursorErrorColor: Theme.of(context).primaryColor,
                  keyboardType: TextInputType.emailAddress,
                ),
                Container(
                  height: 335,
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: FloatingActionButton(
                        backgroundColor: Theme.of(context).primaryColor,
                        onPressed: () async {
                          if (Email.text == "") {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.warning,
                              dialogBackgroundColor:
                                  Color.fromARGB(255, 255, 253, 245),
                              animType: AnimType.rightSlide,
                              title: 'Warning',
                              titleTextStyle: TextStyle(
                                color: Theme.of(context).primaryColorDark,
                                fontSize: 20,
                              ),
                              desc: 'enter your Email',
                              descTextStyle: TextStyle(
                                  color: Theme.of(context).primaryColorDark),
                              btnCancelOnPress: () {},
                              btnCancelColor: Theme.of(context).primaryColor,
                            ).show();
                          } else {
                            try {
                              await FirebaseAuth.instance
                                  .sendPasswordResetEmail(email: Email.text);
                              Navigator.of(context)
                                  .pushReplacementNamed("login");
                            } catch (e) {
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.warning,
                                dialogBackgroundColor:
                                    Color.fromARGB(255, 255, 253, 245),
                                animType: AnimType.rightSlide,
                                title: 'Warning',
                                titleTextStyle: const TextStyle(
                                  color: Color.fromARGB(255, 66, 77, 34),
                                  fontSize: 20,
                                ),
                                desc: "Invalid or unregistered email",
                                descTextStyle: const TextStyle(
                                    color: Color.fromARGB(255, 66, 77, 34)),
                                btnCancelOnPress: () {},
                                btnCancelColor:
                                    const Color.fromARGB(255, 194, 133, 64),
                              ).show();
                            }
                          }
                        },
                        child: Text(
                          'Send',
                          style: TextStyle(
                              color: Theme.of(context).primaryColorLight),
                        ),
                      )),
                )
              ],
            ),
          )),
    );
  }
}
