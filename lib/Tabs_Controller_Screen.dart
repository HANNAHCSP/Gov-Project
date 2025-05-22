import 'dart:math';
import 'forums_page.dart';
import 'messages_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/Authprovider.dart';
import 'HomePage.dart';
import 'maindrawer.dart';
import 'emergency_page.dart';

class TabsControllerScreen extends StatefulWidget {
  @override
  _TabsControllerScreenState createState() => _TabsControllerScreenState();
}

class _TabsControllerScreenState extends State<TabsControllerScreen> {
  var selectedTabIndex = 0;
  final List<Widget> tabs = [
    HomePage(),
    ForumsPage(),
    MessagesPage(),
    EmergencyPage(),
  ];

  // Add a list of tab titles corresponding to each tab
  final List<String> tabTitles = ['Home', 'Forums', 'Messages', 'Emergency'];

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/');
      });
    }
  }

  void switchPage(int index) {
    setState(() {
      selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tabTitles[selectedTabIndex], // Dynamic title based on selected tab
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.red[700],
        elevation: 0,
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, size: 26),
            onPressed: () {
              authProvider.logoutOfAccount();
              Navigator.of(context).pushReplacementNamed('/');
            },
            tooltip: 'Logout',
          ),
        ],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: Maindrawer(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
          child: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_filled),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.forum_outlined),
                activeIcon: Icon(Icons.forum),
                label: 'Forums', 
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.message_outlined),
                activeIcon: Icon(Icons.message),
                label: 'Messages',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.emergency_outlined),
                activeIcon: Icon(Icons.emergency),
                label: 'Emergency', 
              ),
            ],
            currentIndex: selectedTabIndex,
            onTap: switchPage,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.red[700],
            unselectedItemColor: Colors.grey[600],
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            elevation: 10,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red[50]!, Colors.white],
          ),
        ),
        child: IndexedStack(index: selectedTabIndex, children: tabs),
      ),
    );
  }
}
