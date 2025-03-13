class Cart {
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
  final int quantity;

  Cart({
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

  // Map to Cart object
 factory Cart.fromMap(Map<dynamic, dynamic> res) {
  return Cart(
    id: res['id'] as int?,
    productId: res['productId'] as String? ?? '', // Provide a default value if null
    name: res['name'] as String? ?? '',
    description: res['description'] as String? ?? '',
    price: (res['price'] as num?)?.toDouble() ?? 0.0, // Default to 0.0 if null
    discount: (res['discount'] as num?)?.toInt() ?? 0, // Default to 0 if null
    stock: (res['stock'] as num?)?.toInt() ?? 0, // Default to 0 if null
    number: res['number'] as int? ?? 0, // Default to 0 if null
    category: res['category'] as String? ?? '',
    imageUrl: res['imageUrl'] as String? ?? '',
    quantity: res['quantity'] as int? ?? 0, // Default to 0 if null
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

  Cart copyWith({required int quantity}) {
    return Cart(
        id: this.id, // Retain the existing id
        productId: this.productId, // Retain the existing productId
        name: this.name, // Retain the existing name
        description: this.description, // Retain the existing description
        price: this.price, // Retain the existing price
        discount: this.discount,
        number: number, // Update the quantity with the new value
        stock: this.stock, // Retain the existing stock
        category: this.category, // Retain the existing category
        imageUrl: this.imageUrl, // Retain the existing imageUrl
        quantity: this.quantity,
        unit: this.unit);
  }
}
