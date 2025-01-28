import 'package:agrive_mart/pages/all_pages.dart';
import 'package:flutter/material.dart';

class GroceryKitchenGrid extends StatelessWidget {
  const GroceryKitchenGrid(
      {super.key, required void Function(int count) updateCart});

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
        'route': (String name) => All_pages(name:name),
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
        'imagePath': 'assets/images/Chicken_meat_fish.jpg',
        'route': (String name) => All_pages(name: name),
      },
    ];

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
        GridView.builder(
          padding: const EdgeInsets.all(8),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Show 3 items per row
            crossAxisSpacing: 6, // Space between items horizontally
            mainAxisSpacing: 6, // Space between rows vertically
            childAspectRatio: 0.7, // Adjust for more vertical space
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
                    height: 100, // Adjust height to ensure the text fits
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: AssetImage(item['imagePath']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6), // Space between image and text
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
      ],
    );
  }
}
