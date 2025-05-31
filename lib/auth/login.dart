import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController Email = TextEditingController();
  TextEditingController Password = TextEditingController();
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
                    height: 50.0,
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      "Log in",
                      style: TextStyle(
                          fontFamily: "Caprasimo",
                          fontSize: 18.0,
                          color: Theme.of(context).primaryColor),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Container(
                    height: 30.0,
                  ),
                  Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.always,
                      child: Column(
                        children: [
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
                            height: 30.0,
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
                          InkWell(
                            onTap: () {
                              Navigator.of(context)
                                  .pushReplacementNamed("forgotPassword");
                            },
                            child: Container(
                              height: 50.0,
                              alignment: Alignment.topRight,
                              padding: const EdgeInsets.all(7),
                              child: Text.rich(TextSpan(children: [
                                TextSpan(
                                  text: "Forgot Password?",
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 14.0,
                                  ),
                                )
                              ])),
                            ),
                          ),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  minimumSize: const Size(350, 55)),
                              onPressed: () async {
                                try {
                                  final credential = await FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                          email: Email.text,
                                          password: Password.text);
                                  Navigator.of(context)
                                      .pushReplacementNamed("splash");
                                } on FirebaseAuthException catch (e) {
                                  if (e.code == 'user-not-found') {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.error,
                                      dialogBackgroundColor:
                                          Color.fromARGB(255, 255, 253, 245),
                                      animType: AnimType.rightSlide,
                                      title: 'Error',
                                      titleTextStyle: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        fontSize: 20,
                                      ),
                                      desc: 'No user found for that email.',
                                      descTextStyle: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                      ),
                                      btnCancelOnPress: () {},
                                      btnCancelColor:
                                          Theme.of(context).primaryColor,
                                    ).show();
                                  } else if (e.code == 'wrong-password') {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.error,
                                      dialogBackgroundColor:
                                          Color.fromARGB(255, 255, 253, 245),
                                      animType: AnimType.rightSlide,
                                      title: 'Error',
                                      titleTextStyle: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        fontSize: 20,
                                      ),
                                      desc:
                                          'Wrong password provided for that user',
                                      descTextStyle: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorDark),
                                      btnCancelOnPress: () {},
                                      btnCancelColor:
                                          Theme.of(context).primaryColor,
                                    ).show();
                                  } else {
                                    print(e.code);
                                  }
                                }
                              },
                              child: Text(
                                "Login",
                                style: TextStyle(
                                    color: Theme.of(context).primaryColorLight,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900),
                              )),
                          Container(
                            height: 80.0,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.of(context)
                                  .pushReplacementNamed("signup");
                            },
                            child: const Center(
                              child: Text.rich(TextSpan(children: [
                                TextSpan(
                                  text: "Dont have an account",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 66, 77, 34),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400),
                                ),
                                TextSpan(
                                  text: " Register",
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
// body: Container(
//           decoration:const BoxDecoration(
//           color: Color(0xFF5F6C37)
//         ),
//         child: ListView(children: [
//           Column(children: [
//             Container(height: 30),
//             Container(
//               alignment: Alignment.center,
//               padding:const EdgeInsets.all(10),
//               child: Image.asset(
//                 "images/logo.png",
//                 width: 150,
//                 height: 110,
//               ),
//             ),
//             Container(height: 20),
//             Container(
//               padding:const EdgeInsets.all(10),
//               height: 650,
//               width: double.infinity,
//               decoration:const BoxDecoration(
//               color: Color.fromARGB(255, 199, 204, 184),
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(60),
//                 topRight: Radius.circular(60)
//               ),
//               ),
//               child: const Column(children: [
//                 Text('Login'),
//               ],),
//             ),
            
//           ],),
//         ],),
//       ),