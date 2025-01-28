import 'dart:convert';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

import '../../components/product_details_page.dart';
import '../../helper/db__helper.dart';
import '../../homepage/home_screen.dart';
import '../../provider/cart_provider.dart';
import '../../screen/cart_screen.dart';
import '../../widgets/product_grid.dart';
import '../screen/error_screen.dart';

class All_pages extends StatefulWidget {
  final String name;
  const All_pages({super.key, required this.name});
  @override
  _All_pagesState createState() => _All_pagesState();
}

class _All_pagesState extends State<All_pages> {
  List<dynamic> products = [];
  bool isLoading = true;
  String? errorMessage;
  final DBHelper dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final url = Uri.parse(
        'http://13.203.77.176:5000/api/user/Products/category/${widget.name}');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          products = data.map((product) {
            return {
              "id": product["_id"],
              "name": product["name"],
              "quantity": product["quantity"],
              "unit": product["unit"] ?? "",
              "price": product["price"].toDouble(),
              "imageUrl": product["imageUrl"],
              "description": product["description"] ?? "",
              "stock": product["stock"] ?? 0,
              "category": product["category"] ?? "",
            };
          }).toList();
          products.shuffle(Random());
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'We are trying hard to get your products....';
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching products: $error';
        isLoading = false;
      });
    }
  }

  Future<bool> _onWillPop() async {
    // Navigate to HomeScreen when the back button is pressed
    Navigator.pushAndRemoveUntil(
      context,
      _createReverseSlideTransitionRoute(
          HomeScreen()), // Redirect to HomeScreen with sliding transition
      (Route<dynamic> route) => false, // Remove all previous routes
    );
    return false; // Prevent default back button behavior
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
    if (errorMessage != null) {
      // Navigate to the error page if an error occurs
      return ErrorPage(
        errorMessage: errorMessage!,
        onRetry: () {
          setState(() {
            isLoading = true;
            errorMessage = null;
          });
          fetchProducts(); // Retry fetching products
        },
      );
    }
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize:
              Size.fromHeight(kToolbarHeight), // Height of the AppBar
          child: Container(
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
            child: AppBar(
              title: const Text('Product List'),
              centerTitle: true,
              backgroundColor:
                  Colors.transparent, // Transparent background for the gradient
              elevation: 0, // Remove shadow
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  // Navigate to HomeScreen when back arrow is pressed
                  Navigator.pushAndRemoveUntil(
                    context,
                    _createReverseSlideTransitionRoute(
                        HomeScreen()), // Redirect to HomeScreen with sliding transition
                    (Route<dynamic> route) =>
                        false, // Remove all previous routes
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
            ),
          ),
        ),
        body: isLoading
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
                      Color(0xFFB8F0C2), // Lighter green
                      Color(0xFF6FDCDC), // Lighter teal
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: errorMessage != null
                    ? Center(child: Text(errorMessage!))
                    : ProductGrid(
                        products: products,
                        dbHelper: dbHelper,
                        cart: cart,
                        onProductTap: (product) {
                          // Navigate to ProductDetailsPage with the selected product data
                          Navigator.push(
                            context,
                            _createSlideTransitionRoute(
                                ProductDetailsPage(product: product)),
                          );
                        },
                      ),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await clearCart(cart);
          },
          child: const Icon(Icons.clear_all),
        ),
      ),
    );
  }

  Future<void> clearCart(CartProvider cart) async {
    try {
      await dbHelper.clearCart();
      cart.clearCart();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Cart cleared'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error clearing the cart'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }
}
