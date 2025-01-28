import 'package:flutter/material.dart';
import '../homepage/home_screen.dart';


class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Navigate to HomeScreen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF92E3A9), // Light green that matches the logo
              const Color(0xFF34B6B6), // Complementary teal
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Image.asset(
            'assets/images/logo1.png', // Use your uploaded logo
            width: 600,
            height: 600,
          ),
        ),
      ),
    );
  }
}
