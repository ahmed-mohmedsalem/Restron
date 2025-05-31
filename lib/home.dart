import 'dart:io';
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:restron1/makeOrder/shared_data.dart';
import 'package:restron1/widgets/drawer.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  User? user = FirebaseAuth.instance.currentUser;
  TextEditingController _restNameController = TextEditingController();

  DocumentSnapshot? userInfo;
  DocumentSnapshot? restInfo;
  String? url;
  String? restName;
  bool _showForm = false;
  bool isLoadingInfo = true;
  List<DocumentSnapshot> mealsList = [];
  DateTime date = DateTime.now();

  getRestInfo() async {
    final CollectionReference users =
        FirebaseFirestore.instance.collection('users');
    DocumentSnapshot documentSnapshot = await users.doc(user!.uid).get();
    userInfo = documentSnapshot;

    final CollectionReference restaurants =
        FirebaseFirestore.instance.collection('restaurants');
    DocumentSnapshot docSnapshot =
        await restaurants.doc(userInfo!['restId']).get();
    restInfo = docSnapshot;
    url = restInfo?['imgUrl'];
    SharedData.requestId = restInfo?['requestId'];
    SharedData.restId = restInfo!.id;
    getToken();
    setState(() {
      isLoadingInfo = false;
    });
  }

  File? file;
  getImage() async {
    final ImagePicker picker = ImagePicker();
    // Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      file = File(image.path);

      var imageName = basename(image.path);

      var refStorage = FirebaseStorage.instance.ref(imageName);
      await refStorage.putFile(file!);
      url = await refStorage.getDownloadURL();

      var newDoc =
          FirebaseFirestore.instance.collection('restaurants').doc(user!.uid);
      await newDoc.update({'imgUrl': url});
    }
    setState(() {
      isLoadingInfo = false;
    });
  }

  String getMealNotServeNum(int count) {
    if (count == 0) {
      return "all meals have been served";
    } else if (count == 1) {
      return "1 meal have not been served yet";
    } else {
      return count.toString() + " meals have not been served yet";
    }
  }

  String getTime(Timestamp date) {
    return DateTime.now().difference(date.toDate()).inMinutes.toString();
  }

  int getRandom() {
    var random = Random();
    int randomNum = 100 + random.nextInt(900);
    return randomNum;
  }

  void getToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    FirebaseFirestore.instance
        .collection('users')
        .doc(userInfo!.id)
        .update({'fcmToken': token});
  }

  @override
  void initState() {
    getRestInfo();
    super.initState();
  }

  Widget build(BuildContext context) {
    restName = restName ?? restInfo?['Name'];
    final theme = Theme.of(context);
    return Scaffold(
        key: scaffoldKey,
        resizeToAvoidBottomInset: false,
        endDrawerEnableOpenDragGesture: false,
        backgroundColor: Theme.of(context).primaryColorDark,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Theme.of(context).primaryColorDark,
          leading: IconButton(
            onPressed: () async {
              scaffoldKey.currentState?.openDrawer();
            },
            icon: const Icon(
              Icons.person,
              size: 30,
            ),
            color: theme.primaryColor,
          ),
        ),
        body: isLoadingInfo
            ? Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              )
            : Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showForm = false;
                      });
                    },
                    child: Positioned.fill(
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            height: 150.0,
                            color: Theme.of(context).primaryColorDark,
                            child: Center(
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 55,
                                        backgroundImage: url != ""
                                            ? NetworkImage(url.toString())
                                            : AssetImage(
                                                'images/Restaurant.png'),
                                      ),
                                      if (userInfo?['accounttype'] == 'Admin')
                                        Positioned(
                                          bottom: -5,
                                          right: -5,
                                          child: IconButton(
                                            onPressed: () async {
                                              await getImage();
                                            },
                                            icon: const Icon(
                                              Icons.add_circle_rounded,
                                              size: 25,
                                            ),
                                            color: theme.primaryColor,
                                          ),
                                        ),
                                    ],
                                  ),
                                  Stack(
                                    children: [
                                      Container(
                                        width: 150,
                                        alignment: Alignment.center,
                                        child: Text("${restName}",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            )),
                                      ),
                                      if (userInfo?['accounttype'] == 'Admin')
                                        Positioned(
                                          bottom: -9,
                                          right: 0,
                                          child: IconButton(
                                            onPressed: () async {
                                              setState(() {
                                                _showForm = true;
                                                _restNameController.text =
                                                    restInfo?['Name'];
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.edit,
                                              size: 18,
                                            ),
                                            color: theme.primaryColor,
                                          ),
                                        ),
                                    ],
                                  )
                                ],
                              ),
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
                                      topRight: Radius.circular(60)),
                                ),
                                child: Column(
                                  children: [
                                    Container(height: 10),
                                    if (!isLoadingInfo)
                                      StreamBuilder(
                                          stream: FirebaseFirestore.instance
                                              .collection('restaurants')
                                              .doc(userInfo!['restId'])
                                              .collection('days')
                                              .doc(DateTime(date.year,
                                                      date.month, date.day)
                                                  .toString())
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasError) {
                                              return const Text('error');
                                            }

                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return Container();
                                            }
                                            if (!snapshot.data!.exists) {
                                              var day = FirebaseFirestore
                                                  .instance
                                                  .collection('restaurants')
                                                  .doc(userInfo!['restId'])
                                                  .collection('days')
                                                  .doc(DateTime(date.year,
                                                          date.month, date.day)
                                                      .toString());

                                              day.set({
                                                'tMeals': 0,
                                                'tOrders': 0,
                                                'tSales': 0,
                                              });
                                            }
                                            final data = snapshot.data!.data();
                                            return Row(
                                              children: [
                                                Container(
                                                  height: 165,
                                                  width: 150,
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                      color: theme.cardColor,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  10)),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color:
                                                              theme.shadowColor,
                                                          spreadRadius: 0,
                                                          blurRadius: 14,
                                                          offset: const Offset(
                                                              2, 2),
                                                        )
                                                      ]),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .all(0),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0),
                                                        width: double.infinity,
                                                        child: Text(
                                                            "Today's total orders",
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorDark,
                                                              height: 1,
                                                            )),
                                                      ),
                                                      Container(height: 1),
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .all(0),
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 5),
                                                        width: double.infinity,
                                                        child: Text(
                                                            data != null
                                                                ? data['tOrders']
                                                                    .toString()
                                                                : '0',
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: TextStyle(
                                                              fontSize: 50,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900,
                                                              color: theme
                                                                  .primaryColor,
                                                              height: 1,
                                                            )),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            Alignment.topRight,
                                                        child: Icon(
                                                          size: 75,
                                                          Icons.edit,
                                                          color: theme
                                                              .primaryColor,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  width: 30,
                                                ),
                                                Container(
                                                  height: 165,
                                                  width: 150,
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                      color: theme.cardColor,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  10)),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color:
                                                              theme.shadowColor,
                                                          spreadRadius: 0,
                                                          blurRadius: 14,
                                                          offset: const Offset(
                                                              2, 2),
                                                        )
                                                      ]),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .all(0),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(0),
                                                        width: double.infinity,
                                                        child: Text(
                                                            "Today's total meals",
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColorDark,
                                                              height: 1,
                                                            )),
                                                      ),
                                                      Container(height: 1),
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .all(0),
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 5),
                                                        width: double.infinity,
                                                        child: Text(
                                                            data != null
                                                                ? data['tMeals']
                                                                    .toString()
                                                                : '0',
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: TextStyle(
                                                              fontSize: 50,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900,
                                                              color: theme
                                                                  .primaryColor,
                                                              height: 1,
                                                            )),
                                                      ),
                                                      Align(
                                                        alignment:
                                                            Alignment.topRight,
                                                        child: Icon(
                                                          size: 75,
                                                          Icons.dinner_dining,
                                                          color: theme
                                                              .primaryColor,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ],
                                            );
                                          }),
                                    const SizedBox(
                                      height: 6,
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text("Latest orders",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: theme.primaryColorDark,
                                          )),
                                    ),
                                    if (!isLoadingInfo)
                                      Expanded(
                                        child: StreamBuilder(
                                            stream: FirebaseFirestore.instance
                                                .collection('restaurants')
                                                .doc(userInfo!['restId'])
                                                .collection('orders')
                                                .where('status',
                                                    isEqualTo: 'Current')
                                                .snapshots(),
                                            builder: (context,
                                                AsyncSnapshot<QuerySnapshot>
                                                    snapshot) {
                                              if (snapshot.hasError) {
                                                return const Text('error');
                                              }

                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return Container();
                                              }
                                              return ListView.builder(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 20),
                                                  itemCount: snapshot
                                                      .data!.docs.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Container(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 6,
                                                          horizontal: 4),
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 7,
                                                              bottom: 7,
                                                              left: 10,
                                                              right: 20),
                                                      decoration: BoxDecoration(
                                                          color:
                                                              theme.cardColor,
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          10)),
                                                          border: Border(
                                                              left: BorderSide(
                                                                  color: theme
                                                                      .primaryColorDark,
                                                                  width:
                                                                      1.50))),
                                                      child: Column(
                                                        children: [
                                                          Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                                "Table " +
                                                                    snapshot.data!
                                                                            .docs[index]
                                                                        [
                                                                        'tableNum'] +
                                                                    ", " +
                                                                    snapshot.data!
                                                                            .docs[index]
                                                                        [
                                                                        'hallName'],
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  color: theme
                                                                      .primaryColorDark,
                                                                )),
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Text(
                                                                    getMealNotServeNum(snapshot
                                                                            .data!
                                                                            .docs[index]
                                                                        [
                                                                        'notServedNum']),
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          10,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color: theme
                                                                          .primaryColorDark,
                                                                    )),
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                      snapshot
                                                                          .data!
                                                                          .docs[
                                                                              index]
                                                                              [
                                                                              'totalPrice']
                                                                          .toString(),
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight.w700,
                                                                        color: theme
                                                                            .primaryColor,
                                                                      )),
                                                                  Text("DZ",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            14,
                                                                        fontWeight:
                                                                            FontWeight.w700,
                                                                        color: theme
                                                                            .primaryColorDark,
                                                                      )),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                                getTime(snapshot
                                                                            .data!
                                                                            .docs[index]
                                                                        [
                                                                        'date']) +
                                                                    " minutes ago",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: theme
                                                                      .primaryColor,
                                                                )),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  });
                                            }),
                                      ),
                                    Container(
                                      height: 30,
                                    )
                                  ],
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showForm)
                    Center(
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 320,
                          padding: const EdgeInsets.all(20),
                          margin: EdgeInsets.only(bottom: 60),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: theme.shadowColor,
                                spreadRadius: 0,
                                blurRadius: 14,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  "Edit Restaurant Name",
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                autofocus: true,
                                controller: _restNameController,
                                decoration: InputDecoration(
                                  hintText: 'Restaurant Name',
                                  hintStyle: TextStyle(
                                      fontSize: 16,
                                      color: theme.primaryColorDark
                                          .withOpacity(0.7)),
                                  border: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(35)),
                                    borderSide: BorderSide(
                                        color: theme.primaryColor, width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: theme.primaryColor, width: 1),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(35)),
                                  ),
                                  filled: true,
                                  fillColor: theme.cardColor,
                                ),
                              ),
                              const SizedBox(height: 30),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      final CollectionReference restaurants =
                                          FirebaseFirestore.instance
                                              .collection('restaurants');
                                      await restaurants
                                          .doc(userInfo!['restId'])
                                          .update({
                                        'Name': _restNameController.text,
                                        'requestId': _restNameController.text +
                                            '-' +
                                            getRandom().toString() +
                                            '-' +
                                            getRandom().toString(),
                                      });
                                      setState(() {
                                        _showForm = false;
                                        restName = _restNameController.text;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.primaryColorDark,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    child: Text(
                                      "Save",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: theme.primaryColorLight,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _showForm = false;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: theme.primaryColorLight,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 56, vertical: 4),
                        color: theme.primaryColorDark,
                        child: SafeArea(
                            top: false,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () async {},
                                  icon: const Icon(
                                    Icons.home_rounded,
                                    size: 35,
                                  ),
                                  color: theme.primaryColor,
                                ),
                                IconButton(
                                  onPressed: () async {
                                    Navigator.of(context).pushNamed("tables");
                                  },
                                  icon: const Icon(
                                    Icons.table_restaurant_rounded,
                                    size: 35,
                                  ),
                                  color: theme.primaryColorLight,
                                ),
                              ],
                            )),
                      )),
                  Positioned(
                    bottom: 22,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                          height: 75,
                          width: 75,
                          decoration: BoxDecoration(
                            color: theme.primaryColorLight,
                            shape: BoxShape.circle,
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 22,
                                top: 22,
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: theme.primaryColorDark,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Align(
                                child: IconButton(
                                  onPressed: () async {
                                    Navigator.of(context)
                                        .pushNamed("selectTable");
                                  },
                                  icon: const Icon(
                                    Icons.add_circle_rounded,
                                    size: 60,
                                  ),
                                  color: theme.primaryColor,
                                ),
                              )
                            ],
                          )),
                    ),
                  ),
                ],
              ),
        drawer: !isLoadingInfo
            ? DrawerWidget(
                accountType: userInfo!['accounttype'],
                requestId: restInfo!['requestId'])
            : null);
  }
}
