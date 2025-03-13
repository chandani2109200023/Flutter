import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../model/cart_model.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  // Getter for database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
 Future<Database> _initDatabase() async {
  final directory = await getApplicationDocumentsDirectory();
  final path = join(directory.path, 'cart.db');
  return await openDatabase(
    path,
    version: 3, // Increment to version 3
    onCreate: (db, version) async {
      await db.execute('''
      CREATE TABLE cart (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId TEXT,
        name TEXT,
        description TEXT,
        price REAL,
        discount INTEGER,
        number INTEGER,
        stock INTEGER,
        category TEXT,
        imageUrl TEXT,
        quantity INTEGER,
        unit TEXT
      )
      ''');
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 3) {
        // Remove variantId if it's present
        // Since we cannot drop a column directly in SQLite, you would typically 
        // create a new table without the 'variantId' and migrate the data.
        // Make sure you handle this properly in your real database upgrade logic
      }
    },
  );
}

  // Insert item into the cart
  Future<int> insert(Cart cart) async {
    final db = await database;
    return await db.insert(
      'cart',
      cart.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // Replace if item exists
    );
  }

  // Retrieve all items in the cart
  Future<List<Cart>> getCartList() async {
    final db = await database;
    final List<Map<String, dynamic>> items = await db.query('cart');
    return items.map((item) => Cart.fromMap(item)).toList();
  }

  // Delete item by ID
  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete(
      'cart',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete item by productId
  Future<int> deleteItemByProductId(String productId) async {
    final db = await database;
    return await db.delete(
      'cart',
      where: 'productId = ?',
      whereArgs: [productId],
    );
  }

  // Delete multiple items by a list of productIds
  Future<int> deleteItemsByProductIds(List<String> productIds) async {
    final db = await database;
    final placeholders = List.filled(productIds.length, '?').join(',');
    return await db.delete(
      'cart',
      where: 'productId IN ($placeholders)',
      whereArgs: productIds,
    );
  }

  // Clear the entire cart
  Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart');
  }

  // Update quantity for a given ID (ensure quantity is positive)
  Future<void> updateQuantity(int id, int quantity) async {
    if (quantity < 0) {
      throw ArgumentError("Quantity cannot be negative");
    }
    final db = await database;
    await db.update(
      'cart',
      {'number': quantity},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete item from the cart by ID
  Future<void> delete(int id) async {
    final db = await database;
    try {
      await db.delete(
        'cart',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print("Error deleting item from database: $e");
    }
  }

  // Manually reset the database (useful for development or testing)
  Future<void> resetDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'cart.db');
    await deleteDatabase(path); // Deletes the existing database
    print('Database deleted');
  }
}
