import 'package:flutter/material.dart';
import '../model/cart_web.dart';
import '../provider/cart_storage_helper.dart';

class CartScreenWeb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Retrieve cart items from the session storage
    List<CartWeb> cartItems = CartStorageHelper.getCartFromSession();
    double totalPrice = CartStorageHelper.getTotalPrice();

    return Scaffold(
      appBar: AppBar(
        title: Text("Cart"),
      ),
      body: cartItems.isEmpty
          ? Center(child: Text("Your cart is empty."))
          : Column(
              children: [
                // List of cart items
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      CartWeb cartItem = cartItems[index];
                      double discountedPrice = cartItem.price * (1 - 0.05); // 5% discount
                      double totalItemPrice = discountedPrice * cartItem.number;

                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: Image.network(cartItem.imageUrl), // Product image
                          title: Text(cartItem.name),
                          subtitle: Text(cartItem.description),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("Qty: ${cartItem.number}"),
                              Text("Price: \$${discountedPrice.toStringAsFixed(2)}"),
                              Text("Total: \$${totalItemPrice.toStringAsFixed(2)}"),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Total Price
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Price (After 5% Discount):"),
                      Text("\$${totalPrice.toStringAsFixed(2)}"),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
