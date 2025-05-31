import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});
  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController UserName = TextEditingController();
  TextEditingController Email = TextEditingController();
  TextEditingController Password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColorDark,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Theme.of(context).primaryColorDark,
        ),
        body: Column(
          children: [
            Container(
                alignment: Alignment.center,
                height: 110.0,
                color: Theme.of(context).primaryColorDark,
                child: Row(
                  verticalDirection: VerticalDirection.up,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Res",
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 40.0,
                          fontFamily: "Caprasimo"),
                    ),
                    Text(
                      "tron",
                      style: TextStyle(
                          color: Theme.of(context).primaryColorLight,
                          fontSize: 40.0,
                          fontFamily: "Caprasimo"),
                    )
                  ],
                )),
            Expanded(
                child: Container(
              padding: const EdgeInsets.all(30),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorLight,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60)),
              ),
              child: SingleChildScrollView(
                  child: Column(
                children: [
                  Container(
                    height: 30.0,
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      "Sign up",
                      style: TextStyle(
                          fontFamily: "Caprasimo",
                          fontSize: 18.0,
                          color: Theme.of(context).primaryColor),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Container(
                    height: 25.0,
                  ),
                  Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.always,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: UserName,
                            decoration: const InputDecoration(
                              hintText: 'UserName',
                              hintStyle: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(55, 0, 0, 0)),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(35)),
                                  borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 194, 133, 64),
                                    width: 1),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(35)),
                              ),
                              filled: true,
                              fillColor: Color.fromARGB(255, 255, 253, 245),
                              prefixIcon: Icon(
                                  size: 20.0,
                                  Icons.person,
                                  color: Color.fromARGB(255, 194, 133, 64)),
                            ),
                            cursorColor: Theme.of(context).primaryColor,
                            cursorErrorColor: Theme.of(context).primaryColor,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          Container(
                            height: 20.0,
                          ),
                          TextFormField(
                            controller: Email,
                            decoration: const InputDecoration(
                              hintText: 'Email',
                              hintStyle: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(55, 0, 0, 0)),
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(35)),
                                  borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 194, 133, 64),
                                    width: 1),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(35)),
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
                            height: 20.0,
                          ),
                          TextFormField(
                            controller: Password,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              hintStyle: const TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(55, 0, 0, 0)),
                              border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(35)),
                                  borderSide: BorderSide.none),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 194, 133, 64),
                                    width: 1),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(35)),
                              ),
                              filled: true,
                              fillColor:
                                  const Color.fromARGB(255, 255, 253, 245),
                              prefixIcon: const Icon(Icons.lock,
                                  size: 20.0,
                                  color: Color.fromARGB(255, 194, 133, 64)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? Icons.remove_red_eye
                                      : Icons.visibility_off,
                                  size: 20.0,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                              ),
                            ),
                            cursorColor: Theme.of(context).primaryColor,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          Container(
                            height: 20.0,
                          ),
                          TextFormField(
                            controller: confirmPassword,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              hintText: 'Confirm Password',
                              hintStyle: const TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(55, 0, 0, 0)),
                              border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(35)),
                                  borderSide: BorderSide.none),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 194, 133, 64),
                                    width: 1),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(35)),
                              ),
                              filled: true,
                              fillColor:
                                  const Color.fromARGB(255, 255, 253, 245),
                              prefixIcon: const Icon(Icons.lock,
                                  size: 20.0,
                                  color: Color.fromARGB(255, 194, 133, 64)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? Icons.remove_red_eye
                                      : Icons.visibility_off,
                                  size: 20.0,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                              ),
                            ),
                            cursorColor: Theme.of(context).primaryColor,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          Container(
                            height: 35.0,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                minimumSize: const Size(350, 55)),
                            child: Text(
                              "Sign up",
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorLight,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900),
                            ),
                            onPressed: () async {
                              if (Password.text == confirmPassword.text) {
                                try {
                                  final credential = await FirebaseAuth.instance
                                      .createUserWithEmailAndPassword(
                                    email: Email.text,
                                    password: Password.text,
                                  );
                                  User? user = credential.user;
                                  await user?.updateDisplayName(UserName.text);
                                  FirebaseAuth.instance.currentUser!
                                      .sendEmailVerification();
                                  Navigator.of(context)
                                      .pushReplacementNamed("emailConfi");
                                } on FirebaseAuthException catch (e) {
                                  if (e.code == 'weak-password') {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.warning,
                                      dialogBackgroundColor:
                                          const Color.fromARGB(
                                              255, 255, 253, 245),
                                      animType: AnimType.rightSlide,
                                      title: 'warning',
                                      titleTextStyle: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        fontSize: 20,
                                      ),
                                      desc:
                                          'The password provided is too weak.',
                                      descTextStyle: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorDark),
                                      btnOkOnPress: () {},
                                      btnOkColor:
                                          Theme.of(context).primaryColor,
                                    ).show();
                                  } else if (e.code == 'email-already-in-use') {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.warning,
                                      dialogBackgroundColor:
                                          Color.fromARGB(255, 255, 253, 245),
                                      animType: AnimType.rightSlide,
                                      title: 'warning',
                                      titleTextStyle: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        fontSize: 20,
                                      ),
                                      desc:
                                          'The account already exists for that email.',
                                      descTextStyle: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorDark),
                                      btnOkOnPress: () {},
                                      btnOkColor:
                                          Theme.of(context).primaryColor,
                                    ).show();
                                  }
                                } catch (e) {
                                  print(e);
                                }
                              } else {
                                AwesomeDialog(
                                  context: context,
                                  dialogType: DialogType.error,
                                  dialogBackgroundColor:
                                      const Color.fromARGB(255, 255, 253, 245),
                                  animType: AnimType.rightSlide,
                                  title: 'Error',
                                  titleTextStyle: TextStyle(
                                    color: Theme.of(context).primaryColorDark,
                                    fontSize: 20,
                                  ),
                                  desc: 'The password dont match',
                                  descTextStyle: TextStyle(
                                      color:
                                          Theme.of(context).primaryColorDark),
                                  btnOkOnPress: () {},
                                  btnOkColor: Theme.of(context).primaryColor,
                                ).show();
                              }
                            },
                          ),
                          Container(
                            height: 80.0,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.of(context)
                                  .pushReplacementNamed("login");
                            },
                            child: const Center(
                              child: Text.rich(TextSpan(children: [
                                TextSpan(
                                  text: "Already have an account",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 66, 77, 34),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400),
                                ),
                                TextSpan(
                                  text: " Login",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 194, 133, 64),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400),
                                )
                              ])),
                            ),
                          )
                        ],
                      ))
                ],
              )),
            ))
          ],
        ),
      ),
    );
  }
}
