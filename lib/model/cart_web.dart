class CartWeb {
  final int? id; // Nullable for auto-increment
  final String productId;
  final String name;
  final String description;
  final double price;
  final int discount;
  int number;
  final int stock;
  final String category;
  final String imageUrl;
  final String unit;
  int quantity;

  CartWeb({
    this.id, // Optional id
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.discount,
    required this.number,
    required this.quantity,
    required this.stock,
    required this.category,
    required this.imageUrl,
    required this.unit,
  });
 factory CartWeb.fromMap(Map<dynamic, dynamic> res) {
  return CartWeb(
    id: res['id'] as int? ?? 0, // Default to 0 if null
    productId: res['productId'] as String? ?? '',
    name: res['name'] as String? ?? '',
    description: res['description'] as String? ?? '',
    price: (res['price'] as num?)?.toDouble() ?? 0.0, // Default to 0.0 if null
    discount: (res['discount'] as num?)?.toInt() ?? 0, // Default to 0 if null
    stock: (res['stock'] as num?)?.toInt() ?? 0, // Default to 0 if null
    number: (res['number'] as int?) ?? 0, // Default to 0 if null
    quantity: (res['quantity'] as int?) ?? 0, // Default to 0 if null
    category: res['category'] as String? ?? '',
    imageUrl: res['imageUrl'] as String? ?? '',
    unit: res['unit'] as String? ?? '',
  );
}

  // Cart object to Map
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'description': description,
      'price': price,
      'discount': discount,
      'number': number,
      'stock': stock,
      'category': category,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'unit': unit
    };
  }
}
