import 'package:flutter/material.dart';

import '../pages/all_pages.dart';

class SnacksDrinksGrid extends StatelessWidget {
  const SnacksDrinksGrid({
    super.key,
    required this.updateCart,
  });

  final void Function(int count) updateCart;
  Route _createSlideTransitionRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Slide from right to left
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {
        'name': 'Chips & Namkeen',
        'imagePath': 'assets/images/chips.jpg',
        'route': (String name) => All_pages(name: name),
      },
      {
        'name': 'Sweets & Chocolates',
        'imagePath': 'assets/images/sweet.png',
        'route': (String name) => All_pages(name: name),
      },
      {
        'name': 'Drinks & Juices',
        'imagePath': 'assets/images/colddrink.png',
        'route': (String name) => All_pages(name: name),
      },
      {
        'name': 'Tea, Coffee & Milk Drinks',
        'imagePath': 'assets/images/teaCoffee.jpg',
        'route': (String name) => All_pages(name: name),
      },
      {
        'name': 'Instant Food',
        'imagePath': 'assets/images/InstantFood.jpg',
        'route': (String name) => All_pages(name: name),
      },
      {
        'name': 'Sauces & Spreads',
        'imagePath': 'assets/images/saucesSpreads.jpg',
        'route': (String name) => All_pages(name: name),
      },
      {
        'name': 'Ice Creams & More',
        'imagePath': 'assets/images/icecream.png',
        'route': (String name) => All_pages(name: name),
      },
    ];
    double screenWidth = MediaQuery.of(context).size.width;

    // Default values for mobile screens
    int crossAxisCount = 3; // Default for small screens (mobile)
    double aspectRatio = 0.75; // Default aspect ratio for images
    double crossAxisSpacing = 8.0;
    double mainAxisSpacing = 6.0; // Default vertical spacing between rows
    double imageHeight = 120; // Default image height for mobile

    if (screenWidth > 1200) {
      // For large screens (web)
      crossAxisCount = 5; // Set to 2 columns on web (large screens)
      crossAxisSpacing = 12.0; // Wider spacing for larger screens
      mainAxisSpacing = 0.0; // Set to 0 for reduced vertical spacing for web
      aspectRatio =
          1.0; // Adjust aspect ratio to give more space for images on web
      imageHeight = 200; // Set image height to 300 for large screens (web)
    } else if (screenWidth > 800) {
      // For medium screens (tablets)
      crossAxisCount = 4;
      crossAxisSpacing = 12.0;
      mainAxisSpacing = 4.0; // Reduced vertical spacing for tablets
      aspectRatio = 0.7; // Slightly taller images for tablets
      imageHeight = 150; // Adjust image height for tablets
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Snacks & Drinks',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          padding: EdgeInsets.zero, // No padding around the grid for web
          child: GridView.builder(
            padding: EdgeInsets.zero, // No padding around items
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount, // Adjust grid columns based on screen width
              crossAxisSpacing: crossAxisSpacing, // Adjust horizontal spacing
              mainAxisSpacing: mainAxisSpacing, // Adjust vertical spacing
              childAspectRatio: aspectRatio, // Adjust aspect ratio to reduce vertical space
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    _createSlideTransitionRoute(
                      item['route'](item['name']), // Pass the name here
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      height: imageHeight, // Adjust image height dynamically
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: AssetImage(item['imagePath']),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 0), // Space between image and text removed
                    Text(
                      item['name']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2, // Allow text to wrap into two lines
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
