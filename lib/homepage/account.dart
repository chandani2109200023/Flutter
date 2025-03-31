import 'package:agrive_mart/helper/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Account/about.dart';
import '../Account/account_privacy.dart';
import '../Account/adress.dart';
import '../Account/login_page.dart';
import '../Account/notification_preferences.dart';
import '../pages/orderpage.dart';
import 'home_screen.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _isLoggedIn = false;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    try {
      String? savedUserName;
      bool isLoggedIn = false;

      if (kIsWeb) {
        savedUserName = await StorageService.getItem('userName');
        String? isLoggedInString = await StorageService.getItem('isLoggedIn');
        isLoggedIn = isLoggedInString == "true"; // ✅ Fix
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        savedUserName = prefs.getString('userName');
        isLoggedIn = prefs.getBool('isLoggedIn') ?? false; // ✅ Fix
      }

      setState(() {
        _isLoggedIn = isLoggedIn;
        _userName = savedUserName ?? '';
      });
    } catch (e) {
      print('⚠️ Error checking login status.....');
    }
  }

  // ✅ Logout Function (Clears storage for web & mobile)
  Future<void> logoutUser() async {
    if (kIsWeb) {
      await StorageService.clear(); // Web: Clear localStorage
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Mobile: Clear SharedPreferences
    }

    setState(() {
      _isLoggedIn = false;
      _userName = "";
    });

    // Navigate to login page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  // ✅ Slide Transition Effect
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
      onWillPop: () async {
        // Navigate to HomeScreen when back button is pressed
        Navigator.pushAndRemoveUntil(
          context,
          _createSlideTransitionRoute(HomeScreen()),
          (Route<dynamic> route) => false,
        );
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "My Account",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                _createSlideTransitionRoute(HomeScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
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
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFB2E59C), // Light Green
                Color(0xFFFFF9C4), // Soft Yellow
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _isLoggedIn ? _buildAuthenticatedView() : _buildGuestView(),
                SizedBox(height: 20),
                _buildExpandableSection("Your Information", Icons.person, [
                  _buildOptionRow("Your Orders", Icons.shopping_basket,
                      _isLoggedIn ? OrdersPage() : LoginPage()),
                  _buildOptionRow("Address Book", Icons.location_on,
                      _isLoggedIn ? AddressBookPage() : LoginPage()),
                ]),
                SizedBox(height: 30),
                _buildExpandableSection("Other Information", Icons.info, [
                  _buildOptionRow("Account Privacy", Icons.privacy_tip,
                      AccountPrivacyPage()),
                  _buildOptionRow("Notification Preferences",
                      Icons.notifications, NotificationPreferencesPage()),
                  _buildOptionRow("About Us", Icons.info, AboutUs()),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ View for Logged-in Users
  Widget _buildAuthenticatedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome back, $_userName!",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            minimumSize: Size(double.infinity, 50),
          ),
          onPressed: logoutUser, // Logout Function
          child: Text("Log Out", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  // ✅ View for Guests (Not Logged-in)
  Widget _buildGuestView() {
    return Column(
      children: [
        Text(
          "Login or sign up to view your complete profile",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 50),
            backgroundColor: Color(0xFF18D175), // Green
          ),
          onPressed: () {
            Navigator.push(
              context,
              _createSlideTransitionRoute(LoginPage()),
            );
          },
          child: Text("Continue"),
        ),
      ],
    );
  }

  // ✅ Expandable Section
  Widget _buildExpandableSection(
      String title, IconData icon, List<Widget> children) {
    return ExpansionTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      children: children,
    );
  }

  // ✅ Option Row
  Widget _buildOptionRow(String title, IconData icon, Widget page) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward),
      onTap: () {
        Navigator.push(
          context,
          _createSlideTransitionRoute(page),
        );
      },
    );
  }
}
