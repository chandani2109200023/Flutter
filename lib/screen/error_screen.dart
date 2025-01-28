import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const ErrorPage({
    Key? key,
    required this.errorMessage,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oops! Something went wrong'),
       flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF92E3A9),
                Color(0xFF34B6B6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
       ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/error.png', // Add a relevant error image here
                height: 200,
              ),
              const SizedBox(height: 24),
              Text(
                'Oops!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 132, 181, 221),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 110, 132, 206),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
