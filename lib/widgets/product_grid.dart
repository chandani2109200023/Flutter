import 'package:agrive_mart/provider/cart_storage_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../helper/db__helper.dart';
import '../provider/cart_provider.dart';
import 'product_grid_item.dart';
import 'product_grid_item_web.dart'; // Import the web version of the product grid item

class ProductGrid extends StatelessWidget {
  final List<dynamic> products;
  final DBHelper dbHelper; // Add DBHelperWeb for web
  final CartProvider cart;
  final CartStorageHelper cartWeb;
  final Function(dynamic product)? onProductTap;

  const ProductGrid({
    Key? key,
    required this.products,
    required this.dbHelper, // Pass the DBHelperWeb instance here
    required this.cart,
    required this.cartWeb,
    this.onProductTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Split products into in-stock and out-of-stock
    List<dynamic> inStockProducts =
        products.where((product) => product['stock'] > 0).toList();
    List<dynamic> outOfStockProducts =
        products.where((product) => product['stock'] == 0).toList();

    // Combine in-stock products first, then out-of-stock products
    List<dynamic> sortedProducts = [...inStockProducts, ...outOfStockProducts];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Adjust grid layout based on screen width
        double maxWidth = constraints.maxWidth;
        int crossAxisCount;
        double mainAxisSpacing;
        double crossAxisSpacing;
        double childAspectRatio;

        // Logic for different screen sizes (mobile, tablet, web)
        if (maxWidth < 600) {
          // Mobile: Single column or two columns
          crossAxisCount = 2;
          mainAxisSpacing = 10;
          crossAxisSpacing = 10;
          childAspectRatio = 0.7; // Aspect ratio for mobile
        } else if (maxWidth < 1200) {
          crossAxisCount = 3;
          mainAxisSpacing = 15;
          crossAxisSpacing = 15;
          childAspectRatio = 0.6; // Aspect ratio for tablet
        } else {
          // Web: 5 columns, no vertical spacing between rows
          crossAxisCount = 5;
          mainAxisSpacing = 0.0; // No space between rows on the web
          crossAxisSpacing = 12;
          childAspectRatio =
              0.9; // Adjust aspect ratio for web (change as needed)
        }

        return GridView.builder(
          padding: const EdgeInsets.all(10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            childAspectRatio: childAspectRatio, // Use dynamic childAspectRatio
          ),
          itemCount: sortedProducts.length,
          itemBuilder: (context, index) {
            final product = sortedProducts[index];

            // Use ProductGridItemWeb if it's a web screen, else use ProductGridItem
            return GestureDetector(
              onTap: () {
                onProductTap?.call(product);
              },
              child: ClipRect(
                // Clips overflowed content
                child: kIsWeb
                    ? ProductGridItemWeb(
                        product: product, // Pass the DBHelperWeb instance here
                        cart: cartWeb,
                      )
                    : ProductGridItem(
                        product: product,
                        dbHelper: dbHelper,
                        cart: cart,
                      ),
              ),
            );
          },
        );
      },
    );
  }
}
