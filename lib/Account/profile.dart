import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../homepage/account.dart';
import '../homepage/home_screen.dart';
import '../pages/orderpage.dart';
import 'about.dart';
import 'account_privacy.dart';
import 'adress.dart';
import 'notification_preferences.dart';

class ProfilePage extends StatefulWidget {
  final String userName;
  final String phoneNumber;

  ProfilePage({required this.userName, required this.phoneNumber});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isAuthenticated =
      true; // Assuming user is authenticated when this page is accessed

  // Function to handle logout and clear all stored data
  Future<void> logoutUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Clear all stored data (token, user info, etc.)
    await prefs.remove('token');
    await prefs.remove('userName');
    await prefs.remove('phoneNumber');

    setState(() {
      isAuthenticated = false;
    });

    // Navigate to AccountPage after logout
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AccountPage()),
    );
  }

  // Custom Page Route with reverse sliding transition (from left to right)
  Route _createReverseSlideTransitionRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0); // Slide from left to right
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
        // Navigate to HomeScreen with reverse sliding transition (from left to right)
        Navigator.pushAndRemoveUntil(
          context,
          _createReverseSlideTransitionRoute(
              HomeScreen()), // Use reverse sliding effect here
          (Route<dynamic> route) => false, // Remove all previous routes
        );
        return Future.value(false); // Prevent default back button behavior
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            "My Account",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              // Navigate to HomeScreen with reverse sliding transition when back arrow is pressed
              Navigator.pushAndRemoveUntil(
                context,
                _createReverseSlideTransitionRoute(
                    HomeScreen()), // Add reverse sliding effect here
                (Route<dynamic> route) => false, // Remove all previous routes
              );
            },
          ),
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
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 209, 236, 197), // Light Green
                Color.fromARGB(255, 252, 248, 212), // Soft Yellow
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
                if (isAuthenticated) _buildUserInfo(),
                SizedBox(height: 20),
                _buildExpandableSection("Your Information", Icons.person, [
                  _buildOptionRow(
                      "Your Orders", Icons.shopping_basket, OrdersPage()),
                  _buildOptionRow(
                      "Address Book", Icons.location_on, AddressBookPage())
                ]),
                SizedBox(height: 30),
                _buildExpandableSection("Other Information", Icons.info, [
                  _buildOptionRow("About Us", Icons.info, AboutUs()),
                  _buildOptionRow("Account Privacy", Icons.privacy_tip,
                      AccountPrivacyPage()),
                  _buildOptionRow("Notification Preferences",
                      Icons.notifications, NotificationPreferencesPage()),
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text("Log Out", style: TextStyle(color: Colors.red)),
                    trailing: Icon(Icons.arrow_forward, color: Colors.red),
                    onTap: logoutUser, // Call logoutUser when tapping Log Out
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // User Information Widget
  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.userName, // Use the passed username
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          widget.phoneNumber, // Use the passed phone number
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // Helper Widget to create an expandable section
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

  // Helper Widget for Displaying Option Row
  Widget _buildOptionRow(String title, IconData icon, Widget page) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward),
      onTap: () {
        Navigator.push(
          context,
          _createReverseSlideTransitionRoute(
              page), // Add reverse sliding effect here
        );
      },
    );
  }
}
