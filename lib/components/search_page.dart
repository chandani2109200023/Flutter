import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'product_details_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<dynamic> products = [];
  List<dynamic> filteredProducts = [];
  bool isLoading = false;
  String? errorMessage;

  // Fetch products from the API and filter them based on the search query
  Future<void> fetchProducts(String query) async {
    setState(() {
      isLoading = true;
      errorMessage = null; // Reset error message
    });

    final url = Uri.parse('http://13.203.77.176:5000/api/user/Products');
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
              "imageUrl": product["imageUrl"],
              "description": product["description"] ?? "",
              "stock": product["stock"] ?? 0,
              "category": product["category"] ?? "",
              "unit":product["unit"]??"",
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
                                  // Navigate to ProductDetailsPage with the selected product data
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailsPage(
                                        product:
                                            product, // Pass selected product
                                      ),
                                    ),
                                  );
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
