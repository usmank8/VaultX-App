import 'package:flutter/material.dart';
import '../app_theme.dart';

class AuthForm extends StatelessWidget {
  final String buttonText;
  final bool showForgotPassword;
  final VoidCallback? onForgotPassword;

  const AuthForm({
    super.key,
    required this.buttonText,
    this.showForgotPassword = false,
    this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.offWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email Field
          const Text('Email', style: TextStyle(color: AppTheme.darkGray)),
          const SizedBox(height: 5),
          const TextField(
            decoration: InputDecoration(
              hintText: 'Enter email',
            ),
          ),
          const SizedBox(height: 20),
          // Password Field
          const Text('Password', style: TextStyle(color: AppTheme.darkGray)),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: const TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Enter password',
                    suffixIcon: Icon(Icons.visibility_off, color: AppTheme.darkGray),
                  ),
                ),
              ),
              if (showForgotPassword) ...[
                const SizedBox(width: 10),
                TextButton(
                  onPressed: onForgotPassword,
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(color: AppTheme.peach),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),
          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              child: Text(buttonText),
            ),
          ),
        ],
      ),
    );
  }
}