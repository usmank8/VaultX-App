// lib/widgets/main_layout.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vaultx_solution/screens/guest_registration.dart';
import 'package:vaultx_solution/screens/home_page.dart';
import 'package:vaultx_solution/screens/notifications.dart';
import 'bottom_navbar.dart';


class MainLayout extends StatefulWidget {
  final int initialIndex;
  final Widget? child;

  const MainLayout({
    Key? key,
    this.initialIndex = 0,
    this.child,
  }) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _currentIndex;
  
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _screens = [
    const DashboardPage(),
    const NotificationsPage(),
    const GuestRegistrationForm(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle back button press
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: widget.child ?? _screens[_currentIndex],
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}