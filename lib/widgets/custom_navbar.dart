// // custom_navbar.dart

// import 'package:flutter/material.dart';

// class CustomBottomNavBar extends StatelessWidget {
//   final int currentIndex; // To track selected index
//   final ValueChanged<int> onTap; // Callback when an item is tapped

//   const CustomBottomNavBar({
//     super.key,
//     required this.currentIndex, // Pass current selected index
//     required this.onTap, // Pass the callback for navigation
//   });

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       currentIndex: currentIndex, // Set the selected index
//       selectedItemColor: Colors.white,
//       unselectedItemColor: Colors.white70,
//       backgroundColor: const Color(0xFF600f0f),
//       items: const [
//         BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Overview'),
//         BottomNavigationBarItem(
//             icon: Icon(Icons.notifications), label: 'Notification'),
//       ],
//       onTap: onTap, // Handle navigation when an item is tapped
//     );
//   }
// }
