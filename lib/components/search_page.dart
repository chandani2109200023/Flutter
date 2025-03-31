import 'dart:convert';
import 'package:agrive_mart/provider/cart_storage_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../helper/db__helper.dart';
import '../provider/cart_provider.dart';
import 'product_details_page.dart';
import 'product_details_web_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<dynamic> products = [];
  List<dynamic> filteredProducts = [];
  final DBHelper dbHelper = DBHelper();
  bool isLoading = false;
  String? errorMessage;
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

  // Fetch products from the API and filter them based on the search query
  Future<void> fetchProducts(String query) async {
    setState(() {
      isLoading = true;
      errorMessage = null; // Reset error message
    });

    final url = Uri.parse('http://13.202.96.108/api/user/Products');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          // Map the API response to ensure the correct fields are extracted
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

          filteredProducts = products
              .where((product) =>
                  product['name'].toLowerCase().contains(query.toLowerCase()))
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load products';
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'An error occurred: $error';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartWeb = Provider.of<CartStorageHelper>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Products'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (query) {
                fetchProducts(query);
              },
              decoration: InputDecoration(
                hintText: 'Type to search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                    ? Center(child: Text(errorMessage!))
                    : filteredProducts.isEmpty
                        ? const Center(child: Text('No products found'))
                        : ListView.builder(
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];
                              return ListTile(
                                leading: Image.network(product['imageUrl']),
                                title: Text(product['name']),
                                subtitle: Text('\Rs${product['price']}'),
                                onTap: () {
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
                                      _createSlideTransitionRoute(
                                          ProductDetailsPage(
                                        product: product,
                                        dbHelper: dbHelper,
                                        cart: cart,
                                      )),
                                    );
                                  }
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
