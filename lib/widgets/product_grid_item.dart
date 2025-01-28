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
        number: 1,
        stock: widget.product["stock"] ?? 0,
        category: widget.product["category"] ?? "",
        imageUrl: widget.product["imageUrl"],
      ));

      widget.cart.addTotalPrice(widget.product["price"].toDouble());
      widget.cart.addCounter();

      setState(() {
        itemCount = 1; // Update local state
      });
    } catch (error) {
    }
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
        widget.cart.removeTotalPrice(cartItem.price);

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Item removed from cart'),
          duration: Duration(seconds: 1),
        ));

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
            cartItem.price * cartItem.number, cartItem.price * newNumber);

        setState(() {
          itemCount = newNumber;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Not enough stock available'),
          duration: Duration(seconds: 1),
        ));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text('Error updating quantity'),
        duration: Duration(seconds: 1),
      ));
    }
  }
 @override
Widget build(BuildContext context) {
  final bool isOutOfStock = (widget.product['stock'] ?? 0) <= 0;

  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Column(
      children: [
        Stack(
          children: [
            ClipOval(
              child: Image.network(
                widget.product["imageUrl"],
                width: 120,
                height: 120,
                fit: BoxFit.fill,
              ),
            ),
            if (isOutOfStock)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                  child: const Center(
                    child: Text(
                      'Out of Stock',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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
                height: 40,
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
              Text(
                '₹${widget.product['price']} - ${widget.product['quantity']}${widget.product['unit']}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              if (!isOutOfStock)
                Align(
                  alignment: Alignment.centerRight,
                  child: itemCount != null && itemCount! > 0
                      ? Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
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
                            width: 100,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Center(
                              child: Text(
                                'Add to cart',
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
  );
}
}
