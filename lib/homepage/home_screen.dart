import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import this for SystemNavigator
import 'package:shared_preferences/shared_preferences.dart';
import '../Account/profile.dart';
import '../components/banner_coursel.dart';
import '../components/custom_header.dart';
import '../components/footer.dart';
import '../components/grocery_kitchens.dart';
import '../components/household_essentials.dart';
import '../components/search_bar.dart';
import '../components/snacks_drinks.dart';
import '../utils/permissions_helper.dart';
import 'account.dart';
import 'all.dart';
import 'order_again.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int cartCount = 0;
  bool _isLoggedIn = false;
  String _userName = '';
  String _phoneNumber = '';
  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _initialize(); // Perform all initial setup
  }

  Future<void> _initialize() async {
    // Request and handle permissions
    await PermissionsHelper
        .handlePermissions(); // Request all permissions at once

    await _checkLoginStatus(); // Check login status
    _initializePages(); // Initialize pages

    setState(() {}); // Trigger UI update after initializing pages
  }

  // Function to check if the user is logged in
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    setState(() {
      if (token != null && token.isNotEmpty) {
        _isLoggedIn = true;
        _userName = prefs.getString('userName') ?? '';
        _phoneNumber = prefs.getString('phoneNumber') ?? '';
      } else {
        _isLoggedIn = false;
      }
    });
  }

  // Function to initialize pages
  void _initializePages() {
    _pages = [
      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomSearchBar(),
            const BannerCarousel(),
            GroceryKitchenGrid(updateCart: _updateCartCount),
            SnacksDrinksGrid(updateCart: _updateCartCount),
            const HouseholdEssentialsGrid(),
          ],
        ),
      ),
      const AllProductsPage(),
      OrdersAgainPage(),
      _isLoggedIn
          ? ProfilePage(userName: _userName, phoneNumber: _phoneNumber)
          : AccountPage(),
    ];
  }

  // Update cart count
  void _updateCartCount(int count) {
    setState(() {
      cartCount += count;
    });
  }

  // Handle bottom navigation item taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    Navigator.pushReplacement(
      context,
      _createSlideTransitionRoute(
          _pages[_selectedIndex]), // Add sliding effect here
    );
  }

  // Function to handle the back button press
  Future<bool> _onWillPop() async {
    // Close the app when the back button is pressed
    SystemNavigator.pop();
    return Future.value(false); // Prevent the default back button behavior
  }

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
    return WillPopScope(
      onWillPop: _onWillPop, // Handle the back button press
      child: Scaffold(
        appBar: _selectedIndex == 0
            ? CustomHeader(cartCount: cartCount)
            : null, // Only show header for HomeScreen
        body: SafeArea(
          child: IndexedStack(
            index: _selectedIndex,
            children: _pages.isNotEmpty
                ? _pages
                : [
                    Center(child: CircularProgressIndicator())
                  ], // Fallback while pages load
          ),
        ),
        bottomNavigationBar: Footer(
          selectedIndex: _selectedIndex,
          onItemTapped:
              _onItemTapped, // Use this method for handling navigation
        ),
      ),
    );
  }
}
