import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import '../helper/db__helper.dart';
import '../model/cart_web.dart';
import '../pages/all_pages.dart';
import '../provider/cart_provider.dart';
import '../model/cart_model.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../provider/cart_storage_helper.dart';
import '../screen/cart_screen_web.dart';
import '../widgets/product_grid.dart';
import 'dart:html';

class ProductDetailsWebPage extends StatefulWidget {
  final dynamic product;

  const ProductDetailsWebPage({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsWebPage> createState() => _ProductDetailsWebPageState();
}

class _ProductDetailsWebPageState extends State<ProductDetailsWebPage> {
  DBHelper dbHelper = DBHelper();
  late Future<List<Cart>> cartItemsFuture;
  bool isDescriptionExpanded = false;
  List<dynamic> products = [];
  bool isLoading = true;
  String? errorMessage;
  int? itemCount;
  int cartCounterWeb = 0;

  @override
  void initState() {
    super.initState();
    cartItemsFuture = dbHelper.getCartList();
    fetchSimilarProducts();
    fetchInitialCartCount();
    cartCounterWeb = CartStorageHelper.getCounter();
  }
   @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure that the counter is updated when the page is resumed
    cartCounterWeb = CartStorageHelper.getCounter();
    setState(() {});
  }

  // Fetch the initial cart count when the product is first displayed
  void fetchInitialCartCount() {
    final cartItems = _getCartListFromStorage();
    final existingItem = cartItems.firstWhere(
      (item) =>
          item.productId == (widget.product["id"] is int
              ? widget.product["id"].toString()
              : widget.product["id"] ?? ''),
      orElse: () => CartWeb(
        productId: widget.product["id"] ?? '',
        description: widget.product["description"] ?? '',
        name: widget.product["name"] ?? '',
        stock: widget.product["stock"] ?? 0,
        unit: widget.product["unit"] ?? '',
        number: 0,
        category: widget.product["category"] ?? '',
        price: (widget.product["price"] as num?)?.toDouble() ?? 0.0,
        quantity: widget.product["quantity"] ?? 0,
        discount: widget.product["discount"] ?? 0,
        imageUrl: widget.product["imageUrl"] ?? '',
      ),
    );

    setState(() {
      itemCount = existingItem.number;
    });
  }

  // Get cart list from localStorage (simulated by `localStorage` in Dart Web)
  List<CartWeb> _getCartListFromStorage() {
    final storedData =
        window.localStorage['cart'] ?? '[]'; // Get stored cart data
    final List<dynamic> dataList = jsonDecode(storedData);

    return dataList.map((e) => CartWeb.fromMap(e)).toList();
  }

  // Save the cart to localStorage
  void _saveCartToStorage(List<CartWeb> cartItems) {
    final cartListJson = cartItems.map((item) => item.toMap()).toList();
    window.localStorage['cart'] = jsonEncode(cartListJson);
  }

  // Add product to the cart
  Future<void> handleAddToCart() async {
    try {
      final cartItems = _getCartListFromStorage();

      // Check if the product already exists in the cart
      if (cartItems.any((item) =>
          item.productId == (widget.product["id"] is int
              ? widget.product["id"].toString()
              : widget.product["id"] ?? ''))) {
        return;
      }

      // Add product to cart
      cartItems.add(CartWeb(
        id: null,
        productId: widget.product["id"] ?? '',
        description: widget.product["description"] ?? '',
        name: widget.product["name"] ?? '',
        stock: widget.product["stock"] ?? 0,
        unit: widget.product["unit"] ?? '',
        quantity: widget.product["quantity"] ?? 0,
        category: widget.product["category"] ?? '',
        price: (widget.product["price"] as num?)?.toDouble() ?? 0.0,
        number: 1,
        discount: widget.product["discount"] ?? 0,
        imageUrl: widget.product["imageUrl"] ?? '',
      ));

      // Update cart and price
      CartStorageHelper.addTotalPrice(
          widget.product["price"].toDouble(), widget.product["discount"]);
      CartStorageHelper.addCounter();

      // Save to localStorage
      _saveCartToStorage(cartItems);

      setState(() {
        itemCount = 1;
      });
    } catch (error) {
      print('Error adding to cart: $error');
    }
  }

  // Handle quantity changes for the product
  Future<void> handleQuantityChange(bool isIncrement) async {
    try {
      if (itemCount == null) return;

      final cartItems = _getCartListFromStorage();

      final cartItem = cartItems.firstWhere(
        (item) =>
            item.productId == (widget.product["id"] is int
                ? widget.product["id"].toString()
                : widget.product["id"] ?? ''),
      );

      int newNumber = isIncrement ? cartItem.number + 1 : cartItem.number - 1;

      if (newNumber < 1) {
        cartItems.removeWhere((item) => item.productId == cartItem.productId);
        CartStorageHelper.removeCounter();
        CartStorageHelper.removeTotalPrice(cartItem.price, cartItem.discount);

        _saveCartToStorage(cartItems);
        setState(() {
          itemCount = 0;
        });
      } else if (newNumber <= cartItem.stock) {
        cartItem.number = newNumber;

        // Update cart and price
        CartStorageHelper.updateTotalPrice(
          (cartItem.price * cartItem.number) -
              (cartItem.price * cartItem.number * cartItem.discount * 0.01),
          (cartItem.price * newNumber) -
              (cartItem.price * newNumber * cartItem.discount * 0.01),
        );

        if (isIncrement) {
          CartStorageHelper.addCounter();
        } else {
          CartStorageHelper.removeCounter();
        }

        // Save to localStorage
        _saveCartToStorage(cartItems);

        setState(() {
          itemCount = newNumber;
        });
      }
    } catch (error) {
      print('Error updating quantity: $error');
    }
  }


  Future<void> fetchSimilarProducts() async {
    final url = Uri.parse(
        'https://sastabazar.onrender.com/api/user/Products/category/${widget.product['category']}');

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
    cartCounterWeb = CartStorageHelper.getCounter();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return IconButton(
                icon: badges.Badge(
                  showBadge: cartCounterWeb > 0,
                  badgeContent: Text(
                    cartCounterWeb.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  child: const Icon(Icons.shopping_bag_outlined),
                ),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartScreenWeb()),
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
                      child: itemCount != null && itemCount! > 0
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
                                    itemCount.toString(),
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
                                width: 50,
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 175, 116, 76),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Add',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
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
                                            ProductDetailsWebPage(
                                          product: products[index]
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
                                      onProductTap: (product) {
                                        Navigator.push(
                                          context,
                                          _createSlideTransitionRoute(
                                            ProductDetailsWebPage(
                                              product: product
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
