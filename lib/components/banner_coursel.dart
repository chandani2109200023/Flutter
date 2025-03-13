import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class BannerCarousel extends StatelessWidget {
  const BannerCarousel({super.key});

  // List of asset image paths for the banners
  final List<String> bannerImages = const [
    'assets/images/banner_1.jpg',
    'assets/images/banner_2.jpg',
    'assets/images/banner_3.jpg',
    'assets/images/banner_4.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    // Get screen width to adjust the carousel for different screen sizes
    double screenWidth = MediaQuery.of(context).size.width;

    // Default values for mobile screens
    double height = 180.0;
    double viewportFraction = 0.8;

    // Adjust settings based on screen width
    if (screenWidth > 1200) {
      // For large screens (web)
      height = 250.0; // Increased height for web
      viewportFraction = 1.0; // Show fewer images side by side on larger screens
    } else if (screenWidth > 800) {
      // For medium screens (tablets)
      height = 220.0; // Increased height for tablets
      viewportFraction = 0.75; // Adjust the images to show more on the screen
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: height,
        autoPlay: true,
        enlargeCenterPage: true,
        autoPlayInterval: const Duration(seconds: 3),
        scrollPhysics: const BouncingScrollPhysics(), // Enables smooth scrolling
        autoPlayAnimationDuration: const Duration(milliseconds: 800), // Speed of the transition
        viewportFraction: viewportFraction, // Adjusts how much of the next image is shown
      ),
      items: bannerImages.map((image) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(image, fit: BoxFit.cover),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
