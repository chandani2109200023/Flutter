import 'dart:convert';
import 'package:agrive_mart/screen/cart_screen_web.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Import this to use kIsWeb
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

import '../../components/product_details_page.dart';
import '../../helper/db__helper.dart';
import '../../homepage/home_screen.dart';
import '../../provider/cart_provider.dart';
import '../../screen/cart_screen.dart';
import '../../widgets/product_grid.dart';
import '../components/product_details_web_page.dart';
import '../model/cart_model.dart';
import '../provider/cart_storage_helper.dart';
import '../screen/error_screen.dart';

class All_pages extends StatefulWidget {
  final String name;
  const All_pages({super.key, required this.name});

  @override
  _AllPagesState createState() => _AllPagesState();
}

class _AllPagesState extends State<All_pages> {
  List<dynamic> products = [];
  List<dynamic> filteredProducts = [];
  bool isLoading = true;
  String? errorMessage;
  final DBHelper dbHelper = DBHelper();
  late Future<List<Cart>> cartItemsFuture;
  TextEditingController searchController = TextEditingController();
  int cartCounterWeb = 0; // Store cart counter for web

  @override
  void initState() {
    super.initState();
    fetchProducts();
    searchController.addListener(_filterProducts);
    cartCounterWeb = CartStorageHelper.getCounter();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure that the counter is updated when the page is resumed
    cartCounterWeb = CartStorageHelper.getCounter();
    setState(() {});
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchProducts() async {
    final url = Uri.parse(
        'https://sastabazar.onrender.com/api/user/Products/category/${widget.name}');
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
              "discount": product["discount"] ?? 0,
              "imageUrl": product["imageUrl"],
              "description": product["description"] ?? "",
              "stock": product["stock"] ?? 0,
              "category": product["category"] ?? "",
            };
          }).toList();
          filteredProducts = List.from(products); // Initially show all products
          filteredProducts.shuffle(Random());
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

  Future<bool> _onWillPop() async {
    // Navigate to HomeScreen when the back button is pressed
    Navigator.pushAndRemoveUntil(
      context,
      _createReverseSlideTransitionRoute(HomeScreen()),
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
    cartCounterWeb = CartStorageHelper.getCounter();

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

    // Check if the app is running on a web platform
    final isWeb = kIsWeb;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight), // AppBar height
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
                  Navigator.pushAndRemoveUntil(
                    context,
                    _createReverseSlideTransitionRoute(HomeScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
              actions: [
                Consumer<CartProvider>(builder: (context, cart, child) {
                  return IconButton(
                    icon: badges.Badge(
                      showBadge: isWeb
                          ? cartCounterWeb > 0 // Web-specific cart counter
                          : cart.counter > 0, // Mobile cart counter
                      badgeContent: Text(
                        isWeb
                            ? cartCounterWeb.toString()
                            : cart.counter.toString(), // Mobile and Web cart count
                        style: const TextStyle(color: Colors.white),
                      ),
                      child: const Icon(Icons.shopping_bag_outlined),
                    ),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: isWeb
                                ? (context) => CartScreenWeb()
                                : (context) => CartScreen()),
                      );
                      // Refresh cartItemsFuture when navigating back from cart screen
                      if (result != null && result == 'update') {
                        setState(() {
                          cartItemsFuture = dbHelper.getCartList(); // Refresh the future
                          cartCounterWeb=CartStorageHelper.getCounter();
                        });
                      }
                    },
                  );
                }),
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
                      color: Colors.green.withOpacity(0.2),
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
                        products: filteredProducts, // Show filtered products
                        dbHelper: dbHelper,
                        cart: cart,
                        onProductTap: (product) {
                          if (kIsWeb) {
                            // For web, navigate using the web product details page
                            Navigator.push(
                              context,
                              _createSlideTransitionRoute(
                                ProductDetailsWebPage(product: product),
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
      ),
    );
  }
}
