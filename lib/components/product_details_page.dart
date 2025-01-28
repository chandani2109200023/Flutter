import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import '../helper/db__helper.dart';
import '../provider/cart_provider.dart';
import '../model/cart_model.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../screen/cart_screen.dart';
import '../widgets/product_grid.dart';

class ProductDetailsPage extends StatefulWidget {
  final dynamic product;

  const ProductDetailsPage({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  DBHelper dbHelper = DBHelper();
  late Future<List<Cart>> cartItemsFuture;
  bool isDescriptionExpanded = false;
  List<dynamic> products = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    cartItemsFuture = dbHelper.getCartList();
    fetchSimilarProducts();
  }

  Future<void> fetchSimilarProducts() async {
    final url = Uri.parse(
        'http://13.203.77.176:5000/api/user/Products/category/${widget.product['category']}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          products = data
              .where((product) =>
                  product["_id"] !=
                  widget.product["id"]) // Exclude current product
              .map((product) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return IconButton(
                icon: badges.Badge(
                  showBadge: cart.counter > 0,
                  badgeContent: Text(
                    cart.counter.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  child: const Icon(Icons.shopping_bag_outlined),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartScreen()),
                  );
                },
              );
            },
          ),
          const SizedBox(width: 20.0),
        ],
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
      body: buildProductDetails(context),
    );
  }

  Widget buildProductDetails(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    String description =
        widget.product['description'] ?? 'No description available.';
    String fullDescription = description + '''
  
  Return Policy:
  The product is non-returnable. For a damaged, rotten or incorrect item, you can request a replacement within 48 hours of delivery.
  
  In case of an incorrect item, you may raise a replacement or return request only if the item is sealed/ unopened/ unused and in original condition.
  
  Disclaimer:
  Product image is for representation only and actual product might differ based on the crop available in Season.
  
  Customer Care Details:
  Email: pravirkumar1992@gmail.com
  ''';
  String truncatedDescription = description.length > 100
        ? description.substring(0, 100) + '...'
        : description;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.product["imageUrl"] ?? '',
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 100),
            ),
            const SizedBox(height: 10),
            Text(
              widget.product['name'] ?? 'No Name',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '₹${widget.product['price']?.toStringAsFixed(2) ?? '0.00'}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
             Text(
            isDescriptionExpanded ? fullDescription : truncatedDescription,
            style: const TextStyle(fontSize: 16),
          ),
            if (description.length > 100)
              InkWell(
                onTap: () {
                  setState(() {
                    isDescriptionExpanded = !isDescriptionExpanded;
                  });
                },
                child: Text(
                  isDescriptionExpanded ? 'Read less' : 'Read more',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  return FutureBuilder<List<Cart>>(
                    future: cartItemsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      final cartItems = snapshot.data ?? [];
                      final productId = widget.product["id"];
                      final existingItem = cartItems.firstWhere(
                        (item) =>
                            item.productId ==
                            (productId is int
                                ? productId.toString()
                                : productId),
                        orElse: () => Cart(
                          id: null,
                          productId: productId is int
                              ? productId.toString()
                              : productId,
                          name: widget.product["name"],
                          description: widget.product["description"] ?? "",
                          price: widget.product["price"].toDouble(),
                          number: 0,
                          quantity: widget.product["quantity"] ?? 0,
                          unit: widget.product["unit"] ?? "",
                          stock: widget.product["stock"] ?? 0,
                          category: widget.product["category"] ?? "",
                          imageUrl: widget.product["imageUrl"],
                        ),
                      );

                      if (existingItem.number > 0) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () => handleQuantityChange(
                                    context, existingItem, false),
                                child: const Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Text(
                                existingItem.number.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(width: 15),
                              InkWell(
                                onTap: () => handleQuantityChange(
                                    context, existingItem, true),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (widget.product["stock"] > 0) {
                        // Check if stock is greater than 0
                        return InkWell(
                          onTap: () => handleAddToCart(context),
                          child: Container(
                            height: 40,
                            width: 120,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Center(
                              child: Text(
                                'Add to cart',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        // Display out of stock if stock is 0 or less
                        return Container(
                          height: 40,
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Center(
                            child: Text(
                              'Out of stock',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Similar Products',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : (errorMessage != null
                    ? Center(child: Text(errorMessage!))
                    : (products.isNotEmpty
                        ? SizedBox(
                            height: 400,
                            child: ProductGrid(
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
                          )
                        : const Center(
                            child: Text('No similar products found.')))),
          ],
        ),
      ),
    );
  }

  Future<void> handleAddToCart(BuildContext context) async {
    try {
      final cartItems = await dbHelper.getCartList();
      if (cartItems.any((item) => item.productId == widget.product["id"])) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Product already in cart'),
          duration: Duration(seconds: 1),
        ));
        return;
      }

      await dbHelper.insert(Cart(
        id: null,
        productId: widget.product["id"] is int
            ? widget.product["id"].toString()
            : widget.product["id"],
        unit: widget.product["unit"],
        quantity: widget.product["quantity"] ?? 1, // Handle quantity fallback
        name: widget.product["name"],
        description: widget.product["description"] ?? "",
        price: widget.product["price"].toDouble(),
        number: 1, // Default number of items in cart
        stock: widget.product["stock"] ?? 0,
        category: widget.product["category"] ?? "",
        imageUrl: widget.product["imageUrl"],
      ));

      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.addTotalPrice(widget.product["price"].toDouble());
      cartProvider.addCounter();

      setState(() {
        cartItemsFuture = dbHelper.getCartList();
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.green,
        content: Text('Product added to cart'),
        duration: Duration(seconds: 1),
      ));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text('Error adding to cart'),
        duration: Duration(seconds: 1),
      ));
    }
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

  Future<void> handleQuantityChange(
      BuildContext context, Cart cartItem, bool isIncrement) async {
    try {
      int newNumber = isIncrement ? cartItem.number + 1 : cartItem.number - 1;
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      if (newNumber < 1) {
        await dbHelper.deleteItem(cartItem.id!);
        cartProvider.removeCounter();
        cartProvider.removeTotalPrice(cartItem.price);
      } else {
        await dbHelper.updateQuantity(cartItem.id!, newNumber);
        if (isIncrement) {
          cartProvider.addCounter();
        } else {
          cartProvider.removeCounter();
        }

        cartProvider.updateTotalPrice(
            cartItem.price * cartItem.number, cartItem.price * newNumber);
        cartItem.number = newNumber;
      }

      setState(() {
        cartItemsFuture = dbHelper.getCartList();
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text('Error updating quantity'),
        duration: Duration(seconds: 1),
      ));
    }
  }
}
