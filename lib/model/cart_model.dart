class Cart {
  final int? id; // Nullable for auto-increment
  final String productId;
  final String name;
  final String description;
  final double price;
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
      productId: res['productId'] as String,
      name: res['name'] as String,
      description: res['description'] as String,
      price: res['price'] as double,
      number: res['number'] as int,
      stock: res['stock'] as int,
      category: res['category'] as String,
      imageUrl: res['imageUrl'] as String,
      quantity: res['quantity'] as int,
      unit: res['unit'] as String,
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
      'number': number,
      'stock': stock,
      'category': category,
      'imageUrl': imageUrl,
      'quantity':quantity,
      'unit':unit
    };
  }

  Cart copyWith({required int quantity}) {
    return Cart(
      id: this.id, // Retain the existing id
      productId: this.productId, // Retain the existing productId
      name: this.name, // Retain the existing name
      description: this.description, // Retain the existing description
      price: this.price, // Retain the existing price
      number: number, // Update the quantity with the new value
      stock: this.stock, // Retain the existing stock
      category: this.category, // Retain the existing category
      imageUrl: this.imageUrl, // Retain the existing imageUrl
      quantity:this.quantity,
      unit: this.unit
    );
  }
}
