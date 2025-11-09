import 'package:flutter/material.dart';
import '../app_theme.dart';

class AuthFooter extends StatelessWidget {
  final String linkText;
  final VoidCallback onLinkTap;

  const AuthFooter({
    super.key,
    required this.linkText,
    required this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Navigation Link
        TextButton(
          onPressed: onLinkTap,
          child: Text(
            linkText,
            style: const TextStyle(color: AppTheme.peach),
          ),
        ),
        const SizedBox(height: 20),
        // Or Continue With
        const Text(
          'OR CONTINUE WITH',
          style: TextStyle(color: AppTheme.darkGray),
        ),
        const SizedBox(height: 20),
        // Social Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {},
              icon: const CircleAvatar(
                backgroundColor: AppTheme.googleRed,
                child: Text('G', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(width: 20),
            IconButton(
              onPressed: () {},
              icon: const CircleAvatar(
                backgroundColor: AppTheme.facebookBlue,
                child: Text('f', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}