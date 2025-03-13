import 'dart:convert';
import 'dart:html' as html;
import '../model/cart_web.dart';

class CartStorageHelper {
  // Save Cart data in sessionStorage
  static void saveCartToSession(List<CartWeb> cartList) {
    List<Map<String, dynamic>> cartMapList =
        cartList.map((cart) => cart.toMap()).toList();
    String cartJson = jsonEncode(cartMapList);
    html.window.sessionStorage['cart'] = cartJson;
  }

  // Update quantity of a specific item in the cart
  static Future<void> updateQuantity(int cartItemId, int newQuantity) async {
    List<CartWeb> cartItems = getCartFromSession();

    // Find the item in the cart using the item ID
    CartWeb? cartItem = cartItems.firstWhere(
      (item) => item.id == cartItemId,
      orElse: () => throw Exception(
          "Item not found in the cart."), // Throw error if item not found
    );

    // Update the quantity
    cartItem.number = newQuantity;

    // Save the updated cart back to sessionStorage
    saveCartToSession(cartItems);
  }

  // Retrieve Cart data from sessionStorage
  static List<CartWeb> getCartFromSession() {
    String? cartJson = html.window.sessionStorage['cart'];
    if (cartJson != null) {
      List<dynamic> cartMapList = jsonDecode(cartJson);
      return cartMapList.map((cartMap) => CartWeb.fromMap(cartMap)).toList();
    }
    return [];
  }

  // Get the total price of all cart items from sessionStorage
  static double getTotalPrice() {
    String? storedTotalPrice = html.window.sessionStorage['totalPrice'];
    if (storedTotalPrice != null) {
      return double.tryParse(storedTotalPrice) ?? 0.0;
    }

    // If no total price is stored, calculate it from the cart items
    List<CartWeb> cartItems = getCartFromSession();
    double totalPrice = cartItems.fold(0.0, (total, cartItem) {
      return total +
          (cartItem.price * cartItem.number) -
          (cartItem.price * cartItem.number * cartItem.discount * 0.01);
    });

    html.window.sessionStorage['totalPrice'] = totalPrice.toString();
    return totalPrice;
  }

  // Add total price when a new item is added to the cart
  static void addTotalPrice(double productPrice, int discount) {
    double currentTotalPrice = getTotalPrice();
    currentTotalPrice += (productPrice - (productPrice * discount * 0.01));
    html.window.sessionStorage['totalPrice'] = currentTotalPrice.toString();
    saveCartToSession(getCartFromSession());
  }

  // Remove total price when an item is removed from the cart
  static void removeTotalPrice(double productPrice, int discount) {
    double currentTotalPrice = getTotalPrice();
    currentTotalPrice -= (productPrice - (productPrice * discount * 0.01));
    html.window.sessionStorage['totalPrice'] = currentTotalPrice.toString();
    saveCartToSession(getCartFromSession());
  }

  static void updateTotalPrice(double oldPrice, double newPrice) {
    double totalPrice = getTotalPrice();
    totalPrice = totalPrice - oldPrice + newPrice;
    saveCartToSession(getCartFromSession()); // Save the cart after modification
  }

  // Add counter
  static void addCounter() {
    int currentCounter = getCounter();
    currentCounter++;
    html.window.sessionStorage['counter'] = currentCounter.toString();
  }

  // Remove counter
  static void removeCounter() {
    int currentCounter = getCounter();
    if (currentCounter > 0) {
      currentCounter--;
      html.window.sessionStorage['counter'] = currentCounter.toString();
    }
  }

  // Update counter value
  static void updateCounterValue(bool isIncrement) {
    if (isIncrement) {
      addCounter();
    } else {
      removeCounter();
    }
  }

  // Handle adding/removing an item to/from the cart
  static void addItem(CartWeb cartItem) {
    List<CartWeb> cartItems = getCartFromSession();
    cartItems.add(cartItem);
    saveCartToSession(cartItems);
    addCounter(); // Increment counter after adding an item
  }

  static void removeItem(CartWeb cartItem) {
    List<CartWeb> cartItems = getCartFromSession();
    cartItems.removeWhere((item) => item.productId == cartItem.productId);
    saveCartToSession(cartItems);
    removeCounter(); // Decrement counter after removing an item
  }

  // Clear all items from the cart
  static void clearCart() {
    html.window.sessionStorage.remove('cart');
    html.window.sessionStorage.remove('counter');
    html.window.sessionStorage.remove('totalPrice');
  }

  // Getter methods for counter and total price
  static double getTotalPriceValue() {
    return getTotalPrice();
  }

  static int getCounter() {
    String? storedCounter = html.window.sessionStorage['counter'];
    if (storedCounter != null) {
      return int.tryParse(storedCounter) ?? 0;
    }
    return 0;
  }
}
