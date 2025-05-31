import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (newPasswordController.text != confirmPasswordController.text) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        dialogBackgroundColor: Color.fromARGB(255, 255, 253, 245),
        animType: AnimType.rightSlide,
        title: 'Error',
        titleTextStyle: TextStyle(
          color: Theme.of(context).primaryColorDark,
          fontSize: 20,
        ),
        desc: 'New password and confirmation do not match.',
        descTextStyle: TextStyle(
          color: Theme.of(context).primaryColorDark,
        ),
        btnCancelOnPress: () {},
        btnCancelColor: Theme.of(context).primaryColor,
      ).show();
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
            code: 'no-user', message: 'No user is currently signed in.');
      }

      // Re-authenticate user with old password
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPasswordController.text,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPasswordController.text);

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        dialogBackgroundColor: Color.fromARGB(255, 255, 253, 245),
        animType: AnimType.rightSlide,
        title: 'Success',
        titleTextStyle: TextStyle(
          color: Theme.of(context).primaryColorDark,
          fontSize: 20,
        ),
        desc: 'Password updated successfully.',
        descTextStyle: TextStyle(
          color: Theme.of(context).primaryColorDark,
        ),
        btnOkOnPress: () {
          Navigator.of(context).pop();
        },
        btnOkColor: Theme.of(context).primaryColor,
      ).show();
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect old password.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'The new password is too weak.';
      } else if (e.code == 'no-user') {
        errorMessage = 'No user is currently signed in.';
      } else {
        errorMessage = 'An error occurred. Please try again.';
      }

      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        dialogBackgroundColor: Color.fromARGB(255, 255, 253, 245),
        animType: AnimType.rightSlide,
        title: 'Error',
        titleTextStyle: TextStyle(
          color: Theme.of(context).primaryColorDark,
          fontSize: 20,
        ),
        desc: errorMessage,
        descTextStyle: TextStyle(
          color: Theme.of(context).primaryColorDark,
        ),
        btnCancelOnPress: () {},
        btnCancelColor: Theme.of(context).primaryColor,
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColorDark,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Theme.of(context).primaryColorDark,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 30,
            ),
            color: Theme.of(context).primaryColor,
          ),
        ),
        body: Column(
          children: [
            Container(
              alignment: Alignment.center,
              height: 110.0,
              color: Theme.of(context).primaryColorDark,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Res",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 40.0,
                      fontFamily: "Caprasimo",
                    ),
                  ),
                  Text(
                    "tron",
                    style: TextStyle(
                      color: Theme.of(context).primaryColorLight,
                      fontSize: 40.0,
                      fontFamily: "Caprasimo",
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(30),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorLight,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height: 50.0,
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          "Change Password",
                          style: TextStyle(
                            fontFamily: "Caprasimo",
                            fontSize: 18.0,
                            color: Theme.of(context).primaryColor,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),
                      const SizedBox(height: 30.0),
                      Form(
                        key: _formKey,
                        autovalidateMode: AutovalidateMode.always,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: oldPasswordController,
                              obscureText: _obscureOldPassword,
                              decoration: InputDecoration(
                                hintText: 'Old Password',
                                hintStyle: const TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(55, 0, 0, 0),
                                ),
                                border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(35)),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color.fromARGB(255, 194, 133, 64),
                                    width: 1,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(35)),
                                ),
                                filled: true,
                                fillColor:
                                    const Color.fromARGB(255, 255, 253, 245),
                                prefixIcon: const Icon(
                                  Icons.lock,
                                  size: 20.0,
                                  color: Color.fromARGB(255, 194, 133, 64),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureOldPassword
                                        ? Icons.remove_red_eye
                                        : Icons.visibility_off,
                                    size: 20.0,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureOldPassword =
                                          !_obscureOldPassword;
                                    });
                                  },
                                ),
                              ),
                              cursorColor: Theme.of(context).primaryColor,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your old password';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30.0),
                            TextFormField(
                              controller: newPasswordController,
                              obscureText: _obscureNewPassword,
                              decoration: InputDecoration(
                                hintText: 'New Password',
                                hintStyle: const TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(55, 0, 0, 0),
                                ),
                                border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(35)),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color.fromARGB(255, 194, 133, 64),
                                    width: 1,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(35)),
                                ),
                                filled: true,
                                fillColor:
                                    const Color.fromARGB(255, 255, 253, 245),
                                prefixIcon: const Icon(
                                  Icons.lock,
                                  size: 20.0,
                                  color: Color.fromARGB(255, 194, 133, 64),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureNewPassword
                                        ? Icons.remove_red_eye
                                        : Icons.visibility_off,
                                    size: 20.0,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureNewPassword =
                                          !_obscureNewPassword;
                                    });
                                  },
                                ),
                              ),
                              cursorColor: Theme.of(context).primaryColor,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a new password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30.0),
                            TextFormField(
                              controller: confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              decoration: InputDecoration(
                                hintText: 'Confirm New Password',
                                hintStyle: const TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(55, 0, 0, 0),
                                ),
                                border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(35)),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color.fromARGB(255, 194, 133, 64),
                                    width: 1,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(35)),
                                ),
                                filled: true,
                                fillColor:
                                    const Color.fromARGB(255, 255, 253, 245),
                                prefixIcon: const Icon(
                                  Icons.lock,
                                  size: 20.0,
                                  color: Color.fromARGB(255, 194, 133, 64),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.remove_red_eye
                                        : Icons.visibility_off,
                                    size: 20.0,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                              ),
                              cursorColor: Theme.of(context).primaryColor,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your new password';
                                }
                                return null;
                              },
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
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Forgot Password?",
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 14.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                minimumSize: const Size(350, 55),
                              ),
                              onPressed: _changePassword,
                              child: Text(
                                "Change Password",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColorLight,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}