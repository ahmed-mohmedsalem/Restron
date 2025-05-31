import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class DrawerWidget extends StatelessWidget {
  final String requestId;
  final String accountType;
  DrawerWidget({required this.accountType, required this.requestId, Key? key})
      : super(key: key);
  final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      backgroundColor: theme.primaryColorLight,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
                color: theme.primaryColorDark,
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25))),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Container(
              alignment: Alignment.center,
              color: Theme.of(context).primaryColorDark,
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.person_rounded,
                        size: 70, color: theme.primaryColor),
                    Container(height: 8),
                    Text(user!.displayName.toString(),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: theme.primaryColorLight,
                        )),
                  ],
                ),
              ),
            ),
          ),
          if (accountType == 'Admin')
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Text(
                'Restaurant ID',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: theme.primaryColor),
              ),
            ),
          if (accountType == 'Admin')
            Divider(
              height: 4,
              color: theme.primaryColor,
            ),
          if (accountType == 'Admin')
            ListTile(
              leading: Text(
                'ID',
                style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800),
              ),
              title: Text(
                requestId,
                style: TextStyle(
                  color: theme.primaryColorDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: const Icon(Icons.copy, size: 16, color: Colors.grey),
              onTap: () {
                Clipboard.setData(ClipboardData(text: requestId));
              },
            ),

          // Settings Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Text(
              'Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
          ),
          Divider(
            height: 4,
            color: theme.primaryColor,
          ),
          if (accountType == 'Admin')
            ListTile(
              leading: Icon(Icons.table_restaurant_rounded,
                  color: theme.primaryColor),
              title: Text(
                'Edit tables',
                style: TextStyle(
                  color: theme.primaryColorDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Navigator.of(context).pushNamed('editTables');
              },
            ),
          if (accountType == 'Admin')
            ListTile(
              leading: Icon(Icons.restaurant_menu, color: theme.primaryColor),
              title: Text(
                'Edit menu',
                style: TextStyle(
                  color: theme.primaryColorDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Navigator.of(context).pushNamed('editMenu');
              },
            ),
          if (accountType == 'Admin')
            ListTile(
              leading: Icon(Icons.person, color: theme.primaryColor),
              title: Text(
                'Staff management',
                style: TextStyle(
                  color: theme.primaryColorDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Navigator.of(context).pushNamed('employees');
              },
            ),
          if (accountType == 'Admin')
            ListTile(
              leading: Icon(Icons.bar_chart, color: theme.primaryColor),
              title: Text(
                'Statistics',
                style: TextStyle(
                  color: theme.primaryColorDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                Navigator.of(context).pushNamed('statistics');
              },
            ),
          ListTile(
            leading: Icon(Icons.qr_code, color: theme.primaryColor),
            title: Text(
              'QR code',
              style: TextStyle(
                color: theme.primaryColorDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              Navigator.of(context).pushNamed('menu');
            },
          ),
          ListTile(
            leading: Icon(Icons.lock, color: theme.primaryColor),
            title: Text(
              'Change Password',
              style: TextStyle(
                color: theme.primaryColorDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              Navigator.of(context).pushNamed('changePassword');
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: theme.primaryColor),
            title: Text(
              'Logout',
              style: TextStyle(
                color: theme.primaryColorDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              // ignore: use_build_context_synchronously
              Navigator.of(context)
                  .pushNamedAndRemoveUntil("login", (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
