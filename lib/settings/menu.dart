import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:restron1/makeOrder/shared_data.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});
  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  User? user = FirebaseAuth.instance.currentUser;
  List<DocumentSnapshot> menus = [];
  bool isLoading = true;
  bool _showForm = false;
  bool isEditing = false;
  bool _showQRcode = false;
  int selectedMenu = 0;
  File? file;
  String? url;
  TextEditingController _menuNameController = TextEditingController();

  Future<void> fetchMenus() async {
    if (user == null) return;
    try {
      QuerySnapshot Snapshot = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(SharedData.restId)
          .collection('menus')
          .get();
      setState(() {
        menus = Snapshot.docs;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

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
    }
    setState(() {});
  }

  Future<void> deleteMenu(String id) async {
    await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(SharedData.restId)
        .collection('menus')
        .doc(id)
        .delete();
  }

  @override
  void initState() {
    super.initState();
    fetchMenus();
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
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  url = '';
                  _showForm = true;
                  isEditing = false;
                });
              },
              icon: const Icon(
                Icons.add_circle,
                size: 30,
              ),
              color: theme.primaryColor,
            ),
          ],
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
            "Menus",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: theme.primaryColor,
            ),
          ),
        ),
        body: GestureDetector(
          onTap: () {
            setState(() {
              url = '';
              _showForm = false;
              isEditing = false;
              _menuNameController.text = '';
            });
          },
          child: Stack(
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
                        padding: const EdgeInsets.symmetric(vertical: 10),
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
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.only(
                                          top: 20, left: 30, right: 30),
                                      itemCount: menus.length,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedMenu = index;
                                                _showForm = true;
                                                isEditing = true;
                                                url = menus[index]['imgUrl'];
                                                _menuNameController.text =
                                                    menus[index]['Name'];
                                              });
                                            },
                                            child: Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 6,
                                                        horizontal: 4),
                                                padding:
                                                    const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: theme.cardColor,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: theme.shadowColor,
                                                      spreadRadius: 0,
                                                      blurRadius: 14,
                                                      offset:
                                                          const Offset(2, 2),
                                                    )
                                                  ],
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(12)),
                                                ),
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      height: 160,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            const BorderRadius
                                                                .only(
                                                                topRight: Radius
                                                                    .circular(
                                                                        10),
                                                                topLeft: Radius
                                                                    .circular(
                                                                        10)),
                                                        image: DecorationImage(
                                                          image: NetworkImage(
                                                              menus[index]
                                                                  ['imgUrl']),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          menus[index]['Name'],
                                                          style: TextStyle(
                                                              color: theme
                                                                  .primaryColorDark,
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                        IconButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                _showQRcode =
                                                                    true;
                                                                selectedMenu =
                                                                    index;
                                                              });
                                                            },
                                                            icon: Icon(
                                                              Icons.qr_code,
                                                              color: theme
                                                                  .primaryColor,
                                                            ))
                                                      ],
                                                    )
                                                  ],
                                                )));
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
              if (_showForm)
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
                                isEditing ? "Edit menu" : "Add Menu",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (url == "")
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: theme.primaryColorLight,
                                        border: Border.all(
                                          color: theme.primaryColor,
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.image,
                                        size: 40,
                                        color: theme.primaryColorDark
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                  if (url != "")
                                    CircleAvatar(
                                        radius: 45,
                                        backgroundImage:
                                            NetworkImage(url.toString())),
                                  Positioned(
                                      bottom: 3,
                                      right: 2,
                                      child: Container(
                                          width: 24,
                                          height: 24,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color: theme.cardColor,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(30))),
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                right: -12,
                                                top: -12,
                                                child: IconButton(
                                                  alignment: Alignment.center,
                                                  onPressed: () async {
                                                    await getImage();
                                                  },
                                                  icon: const Icon(
                                                    Icons.add_circle_rounded,
                                                    size: 25,
                                                  ),
                                                  color: theme.primaryColor,
                                                ),
                                              )
                                            ],
                                          ))),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              autofocus: true,
                              controller: _menuNameController,
                              decoration: InputDecoration(
                                hintText: 'Menu name',
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    isEditing
                                        ? await FirebaseFirestore.instance
                                            .collection('restaurants')
                                            .doc(SharedData.restId)
                                            .collection('menus')
                                            .doc(menus[selectedMenu].id)
                                            .update({
                                            'Name': _menuNameController.text,
                                            'imgUrl': url,
                                          })
                                        : await FirebaseFirestore.instance
                                            .collection('restaurants')
                                            .doc(SharedData.restId)
                                            .collection('menus')
                                            .doc()
                                            .set({
                                            'Name': _menuNameController.text,
                                            'imgUrl': url,
                                          });
                                    await fetchMenus();
                                    setState(() {
                                      url = '';
                                      _showForm = false;
                                      isEditing = false;
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
                                    if (isEditing)
                                      deleteMenu(menus[selectedMenu].id);
                                    setState(() {
                                      selectedMenu = 0;
                                      _showForm = false;
                                      isEditing = false;
                                      url = '';
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  child: Text(
                                    isEditing ? "Delete" : "Cancel",
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
                                menus[selectedMenu]['Name'],
                                style: TextStyle(
                                  fontSize: 22,
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
                                  data: menus[selectedMenu]['imgUrl'],
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
                                    if (isEditing)
                                      deleteMenu(menus[selectedMenu].id);
                                    setState(() {
                                      selectedMenu = 0;
                                      _showQRcode = false;
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
        ));
  }
}
