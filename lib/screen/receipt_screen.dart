import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../homepage/home_screen.dart';

class ReceiptPage extends StatefulWidget {
  final String orderId;
  final List<dynamic> products;

  const ReceiptPage({Key? key, required this.orderId, required this.products})
      : super(key: key);

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  bool _isLoading = true;
  bool _hasError = false;
  bool _statusUpdated = false;
  Map<String, dynamic>? _orderDetails;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!_statusUpdated) {
        _fetchOrderDetails();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchOrderDetails() async {
    final String orderApiUrl =
        'http://13.202.96.108/api/delivery/order/${widget.orderId}';

    try {
      final orderResponse = await http.get(Uri.parse(orderApiUrl));

      if (orderResponse.statusCode == 200) {
        final responseData = json.decode(orderResponse.body);
        if (responseData['data'] != null) {
          setState(() {
            _orderDetails = responseData['data'];
            _isLoading = false;
            _statusUpdated = true;
          });
        } else {
          _setErrorState();
        }
      } else {
        _setErrorState();
      }
    } catch (e) {
      print('Error fetching order details: $e');
      _setErrorState();
    }
  }

  void _setErrorState() {
    setState(() {
      _hasError = true;
      _isLoading = false;
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _statusUpdated = false;
    });
    await _fetchOrderDetails();
  }

  Route _createReverseSlideTransitionRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0); // Slide from left to right
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          _createReverseSlideTransitionRoute(
              HomeScreen()), // Redirect to HomeScreen with sliding transition
          (Route<dynamic> route) => false, // Remove all previous routes
        );
        return false; // Prevent default pop behavior
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Receipt'),
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
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 160, 229, 179),
                Color.fromARGB(255, 66, 226, 226),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _hasError
                    ? const Center(
                        child: Text(
                          'Failed to load data. Please try again later.',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : _orderDetails == null || _orderDetails!.isEmpty
                        ? const Center(
                            child: Text(
                              'No order details found.',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Order Placed Successfully!',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  _buildDeliveryStatusCard(),
                                  const SizedBox(height: 20),
                                  _buildDeliveryPersonCard(),
                                  const SizedBox(height: 20),
                                  _buildOrderDetailsCard(),
                                  const SizedBox(height: 20),
                                  _buildShippingAddressCard(),
                                  const SizedBox(height: 20),
                                  _buildOrderedProducts(),
                                ],
                              ),
                            ),
                          ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryStatusCard() {
    return Card(
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.local_shipping, color: Colors.teal, size: 40),
        title: Text(
          'Delivery Status',
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[900]),
        ),
        subtitle: Text(
          _orderDetails?['status'] ?? 'N/A',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildDeliveryPersonCard() {
    return Card(
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal,
          child: const Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          'Delivery Person',
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[900]),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _orderDetails?['deliveryPerson']?['name'] ??
                  'No delivery person assigned',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Phone: ${_orderDetails?['deliveryPerson']?['phone'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailsCard() {
    return Card(
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Details',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal),
            ),
            const Divider(),
            Text('Order ID: ${widget.orderId}',
                style: const TextStyle(fontSize: 16)),
            Text('Amount: ₹${_orderDetails?['amount'] ?? 'N/A'}',
                style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingAddressCard() {
    return Card(
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shipping Address',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal),
            ),
            const Divider(),
            Text(
              _orderDetails?['address']['fullName'] ?? 'N/A',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              '${_orderDetails?['address']['houseDetails']}, ${_orderDetails?['address']['roadDetails']}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              '${_orderDetails?['address']['city']}, ${_orderDetails?['address']['state']} - ${_orderDetails?['address']['pincode']}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Phone: ${_orderDetails?['address']['phoneNumber'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderedProducts() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ordered Products:',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.products.map<Widget>((product) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Image.network(
                      product['imageUrl'],
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['name'],
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "₹${product['price']}/kg x ${product['number']}",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
