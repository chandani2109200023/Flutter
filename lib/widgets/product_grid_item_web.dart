import 'package:flutter/material.dart';
import 'package:agrive_mart/provider/cart_storage_web.dart'; // Import CartStorageHelper
import '../model/cart_web.dart'; // Import CartWeb model

class ProductGridItemWeb extends StatefulWidget {
  final dynamic product;
  final CartStorageHelper cart;

  const ProductGridItemWeb(
      {super.key, required this.product, required this.cart});

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

  void fetchInitialCartCount() {
    final cartItems = widget.cart.cartItems;
    final existingItem = cartItems.firstWhere(
      (item) => item.productId == widget.product["id"].toString(),
      orElse: () => CartWeb(
        productId: widget.product["id"].toString(),
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

  Future<void> handleAddToCart() async {
    final cartItems = await widget.cart.cartItems;
    if (cartItems
        .any((item) => item.productId == widget.product["id"].toString())) {
      return;
    }

    widget.cart.addItem(
      CartWeb(
        id: null,
        productId: widget.product["id"].toString(),
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
      ),
    );

    widget.cart.addTotalPrice(
        widget.product["price"].toDouble(), widget.product["discount"]);
    widget.cart.addCounter();
    setState(() {
      itemCount = 1;
    });
  }

  Future<void> handleQuantityChange(bool isIncrement) async {
    try {
      if (itemCount == null) return;

      final cartItems = widget.cart.cartItems;

      final cartItem = cartItems.firstWhere(
        (item) =>
            item.productId ==
            (widget.product["id"] is int
                ? widget.product["id"].toString()
                : widget.product["id"] ?? ''),
      );

      int newNumber = isIncrement ? cartItem.number + 1 : cartItem.number - 1;

      if (newNumber < 1) {
        cartItems.removeWhere((item) => item.productId == cartItem.productId);
        widget.cart.removeCounter();
        widget.cart.removeTotalPrice(cartItem.price, cartItem.discount);
        setState(() {
          itemCount = 0;
        });
      } else if (newNumber <= cartItem.stock) {
        await widget.cart.updateQuantity(cartItem.productId, newNumber);

        if (isIncrement) {
          widget.cart.addCounter();
        } else {
          widget.cart.removeCounter();
        }

        // Update cart and price
        widget.cart.updateTotalPrice(
          (cartItem.price * cartItem.number) -
              (cartItem.price * cartItem.number * cartItem.discount * 0.01),
          (cartItem.price * newNumber) -
              (cartItem.price * newNumber * cartItem.discount * 0.01),
        );
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
      print('Error updating quantity: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock = (widget.product['stock'] ?? 0) <= 0;

    return SingleChildScrollView(
      // Wrap entire widget with SingleChildScrollView
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
                      child: FutureBuilder<List<CartWeb>>(
                        future: widget.cart.getCartFromLocal(),
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
                            orElse: () => CartWeb(
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

                          return cartItem.number > 0
                              ? Container(
                                  decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(255, 175, 116, 76),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 5),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () =>
                                            handleQuantityChange(false),
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
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 175, 116, 76),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Add',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                );
                        },
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
