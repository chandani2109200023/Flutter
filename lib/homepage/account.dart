import 'package:flutter/material.dart';
import '../Account/about.dart';
import '../Account/adress.dart';
import '../Account/login_page.dart';
import '../pages/orderpage.dart';
import 'home_screen.dart'; // Ensure HomeScreen is imported

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool isAuthenticated = false;

  // Function to handle logout
  void logoutUser() {
    setState(() {
      isAuthenticated = false;
    });
  }

  // Function to handle login (set to true for authenticated state)
  void loginUser() {
    setState(() {
      isAuthenticated = true;
    });
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
        // Navigate to HomeScreen with sliding transition when back button is pressed
        Navigator.pushAndRemoveUntil(
          context,
          _createReverseSlideTransitionRoute(
              HomeScreen()), // Add sliding effect here
          (Route<dynamic> route) => false, // Remove all previous routes
        );
        return false; // Prevent the default back button behavior (closing the app)
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "My Account",
            style: TextStyle(
              fontSize: 24, // Increase font size
              fontWeight: FontWeight.bold, // Make text bold
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              // Navigate to HomeScreen with sliding transition when back arrow is pressed
              Navigator.pushAndRemoveUntil(
                context,
                _createReverseSlideTransitionRoute(
                    HomeScreen()), // Add sliding effect here
                (Route<dynamic> route) => false, // Remove all previous routes
              );
            },
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF92E3A9), // Light green
                  Color(0xFF34B6B6), // Teal
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
                Color(0xFFB8F0C2), // Lighter green
                Color(0xFF6FDCDC), // Lighter teal
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
                isAuthenticated
                    ? _buildAuthenticatedView()
                    : Column(
                        children: [
                          Text(
                            "Login or sign up to view your complete profile",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(
                                  double.infinity, 50), // Elongated horizontally
                              backgroundColor: const Color.fromARGB(
                                  255, 24, 209, 117), // Light blue color
                            ),
                            onPressed: () {
                              // Navigate to the page where the user chooses between SignIn and SignUp
                              Navigator.push(
                                context,
                                _createSlideTransitionRoute(
                                    LoginPage()), // Add sliding effect here
                              );
                            },
                            child: Text("Continue"),
                          ),
                        ],
                      ),
                // Display these sections for all users, even if not authenticated
                SizedBox(height: 20),
                _buildExpandableSection("Your Information", Icons.person, [
                  _buildOptionRow("Your Orders", Icons.shopping_basket,
                      isAuthenticated ? OrdersPage() : LoginPage()),
                  _buildOptionRow(
                    "Address Book",
                    Icons.location_on,
                    isAuthenticated ? AddressBookPage() : LoginPage(),
                  ),
                ]),
                SizedBox(height: 30),
                _buildExpandableSection("Other Information", Icons.info, [
                  _buildOptionRow("About Us", Icons.info, AboutUs()),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build the view for authenticated users
  Widget _buildAuthenticatedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Additional authenticated content could go here if needed
        Text(
          "Welcome back, user!",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        // Other authenticated content goes here
        SizedBox(height: 20),
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
          _createSlideTransitionRoute(page), // Add sliding effect here
        );
      },
    );
  }
}
