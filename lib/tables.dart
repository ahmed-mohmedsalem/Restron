import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:restron1/widgets/drawer.dart';

class Tables extends StatefulWidget {
  const Tables({super.key});
  @override
  State<Tables> createState() => _TablesState();
}

class _TablesState extends State<Tables> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  int _selectedIndex = 0;
  String _selected = 'To prepare';
  bool isLoadingHalls = true;
  bool _showQRcode = false;
  User? user = FirebaseAuth.instance.currentUser;
  DocumentSnapshot? userInfo;
  DocumentSnapshot? orderInfo;
  DocumentSnapshot? restInfo;
  List<DocumentSnapshot> hallsList = [];
  List<DocumentSnapshot> mealsList = [];
  List<DocumentSnapshot<Object?>> MealsWithoutR = [];
  List<DocumentSnapshot> ordersList = [];

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
    if (docSnapshot.exists) {
      await getHalls();
      getOrders();
      isLoadingHalls = false;
    }
    setState(() {});
  }

  getHalls() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(userInfo!['restId'])
        .collection('halls')
        .get();
    hallsList.clear();
    hallsList.addAll(querySnapshot.docs);
    setState(() {
      isLoadingHalls = false;
    });
  }

  int getMealNum(var meal) {
    var count = 0;
    for (var m in mealsList) {
      if (m['Name'] == meal['Name']) {
        count++;
      }
    }
    return count;
  }

  getOrders() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(userInfo!['restId'])
        .collection('orders')
        .get();
    ordersList.clear();
    ordersList.addAll(querySnapshot.docs);
  }

  String getTable(String orderId) {
    for (var order in ordersList) {
      if (order.id == orderId) {
        return 'T' + order['tableNum'] + ', ' + order['hallName'];
      }
    }
    return '';
  }

  String getOrderDate(String orderId) {
    for (var order in ordersList) {
      if (order.id == orderId) {
        DateTime dateTime = (order['date'] as Timestamp).toDate();
        return DateTime.now().difference(dateTime).inMinutes.toString();
      }
    }
    return '';
  }

  int getTotalPrice() {
    var count = 0;
    for (var m in mealsList) {
      count = count + int.parse(m['Price']);
    }
    return count;
  }

  void deletePdf(String url) async {
    try {
      final uri = Uri.parse(url);
      final fullPathEncoded = uri.pathSegments.last;
      final fullPath = Uri.decodeFull(fullPathEncoded);
      final ref = FirebaseStorage.instance.ref().child(fullPath);
      await ref.delete();
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    getRestInfo();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _showMealsBottomSheet(
      BuildContext context, String orderId, String tableId) async {
    final theme = Theme.of(context);
    QuerySnapshot mealsQuerySnapshot = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(userInfo!['restId'])
        .collection('orderMeals')
        .where('orderId', isEqualTo: orderId)
        .get();
    mealsList.clear();
    MealsWithoutR.clear();
    mealsList.addAll(mealsQuerySnapshot.docs);
    for (var meal in mealsList) {
      if (!MealsWithoutR.any((m) => m['Name'] == meal['Name'])) {
        MealsWithoutR.add(meal);
      }
    }

    final CollectionReference order = FirebaseFirestore.instance
        .collection('restaurants')
        .doc(userInfo!['restId'])
        .collection('orders');
    DocumentSnapshot docSnapshot = await order.doc(orderId).get();
    orderInfo = docSnapshot;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: theme.primaryColorDark,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                margin: const EdgeInsets.only(top: 7),
                width: 85,
                height: 3,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                    color: theme.primaryColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Table $tableId",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: theme.primaryColorLight,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: MealsWithoutR.length,
                itemBuilder: (context, index) {
                  return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 10),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getMealNum(MealsWithoutR[index]).toString(),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    MealsWithoutR[index]['Name'],
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400,
                                      color: theme.primaryColorLight,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    (int.parse(MealsWithoutR[index]['Price']) *
                                            getMealNum(MealsWithoutR[index]))
                                        .toString(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: theme.primaryColorLight,
                                    ),
                                  ),
                                  Text(
                                    " DZ",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Divider(
                            height: 1,
                            color: theme.primaryColorLight,
                          ),
                        ],
                      ));
                },
              ),
            ),
            Divider(
              height: 1,
              color: theme.primaryColorLight,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    mealsList.length.toString(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: theme.primaryColor,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        getTotalPrice().toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColorLight,
                        ),
                      ),
                      Text(
                        "DZ",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: orderInfo!['billStatus'] == 'notPaid'
                  ? ElevatedButton(
                      onPressed: () async {
                        DateTime date = DateTime.now();
                        await FirebaseFirestore.instance
                            .collection('restaurants')
                            .doc(userInfo!['restId'])
                            .collection('orders')
                            .doc(orderId)
                            .update({'billStatus': 'Paid'});
                        var day = FirebaseFirestore.instance
                            .collection('restaurants')
                            .doc(userInfo!['restId'])
                            .collection('days')
                            .doc(DateTime(date.year, date.month, date.day)
                                .toString());

                        await day.update({
                          'tMeals': FieldValue.increment(mealsList.length),
                          'tOrders': FieldValue.increment(1),
                          'tSales': FieldValue.increment(getTotalPrice()),
                        });
                        Navigator.pop(context);
                        setState(() {
                          _showQRcode = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        "confirm payment",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: theme.primaryColorLight,
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('restaurants')
                            .doc(userInfo!['restId'])
                            .collection('orders')
                            .doc(orderId)
                            .update({
                          'status': 'Finish',
                        });
                        await FirebaseFirestore.instance
                            .collection('restaurants')
                            .doc(userInfo!['restId'])
                            .collection('halls')
                            .doc(hallsList[_selectedIndex].id)
                            .collection('tables')
                            .doc(tableId)
                            .update({
                          'status': 'Empty',
                          'currentOrder': 'Empty',
                        });

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        "Finish Order",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: theme.primaryColorLight,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
        key: scaffoldKey,
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
        body: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: 25.0,
                    color: Theme.of(context).primaryColorDark,
                  ),
                  Expanded(
                    child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColorLight,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(60),
                              topRight: Radius.circular(60)),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 60,
                                          child: isLoadingHalls
                                              ? Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                )
                                              : ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 30),
                                                  shrinkWrap: true,
                                                  physics:
                                                      AlwaysScrollableScrollPhysics(),
                                                  itemCount: hallsList.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    bool isActive =
                                                        index == _selectedIndex;
                                                    return GestureDetector(
                                                        onTap: () async {
                                                          setState(() {
                                                            _selectedIndex =
                                                                index;
                                                          });
                                                        },
                                                        child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical:
                                                                        10),
                                                            child: Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            8,
                                                                        vertical:
                                                                            5),
                                                                decoration: BoxDecoration(
                                                                    border: isActive
                                                                        ? Border.all(
                                                                            color: theme
                                                                                .primaryColor,
                                                                            width:
                                                                                2,
                                                                            style: BorderStyle
                                                                                .solid)
                                                                        : null,
                                                                    borderRadius:
                                                                        const BorderRadius
                                                                            .all(
                                                                            Radius.circular(21))),
                                                                child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  child: Text(
                                                                    hallsList[
                                                                            index]
                                                                        [
                                                                        'Name'],
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600,
                                                                        color: theme
                                                                            .primaryColorDark),
                                                                  ),
                                                                ))));
                                                  },
                                                ),
                                        ),
                                        Divider(
                                          height: 1,
                                          color: theme.cardColor,
                                        ),
                                        if (!isLoadingHalls)
                                          StreamBuilder(
                                              stream: FirebaseFirestore.instance
                                                  .collection('restaurants')
                                                  .doc(userInfo!['restId'])
                                                  .collection('halls')
                                                  .doc(hallsList[_selectedIndex]
                                                      .id)
                                                  .collection('tables')
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
                                                return GridView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 20,
                                                          left: 30,
                                                          right: 30),
                                                  gridDelegate:
                                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 3,
                                                    crossAxisSpacing: 12,
                                                    mainAxisSpacing: 12,
                                                    childAspectRatio: 1,
                                                  ),
                                                  itemCount: snapshot
                                                      .data?.docs.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final tableNumber = snapshot
                                                        .data!.docs[index].id;
                                                    String status = snapshot
                                                        .data!
                                                        .docs[index]['status'];
                                                    Color statusColor;
                                                    switch (status) {
                                                      case "Taken":
                                                        statusColor =
                                                            theme.primaryColor;
                                                        break;
                                                      default:
                                                        statusColor = theme
                                                            .primaryColorDark;
                                                    }
                                                    return GestureDetector(
                                                      onTap: () {
                                                        if (snapshot.data!
                                                                    .docs[index]
                                                                ['status'] !=
                                                            'Empty') {
                                                          _showMealsBottomSheet(
                                                              context,
                                                              snapshot.data!
                                                                          .docs[
                                                                      index][
                                                                  'currentOrder'],
                                                              tableNumber);
                                                        }
                                                      },
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              theme.cardColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: theme
                                                                  .shadowColor,
                                                              spreadRadius: 0,
                                                              blurRadius: 14,
                                                              offset:
                                                                  const Offset(
                                                                      2, 2),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Container(
                                                                  width: 50,
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              6),
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          10,
                                                                      horizontal:
                                                                          10),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: theme
                                                                        .primaryColor,
                                                                    borderRadius:
                                                                        const BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              10),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              10),
                                                                    ),
                                                                  ),
                                                                  child: Text(
                                                                    tableNumber,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          20,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w900,
                                                                      color: theme
                                                                          .primaryColorLight,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  child: Icon(
                                                                    Icons
                                                                        .table_restaurant_rounded,
                                                                    size: 40,
                                                                    color: theme
                                                                        .primaryColor,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Container(
                                                              height: 50,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: Text(
                                                                status,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w800,
                                                                  color:
                                                                      statusColor,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              })
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30, vertical: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _selected = 'To prepare';
                                                });
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 5),
                                                decoration: BoxDecoration(
                                                  border: _selected ==
                                                          'To prepare'
                                                      ? Border.all(
                                                          color: theme
                                                              .primaryColor,
                                                          width: 2,
                                                          style:
                                                              BorderStyle.solid)
                                                      : null,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(21)),
                                                ),
                                                child: Text(
                                                  "to prepare",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        theme.primaryColorDark,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _selected = 'To serve';
                                                });
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 5),
                                                decoration: BoxDecoration(
                                                  border: _selected ==
                                                          'To serve'
                                                      ? Border.all(
                                                          color: theme
                                                              .primaryColor,
                                                          width: 2,
                                                          style:
                                                              BorderStyle.solid)
                                                      : null,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(21)),
                                                ),
                                                child: Text(
                                                  "to serve",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        theme.primaryColorDark,
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Divider(
                                        height: 1,
                                        color: theme.cardColor,
                                      ),
                                      if (!isLoadingHalls)
                                        Expanded(
                                          child: SingleChildScrollView(
                                              child: StreamBuilder(
                                                  stream: FirebaseFirestore
                                                      .instance
                                                      .collection('restaurants')
                                                      .doc(userInfo!['restId'])
                                                      .collection('orderMeals')
                                                      .where('status',
                                                          isEqualTo: _selected)
                                                      .snapshots(),
                                                  builder: (context,
                                                      AsyncSnapshot<
                                                              QuerySnapshot>
                                                          snapshot) {
                                                    if (snapshot.hasError) {
                                                      return const Text(
                                                          'error');
                                                    }

                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return Container();
                                                    }
                                                    return ListView.builder(
                                                      shrinkWrap: true,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 20,
                                                              left: 30,
                                                              right: 30),
                                                      itemCount: snapshot
                                                          .data!.docs.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Stack(
                                                          children: [
                                                            Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          6,
                                                                      horizontal:
                                                                          4),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top: 4,
                                                                      left: 4,
                                                                      right: 8,
                                                                      bottom:
                                                                          4),
                                                              decoration: BoxDecoration(
                                                                  color: theme
                                                                      .cardColor,
                                                                  borderRadius:
                                                                      const BorderRadius
                                                                          .all(
                                                                          Radius.circular(
                                                                              12)),
                                                                  border: Border(
                                                                      left: BorderSide(
                                                                          color: theme
                                                                              .primaryColorDark,
                                                                          width:
                                                                              1.50))),
                                                              child: Row(
                                                                children: [
                                                                  Container(
                                                                    width: 60,
                                                                    height: 60,
                                                                    margin: const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            16),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                      image:
                                                                          DecorationImage(
                                                                        image: NetworkImage(snapshot
                                                                            .data!
                                                                            .docs[index]['imgUrl']),
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                      child:
                                                                          Container(
                                                                    height: 65,
                                                                    padding: EdgeInsets.only(
                                                                        bottom:
                                                                            3,
                                                                        top: 3,
                                                                        right:
                                                                            6),
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text(
                                                                              snapshot.data!.docs[index]["Name"],
                                                                              style: TextStyle(
                                                                                fontSize: 15,
                                                                                fontWeight: FontWeight.w700,
                                                                                color: theme.primaryColorDark,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text(
                                                                              getTable(snapshot.data!.docs[index]['orderId']),
                                                                              style: TextStyle(
                                                                                fontSize: 12,
                                                                                fontWeight: FontWeight.w600,
                                                                                color: theme.primaryColorDark,
                                                                              ),
                                                                            ),
                                                                            Text(
                                                                              getOrderDate(snapshot.data!.docs[index]['orderId']) + ' minutes ago',
                                                                              style: TextStyle(
                                                                                fontSize: 14,
                                                                                fontWeight: FontWeight.w600,
                                                                                color: theme.primaryColor.withOpacity(0.7),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )),
                                                                ],
                                                              ),
                                                            ),
                                                            Positioned(
                                                              top: 0,
                                                              right: 0,
                                                              child: IconButton(
                                                                onPressed:
                                                                    () async {
                                                                  if (_selected ==
                                                                      'To prepare') {
                                                                    await FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'restaurants')
                                                                        .doc(userInfo![
                                                                            'restId'])
                                                                        .collection(
                                                                            'orderMeals')
                                                                        .doc(snapshot
                                                                            .data!
                                                                            .docs[index]
                                                                            .id)
                                                                        .update({
                                                                      'status':
                                                                          'To serve',
                                                                    });
                                                                  } else {
                                                                    await FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'restaurants')
                                                                        .doc(userInfo![
                                                                            'restId'])
                                                                        .collection(
                                                                            'orderMeals')
                                                                        .doc(snapshot
                                                                            .data!
                                                                            .docs[index]
                                                                            .id)
                                                                        .update({
                                                                      'status':
                                                                          'Served',
                                                                    });
                                                                    await FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'restaurants')
                                                                        .doc(userInfo![
                                                                            'restId'])
                                                                        .collection(
                                                                            'orders')
                                                                        .doc(snapshot.data!.docs[index]
                                                                            [
                                                                            'orderId'])
                                                                        .update({
                                                                      'notServedNum':
                                                                          FieldValue.increment(
                                                                              -1)
                                                                    });
                                                                  }
                                                                },
                                                                icon:
                                                                    const Icon(
                                                                  Icons
                                                                      .check_circle,
                                                                  size: 20,
                                                                ),
                                                                color: theme
                                                                    .primaryColor,
                                                              ),
                                                            )
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  })),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )),
                  ),
                ],
              ),
            ),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 56, vertical: 4),
                  color: theme.primaryColorDark,
                  child: SafeArea(
                      top: false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(
                              Icons.home_rounded,
                              size: 35,
                            ),
                            color: theme.primaryColorLight,
                          ),
                          IconButton(
                            onPressed: () async {
                              Navigator.of(context)
                                  .pushReplacementNamed("tables");
                            },
                            icon: const Icon(
                              Icons.table_restaurant_rounded,
                              size: 35,
                            ),
                            color: theme.primaryColor,
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
                              Navigator.of(context).pushNamed("selectTable");
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
            Positioned(
              width: 250,
              height: 55,
              right: 70,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(30),
                    border: const Border(bottom: BorderSide.none)),
                child: TabBar(
                  dividerHeight: 0,
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 0),
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  indicatorWeight: 1,
                  labelStyle: TextStyle(
                      fontSize: 18,
                      color: theme.primaryColorDark,
                      fontWeight: FontWeight.w600),
                  unselectedLabelStyle: TextStyle(
                      fontSize: 18,
                      color: theme.primaryColorDark,
                      fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(
                      child: SizedBox(
                        width: 150,
                        child: Center(
                          child: Text("Tables"),
                        ),
                      ),
                    ),
                    Tab(
                      child: SizedBox(
                        width: 150,
                        child: Center(
                          child: Text("Meals"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_showQRcode)
              Center(
                child: SingleChildScrollView(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 320,
                      padding: const EdgeInsets.all(20),
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
                              'Scan me to get the bill as pdf ',
                              style: TextStyle(
                                fontSize: 18,
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Divider(
                            height: 1,
                            color: theme.primaryColor,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            child: Center(
                              child: QrImageView(
                                data: orderInfo!['billUrl'],
                                version: QrVersions.auto,
                                size: 200.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  setState(() {
                                    _showQRcode = false;
                                    deletePdf(orderInfo!['billUrl']);
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: Text(
                                  "Hide",
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
              ),
          ],
        ),
        drawer: !isLoadingHalls
            ? DrawerWidget(
                accountType: userInfo!['accounttype'],
                requestId: restInfo!['requestId'])
            : null);
  }
}
