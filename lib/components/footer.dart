import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const Footer({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFB2E59C), // Light Green
            Color(0xFFFFF9C4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: BottomNavigationBar(
        currentIndex:
            selectedIndex, // This uses the selected index to highlight the active tab
        onTap: (index) {
          if (index != selectedIndex) {
            onItemTapped(
                index); // Update the selected index in the parent widget
          }
        },
        backgroundColor: Colors
            .transparent, // Set to transparent to allow the gradient to show through
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'All',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.replay),
            label: 'Order Again',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
