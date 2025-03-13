import 'package:flutter/material.dart';
import 'package:agrive_mart/pages/all_pages.dart';

class GroceryKitchenGrid extends StatelessWidget {
  const GroceryKitchenGrid({super.key, required void Function(int count) updateCart});

  @override
  Widget build(BuildContext context) {
    // Custom Page Route with sliding transition
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

    final List<Map<String, dynamic>> items = [
      {
        'name': 'Vegetables & Fruits',
        'imagePath': 'assets/images/vegetables_fruits.png',
        'route': (String name) => All_pages(name: name),
      },
      {
        'name': 'Atta, Rice & Dal',
        'imagePath': 'assets/images/atta_rice_dal.webp',
        'route': (String name) => All_pages(name: name),
      },
      {
        'name': 'Oil, Ghee & Masala',
        'imagePath': 'assets/images/oil_ghee_masala.png',
        'route': (String name) => All_pages(name: name),
      },
      {
        'name': 'Dairy, Bread & Eggs',
        'imagePath': 'assets/images/dairy_bread_eggs.png',
        'route': (String name) => All_pages(name: name),
      },
      {
        'name': 'Bakery & Biscuits',
        'imagePath': 'assets/images/bakery_biscuits.png',
        'route': (String name) => All_pages(name: name),
      },
      {
        'name': 'Dry Fruits',
        'imagePath': 'assets/images/dry_fruits.jpg',
        'route': (String name) => All_pages(name: name),
      },
      {
        'name': 'Chicken, Meat & Fish',
        'imagePath': 'assets/images/Chicken_meat_fish.png',
        'route': (String name) => All_pages(name: name),
      },
    ];

    // Get screen width to make responsive adjustments
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
      aspectRatio = 1.0; // Adjust aspect ratio to give more space for images on web
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
            'Grocery & Kitchen',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        // Container added to ensure no extra space is added around grid
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
