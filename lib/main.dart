import 'package:flutter/material.dart';
import 'package:vaultx_solution/auth/screens/loginscreen.dart';
import 'package:vaultx_solution/auth/screens/profile_registration.dart';
import 'package:vaultx_solution/screens/change_password_page.dart';
import 'package:vaultx_solution/screens/home_page.dart';
import 'package:vaultx_solution/screens/edit_profile_screen.dart';

import 'screens/splash_scree.dart';

void main() {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VaultX Solution',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Color(0xFFD6A19F),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFD6A19F),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const LoginPage(),
        '/profile': (context) => const ProfileRegistrationPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/change-password': (context) => const ChangePasswordScreen(),
      },
    );
  }
}
