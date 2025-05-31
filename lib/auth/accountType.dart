import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Accounttype extends StatefulWidget {
  const Accounttype({super.key});
  @override
  State<Accounttype> createState() => _AccounttypeState();
}

class _AccounttypeState extends State<Accounttype> {
  User? user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Theme.of(context).primaryColorLight,
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
                  'Account type',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Container(
                  height: 50,
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color: Theme.of(context).primaryColor,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                    boxShadow: [
                      BoxShadow(
                          offset: Offset.fromDirection(2, 2.0),
                          blurRadius: 16.0,
                          color: const Color.fromARGB(120, 194, 133, 64))
                    ],
                    color: Theme.of(context).cardColor,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Admin account',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                      IconButton(
                          onPressed: () async {
                            var newDoc = FirebaseFirestore.instance
                                .collection('restaurants')
                                .doc(user!.uid);
                            await newDoc.set({'Name': ''});
                            final CollectionReference users =
                                FirebaseFirestore.instance.collection('users');
                            await users.doc(user!.uid).set({
                              'accounttype': 'Admin',
                              'restId': newDoc.id,
                              'fcmToken': ''
                            });
                            Navigator.of(context).pushReplacementNamed("home");
                          },
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            color: Theme.of(context).primaryColor,
                          ))
                    ],
                  ),
                ),
                Container(
                  height: 20,
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 2,
                      color: Theme.of(context).primaryColor,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                    boxShadow: [
                      BoxShadow(
                          offset: Offset.fromDirection(2, 2.0),
                          blurRadius: 16.0,
                          color: const Color.fromARGB(120, 194, 133, 64))
                    ],
                    color: Theme.of(context).cardColor,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Employee account',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                      IconButton(
                          onPressed: () async {
                            final CollectionReference users =
                                FirebaseFirestore.instance.collection('users');
                            await users.doc(user!.uid).set({
                              'accounttype': '',
                              'restId': '',
                              'fcmToken': ''
                            });
                            Navigator.of(context)
                                .pushReplacementNamed("request");
                          },
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            color: Theme.of(context).primaryColor,
                          ))
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }
}
