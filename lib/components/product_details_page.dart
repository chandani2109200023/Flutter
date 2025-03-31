import 'dart:convert';
import 'dart:math';
import 'package:agrive_mart/provider/cart_storage_web.dart';
import 'package:flutter/material.dart';
import '../helper/db__helper.dart';
import '../pages/all_pages.dart';
import '../provider/cart_provider.dart';
import '../model/cart_model.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../screen/cart_screen.dart';
import '../widgets/product_grid.dart';

class ProductDetailsPage extends StatefulWidget {
  final dynamic product;
  final DBHelper dbHelper;
  final CartProvider cart;

  const ProductDetailsPage({
    super.key,
    required this.product,
    required this.dbHelper,
    required this.cart,
  });

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
  int? itemCount;

  @override
  void initState() {
    super.initState();
    cartItemsFuture = dbHelper.getCartList();
    fetchSimilarProducts();
    fetchInitialCartCount();
  }

  Future<void> fetchInitialCartCount() async {
    final cartItems = await widget.dbHelper.getCartList();
    final existingItem = cartItems.firstWhere(
      (item) =>
          item.productId ==
          (widget.product["id"] is int
              ? widget.product["id"].toString()
              : widget.product["id"]),
      orElse: () => Cart(
        id: null,
        unit: widget.product["unit"],
        quantity: widget.product["quantity"] ?? 0,
        productId: widget.product["id"] is int
            ? widget.product["id"].toString()
            : widget.product["id"],
        name: widget.product["name"],
        description: widget.product["description"] ?? "",
        price: widget.product["price"].toDouble(),
        discount: widget.product["discount"] ?? 0,
        number: 0,
        stock: widget.product["stock"] ?? 0,
        category: widget.product["category"] ?? "",
        imageUrl: widget.product["imageUrl"],
      ),
    );

    setState(() {
      itemCount = existingItem.number;
    });
  }

  Future<void> handleAddToCart() async {
    try {
      final cartItems = await widget.dbHelper.getCartList();

      if (cartItems.any((item) =>
          item.productId ==
          (widget.product["id"] is int
              ? widget.product["id"].toString()
              : widget.product["id"]))) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Product already in cart'),
          duration: Duration(seconds: 1),
        ));
        return;
      }

      await widget.dbHelper.insert(Cart(
        id: null,
        productId: widget.product["id"] is int
            ? widget.product["id"].toString()
            : widget.product["id"],
        unit: widget.product["unit"],
        quantity: widget.product["quantity"] ?? 1,
        name: widget.product["name"],
        description: widget.product["description"] ?? "",
        price: widget.product["price"].toDouble(),
        discount: widget.product["discount"] ?? 0,
        number: 1,
        stock: widget.product["stock"] ?? 0,
        category: widget.product["category"] ?? "",
        imageUrl: widget.product["imageUrl"],
      ));

      widget.cart.addTotalPrice(
          widget.product["price"].toDouble(), widget.product["discount"]);
      widget.cart.addCounter();

      setState(() {
        itemCount = 1; // Update local state
      });
    } catch (error) {}
  }

  Future<void> handleQuantityChange(bool isIncrement) async {
    try {
      if (itemCount == null) return;

      final cartItems = await widget.dbHelper.getCartList();
      final cartItem = cartItems.firstWhere(
        (item) =>
            item.productId ==
            (widget.product["id"] is int
                ? widget.product["id"].toString()
                : widget.product["id"]),
      );

      int newNumber = isIncrement ? cartItem.number + 1 : cartItem.number - 1;

      if (newNumber < 1) {
        // Remove the item from the cart if the number is less than 1
        await widget.dbHelper.deleteItem(cartItem.id!);
        widget.cart.removeCounter();
        widget.cart.removeTotalPrice(cartItem.price, cartItem.discount);

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Item removed from cart'),
          duration: Duration(seconds: 1),
        ));

        setState(() {
          itemCount = 0;
        });
      } else if (newNumber <= cartItem.stock) {
        // Update the cart item if the new quantity is within the stock limits
        await widget.dbHelper.updateQuantity(cartItem.id!, newNumber);

        if (isIncrement) {
          widget.cart.addCounter();
        } else {
          widget.cart.removeCounter();
        }

        widget.cart.updateTotalPrice(
            (cartItem.price * cartItem.number) -
                (cartItem.price * cartItem.number * cartItem.discount * 0.01),
            (cartItem.price * newNumber) -
                (cartItem.price * newNumber * cartItem.discount * 0.01));

        setState(() {
          itemCount = newNumber;
        });
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Stock Limit Reached"),
              content: Text(
                  "You can only add up to ${cartItem.stock} items to the cart."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text('Error updating quantity'),
        duration: Duration(seconds: 1),
      ));
    }
  }

  Future<void> fetchSimilarProducts() async {
    final url = Uri.parse(
        'http://13.202.96.108/api/user/Products/category/${widget.product['category']}');

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
              "discount": product["discount"] ?? 0,
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
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartScreen()),
                  );
                  // Refresh cartItemsFuture when navigating back from cart screen
                  if (result != null && result == 'update') {
                    setState(() {
                      cartItemsFuture =
                          dbHelper.getCartList(); // Refresh the future
                    });
                  }
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
                Color(0xFFB2E59C), // Light Green
                Color(0xFFFFF9C4), // Soft Yellow
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
    final cartWeb = Provider.of<CartStorageHelper>(context);
    String description =
        widget.product['description'] ?? 'No description available.';
    String fullDescription = description +
        '''
  
  Return Policy:
  The product is non-returnable. For a damaged, rotten or incorrect item, you can request a replacement within 48 hours of delivery.
  
  In case of an incorrect item, you may raise a replacement or return request only if the item is sealed/ unopened/ unused and in original condition.
  
  Disclaimer:
  Product image is for representation only and actual product might differ based on the crop available in Season.
  
  Customer Care Details:
  Email: pravirkumar1992@gmail.com
  ''';
    double screenWidth = MediaQuery.of(context).size.width;

    // Define different image sizes based on screen width
    double imageSize = screenWidth < 600
        ? MediaQuery.of(context).size.width * 0.6 // 60% width for mobile
        : screenWidth < 1200
            ? MediaQuery.of(context).size.width * 0.4 // 40% width for tablet
            : MediaQuery.of(context).size.width * 0.3; // 30% width for web

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        // Ensuring that everything is scrollable
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                widget.product["imageUrl"] ?? '',
                width: imageSize,
                height: imageSize,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 100),
              ),
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
            (widget.product['discount'] ?? 0) > 0
                ? Text(
                    '${widget.product['discount']}% Off',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.blue,
                    ),
                  )
                : const SizedBox.shrink(),

            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                children: [
                  /// Original Price (Strikethrough if Discount Exists)
                  TextSpan(
                    text: '₹${widget.product['price']} ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: widget.product['discount'] > 0
                          ? Colors.grey
                          : Colors.black,
                      decoration: widget.product['discount'] > 0
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  if (widget.product['discount'] > 0) ...[
                    const WidgetSpan(child: SizedBox(width: 5)),
                    TextSpan(
                      text:
                          '₹${(widget.product['price'] - (widget.product['price'] * widget.product['discount'] * 0.01)).toStringAsFixed(2)} ',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                  const WidgetSpan(child: SizedBox(width: 5)), // Space
                  TextSpan(
                    text:
                        '- ${widget.product['quantity']} ${widget.product['unit']}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 15, 15, 15),
                    ),
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: FutureBuilder<List<Cart>>(
                future: dbHelper.getCartList(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final cartItem = snapshot.data!.firstWhere(
                    (item) =>
                        item.productId ==
                        (widget.product["id"] is int
                            ? widget.product["id"].toString()
                            : widget.product["id"]),
                    orElse: () => Cart(
                      id: null,
                      productId: widget.product["id"] is int
                          ? widget.product["id"].toString()
                          : widget.product["id"],
                      name: widget.product["name"],
                      description: widget.product["description"] ?? "",
                      price: widget.product["price"].toDouble(),
                      discount: widget.product["discount"] ?? 0,
                      quantity: widget.product["quantity"] ?? 0,
                      number: 0,
                      unit: widget.product["unit"],
                      stock: widget.product["stock"] ?? 0,
                      category: widget.product["category"] ?? "",
                      imageUrl: widget.product["imageUrl"],
                    ),
                  );

                  bool isOutOfStock = widget.product["stock"] == 0;

                  return isOutOfStock
                      ? Container(
                          height: 35,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Center(
                            child: Text(
                              'Out of Stock',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      : cartItem.number > 0
                          ? Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 175, 116, 76),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 5),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () => handleQuantityChange(false),
                                    child: const Icon(Icons.remove,
                                        color: Colors.white),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    cartItem.number.toString(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                  const SizedBox(width: 10),
                                  InkWell(
                                    onTap: () => handleQuantityChange(true),
                                    child: const Icon(Icons.add,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            )
                          : InkWell(
                              onTap: handleAddToCart,
                              child: Container(
                                height: 35,
                                width: 100,
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 175, 116, 76),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Add to cart',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
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
                    : products.isNotEmpty
                        ? SizedBox(
                            height:
                                260, // Set a fixed height for the horizontal list
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount:
                                  products.length > 10 ? 10 : products.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProductDetailsPage(
                                          product: products[index],
                                          dbHelper: dbHelper,
                                          cart: cart,
                                        ),
                                      ),
                                    );
                                  },
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width /
                                        3, // Set the width to half the screen width for two products
                                    child: ProductGrid(
                                      products: [
                                        products[index]
                                      ], // Show only one product at a time
                                      dbHelper: dbHelper,
                                      cart: cart,
                                      cartWeb: cartWeb,
                                      onProductTap: (product) {
                                        Navigator.push(
                                          context,
                                          _createSlideTransitionRoute(
                                            ProductDetailsPage(
                                              product: product,
                                              dbHelper: dbHelper,
                                              cart: cart,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : const Center(
                            child: Text('No similar products found.'))),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: double
                    .infinity, // Make the container take up the full width
                padding: const EdgeInsets.symmetric(
                    vertical: 2), // Further reduced vertical padding
                decoration: BoxDecoration(
                  color: Colors.blue[50], // Light blue background color
                  borderRadius:
                      BorderRadius.circular(8), // Optional rounded corners
                  border: Border.all(
                    color: Colors.blue,
                    width: 1,
                  ), // Optional border
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero, // Removes the default padding
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => All_pages(
                          name: widget.product["category"],
                        ),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'See More Products',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize:
                              16, // Adjust text size for better readability
                        ),
                      ),
                      SizedBox(
                          width: 5), // Add some space between text and icon
                      Icon(
                        Icons.chevron_right, // Only the head of the arrow
                        color: Colors.blue,
                        size: 18, // Set the size of the arrow
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Product Description Section
            const SizedBox(height: 30),
            const Text('Product Description',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(fullDescription),
          ],
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
}
