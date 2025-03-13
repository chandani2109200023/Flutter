import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helper/db__helper.dart';
import '../model/cart_model.dart';

class CartProvider with ChangeNotifier {
  DBHelper db = DBHelper();

  int _counter = 0;
  double _totalPrice = 0.0;
  Future<List<Cart>> _cart = Future.value([]);
  List<Cart> _cartItems = []; // Initialize an empty list for cart items

  // Getter to access cart items
  List<Cart> get cartItems => _cartItems;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  int get counter => _counter;
  double get totalPrice => _totalPrice;
  Future<List<Cart>> get cart => _cart;

  CartProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await _prefs;
    _counter = prefs.getInt('cart_item') ?? 0;
    _totalPrice = prefs.getDouble('total_price') ?? 0.0;
    notifyListeners();
  }

  Future<void> _setPrefItems() async {
    final prefs = await _prefs;
    await prefs.setInt('cart_item', _counter);
    await prefs.setDouble('total_price', _totalPrice);
  }

  void addItem(Cart cartItem) {
    _cartItems.add(cartItem);
    _totalPrice += (cartItem.price * cartItem.number)-(cartItem.price*cartItem.number*cartItem.discount*0.01);
    notifyListeners();
  }

  Future<List<Cart>> getData() async {
    _cart = db.getCartList(); // Fetch the cart data from DB
    return _cart;
  }

  Future<void> updateQuantity(Cart cart, int number) async {
    // Ensure the quantity is valid before updating
    if (number <= 0) {
      throw ArgumentError("Quantity must be greater than 0");
    }

    // Update quantity in the database using cart id
    await db.updateQuantity(cart.id!, number);

    // Fetch the updated cart list from the database
    _cartItems = await db.getCartList();

    // Notify listeners to update the UI
    notifyListeners();
  }

  void addTotalPrice(double productPrice,int discount ){
    _totalPrice += ((productPrice)-(productPrice*discount*0.01));
    _setPrefItems();
    notifyListeners();
  }

  void removeTotalPrice(double productPrice,int discount) {
    _totalPrice -= ((productPrice)-(productPrice*discount*0.01));
    _setPrefItems();
    notifyListeners();
  }

  void updateTotalPrice(double oldPrice, double newPrice) {
    _totalPrice = _totalPrice - oldPrice + newPrice;
    _setPrefItems();
    notifyListeners();
  }

  // Corrected clearCart method
  Future<void> clearCart() async {
    await db.clearCart(); // Clear the cart in the database
    _counter = 0;
    _totalPrice = 0.0;
    _cart = Future.value([]); // Set the cart to an empty list
    _setPrefItems(); // Update preferences
    notifyListeners();
  }

  void addCounter() {
    _counter++;
    _setPrefItems();
    notifyListeners();
  }

  void removeCounter() {
    if (_counter > 0) {
      _counter--;
      _setPrefItems();
      notifyListeners();
    }
  }

  void updateCounter(bool isIncrement) {
    if (isIncrement) {
      addCounter();
    } else {
      removeCounter();
    }
  }

  double getTotalPrice() {
    return _totalPrice;
  }

  int getCounter() {
    return _counter;
  }

  void addToCart(Cart product) {
    // Check if the product is already in the cart
    bool productExists =
        _cartItems.any((item) => item.productId == product.productId);

    if (productExists) {
      // If product exists, update the quantity
      updateQuantity(product, product.number + 1);
    } else {
      // If the product doesn't exist, add it to the cart
      _cartItems.add(product);
    }
    notifyListeners();
  }

  void removeItem(Cart cartItem) {
    _cartItems.remove(cartItem);
    _totalPrice -= cartItem.price * cartItem.number;
    notifyListeners();
  }
}
