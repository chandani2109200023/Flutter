import 'package:agrive_mart/provider/cart_storage_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;

import '../provider/cart_provider.dart';
import '../screen/cart_screen.dart';
import '../screen/cart_screen_web.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final int cartCount;

  const CustomHeader({super.key, required this.cartCount});

  @override
  Size get preferredSize => const Size.fromHeight(70.0);

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

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartWeb = Provider.of<CartStorageHelper>(context);
    final isWeb = kIsWeb;
    return AppBar(
      backgroundColor: Colors.transparent, // Transparent for gradient
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFB2E59C), // Light Green
              Color(0xFFFFF9C4), // Soft Yellow
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      elevation: 0,
      centerTitle: true, // Ensures the title is centered
      title: Image.asset(
        'assets/images/logo1.png', // Path to your logo
        height: 60, // Adjusted to match the AppBar height
        fit: BoxFit.contain, // Ensures proper scaling within the height
      ),
      actions: [
        if (isWeb) ...[
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                _createSlideTransitionRoute(
                    CartScreenWeb()), // Slide transition for mobile
              );
            },
            child: Center(
              child: badges.Badge(
                showBadge: cartWeb.counter > 0,
                badgeContent: Text(
                  cartWeb.counter.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
            ),
          ),
          const SizedBox(width: 20.0),
        ] else ...[
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                _createSlideTransitionRoute(
                    const CartScreen()), // Slide transition for mobile
              );
            },
            child: Center(
              child: badges.Badge(
                showBadge: cart.counter > 0,
                badgeContent: Text(
                  cart.counter.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
            ),
          ),
          const SizedBox(width: 20.0),
        ]
      ],
    );
  }
}
