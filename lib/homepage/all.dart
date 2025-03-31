import 'dart:convert';
import 'package:agrive_mart/provider/cart_storage_web.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

import '../components/product_details_page.dart';
import '../components/product_details_web_page.dart';
import '../helper/db__helper.dart';
import '../provider/cart_provider.dart';
import '../screen/cart_screen.dart';
import '../screen/cart_screen_web.dart';
import '../screen/error_screen.dart';
import '../widgets/product_grid.dart';
import 'home_screen.dart';

class AllProductsPage extends StatefulWidget {
  const AllProductsPage({super.key});

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  List<dynamic> products = [];
  List<dynamic> filteredProducts = [];
  bool isLoading = true;
  String? errorMessage;
  final DBHelper dbHelper = DBHelper();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProducts();
    searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchProducts() async {
    final url = Uri.parse('http://13.202.96.108/api/user/Products');
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
              "price": product["price"].toDouble(),
              "discount": product["discount"] ?? 0,
              "imageUrl": product["imageUrl"],
              "description": product["description"] ?? "",
              "stock": product["stock"] ?? 0,
              "category": product["category"] ?? "",
              "unit": product["unit"] ?? "",
            };
          }).toList();
          filteredProducts = List.from(products); // Initially show all products
          filteredProducts.shuffle(Random());
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              "We are trying hard to get your products....Keep Patience";
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage =
            "We are trying hard to get your products.....Keep Patience!";
        isLoading = false;
      });
    }
  }

  // Filter products based on search query
  void _filterProducts() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredProducts = products
          .where((product) =>
              product["name"].toLowerCase().contains(query) ||
              product["category"].toLowerCase().contains(query))
          .toList();
    });
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

  Future<bool> _onWillPop() async {
    // Navigate to HomeScreen when the back button is pressed
    Navigator.pushAndRemoveUntil(
      context,
      _createReverseSlideTransitionRoute(
          HomeScreen()), // Redirect to HomeScreen with sliding transition
      (Route<dynamic> route) => false, // Remove all previous routes
    );
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartWeb = Provider.of<CartStorageHelper>(context);
    if (errorMessage != null) {
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
    final isWeb = kIsWeb;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize:
              const Size.fromHeight(kToolbarHeight), // Increased AppBar height
          child: Container(
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
                    _createReverseSlideTransitionRoute(HomeScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
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
                      Color(0xFFB2E59C), // Light Green
                      Color(0xFFFFF9C4), // Soft Yellow
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search Products...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ProductGrid(
                        cartWeb: cartWeb,
                        products: filteredProducts, // Show filtered products
                        dbHelper: dbHelper,
                        cart: cart,
                        onProductTap: (product) {
                          if (kIsWeb) {
                            // For web, navigate using the web product details page
                            Navigator.push(
                              context,
                              _createSlideTransitionRoute(
                                ProductDetailsWebPage(
                                    product: product, cart: cartWeb),
                              ),
                            );
                          } else {
                            // For mobile, use the existing navigation logic
                            Navigator.push(
                              context,
                              _createSlideTransitionRoute(ProductDetailsPage(
                                product: product,
                                dbHelper: dbHelper,
                                cart: cart,
                              )),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            cartWeb.clearCart();
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
