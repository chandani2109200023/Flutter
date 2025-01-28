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
        'route': (String name) => All_pages(name:name),
      },
      {
        'name': 'Sweets & Chocolates',
        'imagePath': 'assets/images/sweets.jpg',
        'route': (String name) => All_pages(name:name),
      },
      {
        'name': 'Drinks & Juices',
        'imagePath': 'assets/images/coldrinks.jpg',
        'route': (String name) => All_pages(name:name),
      },
      {
        'name': 'Tea, Coffee & Milk Drinks',
        'imagePath': 'assets/images/teaCoffee.jpg',
        'route': (String name) => All_pages(name:name),
      },
      {
        'name': 'Instant Food',
        'imagePath': 'assets/images/InstantFood.jpg',
        'route': (String name) => All_pages(name:name),
      },
      {
        'name': 'Sauces & Spreads',
        'imagePath': 'assets/images/saucesSpreads.jpg',
        'route': (String name) => All_pages(name:name),
      },
      {
        'name': 'Ice Creams & More',
        'imagePath': 'assets/images/icecreams.jpg',
        'route': (String name) => All_pages(name:name),
      },
    ];

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
        GridView.builder(
          padding: const EdgeInsets.all(8),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Show 3 items per row
            crossAxisSpacing: 6, // Space between items horizontally
            mainAxisSpacing: 12, // Space between rows vertically
            childAspectRatio: 0.8, // Adjust to provide more vertical space
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  _createSlideTransitionRoute(
                      item['route'](item['name'])), // Call the route function
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Image box
                  Container(
                    width: double.infinity,
                    height: 100, // Adjusted height for consistency
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: AssetImage(item['imagePath']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6), // Space between image and text
                  Flexible(
                    child: Text(
                      item['name']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14, // Adjust font size for readability
                      ),
                      maxLines: 2, // Allow text to wrap into two lines
                      overflow: TextOverflow.ellipsis, // Handle overflow
                    ),
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
