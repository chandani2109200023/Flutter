import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../screen/receipt_delivery.dart';
import '../screen/receipt_screen.dart';

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  bool _isLoading = true;
  List<dynamic> _orders = [];
  List<dynamic> _filteredOrders = []; // Stores filtered orders
  String _errorMessage = '';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    searchController.addListener(_filterOrders); // Add listener for search
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Fetch orders along with their details from the API
  Future<void> _fetchOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    final url = 'http://13.202.96.108/api/payments/user/$userId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final orders = json.decode(response.body);

        for (var order in orders) {
          final orderDetailsResponse = await http.get(
            Uri.parse(
                'http://13.202.96.108/api/delivery/order/${order['orderId']}'),
          );

          if (orderDetailsResponse.statusCode == 200) {
            final orderDetails = json.decode(orderDetailsResponse.body);
            order['details'] = orderDetails['data'];
          } else {
            order['details'] = null;
          }
        }

        if (mounted) {
          setState(() {
            _orders = orders;
            _filteredOrders = List.from(_orders); // Initially show all orders
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to load orders';
            _isLoading = false;
          });
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: $error';
          _isLoading = false;
        });
      }
    }
  }

  // Filter orders based on search input
  void _filterOrders() {
    final query = searchController.text.toLowerCase();
    setState(() {
      _filteredOrders = _orders.where((order) {
        final orderId = order['orderId'].toString().toLowerCase();
        final productNames = order['products']
            .map<String>((item) => item['name'].toString().toLowerCase())
            .join(" "); // Combine product names

        return orderId.contains(query) || productNames.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Orders"),
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
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by Order ID or Product Name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),

          // Orders List
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage))
                    : ListView.builder(
                        itemCount: _filteredOrders.length, // Use filtered list
                        itemBuilder: (context, index) {
                          final order = _filteredOrders[index];
                          final orderDetails = order['details'];

                          return GestureDetector(
                            onTap: () {
                              if (orderDetails != null &&
                                  orderDetails['status'] == 'delivered') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReceiptDeliveryPage(
                                      orderId: order['orderId'],
                                      products: order['products'],
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReceiptPage(
                                      orderId: order['orderId'],
                                      products: order['products'],
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Card(
                              margin: EdgeInsets.all(10),
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order ID: ${order['orderId']}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      'Delivery Status: ${orderDetails != null ? orderDetails['status'] : 'Loading...'}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text('Date: ${order['createdAt']}'),
                                    SizedBox(height: 10),
                                    Text('Items:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Column(
                                      children:
                                          order['products'].map<Widget>((item) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5),
                                          child: Row(
                                            children: [
                                              Image.network(item['imageUrl'],
                                                  width: 50,
                                                  height: 50,
                                                  fit: BoxFit.cover),
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  '${item['name']} - Rs${item['price']}',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'Total Price: Rs${order['amount']}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
