import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About Us"),
        backgroundColor: Colors.green, // Adjust color to match your theme
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome to Agrive Mart!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Agrive Mart is your trusted solution for purchasing fresh groceries, daily essentials, and location-based services at the best prices. "
              "We are committed to providing top-quality products and services directly to your doorstep, making shopping more convenient, reliable, and affordable.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "Our Vision",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "To empower individuals by offering a seamless shopping experience for their daily needs while ensuring privacy, security, and transparency.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              "Why Choose Agrive Mart?",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "✓ Fresh groceries, daily essentials, and personalized recommendations\n"
              "✓ Affordable prices with exciting discounts\n"
              "✓ Reliable delivery services tailored to your location\n"
              "✓ Easy-to-use app ensuring privacy and data security\n"
              "✓ Committed to safeguarding your data and improving user experience",
              style: TextStyle(fontSize: 16),
            ),
            Spacer(),
            Center(
              child: Text(
                "Thank you for choosing Agrive Mart!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
