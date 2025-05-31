import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditTables extends StatefulWidget {
  const EditTables({super.key});
  @override
  State<EditTables> createState() => _EditTablesState();
}

class _EditTablesState extends State<EditTables> {
  int _selectedIndex = 0;
  bool _showForm = false;
  bool isLoadingHalls = true;
  TextEditingController _hallNameController = TextEditingController();
  TextEditingController _tablesController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  // DocumentSnapshot? userInfo;
  // DocumentSnapshot? restInfo;
  List<DocumentSnapshot> hallsList = [];
  List<DocumentSnapshot> tablesList = [];
  // getRestInfo() async {
  //   final CollectionReference users =
  //       FirebaseFirestore.instance.collection('users');
  //   DocumentSnapshot documentSnapshot = await users.doc(user!.uid).get();
  //   userInfo = documentSnapshot;

  //   final CollectionReference restaurants =
  //       FirebaseFirestore.instance.collection('restaurants');
  //   DocumentSnapshot docSnapshot =
  //       await restaurants.doc(user!.uid).get();
  //   restInfo = docSnapshot;
  //   if (docSnapshot.exists) {
  //     await getHalls();
  //     isLoadingHalls = false;
  //   }
  //   setState(() {});
  // }

  getHalls() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(user!.uid)
        .collection('halls')
        .get();
    hallsList.clear();
    hallsList.addAll(querySnapshot.docs);
    if (hallsList.isNotEmpty) {
      await getHallTables(hallsList[_selectedIndex].id);
    }
    isLoadingHalls = false;
    setState(() {});
  }

  deleteHall(String id, int nTables) async {
    await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(user!.uid)
        .collection('halls')
        .doc(id)
        .delete();
    for (int i = 1; i <= nTables; i++) {
      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(user!.uid)
          .collection('halls')
          .doc(_hallNameController.text)
          .collection('tables')
          .doc(i.toString())
          .delete();
    }
    setState(() {
      _selectedIndex = 0;
      _showForm = false;
    });
  }

  getHallTables(String id) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(user!.uid)
        .collection('halls')
        .doc(id)
        .collection('tables')
        .get();
    tablesList.clear();
    tablesList.addAll(querySnapshot.docs);
  }

  @override
  void dispose() {
    _hallNameController.dispose();
    _tablesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    getHalls();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryColorLight,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: theme.primaryColorLight,
        title: Text(
          "Edit Tables",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: theme.primaryColor,
          ),
        ),
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
          GestureDetector(
            onTap: () {
              setState(() {
                _showForm = false;
              });
            },
            child: Column(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 7),
                    width: 340,
                    height: 3,
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(6)),
                        color: theme.primaryColor),
                  ),
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
                                    _showForm = false;
                                  });
                                },
                                onLongPress: () async {
                                  await getHallTables(hallsList[index].id);
                                  setState(() {
                                    _selectedIndex = index;
                                    _showForm = true;
                                    _hallNameController.text =
                                        hallsList[index]['Name'];
                                    _tablesController.text =
                                        hallsList[index]['Ntables'].toString();
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemCount: tablesList.length,
                    itemBuilder: (context, index) {
                      String status = tablesList[index]['status'];
                      Color statusColor = theme.primaryColorDark;

                      return Container(
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(10),
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
                                    tablesList[index].id,
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
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_showForm)
            Center(
              child: GestureDetector(
                onTap: () {
                  // Prevent closing when tapping inside the form
                },
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
                          "Add hall",
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
                        controller: _hallNameController,
                        decoration: InputDecoration(
                          hintText: 'Hall Name',
                          hintStyle: TextStyle(
                              fontSize: 16,
                              color: theme.primaryColorDark.withOpacity(0.7)),
                          border: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(35)),
                            borderSide:
                                BorderSide(color: theme.primaryColor, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: theme.primaryColor, width: 1),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(35)),
                          ),
                          filled: true,
                          fillColor: theme.cardColor,
                        ),
                      ),
                      const SizedBox(height: 25),
                      TextField(
                        controller: _tablesController,
                        decoration: InputDecoration(
                          hintText: 'Number of tables',
                          hintStyle: TextStyle(
                              fontSize: 16,
                              color: theme.primaryColorDark.withOpacity(0.7)),
                          border: OutlineInputBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(35)),
                            borderSide:
                                BorderSide(color: theme.primaryColor, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: theme.primaryColor, width: 1),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(35)),
                          ),
                          filled: true,
                          fillColor: theme.cardColor,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('restaurants')
                                  .doc(user!.uid)
                                  .collection('halls')
                                  .doc(_hallNameController.text)
                                  .set({
                                'Name': _hallNameController.text,
                                'Ntables': int.parse(_tablesController.text)
                              });
                              for (int i = 1;
                                  i <= int.parse(_tablesController.text);
                                  i++) {
                                await FirebaseFirestore.instance
                                    .collection('restaurants')
                                    .doc(user!.uid)
                                    .collection('halls')
                                    .doc(_hallNameController.text)
                                    .collection('tables')
                                    .doc(i.toString())
                                    .set({
                                  'status': 'Empty',
                                  'currentOrder': ''
                                });
                              }
                              await getHalls();
                              setState(() {
                                _showForm = false;
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
                            onPressed: () async {
                              await deleteHall(hallsList[_selectedIndex].id,
                                  hallsList[_selectedIndex]['Ntables']);
                              await getHalls();
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
                              "Delete",
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
              right: 20,
              bottom: 10,
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
                        setState(() {
                          _showForm = true;
                          _hallNameController.clear();
                          _tablesController.clear();
                        });
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
        ],
      ),
    );
  }
}
