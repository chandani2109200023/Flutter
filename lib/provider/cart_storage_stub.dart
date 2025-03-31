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

  CartStorageHelper();

  Future<List<CartWeb>> getCartFromLocal() async {
    return _cart;
  }

  void addItem(CartWeb cartItem) {
    _cartItems.add(cartItem);
    _totalPrice += (cartItem.price - (cartItem.price * cartItem.discount * 0.01));
    notifyListeners();
  }

  void removeItem(CartWeb cartItem) {
    _cartItems.removeWhere((item) => item.productId == cartItem.productId);
    _totalPrice -= (cartItem.price - (cartItem.price * cartItem.discount * 0.01));
    notifyListeners();
  }

  Future<void> updateQuantity(String productId, int newQuantity) async {
    if (newQuantity <= 0) {
      throw ArgumentError("Quantity must be greater than 0");
    }

    int index = _cartItems.indexWhere((item) => item.productId == productId);
    if (index == -1) throw Exception("Item not found in the cart.");

    double oldPrice = (_cartItems[index].price * _cartItems[index].number) -
        (_cartItems[index].price * _cartItems[index].number * _cartItems[index].discount * 0.01);

    _cartItems[index].number = newQuantity;

    double newPrice = (_cartItems[index].price * newQuantity) -
        (_cartItems[index].price * newQuantity * _cartItems[index].discount * 0.01);

    _totalPrice = _totalPrice - oldPrice + newPrice;
    
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    _counter = 0;
    _totalPrice = 0.0;
    notifyListeners();
  }

  void addTotalPrice(double productPrice, int discount) {
    _totalPrice += (productPrice - (productPrice * discount * 0.01));
    notifyListeners();
  }

  void removeTotalPrice(double productPrice, int discount) {
    _totalPrice -= (productPrice - (productPrice * discount * 0.01));
    notifyListeners();
  }

  void updateTotalPrice(double oldPrice, double newPrice) {
    _totalPrice = _totalPrice - oldPrice + newPrice;
    notifyListeners();
  }

  double getTotalPrice() => _totalPrice;

  void addCounter() {
    _counter++;
    notifyListeners();
  }

  void removeCounter() {
    if (_counter > 0) {
      _counter--;
      notifyListeners();
    }
  }
}
