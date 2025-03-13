import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:badges/badges.dart' as badges;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/product_details_page.dart';
import '../helper/db__helper.dart';
import '../provider/cart_provider.dart';
import '../screen/cart_screen.dart';
import '../widgets/product_grid.dart';
import 'home_screen.dart';

class OrdersAgainPage extends StatefulWidget {
  @override
  _OrdersAgainPageState createState() => _OrdersAgainPageState();
}

class _OrdersAgainPageState extends State<OrdersAgainPage> {
  bool _isLoading = true;
  String? errorMessage;
  List<dynamic> _orderedProducts = [];
  List<dynamic> Products = [];
  bool _isLoggedIn = false;
  final DBHelper dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _initialize(); // Perform all initial setup
  }

  // Perform all initial setup including checking login status
  Future<void> _initialize() async {
    await _checkLoginStatus(); // Check login status
    if (_isLoggedIn) {
      await _getUserIdAndFetchOrders(); // Fetch orders if logged in
    } else {
      await fetchProducts(); // Fetch all products if not logged in
    }
    setState(() {}); // Trigger UI update after initializing
  }

  // Function to check if the user is logged in
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    setState(() {
      if (token != null && token.isNotEmpty) {
        _isLoggedIn = true;
      } else {
        _isLoggedIn = false;
      }
    });
  }

  // Fetch ordered products for the logged-in user
  Future<void> _getUserIdAndFetchOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId != null && userId.isNotEmpty) {
      final String apiUrl =
          'https://sastabazar.onrender.com/api/payments/user/$userId';

      try {
        final response = await http.get(Uri.parse(apiUrl));

        if (response.statusCode == 200) {
          setState(() {
            final data = json.decode(response.body);
            if (data.isNotEmpty) {
              _orderedProducts = [];
              for (var order in data) {
                if (order['products'] != null) {
                  _orderedProducts.addAll(order['products']);
                }
              }
            }
            _orderedProducts.shuffle(Random());
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> fetchProducts() async {
    final url = Uri.parse('https://sastabazar.onrender.com/api/user/Products');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          Products = data.map((product) {
            return {
              "id": product["_id"],
              "name": product["name"],
              "quantity": product["quantity"],
              "price": product["price"].toDouble(),
              "discount": product["discount"] ?? 0,
              "imageUrl": product["imageUrl"],
              "description": product["description"] ?? "",
              "stock": product["stock"] ?? 0,
              "category": product["category"] ?? "",
              "unit": product["unit"] ?? "",
            };
          }).toList();
          Products.shuffle(Random());
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching products: $error';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          _createReverseSlideTransitionRoute(HomeScreen()),
        );
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              _isLoggedIn ? "Ordered Products" : "You May Like These Products"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                _createReverseSlideTransitionRoute(HomeScreen()),
              );
            },
          ),
          actions: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  _createSlideTransitionRoute(
                      const CartScreen()), // Add sliding effect here
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
        body: _isLoading
            ? Stack(
                children: [
                  Positioned.fill(
                    child: Icon(
                      Icons.shopping_cart, // Shopping cart icon in background
                      size: 200,
                      color: Colors.green
                          .withOpacity(0.2), // Optional color and opacity
                    ),
                  ),
                ],
              )
            : Container(
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
                child: errorMessage != null
                    ? Center(child: Text(errorMessage!))
                    : ProductGrid(
                        products: _isLoggedIn
                            ? _orderedProducts // Show ordered products if logged in
                            : Products, // Show all products if not logged in
                        dbHelper:
                            dbHelper, // Replace with actual dbHelper instance
                        cart: cart, // Replace with actual cart instance
                        onProductTap: (product) {
                          Navigator.push(
                            context,
                            _createSlideTransitionRoute(ProductDetailsPage(
                              product: product,
                              dbHelper: dbHelper,
                              cart: cart,
                            )),
                          );
                        }),
              ),
      ),
    );
  }

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
        const begin = Offset(-1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }
}
