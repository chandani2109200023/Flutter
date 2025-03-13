import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Account/profile.dart';
import '../components/banner_coursel.dart';
import '../components/custom_header.dart';
import '../components/footer.dart';
import '../components/grocery_kitchens.dart';
import '../components/household_essentials.dart';
import '../components/search_bar.dart';
import '../components/snacks_drinks.dart';
import '../utils/permissions_mobile.dart';
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
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _initialize();
  }

  Future<void> _initialize() async {
    await PermissionsHelper.handlePermissions();
    await _checkLoginStatus();
    setState(() {}); // Trigger UI update
  }

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

  void _updateCartCount(int count) {
    setState(() {
      cartCount += count;
    });
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
      });
      _pageController.jumpToPage(0); // Move back to the home screen
      return Future.value(false);
    } else {
      SystemNavigator.pop(); // Exit the app
      return Future.value(false);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        extendBodyBehindAppBar: false,
        appBar: _selectedIndex == 0 ? CustomHeader(cartCount: cartCount) : null,
        // body: SafeArea(
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomSearchBar(),
                    const BannerCarousel(),
                    GroceryKitchenGrid(updateCart: _updateCartCount),
                    SnacksDrinksGrid(updateCart: _updateCartCount),
                    HouseholdEssentialsGrid(updateCart: _updateCartCount),
                  ],
                ),
              ),
              const AllProductsPage(),
              OrdersAgainPage(),
              _isLoggedIn
                  ? ProfilePage(userName: _userName, phoneNumber: _phoneNumber)
                  : AccountPage(),
            ],
          // ),
        ),
        bottomNavigationBar: Footer(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}
