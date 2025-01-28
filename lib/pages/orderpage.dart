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
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  // Fetch orders along with their details from the API
  Future<void> _fetchOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    final url = 'http://13.203.77.176:5000/api/payments/user/$userId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final orders = json.decode(response.body);

        // Fetch order details for each order
        for (var order in orders) {
          final orderDetailsResponse = await http.get(
            Uri.parse('http://13.203.77.176:5000/api/delivery/order/${order['orderId']}'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Orders"),
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
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    final orderDetails = order['details'];

                    return GestureDetector(
                      onTap: () {
                        if (orderDetails != null &&
                            orderDetails['status'] == 'delivered') {
                          // Redirect to ReceiptDeliveryPage for delivered orders
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReceiptDeliveryPage(
                                orderId: order['orderId'], // Pass the orderId
                                products: order['products'], // Pass the products
                              ),
                            ),
                          );
                        } else {
                          // Redirect to ReceiptPage for other statuses
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReceiptPage(
                                orderId: order['orderId'], // Pass the orderId
                                products: order['products'], // Pass the products
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
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                'Delivery Status: ${orderDetails != null ? orderDetails['status'] : 'Loading...'}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text('Date: ${order['createdAt']}'),
                              SizedBox(height: 10),
                              Text('Items:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Column(
                                children: order['products'].map<Widget>((item) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
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
                                            overflow: TextOverflow.ellipsis,
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
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
