import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:restron1/makeOrder/shared_data.dart';

class SelectTable extends StatefulWidget {
  const SelectTable({super.key});
  @override
  State<SelectTable> createState() => _SelectTableState();
}

class _SelectTableState extends State<SelectTable> {
  int _selectedIndex = 0;
  int? _selectedTable = 0;
  bool isLoadingHalls = true;
  User? user = FirebaseAuth.instance.currentUser;
  DocumentSnapshot? userInfo;
  DocumentSnapshot? restInfo;
  List<DocumentSnapshot> hallsList = [];
  List<DocumentSnapshot> tablesList = [];
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
    await getHallTables(hallsList[_selectedIndex].id);
    setState(() {
      isLoadingHalls = false;
    });
  }

  deleteHall(String id) async {
    await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(userInfo!['restId'])
        .collection('halls')
        .doc(id)
        .delete();
    setState(() {
      _selectedIndex = 0;
    });
  }

  getHallTables(String id) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(userInfo!['restId'])
        .collection('halls')
        .doc(id)
        .collection('tables')
        .get();
    tablesList.clear();
    for (var table in querySnapshot.docs) {
      if (table['status'] == 'Empty') {
        tablesList.add(table);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getRestInfo();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Theme.of(context).primaryColorLight,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 30,
          ),
          color: theme.primaryColor,
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 7),
                      width: 170,
                      height: 3,
                      decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(6)),
                          color: theme.primaryColor),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 7),
                      width: 170,
                      height: 3,
                      decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(6)),
                          color: theme.cardColor),
                    ),
                  ),
                ],
              ),
              Container(
                height: 60,
                child: isLoadingHalls
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        shrinkWrap: true,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemCount: hallsList.length,
                        itemBuilder: (context, index) {
                          bool isActive = index == _selectedIndex;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: GestureDetector(
                              onTap: () async {
                                await getHallTables(hallsList[index].id);
                                setState(() {
                                  _selectedIndex = index;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 5),
                                decoration: BoxDecoration(
                                  border: isActive
                                      ? Border.all(
                                          color: theme.primaryColor,
                                          width: 2,
                                          style: BorderStyle.solid)
                                      : null,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(21)),
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    hallsList[index]['Name'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: theme.primaryColorDark,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Divider(
                height: 1,
                color: theme.cardColor,
              ),
              Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(
                      top: 20, left: 30, right: 30, bottom: 80),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemCount: tablesList.length,
                  itemBuilder: (context, index) {
                    final tableNumber = tablesList[index].id;
                    String status = tablesList[index]['status'];
                    Color statusColor = theme.primaryColorDark;
                    bool isSelected = _selectedTable == int.parse(tableNumber);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTable = int.parse(tableNumber);
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(10),
                          border: isSelected
                              ? Border.all(
                                  color: theme.primaryColor,
                                  width: 2,
                                  style: BorderStyle.solid,
                                  strokeAlign: BorderSide.strokeAlignOutside)
                              : null,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    tableNumber,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: theme.primaryColorLight,
                                    ),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.table_restaurant_rounded,
                                    size: 40,
                                    color: theme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: 50,
                              alignment: Alignment.center,
                              child: Text(
                                status,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
              right: 20,
              bottom: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: const BorderRadius.all(Radius.circular(25))),
                child: IconButton(
                  onPressed: () async {
                    if (_selectedTable == 0) {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.warning,
                        dialogBackgroundColor:
                            const Color.fromARGB(255, 255, 253, 245),
                        animType: AnimType.rightSlide,
                        title: 'warning',
                        titleTextStyle: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontSize: 20,
                        ),
                        desc: 'You Have to Select Table First',
                        descTextStyle: TextStyle(
                            color: Theme.of(context).primaryColorDark),
                        btnOkOnPress: () {},
                        btnOkColor: Theme.of(context).primaryColor,
                      ).show();
                    } else {
                      SharedData.selectedHall =
                          hallsList[_selectedIndex]['Name'];
                      SharedData.selectedHallNum = _selectedTable.toString();
                      Navigator.of(context).pushNamed('selectMeals');
                    }
                  },
                  icon: const Icon(
                    Icons.arrow_forward_outlined,
                    size: 35,
                    fill: 1,
                  ),
                  color: theme.primaryColorDark,
                ),
              ))
        ],
      ),
    );
  }
}
