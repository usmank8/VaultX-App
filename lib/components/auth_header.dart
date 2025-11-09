import 'package:flutter/material.dart';
import '../app_theme.dart';

class AuthHeader extends StatelessWidget {
  final String title;

  const AuthHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      color: AppTheme.burgundy,
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }
}