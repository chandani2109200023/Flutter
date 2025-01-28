import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;

import '../provider/cart_provider.dart';
import '../screen/cart_screen.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final int cartCount;

  const CustomHeader({super.key, required this.cartCount});

  @override
  Size get preferredSize => const Size.fromHeight(70.0);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return AppBar(
      backgroundColor: Colors.transparent, // Transparent for gradient
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF92E3A9), // Light green that matches the logo
              Color(0xFF34B6B6), // Complementary teal
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
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
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
      ],
    );
  }
}
