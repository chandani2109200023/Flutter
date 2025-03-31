import 'package:agrive_mart/screen/payment_page_web.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Account/adress.dart';
import '../Account/login_page.dart';
import '../model/cart_web.dart';
import '../provider/cart_storage_web.dart';
import 'package:badges/badges.dart' as badges;

class CartScreenWeb extends StatefulWidget {
  @override
  _CartScreenWebState createState() => _CartScreenWebState();
}

class _CartScreenWebState extends State<CartScreenWeb> {
  double totalPrice = 0.0;
  late bool _isLoggedIn;
  bool _isAddressSelected = false; // Track if address is selected
  late Map<String, dynamic> _selectedAddress;
  int? itemCount;

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
    final cart = Provider.of<CartStorageHelper>(context);
    double totalAmount = cart.getTotalPrice();
    return Scaffold(
      appBar: AppBar(
        title: Text("Shopping Cart"),
        actions: [
          Center(
            child: badges.Badge(
              badgeContent:
                  Consumer<CartStorageHelper>(builder: (context, value, child) {
                print("Cart item count: ${value.getCounter()}");
                return Text(value.getCounter().toString(),
                    style: const TextStyle(color: Colors.white));
              }),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
          ),
          const SizedBox(width: 20.0),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFB2E59C), // Light Green
                Color(0xFFFFF9C4), // Soft Yellow
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                FutureBuilder(
                  future: cart.getCartFromLocal(),
                  builder: (context, AsyncSnapshot<List<CartWeb>> snapshot) {
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
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    'Category: ',
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors
                                                            .grey), // You can change the color if needed
                                                  ),
                                                  Text(
                                                    '${cartItem.category}',
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors
                                                            .grey), // Set a different color if needed
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Text(
                                                    'Price: ',
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey),
                                                  ),
                                                  Text(
                                                    '₹${cartItem.price}',
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors
                                                            .grey), // Highlighted price color
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Text(
                                                    'Quantity: ',
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey),
                                                  ),
                                                  Text(
                                                    '${cartItem.number}',
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              cartItem.discount > 0
                                                  ? Row(
                                                      children: [
                                                        Text(
                                                          '${cartItem.discount}% Off',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    54,
                                                                    130,
                                                                    244),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : const SizedBox.shrink(),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Text(
                                                    'Total: ',
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey),
                                                  ),
                                                  Text(
                                                    '₹${(cartItem.price * cartItem.number) - (cartItem.price * cartItem.number * cartItem.discount * 0.01)}',
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors
                                                            .grey), // Total color
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: InkWell(
                                              onTap: () {},
                                              child: Container(
                                                height: 35,
                                                width: 100,
                                                decoration: BoxDecoration(
                                                  color: const Color.fromARGB(
                                                      255, 175, 116, 76),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
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
                                                          if (cartItem.number >
                                                              1) {
                                                            int oldNumber =
                                                                cartItem.number;
                                                            int newNumber =
                                                                oldNumber - 1;

                                                            double oldPrice = (cartItem
                                                                        .price *
                                                                    oldNumber) -
                                                                (cartItem
                                                                        .price *
                                                                    oldNumber *
                                                                    cartItem
                                                                        .discount *
                                                                    0.01);
                                                            double newPrice = (cartItem
                                                                        .price *
                                                                    newNumber) -
                                                                (cartItem
                                                                        .price *
                                                                    newNumber *
                                                                    cartItem
                                                                        .discount *
                                                                    0.01);

                                                            cart
                                                                .updateQuantity(
                                                                    cartItem
                                                                        .productId,
                                                                    newNumber)
                                                                .then((_) {
                                                              cart.updateTotalPrice(
                                                                  oldPrice,
                                                                  newPrice);
                                                              cart.removeCounter();
                                                              setState(() {
                                                                cartItem.number =
                                                                    newNumber;
                                                              });
                                                            }).catchError(
                                                                    (error) {
                                                              print(
                                                                  "Error: ${error.toString()}");
                                                            });
                                                          } else {
                                                            cart
                                                                .removeItem(
                                                                    cartItem);
                                                            cart.removeCounter();
                                                            cart.removeTotalPrice(
                                                                cartItem.price,
                                                                cartItem
                                                                    .discount);
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
                                                          if (cartItem.number <
                                                              cartItem.stock) {
                                                            int oldNumber =
                                                                cartItem.number;
                                                            int newNumber =
                                                                oldNumber + 1;

                                                            double oldPrice = (cartItem
                                                                        .price *
                                                                    oldNumber) -
                                                                (cartItem
                                                                        .price *
                                                                    oldNumber *
                                                                    cartItem
                                                                        .discount *
                                                                    0.01);
                                                            double newPrice = (cartItem
                                                                        .price *
                                                                    newNumber) -
                                                                (cartItem
                                                                        .price *
                                                                    newNumber *
                                                                    cartItem
                                                                        .discount *
                                                                    0.01);

                                                            cart
                                                                .updateQuantity(
                                                                    cartItem
                                                                        .productId,
                                                                    newNumber)
                                                                .then((_) {
                                                              cart.updateTotalPrice(
                                                                  oldPrice,
                                                                  newPrice);
                                                              cart.addCounter();
                                                              setState(() {
                                                                cartItem.number =
                                                                    newNumber;
                                                              });
                                                            }).catchError(
                                                                    (error) {
                                                              print(
                                                                  "Error: ${error.toString()}");
                                                            });
                                                          } else {
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return AlertDialog(
                                                                  title: const Text(
                                                                      "Stock Limit Reached"),
                                                                  content: Text(
                                                                      "You can only add up to ${cartItem.stock} items to the cart."),
                                                                  actions: <Widget>[
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                      child: const Text(
                                                                          "OK"),
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                          }
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
                                          ),
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
                Consumer<CartStorageHelper>(builder: (context, value, child) {
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
                      final product = await cart.getCartFromLocal();
                      // Navigate to the Payment Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentPageWeb(
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
