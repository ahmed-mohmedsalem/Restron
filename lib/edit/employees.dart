import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:restron1/makeOrder/shared_data.dart';

class Employees extends StatefulWidget {
  const Employees({super.key});
  @override
  State<Employees> createState() => _EmployeesState();
}

class _EmployeesState extends State<Employees> {
  User? user = FirebaseAuth.instance.currentUser;
  List<DocumentSnapshot> pendingRequests = [];
  List<DocumentSnapshot> acceptedEmployees = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    if (user == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot pendingSnapshot = await FirebaseFirestore.instance
          .collection('requests')
          .where('status', isEqualTo: 'Pending')
          .where('RestId', isEqualTo: SharedData.requestId)
          .get();

      QuerySnapshot acceptedSnapshot = await FirebaseFirestore.instance
          .collection('requests')
          .where('status', isEqualTo: 'Accepted')
          .where('RestId', isEqualTo: SharedData.requestId)
          .get();

      setState(() {
        pendingRequests = pendingSnapshot.docs;
        acceptedEmployees = acceptedSnapshot.docs;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching requests: $e')),
      );
    }
  }

  Future<void> updateRequestStatus(String requestId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .update({'status': newStatus});
      await fetchRequests();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.primaryColorDark,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: theme.primaryColorDark,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 30,
          ),
          color: theme.primaryColor,
        ),
        title: Text(
          "Employees",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: theme.primaryColor,
          ),
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
                  color: theme.primaryColorDark,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.primaryColorLight,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(60),
                        topRight: Radius.circular(60),
                      ),
                    ),
                    child: isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: theme.primaryColor,
                            ),
                          )
                        : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 10),
                                  child: Text(
                                    "Requests",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: theme.primaryColorDark,
                                    ),
                                  ),
                                ),
                                Divider(
                                  height: 1,
                                  color: theme.cardColor,
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.only(
                                      top: 20, left: 30, right: 30),
                                  itemCount: pendingRequests.length,
                                  itemBuilder: (context, index) {
                                    final request = pendingRequests[index];
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 6, horizontal: 4),
                                      padding: const EdgeInsets.only(
                                          top: 4, left: 4, right: 8, bottom: 4),
                                      decoration: BoxDecoration(
                                        color: theme.cardColor,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(12)),
                                        border: Border(
                                          left: BorderSide(
                                            color: theme.primaryColorDark,
                                            width: 1.50,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 60,
                                            height: 60,
                                            margin: const EdgeInsets.only(
                                                right: 16),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: theme.primaryColor,
                                            ),
                                            child: Icon(
                                              Icons.person,
                                              size: 40,
                                              color: theme.primaryColorLight,
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      request['Name'] ??
                                                          'Unknown',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: theme
                                                            .primaryColorDark,
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        IconButton(
                                                          icon: Icon(
                                                            Icons.close,
                                                            color: theme
                                                                .primaryColor,
                                                            size: 24,
                                                          ),
                                                          onPressed: () async {
                                                            updateRequestStatus(
                                                                request.id,
                                                                'Rejected');
                                                          },
                                                        ),
                                                        IconButton(
                                                          icon: Icon(
                                                            Icons.check_circle,
                                                            color: theme
                                                                .primaryColor,
                                                            size: 24,
                                                          ),
                                                          onPressed: () async {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'users')
                                                                .doc(request[
                                                                    'employeeId'])
                                                                .update({
                                                              'accounttype':
                                                                  'Employee',
                                                              'restId':
                                                                  user?.uid
                                                            });
                                                            updateRequestStatus(
                                                                request.id,
                                                                'Accepted');
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 10),
                                  child: Text(
                                    "Employees",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: theme.primaryColorDark,
                                    ),
                                  ),
                                ),
                                Divider(
                                  height: 1,
                                  color: theme.cardColor,
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.only(
                                      top: 20, left: 30, right: 30, bottom: 20),
                                  itemCount: acceptedEmployees.length,
                                  itemBuilder: (context, index) {
                                    final employee = acceptedEmployees[index];
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 6, horizontal: 4),
                                      padding: const EdgeInsets.only(
                                          top: 4, left: 4, right: 8, bottom: 4),
                                      decoration: BoxDecoration(
                                        color: theme.cardColor,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(12)),
                                        border: Border(
                                          left: BorderSide(
                                            color: theme.primaryColorDark,
                                            width: 1.50,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 60,
                                            height: 60,
                                            margin: const EdgeInsets.only(
                                                right: 16),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: theme.primaryColor,
                                            ),
                                            child: Icon(
                                              Icons.person,
                                              size: 40,
                                              color: theme.primaryColorLight,
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      employee['Name'] ??
                                                          'Unknown',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: theme
                                                            .primaryColorDark,
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons.close,
                                                        color:
                                                            theme.primaryColor,
                                                        size: 24,
                                                      ),
                                                      onPressed: () async {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection('users')
                                                            .doc(employee[
                                                                'employeeId'])
                                                            .update({
                                                          'accounttype': '',
                                                          'restId': ''
                                                        });
                                                        updateRequestStatus(
                                                            employee.id,
                                                            'Rejected');
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
