import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:shared_preferences/shared_preferences.dart';

import '../helper/db__helper.dart';
import '../model/cart_model.dart';
import '../provider/cart_provider.dart';
import '../Account/adress.dart';
import '../Account/login_page.dart';
import 'payement_page.dart'; // Import your PaymentPage

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late bool _isLoggedIn;
  bool _isAddressSelected = false; // Track if address is selected
  late Map<String, dynamic> _selectedAddress; // Define the selected address
  final DBHelper dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  double calculateDiscount(double totalPrice) {
    double discountPercentage = 5.0; // 5% discount
    return totalPrice * discountPercentage / 100;
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? userId = prefs.getString('userId'); // Retrieve userId

    print("Checking login status...");
    if (token != null && token.isNotEmpty) {
      print("User is logged in");
      setState(() {
        _isLoggedIn = true;
        if (userId != null) {
          _selectedAddress['userId'] = userId; // Store userId for later use
        }
      });
    } else {
      print("User is not logged in");
      setState(() {
        _isLoggedIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    double totalAmount = cart.getTotalPrice();
    print("Total amount in cart: $totalAmount");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF92E3A9), // Light green
                Color(0xFF34B6B6), // Teal
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Center(
            child: badges.Badge(
              badgeContent:
                  Consumer<CartProvider>(builder: (context, value, child) {
                print("Cart item count: ${value.getCounter()}");
                return Text(value.getCounter().toString(),
                    style: const TextStyle(color: Colors.white));
              }),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
          ),
          const SizedBox(width: 20.0),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                FutureBuilder(
                  future: cart.getData(),
                  builder: (context, AsyncSnapshot<List<Cart>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasData && snapshot.data!.isEmpty) {
                      print("Cart is empty");
                      return Align(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            const Image(
                              image: AssetImage('assets/images/empty_cart.png'),
                            ),
                            const SizedBox(height: 20),
                            Text('Your cart is empty',
                                style:
                                    Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 20),
                            Text(
                              'Explore products and shop your\nfavourite items',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleSmall,
                            )
                          ],
                        ),
                      );
                    } else if (snapshot.hasData) {
                      print("Displaying cart items");
                      return Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final cartItem = snapshot.data![index];
                            print("Cart item: ${cartItem.name}");
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Image(
                                      height: 100,
                                      width: 100,
                                      image: NetworkImage(cartItem.imageUrl),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                // Ensures the text fits within the available space
                                                child: Text(
                                                  cartItem.name,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  maxLines:
                                                      2, // Allow up to 2 lines
                                                  overflow: TextOverflow
                                                      .ellipsis, // Truncate with ellipsis if needed
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                              '${cartItem.category} - ₹${cartItem.price}*${cartItem.number}=${cartItem.price * cartItem.number}',
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500)),
                                          const SizedBox(height: 5),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: InkWell(
                                              onTap: () {},
                                              child: Container(
                                                height: 35,
                                                width: 100,
                                                decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          print(
                                                              "Removing item");
                                                          int number =
                                                              cartItem.number;
                                                          double oldPrice =
                                                              cartItem.price *
                                                                  number;

                                                          if (number > 1) {
                                                            // Decrease quantity
                                                            number--;
                                                            dbHelper
                                                                .updateQuantity(
                                                                    cartItem
                                                                        .id!,
                                                                    number)
                                                                .then((value) {
                                                              double newPrice =
                                                                  cartItem.price *
                                                                      number;
                                                              cart.updateTotalPrice(
                                                                  oldPrice,
                                                                  newPrice);
                                                              cart.removeCounter();
                                                              setState(() {});
                                                            }).onError((error,
                                                                    stackTrace) {
                                                              print(
                                                                  "Error: ${error.toString()}");
                                                            });
                                                          } else {
                                                            // If quantity is 1, remove item from cart
                                                            dbHelper.deleteItem(
                                                                cartItem.id!);
                                                            cart.removeCounter();
                                                            cart.removeTotalPrice(
                                                                cartItem.price);
                                                            setState(() {});
                                                          }
                                                        },
                                                        child: const Icon(
                                                            Icons.remove,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      Text(
                                                          cartItem.number
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white)),
                                                      InkWell(
                                                        onTap: () {
                                                          print("Adding item");
                                                          int number =
                                                              cartItem.number;
                                                          double oldPrice =
                                                              cartItem.price *
                                                                  number;
                                                          number++;
                                                          dbHelper
                                                              .updateQuantity(
                                                                  cartItem.id!,
                                                                  number)
                                                              .then((value) {
                                                            double newPrice =
                                                                cartItem.price *
                                                                    number;
                                                            cart.updateTotalPrice(
                                                                oldPrice,
                                                                newPrice);
                                                            cart.addCounter();
                                                            setState(() {});
                                                          }).onError((error,
                                                                  stackTrace) {
                                                            print(
                                                                "Error: ${error.toString()}");
                                                          });
                                                        },
                                                        child: const Icon(
                                                            Icons.add,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                    print("No items in cart");
                    return const Center(child: Text('No items in cart'));
                  },
                ),
                Consumer<CartProvider>(builder: (context, value, child) {
                  double totalPrice = value.getTotalPrice();
                  double discount = calculateDiscount(totalPrice);
                  double finalPrice = totalPrice - discount;

                  print(
                      "Total price: $totalPrice, Discount: $discount, Final Price: $finalPrice");

                  return Visibility(
                    visible: totalPrice.toStringAsFixed(2) != "0.00",
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 50.0),
                      child: Card(
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 10.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              ReusableWidget(
                                title: 'Sub Total',
                                value: '₹' + totalPrice.toStringAsFixed(2),
                              ),
                              ReusableWidget(
                                title: 'Discount 5%',
                                value: '₹' + discount.toStringAsFixed(2),
                              ),
                              ReusableWidget(
                                title: 'Total',
                                value: '₹' + finalPrice.toStringAsFixed(2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                })
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextButton(
                onPressed: () async {
                  print("Proceeding to payment");
                  print(cart.cartItems);
                  if (_isLoggedIn) {
                    if (_isAddressSelected && _selectedAddress.isNotEmpty) {
                      final product = await cart.getData();
                      // Navigate to the Payment Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentPage(
                            totalAmount: totalAmount - (totalAmount * 0.05),
                            selectedAddress: _selectedAddress,
                            products: product,
                            userId: _selectedAddress['userId'],
                          ),
                        ),
                      );
                    } else {
                      // Navigate to AddressBookPage if no address is selected
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddressBookPage(
                            onAddressSelected: (selectedAddress) {
                              if (selectedAddress != null) {
                                setState(() {
                                  _selectedAddress = selectedAddress;
                                  _isAddressSelected = true;
                                });
                              }
                            },
                          ),
                        ),
                      );
                    }
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  }
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 14.0),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _isAddressSelected
                      ? 'Pay Now'
                      : 'Add Address At the Next Step',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReusableWidget extends StatelessWidget {
  final String title;
  final String value;

  const ReusableWidget({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
