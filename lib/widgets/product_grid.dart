import 'package:flutter/material.dart';
import '../helper/db__helper.dart';
import '../provider/cart_provider.dart';
import 'product_grid_item.dart';

class ProductGrid extends StatelessWidget {
  final List<dynamic> products;
  final DBHelper dbHelper;
  final CartProvider cart;
  final Function(dynamic product)? onProductTap; // onProductTap callback

  const ProductGrid({
    Key? key,
    required this.products,
    required this.dbHelper,
    required this.cart,
    this.onProductTap, // Optional callback for handling product taps
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Split products into in-stock and out-of-stock
    List<dynamic> inStockProducts = products.where((product) => product['stock'] > 0).toList();
    List<dynamic> outOfStockProducts = products.where((product) => product['stock'] == 0).toList();

    // Combine in-stock products first, then out-of-stock products
    List<dynamic> sortedProducts = [...inStockProducts, ...outOfStockProducts];

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 20,
      ),
      itemCount: sortedProducts.length,
      itemBuilder: (context, index) {
        final product = sortedProducts[index];
        return GestureDetector(
          onTap: () {
            // Trigger the onProductTap callback if it's provided
            onProductTap?.call(product);
          },
          child: ProductGridItem(
            product: product,
            dbHelper: dbHelper,
            cart: cart,
          ),
        );
      },
    );
  }
}
