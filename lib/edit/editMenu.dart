import 'dart:io';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class EditMenu extends StatefulWidget {
  const EditMenu({super.key});
  @override
  State<EditMenu> createState() => _EditMenuState();
}

class _EditMenuState extends State<EditMenu> {
  User? user = FirebaseAuth.instance.currentUser;
  int _selectedIndex = 0; // To track selected category
  int _selectedMealIndex = 0;
  bool _showCategoryForm = false; // To control category form visibility
  bool _showMealForm = false; // To control meal form visibility
  TextEditingController _categoryNameController = TextEditingController();
  TextEditingController _mealNameController = TextEditingController();
  TextEditingController _mealDescriptionController = TextEditingController();
  TextEditingController _mealPriceController = TextEditingController();
  bool _isEditingCategory = false;
  bool _isEditingMeal = false;
  var isLoadingCategories = true;
  List<DocumentSnapshot> categoriesList = [];
  List<DocumentSnapshot> mealsList = [];
  File? file;
  String? url;

  getCategories() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(user!.uid)
        .collection('categories')
        .get();
    categoriesList.clear();
    categoriesList.addAll(querySnapshot.docs);
    await getCategoryMeals(categoriesList[_selectedIndex].id);
    setState(() {
      isLoadingCategories = false;
    });
  }

  getCategoryMeals(String id) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(user!.uid)
        .collection('categories')
        .doc(id)
        .collection('meals')
        .get();
    mealsList.clear();
    mealsList.addAll(querySnapshot.docs);
  }

  deleteCategory(String id) async {
    await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(user!.uid)
        .collection('categories')
        .doc(id)
        .delete();
    setState(() {
      _selectedIndex = 0;
      _showCategoryForm = false;
    });
  }

  deleteMeal(String id, String mealID) async {
    await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(user!.uid)
        .collection('categories')
        .doc(id)
        .collection('meals')
        .doc(mealID)
        .delete();
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

      var newDoc = FirebaseFirestore.instance
          .collection('restaurants')
          .doc(user!.uid)
          .collection('categories')
          .doc(categoriesList[_selectedIndex].id);
      await newDoc.update({'imgUrl': url});
    }
    setState(() {});
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    _mealNameController.dispose();
    _mealDescriptionController.dispose();
    _mealPriceController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getCategories();
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
          "Edit Meals",
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
                _showCategoryForm = false;
                _showMealForm = false;
                url = '';
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
                          itemCount: categoriesList.length + 1,
                          itemBuilder: (context, index) {
                            if (index == categoriesList.length) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.add_circle_rounded,
                                    size: 25,
                                    color: theme.primaryColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _showCategoryForm = true;
                                      _isEditingCategory = false;
                                      _categoryNameController.clear();
                                    });
                                  },
                                ),
                              );
                            }
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
                                    _showCategoryForm = false;
                                    _showMealForm = false;
                                  });
                                },
                                onLongPress: () async {
                                  await getCategoryMeals(
                                      categoriesList[index].id);
                                  setState(() {
                                    _selectedIndex = index;
                                    _showCategoryForm = true;
                                    _isEditingCategory = true;
                                    _categoryNameController.text =
                                        categoriesList[index]['Name'];
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
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(
                        top: 20, left: 20, right: 20, bottom: 20),
                    itemCount: mealsList.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
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
                                        color: theme.primaryColorDark,
                                        width: 1.50))),
                            child: Row(
                              children: [
                                Container(
                                  width: 80,
                                  height: 85,
                                  margin: const EdgeInsets.only(right: 16),
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
                                  height: 85,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            mealsList[index]["Name"]!,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: theme.primaryColorDark,
                                            ),
                                          ),
                                          Text(
                                            mealsList[index]["Description"]!,
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
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            mealsList[index]['Price'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: theme.primaryColorDark,
                                            ),
                                          ),
                                          Text(
                                            " DZ",
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
                                )),
                              ],
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: IconButton(
                              icon: Icon(
                                Icons.edit_note,
                                color: theme.primaryColor,
                                size: 28,
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedMealIndex = index;
                                  _showMealForm = true;
                                  _isEditingMeal = true;
                                  _mealNameController.text =
                                      mealsList[index]["Name"]!;
                                  url = mealsList[index]["imgUrl"]!;
                                  _mealDescriptionController.text =
                                      mealsList[index]["Description"]!;
                                  _mealPriceController.text =
                                      mealsList[index]["Price"]!.split(" ")[0];
                                });
                              },
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_showCategoryForm)
            Center(
              child: SingleChildScrollView(
                // Added to make form scrollable
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
                            _isEditingCategory
                                ? "Edit Category"
                                : "Add Category",
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
                          controller: _categoryNameController,
                          decoration: InputDecoration(
                            hintText: 'Category Name',
                            hintStyle: TextStyle(
                                fontSize: 16,
                                color: theme.primaryColorDark.withOpacity(0.7)),
                            border: OutlineInputBorder(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(35)),
                              borderSide: BorderSide(
                                  color: theme.primaryColor, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: theme.primaryColor, width: 1),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(35)),
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
                                await FirebaseFirestore.instance
                                    .collection('restaurants')
                                    .doc(user!.uid)
                                    .collection('categories')
                                    .doc()
                                    .set({
                                  'Name': _categoryNameController.text,
                                });
                                await getCategories();
                                setState(() {
                                  _showCategoryForm = false;
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
                                await deleteCategory(
                                    categoriesList[_selectedIndex].id);
                                await getCategories();
                                setState(() {
                                  _selectedIndex = 0;
                                  _showCategoryForm = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Text(
                                _isEditingCategory ? "Delete" : "Cancel",
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
          if (_showMealForm)
            Center(
              child: SingleChildScrollView(
                // Added to make form scrollable
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
                            _isEditingMeal ? "Edit Meal" : "Add Meal",
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
                                    color:
                                        theme.primaryColorDark.withOpacity(0.7),
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
                          controller: _mealNameController,
                          decoration: InputDecoration(
                            hintText: 'Meal name',
                            hintStyle: TextStyle(
                                fontSize: 16,
                                color: theme.primaryColorDark.withOpacity(0.7)),
                            border: OutlineInputBorder(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(35)),
                              borderSide: BorderSide(
                                  color: theme.primaryColor, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: theme.primaryColor, width: 1),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(35)),
                            ),
                            filled: true,
                            fillColor: theme.cardColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _mealDescriptionController,
                          decoration: InputDecoration(
                            hintText: 'Meal description',
                            hintStyle: TextStyle(
                                fontSize: 16,
                                color: theme.primaryColorDark.withOpacity(0.7)),
                            border: OutlineInputBorder(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(35)),
                              borderSide: BorderSide(
                                  color: theme.primaryColor, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: theme.primaryColor, width: 1),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(35)),
                            ),
                            filled: true,
                            fillColor: theme.cardColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _mealPriceController,
                          decoration: InputDecoration(
                            hintText: 'Meal price',
                            hintStyle: TextStyle(
                                fontSize: 16,
                                color: theme.primaryColorDark.withOpacity(0.7)),
                            border: OutlineInputBorder(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(35)),
                              borderSide: BorderSide(
                                  color: theme.primaryColor, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: theme.primaryColor, width: 1),
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
                                _isEditingMeal
                                    ? await FirebaseFirestore.instance
                                        .collection('restaurants')
                                        .doc(user!.uid)
                                        .collection('categories')
                                        .doc(categoriesList[_selectedIndex].id)
                                        .collection('meals')
                                        .doc(mealsList[_selectedMealIndex].id)
                                        .set({
                                        'Name': _mealNameController.text,
                                        'Description':
                                            _mealDescriptionController.text,
                                        'Price': _mealPriceController.text,
                                      })
                                    : await FirebaseFirestore.instance
                                        .collection('restaurants')
                                        .doc(user!.uid)
                                        .collection('categories')
                                        .doc(categoriesList[_selectedIndex].id)
                                        .collection('meals')
                                        .doc()
                                        .set({
                                        'Name': _mealNameController.text,
                                        'Description':
                                            _mealDescriptionController.text,
                                        'Price': _mealPriceController.text,
                                        'imgUrl': url,
                                      });
                                await getCategoryMeals(
                                    categoriesList[_selectedIndex].id);
                                setState(() {
                                  url = '';
                                  _showMealForm = false;
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
                                if (_isEditingMeal) {
                                  await deleteMeal(
                                      categoriesList[_selectedIndex].id,
                                      mealsList[_selectedMealIndex].id);
                                  await getCategoryMeals(
                                      categoriesList[_selectedIndex].id);
                                }
                                setState(() {
                                  _showMealForm = false;
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
                                _isEditingMeal ? "Delete" : "Cancel",
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
          if (!_showCategoryForm && !_showMealForm)
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
                        onPressed: () {
                          setState(() {
                            _showMealForm = true;
                            url = '';
                            _isEditingMeal = false;
                            _mealNameController.clear();
                            _mealDescriptionController.clear();
                            _mealPriceController.clear();
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
