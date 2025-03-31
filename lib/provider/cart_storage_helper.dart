import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../model/cart_web.dart';

class CartStorageHelper with ChangeNotifier {
  List<CartWeb> _cartItems = [];
  double _totalPrice = 0.0;
  int _counter = 0;
  Future<List<CartWeb>> _cart = Future.value([]);

  List<CartWeb> get cartItems => _cartItems;
  double get totalPrice => _totalPrice;
  int get counter => _counter;
  Future<List<CartWeb>> get cart => _cart;
  int getCounter() => _counter;

  CartStorageHelper() {
    _loadCartFromLocalStorage();
  }

  // Load cart items from localStorage
  void _loadCartFromLocalStorage() {
    String? cartJson = html.window.localStorage['cart'];
    if (cartJson != null) {
      List<dynamic> cartMapList = jsonDecode(cartJson);
      _cartItems =
          cartMapList.map((cartMap) => CartWeb.fromMap(cartMap)).toList();
      _counter = int.tryParse(html.window.localStorage['counter'] ?? '0') ?? 0;
      _totalPrice = _calculateTotalPrice();
    }
    _cart = Future.value(_cartItems); // Ensure future is updated
    notifyListeners();
  }

  Future<List<CartWeb>> getCartFromLocal() async {
    _loadCartFromLocalStorage();
    return _cart;
  }

  void _saveCartToLocalStorage() {
    html.window.localStorage['cart'] =
        jsonEncode(_cartItems.map((cart) => cart.toMap()).toList());
    html.window.localStorage['totalPrice'] = _totalPrice.toString();
    html.window.localStorage['counter'] = _counter.toString();
  }

  void addItem(CartWeb cartItem) {
    _cartItems.add(cartItem);
    _totalPrice +=
        (cartItem.price - (cartItem.price * cartItem.discount * 0.01));
    _saveCartToLocalStorage();
    notifyListeners();
  }

  void removeItem(CartWeb cartItem) {
    _cartItems.removeWhere((item) => item.productId == cartItem.productId);
    _totalPrice -=
        (cartItem.price - (cartItem.price * cartItem.discount * 0.01));
    _saveCartToLocalStorage();
    notifyListeners();
  }

  Future<void> updateQuantity(String productId, int newQuantity) async {
    if (newQuantity <= 0) {
      throw ArgumentError("Quantity must be greater than 0");
    }

    // Find the item in the cart list
    int index = _cartItems.indexWhere((item) => item.productId == productId);
    if (index == -1) throw Exception("Item not found in the cart.");

    // Calculate old price
    double oldPrice = (_cartItems[index].price * _cartItems[index].number) -
        (_cartItems[index].price *
            _cartItems[index].number *
            _cartItems[index].discount *
            0.01);

    // Update the quantity
    _cartItems[index].number = newQuantity;
    print(newQuantity);
    print(_cartItems[index].number);

    // Calculate new price
    double newPrice = (_cartItems[index].price * newQuantity) -
        (_cartItems[index].price *
            newQuantity *
            _cartItems[index].discount *
            0.01);

    // Update total price
    _totalPrice = _totalPrice - oldPrice + newPrice;

    // Save updated cart to local storage
    _saveCartToLocalStorage();

    // Notify listeners if using Provider/State Management
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    _counter = 0;
    _totalPrice = 0.0;
    _saveCartToLocalStorage();
    notifyListeners();
  }

  void addTotalPrice(double productPrice, int discount) {
    _totalPrice += ((productPrice) - (productPrice * discount * 0.01));
    _saveCartToLocalStorage();
    notifyListeners();
  }

  void removeTotalPrice(double productPrice, int discount) {
    _totalPrice -= ((productPrice) - (productPrice * discount * 0.01));
    _saveCartToLocalStorage();
    notifyListeners();
  }

  void updateTotalPrice(double oldPrice, double newPrice) {
    _totalPrice = _totalPrice - oldPrice + newPrice;
    _saveCartToLocalStorage();
    notifyListeners();
  }

  double _calculateTotalPrice() {
    return _cartItems.fold(0.0, (sum, cartItem) {
      return sum +
          (cartItem.price * cartItem.number) -
          (cartItem.price * cartItem.number * cartItem.discount * 0.01);
    });
  }

  double getTotalPrice() => _totalPrice;

  void addCounter() {
    _counter++;
    _saveCartToLocalStorage();
    notifyListeners();
  }

  void removeCounter() {
    if (_counter > 0) {
      _counter--;
      _saveCartToLocalStorage();
      notifyListeners();
    }
  }
}
