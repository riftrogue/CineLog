import 'package:flutter/material.dart';
import 'package:cinelog/features/home/home_page.dart';
import 'package:cinelog/features/review_log/review_log_search_page.dart';
import 'package:cinelog/features/activity/activity_page.dart';
import 'package:cinelog/features/profile/profile_page.dart';
import 'package:cinelog/config/app_constants.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  _AppScaffoldState createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  int _currentTab = AppConstants.homeTab;

  final List<Widget> _pages = [
    const HomePage(),
    const ReviewLogSearchPage(),
    const ActivityPage(),
    const ProfilePage(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _currentTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,  // Prevents back button from working
      child: Scaffold(
        backgroundColor: Colors.black,
        body: IndexedStack(
          index: _currentTab,
          children: _pages,
        ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.black,
          ),
          child: BottomNavigationBar(
            currentIndex: _currentTab,
            onTap: _onTabSelected,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.black,
            selectedItemColor: Colors.tealAccent,
            unselectedItemColor: Colors.grey,
            selectedIconTheme: IconThemeData(size: 28),
            unselectedIconTheme: IconThemeData(size: 24),
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add,
                    size: 16,
                  ),
                ),
                label: 'Review Log',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.local_activity_sharp),
                label: 'Activity',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
