import 'package:flutter/material.dart';
import 'dart:math' as math;

class UnderReviewScreen extends StatefulWidget {
  const UnderReviewScreen({super.key});

  @override
  State<UnderReviewScreen> createState() => _UnderReviewScreenState();
}

class _UnderReviewScreenState extends State<UnderReviewScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(); // Infinite rotation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _controller,
              child: Image.asset(
                'assets/loading.png',
                width: 160,
                height: 120,
              ),
            ),
            const SizedBox(height: 80),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Loading......",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4B0D0D), // Maroon color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
