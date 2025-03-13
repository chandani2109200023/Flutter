import 'dart:convert';
import 'dart:html'; // Importing for localStorage
import 'package:flutter/material.dart';
import 'package:agrive_mart/provider/cart_storage_helper.dart'; // Import your helper
import '../model/cart_web.dart'; // Import the CartWeb model

class ProductGridItemWeb extends StatefulWidget {
  final dynamic product;

  const ProductGridItemWeb({super.key, required this.product});

  @override
  State<ProductGridItemWeb> createState() => _ProductGridItemWebState();
}

class _ProductGridItemWebState extends State<ProductGridItemWeb> {
  int? itemCount;

  @override
  void initState() {
    super.initState();
    fetchInitialCartCount();
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

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock = (widget.product['stock'] ?? 0) <= 0;

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: isOutOfStock ? Colors.grey[300] : Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    widget.product["imageUrl"],
                    width: 179,
                    height: 160,
                    fit: BoxFit.fill,
                  ),
                ),
                if (isOutOfStock)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                if (widget.product["discount"] > 0)
                  Positioned(
                    top: 1,
                    right: 1,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 244, 108, 54),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${widget.product["discount"]}% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 20,
                    child: Text(
                      widget.product['name'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text.rich(
                    TextSpan(
                      children: [
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
                        const WidgetSpan(child: SizedBox(width: 5)),
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
                  const SizedBox(height: 5),
                  if (!isOutOfStock)
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
