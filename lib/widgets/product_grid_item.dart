import 'package:flutter/material.dart';
import '../helper/db__helper.dart';
import '../provider/cart_provider.dart';
import '../model/cart_model.dart';

class ProductGridItem extends StatefulWidget {
  final dynamic product;
  final DBHelper dbHelper;
  final CartProvider cart;

  const ProductGridItem({
    super.key,
    required this.product,
    required this.dbHelper,
    required this.cart,
  });

  @override
  State<ProductGridItem> createState() => _ProductGridItemState();
}

class _ProductGridItemState extends State<ProductGridItem> {
  int? itemCount;

  @override
  void initState() {
    super.initState();
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
        itemCount = 1;
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
        await widget.dbHelper.deleteItem(cartItem.id!);
        widget.cart.removeCounter();
        widget.cart.removeTotalPrice(cartItem.price, cartItem.discount);

        setState(() {
          itemCount = 0;
        });
      } else if (newNumber <= cartItem.stock) {
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
    } catch (error) {}
  }

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock = (widget.product['stock'] ?? 0) <= 0;

    return SingleChildScrollView( // Wrap entire widget with SingleChildScrollView
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                      child: FutureBuilder<List<Cart>>(
                        future: widget.dbHelper.getCartList(),
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

                          return cartItem.number > 0
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 175, 116, 76),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () => handleQuantityChange(false),
                                        child: const Icon(Icons.remove, color: Colors.white),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        cartItem.number.toString(),
                                        style: const TextStyle(color: Colors.white, fontSize: 16),
                                      ),
                                      const SizedBox(width: 10),
                                      InkWell(
                                        onTap: () => handleQuantityChange(true),
                                        child: const Icon(Icons.add, color: Colors.white),
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
                                      color: const Color.fromARGB(255, 175, 116, 76),
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
