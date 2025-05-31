import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class Request extends StatefulWidget {
  const Request({super.key});
  @override
  State<Request> createState() => _RequestState();
}

class _RequestState extends State<Request> {
  TextEditingController Idrest = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  bool isSend = false;
  bool isRejected = false;
  Future<void> hasRequest() async {
    var doc = await FirebaseFirestore.instance
        .collection('requests')
        .doc(user?.uid)
        .get();
    if (doc.data() != null) {
      if (doc.data()!['status'] == 'Accepted') {
        Navigator.of(context).pushReplacementNamed("home");
      } else if (doc.data()!['status'] == 'Rejected') {
        setState(() {
          isRejected = true;
          isSend = false;
        });
      } else {
        setState(() {
          isRejected = false;
          isSend = true;
        });
      }
    }
  }

  void getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .update({'fcmToken': token});
  }

  void sendNot(String toToken) {}
  @override
  void initState() {
    super.initState();
    hasRequest();
    getToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Theme.of(context).primaryColorLight,
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // ignore: use_build_context_synchronously
              Navigator.of(context)
                  .pushNamedAndRemoveUntil("login", (route) => false);
            },
            icon: Icon(Icons.exit_to_app),
            color: Colors.red,
          )
        ],
      ),
      body: Container(
          padding: const EdgeInsets.all(25),
          color: Theme.of(context).primaryColorLight,
          child: Center(
            child: Column(
              children: [
                Container(
                  height: 100,
                ),
                Text(
                  'Asset Request ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Container(
                  height: 40,
                ),
                Text(
                  'This request will be sent to the manager.You will receive a notification when it  is approved or rejected.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Theme.of(context).primaryColorDark,
                  ),
                ),
                Container(
                  height: 30,
                ),
                if (isRejected)
                  Text(
                    'Request Rejected, you can try again',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                if (!isSend)
                  TextFormField(
                    controller: Idrest,
                    decoration: const InputDecoration(
                      hintText: 'restaurant id',
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
                          Icons.restaurant,
                          color: Color.fromARGB(255, 194, 133, 64)),
                    ),
                    cursorColor: Theme.of(context).primaryColor,
                    cursorErrorColor: Theme.of(context).primaryColor,
                    keyboardType: TextInputType.emailAddress,
                  ),
                Container(
                  height: 40,
                ),
                if (!isSend)
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          minimumSize: const ui.Size(350, 55)),
                      onPressed: () async {
                        QuerySnapshot Snapshot = await FirebaseFirestore
                            .instance
                            .collection('restaurants')
                            .where('requestId', isEqualTo: Idrest.text)
                            .get();
                        if (Snapshot.docs.isNotEmpty) {
                          await FirebaseFirestore.instance
                              .collection('requests')
                              .doc(user?.uid)
                              .set({
                            'RestId': Idrest.text,
                            'status': 'Pending',
                            'Name': user?.displayName,
                            'employeeId': user?.uid
                          });
                          final CollectionReference users =
                              FirebaseFirestore.instance.collection('users');
                          QuerySnapshot toUser = await users
                              .where('restId', isEqualTo: Snapshot.docs[0].id)
                              .get();

                          await {
                            FirebaseFirestore.instance
                                .collection('notification_requests')
                                .add({
                              'toUserId': toUser.docs[0].id,
                              'fromUserId': user?.uid,
                              'fromUserName': user?.displayName,
                              'type': 'join_request',
                              'timestamp': FieldValue.serverTimestamp(),
                            })
                          };
                          AwesomeDialog(
                            context: context,
                            dialogType: DialogType.success,
                            dialogBackgroundColor:
                                Color.fromARGB(255, 255, 253, 245),
                            animType: AnimType.rightSlide,
                            title: 'success',
                            titleTextStyle: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                              fontSize: 20,
                            ),
                            desc: 'Request send successfully',
                            descTextStyle: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                            ),
                            btnOkOnPress: () {
                              setState(() {
                                isSend = true;
                              });
                            },
                            btnOkColor: Theme.of(context).primaryColor,
                          ).show();
                        } else {
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
                            desc: 'Incorrect Restaurant id',
                            descTextStyle: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                            ),
                            btnOkOnPress: () {},
                            btnOkColor: Theme.of(context).primaryColor,
                          ).show();
                        }
                      },
                      child: Text(
                        "Send request",
                        style: TextStyle(
                            color: Theme.of(context).primaryColorLight,
                            fontSize: 20,
                            fontWeight: FontWeight.w900),
                      )),
                if (isSend)
                  Text(
                    'Request sended, whiting for response',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
              ],
            ),
          )),
    );
  }
}
