import 'dart:io';
import 'dart:typed_data';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:restron1/makeOrder/shared_data.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class SelectMeals extends StatefulWidget {
  const SelectMeals({super.key});
  @override
  State<SelectMeals> createState() => _SelectMealsState();
}

class _SelectMealsState extends State<SelectMeals> {
  User? user = FirebaseAuth.instance.currentUser;
  int _selectedIndex = 0;
  bool isLoadingCategories = true;
  DocumentSnapshot? userInfo;
  DocumentSnapshot? restInfo;
  List<DocumentSnapshot> categoriesList = [];
  List<DocumentSnapshot> mealsList = [];
  List<DocumentSnapshot<Object?>> selectedMeals = [];
  List<DocumentSnapshot<Object?>> selectedMealsWithoutR = [];
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
      await getCategories();
      isLoadingCategories = false;
    }
    setState(() {});
  }

  getCategories() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(userInfo!['restId'])
        .collection('categories')
        .get();
    categoriesList.clear();
    categoriesList.addAll(querySnapshot.docs);
    await getCategoryMeals(categoriesList[_selectedIndex].id);
  }

  getCategoryMeals(String id) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(userInfo!['restId'])
        .collection('categories')
        .doc(id)
        .collection('meals')
        .get();
    mealsList.clear();
    mealsList.addAll(querySnapshot.docs);
  }

  int getMealNum(var meal) {
    var count = 0;
    for (var m in selectedMeals) {
      if (m.id == meal.id) {
        count++;
      }
    }
    return count;
  }

  void removeMealFromOrder(var meal) {
    for (var m in selectedMeals) {
      if (m.id == meal.id) {
        selectedMeals.remove(m);
        break;
      }
    }
  }

  bool isSelected(var meal) {
    for (var m in selectedMeals) {
      if (m.id == meal.id) {
        return true;
      }
    }
    return false;
  }

  int getTotalPrice() {
    var count = 0;
    for (var m in selectedMeals) {
      count = count + int.parse(m['Price']);
    }
    return count;
  }

  Future<String> createPdfFile(String fileName, String dateString) async {
    final pdf = pw.Document();
    Uint8List logoBytes;
    try {
      final response = await http.get(Uri.parse(restInfo!['imgUrl']));
      if (response.statusCode == 200) {
        logoBytes = response.bodyBytes;
      } else {
        throw Exception('Failed');
      }
    } catch (e) {
      print(e);
      logoBytes = Uint8List(0);
    }
    pdf.addPage(
      pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  if (logoBytes.isNotEmpty)
                    pw.ClipOval(
                      child: pw.Image(pw.MemoryImage(logoBytes),
                          width: 80, height: 80, fit: pw.BoxFit.cover),
                    ),
                  pw.SizedBox(height: 10),
                  pw.Text(restInfo!['Name'],
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 10),
                  pw.Text(
                      SharedData.selectedHall +
                          ' Table ' +
                          SharedData.selectedHallNum,
                      style: pw.TextStyle(
                          fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 10),
                  pw.Text(dateString, style: pw.TextStyle(fontSize: 20)),
                  pw.SizedBox(height: 20),
                  pw.TableHelper.fromTextArray(
                    headers: ['Item', 'Quantity', 'Unit Price', 'Total'],
                    data: selectedMealsWithoutR.map((item) {
                      final qty = getMealNum(item);
                      final total = qty * int.parse(item['Price']);
                      return [
                        item['Name'],
                        qty.toString(),
                        '${item['Price'].toString()} DZ',
                        '${total.toString()} DZ'
                      ];
                    }).toList(),
                    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    headerDecoration:
                        pw.BoxDecoration(color: PdfColors.grey300),
                    border: pw.TableBorder.all(color: PdfColors.grey600),
                    cellAlignment: pw.Alignment.centerLeft,
                  ),
                  pw.SizedBox(height: 20),

                  // Summary
                  pw.Divider(),
                  pw.Align(
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                            "Total Quantity : ${selectedMeals.length.toString()} ",
                            style: pw.TextStyle(
                                fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.Text("Total Price : ${getTotalPrice()} DZ",
                            style: pw.TextStyle(
                                fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      ],
                    ),
                  ),
                  pw.Divider(),
                  pw.SizedBox(height: 30),
                  // Footer
                  pw.Center(
                    child: pw.Text(
                      "Thank you for dining with us!",
                      style: pw.TextStyle(
                          fontSize: 14, fontStyle: pw.FontStyle.italic),
                    ),
                  ),
                ]);
          }),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/ex.pdf");

    await file.writeAsBytes(await pdf.save());

    final storageRef = FirebaseStorage.instance.ref(fileName);
    await storageRef.putFile(file);
    final pdfUrl = storageRef.getDownloadURL();

    return pdfUrl;
  }

  @override
  void initState() {
    super.initState();
    if (categoriesList.isEmpty) getRestInfo();
  }

  void _showMealsBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    for (var meal in selectedMeals) {
      if (!selectedMealsWithoutR.any((m) => m.id == meal.id)) {
        selectedMealsWithoutR.add(meal);
      }
    }
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
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                "Order Details",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ),
            Divider(
              height: 1,
              color: theme.primaryColorLight,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: selectedMealsWithoutR.length,
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
                                    "${getMealNum(selectedMealsWithoutR[index])}",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    selectedMealsWithoutR[index]['Name'],
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
                                    (int.parse(
                                              selectedMealsWithoutR[index]
                                                  ['Price'],
                                            ) *
                                            getMealNum(
                                                selectedMealsWithoutR[index]))
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
                    selectedMeals.length.toString(),
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
              child: ElevatedButton(
                onPressed: () async {
                  AwesomeDialog(
                      context: context,
                      dialogType: DialogType.noHeader,
                      animType: AnimType.scale,
                      dismissOnTouchOutside: false,
                      dismissOnBackKeyPress: false,
                      body: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            "Please wait ..",
                            style: TextStyle(fontSize: 16),
                          )
                        ],
                      )).show();
                  try {
                    var order = await FirebaseFirestore.instance
                        .collection('restaurants')
                        .doc(userInfo!['restId'])
                        .collection('orders')
                        .doc();
                    final DateTime date = DateTime.now();
                    final billUrl = await createPdfFile(
                        restInfo!['Name'] +
                            '_' +
                            DateTime(date.year, date.month, date.day, date.hour,
                                    date.minute, date.second)
                                .toString(),
                        DateTime(date.year, date.month, date.day, date.hour,
                                date.minute, date.second)
                            .toString());
                    order.set({
                      'hallName': SharedData.selectedHall,
                      'tableNum': SharedData.selectedHallNum,
                      'totalPrice': getTotalPrice(),
                      'status': 'Current',
                      'billStatus': 'notPaid',
                      'date': DateTime.now(),
                      'notServedNum': selectedMeals.length,
                      'billUrl': billUrl
                    });
                    FirebaseFirestore.instance
                        .collection('restaurants')
                        .doc(userInfo!['restId'])
                        .collection('halls')
                        .doc(SharedData.selectedHall)
                        .collection('tables')
                        .doc(SharedData.selectedHallNum)
                        .update({
                      'status': 'Taken',
                      'currentOrder': order.id,
                    });
                    for (int i = 1; i <= selectedMeals.length; i++) {
                      await FirebaseFirestore.instance
                          .collection('restaurants')
                          .doc(userInfo!['restId'])
                          .collection('orderMeals')
                          .doc()
                          .set({
                        'Name': selectedMeals[i - 1]['Name'],
                        'Price': selectedMeals[i - 1]['Price'],
                        'status': 'To prepare',
                        'mealId': selectedMeals[i - 1].id,
                        'orderId': order.id,
                        'imgUrl': selectedMeals[i - 1]['imgUrl']
                      });
                    }
                    Navigator.of(context).pop();
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.success,
                      dialogBackgroundColor: Color.fromARGB(255, 255, 253, 245),
                      animType: AnimType.rightSlide,
                      title: 'success',
                      titleTextStyle: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                        fontSize: 20,
                      ),
                      desc: 'Order Confirmed',
                      descTextStyle: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                      ),
                      btnOkOnPress: () {
                        setState(() {
                          Navigator.pushReplacementNamed(context, 'home');
                        });
                      },
                      btnOkColor: Theme.of(context).primaryColor,
                    ).show();
                  } catch (e) {
                    Navigator.of(context).pop();
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
                      desc: 'Filed to Confirm Order',
                      descTextStyle: TextStyle(
                        color: Theme.of(context).primaryColorDark,
                      ),
                      btnOkOnPress: () {
                        setState(() {
                          Navigator.pushReplacementNamed(context, 'home');
                        });
                      },
                      btnOkColor: Theme.of(context).primaryColor,
                    ).show();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  "confirm order",
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
                          color: theme.primaryColor),
                    ),
                  ),
                ],
              ),
              Container(
                height: 60,
                child: isLoadingCategories
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
                        itemCount: categoriesList.length,
                        itemBuilder: (context, index) {
                          bool isActive = index == _selectedIndex;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: GestureDetector(
                              onTap: () async {
                                await getCategoryMeals(
                                    categoriesList[index].id);
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
                                    categoriesList[index]['Name'],
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
                child: SingleChildScrollView(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(
                        top: 20, left: 20, right: 20, bottom: 80),
                    itemCount: mealsList.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          if (!isSelected(mealsList[index])) {
                            selectedMeals.add(mealsList[index]);
                          }
                          setState(() {});
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 4),
                          padding: const EdgeInsets.only(
                              top: 4, left: 4, right: 8, bottom: 4),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12)),
                            border: Border(
                              left: BorderSide(
                                  color: theme.primaryColorDark, width: 1.50),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                height: 85,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        mealsList[index]['imgUrl']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Expanded(
                                  child: Container(
                                padding: EdgeInsets.all(2),
                                height: 90,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          mealsList[index]['Name'],
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: theme.primaryColorDark,
                                          ),
                                        ),
                                        Text(
                                          mealsList[index]['Description'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: theme.primaryColorDark
                                                .withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  mealsList[index]['Price'],
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        theme.primaryColorDark,
                                                  ),
                                                ),
                                                Text(
                                                  "DZ",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: theme.primaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        if (selectedMeals.any(
                                            (m) => m.id == mealsList[index].id))
                                          Row(
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  removeMealFromOrder(
                                                      mealsList[index]);

                                                  setState(() {});
                                                },
                                                icon: Icon(
                                                  Icons.remove_circle_rounded,
                                                  size: 25,
                                                  color: theme.primaryColor,
                                                ),
                                              ),
                                              Text(
                                                "${getMealNum(mealsList[index])}",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: theme.primaryColorDark,
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  selectedMeals
                                                      .add(mealsList[index]);
                                                  setState(() {});
                                                },
                                                icon: Icon(
                                                  Icons.add_circle_rounded,
                                                  size: 25,
                                                  color: theme.primaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              )),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          if (selectedMeals.isNotEmpty)
            Positioned(
              right: 0,
              left: 0,
              bottom: 0,
              child: GestureDetector(
                  onTap: () {
                    _showMealsBottomSheet(context);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    decoration: BoxDecoration(
                      color: theme.primaryColorDark,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(35),
                          topRight: Radius.circular(35)),
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
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(6)),
                                color: theme.primaryColor),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedMeals.length.toString(),
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
                      ],
                    ),
                  )),
            ),
        ],
      ),
    );
  }
}
