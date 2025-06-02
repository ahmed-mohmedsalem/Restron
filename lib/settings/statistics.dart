import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Statistics extends StatefulWidget {
  const Statistics({super.key});
  @override
  State<Statistics> createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  bool _showWeekly = true;
  User? user = FirebaseAuth.instance.currentUser;

  Map<String, dynamic>? _cachedSalesData;
  List<Map<String, dynamic>>? _cachedTopMeals;
  bool _isInitialSalesLoading = true;
  bool _isInitialTopMealsLoading = true;
  int _selectedDayIndex = DateTime.now().weekday - 1;

  Future<List<Map<String, dynamic>>> _fetchTopMeals() async {
    if (_cachedTopMeals != null) {
      return _cachedTopMeals!;
    }

    List<Map<String, dynamic>> allMeals = [];
    QuerySnapshot mealsSnapshot = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(user!.uid)
        .collection('orderMeals')
        .get();
    bool isCounted = false;
    for (var meal in mealsSnapshot.docs) {
      for (var m in allMeals) {
        if (m['name'] == meal['Name']) {
          isCounted = true;
          m['timesOrdered']++;
          break;
        }
      }
      if (!isCounted) {
        allMeals.add({
          'name': meal['Name'],
          'imgUrl': meal['imgUrl'],
          'timesOrdered': 1,
        });
        isCounted = false;
      }
    }

    allMeals.sort((a, b) => b['timesOrdered'].compareTo(a['timesOrdered']));
    _cachedTopMeals = allMeals.take(3).toList();
    setState(() {
      _isInitialTopMealsLoading = false;
    });
    return _cachedTopMeals!;
  }

  Future<Map<String, dynamic>> _fetchSalesData() async {
    if (_cachedSalesData != null) {
      return _cachedSalesData!;
    }
    DateTime now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 4, 1)).inDays + 1;
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysInPrevMonth = DateTime(now.year, now.month, 0).day;
    List<double> weeklyData = List.filled(7, 0.0);
    List<double> monthlyData = List.filled(daysInMonth, 0.0);
    List<double> yearlyData = List.filled(dayOfYear, 0.0);
    List<String> labelsWeekly = [
      'mon',
      'tue',
      'wed',
      'thu',
      'fri',
      'sat',
      'sun',
    ];
    List<String> labelsMonthly =
        List.generate(daysInMonth, (index) => (index + 1).toString());
    double weeklyTotalSales = 0.0;
    double monthlyTotalSales = 0.0;
    double prevWeeklyTotalSales = 0.0;
    double prevMonthlyTotalSales = 0.0;
    double yearlyTotalSales = 0.0;
    double maxSales = 0.0;

    // Fetch current week
    for (int i = 0; i < now.weekday; i++) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateTime(date.year, date.month, date.day).toString();
      final doc = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(user!.uid)
          .collection('days')
          .doc(dateStr)
          .get();
      if (doc.exists && doc.data()!['tSales'] != null) {
        weeklyData[now.weekday - 1 - i] =
            (doc.data()!['tSales'] as num).toDouble();
        weeklyTotalSales += weeklyData[now.weekday - 1 - i];
        if (weeklyData[now.weekday - 1 - i] > maxSales) {
          maxSales = weeklyData[now.weekday - 1 - i];
        }
      }
    }

    // Fetch previous week
    for (int i = now.weekday; i < (now.weekday + 7); i++) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateTime(date.year, date.month, date.day).toString();
      final doc = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(user!.uid)
          .collection('days')
          .doc(dateStr)
          .get();
      if (doc.exists && doc.data()!['tSales'] != null) {
        prevWeeklyTotalSales += (doc.data()!['tSales'] as num).toDouble();
      }
    }

    // Fetch current month
    for (int i = 0; i < now.day; i++) {
      final date = DateTime(now.year, now.month, now.day - i);
      final dateStr = DateTime(date.year, date.month, date.day).toString();
      final doc = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(user!.uid)
          .collection('days')
          .doc(dateStr)
          .get();
      if (doc.exists && doc.data()!['tSales'] != null) {
        monthlyData[now.day - 1 - i] =
            (doc.data()!['tSales'] as num).toDouble();
        monthlyTotalSales += monthlyData[now.day - 1 - i];
        if (monthlyData[now.day - 1 - i] > maxSales) {
          maxSales = monthlyData[now.day - 1 - i];
        }
      }
    }

    // Fetch previous month
    for (int i = now.day; i < (daysInPrevMonth + now.day); i++) {
      final date =
          DateTime(now.year, now.month - 1, (daysInPrevMonth + now.day) - i);
      final dateStr = DateTime(date.year, date.month, date.day).toString();
      final doc = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(user!.uid)
          .collection('days')
          .doc(dateStr)
          .get();
      if (doc.exists && doc.data()!['tSales'] != null) {
        prevMonthlyTotalSales += (doc.data()!['tSales'] as num).toDouble();
      }
    }

    for (int i = 0; i < dayOfYear; i++) {
      final date = DateTime(now.year, 4, 1).add(Duration(days: i));
      final dateStr = DateTime(date.year, date.month, date.day).toString();
      final doc = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(user!.uid)
          .collection('days')
          .doc(dateStr)
          .get();
      if (doc.exists && doc.data()!['tSales'] != null) {
        yearlyTotalSales += (doc.data()!['tSales'] as num).toDouble();
      }
    }

    // Calculate average sales
    double weeklyAverageSales = weeklyTotalSales / 7;
    double monthlyAverageSales = monthlyTotalSales / daysInMonth;

    // Calculate percentage changes
    double weeklyPercentage = weeklyTotalSales == 0
        ? 0
        : ((weeklyTotalSales - prevWeeklyTotalSales) / prevWeeklyTotalSales) *
            100;
    double monthlyPercentage = monthlyTotalSales == 0
        ? 0
        : ((monthlyTotalSales - prevMonthlyTotalSales) /
                prevMonthlyTotalSales) *
            100;

    final data = {
      'weeklyData': weeklyData,
      'monthlyData': monthlyData,
      'yearlyData': yearlyData,
      'labelsWeekly': labelsWeekly,
      'labelsMonthly': labelsMonthly,
      'weeklyAverageSales': weeklyAverageSales,
      'monthlyAverageSales': monthlyAverageSales,
      'weeklyTotalSales': weeklyTotalSales,
      'monthlyTotalSales': monthlyTotalSales,
      'yearlyTotalSales': yearlyTotalSales,
      'weeklyPercentage': weeklyPercentage,
      'monthlyPercentage': monthlyPercentage,
      'maxSales': maxSales,
      'daysInMonth': daysInMonth,
    };
    _cachedSalesData = data;
    setState(() {
      _isInitialSalesLoading = false;
    });

    return data;
  }

  @override
  void initState() {
    super.initState();
    _fetchSalesData();
    _fetchTopMeals();
  }

  Widget _buildCustomBarChart(BuildContext context) {
    final theme = Theme.of(context);

    if (_isInitialSalesLoading) {
      return Container(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(
            color: theme.primaryColor,
          ),
        ),
      );
    }

    final data = _cachedSalesData!;
    final salesData = _showWeekly ? data['weeklyData'] : data['monthlyData'];
    final labels = _showWeekly ? data['labelsWeekly'] : data['labelsMonthly'];
    final maxSales = data['maxSales'] as double;
    final barWidth = _showWeekly ? 16.0 : 6.0;

    return Container(
      height: 200,
      padding: const EdgeInsets.only(top: 0, right: 30, left: 30, bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(salesData.length, (index) {
          final sales = salesData[index] as double;
          double barHeight = maxSales == 0 ? 0 : (sales / maxSales) * 150;
          final isHighlighted = _selectedDayIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDayIndex = index;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: barWidth,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: isHighlighted
                          ? theme.primaryColor
                          : theme.primaryColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  if (_showWeekly) ...[
                    const SizedBox(height: 8),
                    Text(
                      labels[index],
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
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
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 30,
          ),
          color: theme.primaryColor,
        ),
        title: Text(
          "Statistics",
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
                  height: 20.0,
                  color: Theme.of(context).primaryColorDark,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColorLight,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(60),
                        topRight: Radius.circular(60),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _isInitialTopMealsLoading
                              ? Container(
                                  height: 130,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 130,
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: List.generate(
                                      _cachedTopMeals!.length > 3
                                          ? 3
                                          : _cachedTopMeals!.length,
                                      (index) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: Column(
                                          children: [
                                            Stack(
                                              children: [
                                                Container(
                                                  width: 75,
                                                  height: 75,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: theme.primaryColor,
                                                      width: 3,
                                                      style: BorderStyle.solid,
                                                    ),
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                          _cachedTopMeals![
                                                              index]['imgUrl']),
                                                      fit: BoxFit.cover,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.4),
                                                        spreadRadius: 0,
                                                        blurRadius: 14,
                                                        offset:
                                                            const Offset(2, 2),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 0,
                                                  right: 0,
                                                  child: Container(
                                                    width: 24,
                                                    height: 28,
                                                    decoration: BoxDecoration(
                                                      color: theme
                                                          .primaryColorDark,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  8)),
                                                      border: Border.all(
                                                        color: theme.cardColor,
                                                        width: 3,
                                                        style:
                                                            BorderStyle.solid,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.4),
                                                          spreadRadius: 0,
                                                          blurRadius: 14,
                                                          offset: const Offset(
                                                              2, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        "${index + 1}",
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              theme.cardColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              width: 100,
                                              child: Text(
                                                textAlign: TextAlign.center,
                                                _cachedTopMeals![index]['name'],
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: theme.primaryColorDark,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 4),
                            child: Text(
                              "Sales",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: theme.primaryColor,
                              ),
                            ),
                          ),
                          Divider(
                            height: 4,
                            color: theme.primaryColor,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _isInitialSalesLoading
                                    ? Text(
                                        "Loading...",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: theme.primaryColorDark,
                                        ),
                                      )
                                    : Row(
                                        children: [
                                          Text(
                                            (_showWeekly
                                                    ? _cachedSalesData![
                                                        'weeklyAverageSales']
                                                    : _cachedSalesData![
                                                        'monthlyAverageSales'])
                                                .toStringAsFixed(0),
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                              color: theme.primaryColorDark,
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
                                          Text(
                                            " by day",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: theme.primaryColorDark
                                                  .withOpacity(0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _showWeekly = true;
                                          _selectedDayIndex =
                                              DateTime.now().weekday - 1;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 5),
                                        decoration: BoxDecoration(
                                          border: _showWeekly
                                              ? Border.all(
                                                  color: theme.primaryColor,
                                                  width: 2,
                                                  style: BorderStyle.solid,
                                                )
                                              : null,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(21)),
                                        ),
                                        child: Text(
                                          "week",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: theme.primaryColorDark,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _showWeekly = false;
                                          _selectedDayIndex =
                                              DateTime.now().day - 1;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 5),
                                        decoration: BoxDecoration(
                                          border: !_showWeekly
                                              ? Border.all(
                                                  color: theme.primaryColor,
                                                  width: 2,
                                                  style: BorderStyle.solid,
                                                )
                                              : null,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(21)),
                                        ),
                                        child: Text(
                                          "month",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: theme.primaryColorDark,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            height: 1,
                            color: theme.cardColor,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: _isInitialSalesLoading
                                ? Text(
                                    "Loading...",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: theme.primaryColorDark,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        (_showWeekly
                                                    ? _cachedSalesData![
                                                        'weeklyData']
                                                    : _cachedSalesData![
                                                        'monthlyData'])[
                                                _selectedDayIndex]
                                            .toStringAsFixed(0),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: theme.primaryColorDark,
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
                          ),

                          _buildCustomBarChart(context),
                          Divider(
                            height: 1,
                            color: theme.cardColor,
                          ),
                          // Total Sales Stats
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 10),
                            child: Column(
                              children: [
                                if (!_isInitialSalesLoading)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColorLight,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          spreadRadius: 0,
                                          blurRadius: 14,
                                          offset: const Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Total sales this week",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                                color: theme.primaryColor,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Row(
                                              children: [
                                                Text(
                                                  _cachedSalesData![
                                                          'weeklyTotalSales']
                                                      .toStringAsFixed(0),
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        theme.primaryColorDark,
                                                  ),
                                                ),
                                                Text(
                                                  " DZ",
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: theme.primaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Text(
                                          "${_cachedSalesData!['weeklyPercentage'] >= 0 ? '+' : ''} ${(_cachedSalesData!['weeklyPercentage']).toStringAsFixed(2)}%",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: _cachedSalesData![
                                                        'weeklyPercentage'] >=
                                                    0
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 10),
                                if (!_isInitialSalesLoading)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColorLight,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          spreadRadius: 0,
                                          blurRadius: 14,
                                          offset: const Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Total sales this month",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                                color: theme.primaryColor,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Row(
                                              children: [
                                                Text(
                                                  _cachedSalesData![
                                                          'monthlyTotalSales']
                                                      .toStringAsFixed(0),
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        theme.primaryColorDark,
                                                  ),
                                                ),
                                                Text(
                                                  " DZ",
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: theme.primaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Text(
                                          "${_cachedSalesData!['monthlyPercentage'] >= 0 ? '+' : ''} ${_cachedSalesData!['monthlyPercentage'].toStringAsFixed(2)}%",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: _cachedSalesData![
                                                        'monthlyPercentage'] >=
                                                    0
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 10),
                                if (!_isInitialSalesLoading)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColorLight,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          spreadRadius: 0,
                                          blurRadius: 14,
                                          offset: const Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Total sales this year",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w800,
                                                color: theme.primaryColor,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Row(
                                              children: [
                                                Text(
                                                  _cachedSalesData![
                                                          'yearlyTotalSales']
                                                      .toStringAsFixed(0),
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        theme.primaryColorDark,
                                                  ),
                                                ),
                                                Text(
                                                  " DZ",
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: theme.primaryColor,
                                                  ),
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
