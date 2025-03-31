import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/cart_model.dart';
import '../provider/cart_provider.dart';
import 'receipt_screen.dart';

class PaymentPage extends StatefulWidget {
  final double totalAmount;
  final Map<String, dynamic> selectedAddress;
  final List<Cart> products;
  final String userId;

  const PaymentPage({
    required this.totalAmount,
    required this.selectedAddress,
    required this.products,
    required this.userId,
  });

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late Razorpay _razorpay;
  bool isLoading = false;
  String selectedPaymentMethod = '';

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> createOrder(double amount) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://13.202.96.108/api/payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'currency': 'INR',
          'address': widget.selectedAddress,
        }),
      );

      if (response.statusCode == 200) {
        final order = jsonDecode(response.body);
        if (selectedPaymentMethod != 'Cash on Delivery') {
          _initiateRazorpayPayment(order['orderId'], amount);
        } else {
          _processCashOnDelivery(order['orderId']);
        }
      } else {
        throw Exception('Failed to create order:');
      }
    } catch (error) {
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _initiateRazorpayPayment(String orderId, double amount) {
    var options = {
      'key': 'rzp_test_J3rUJf6igdVikD', // Replace with your Razorpay Key ID
      'amount': amount * 100, // Amount in paise
      'currency': 'INR',
      'name': 'AgriveMart',
      'description': 'E-commerce Payment',
      'order_id': orderId,
      'prefill': {
        'contact': widget.selectedAddress['phoneNumber'],
        'email': 'test@example.com',
      },
      'theme': {'color': 'Color(0xFFFFF9C4)'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {}
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final paymentDetails =
          await fetchPaymentDetailsFromRazorpay(response.paymentId!);

      final String paymentMethod = paymentDetails['method'] ?? 'Unknown';
      final String status = paymentDetails['status'] ?? 'Unknown';

      await sendPaymentToBackend(
          response.paymentId!, response.orderId!, status, paymentMethod);

      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      for (var cart in widget.products) {
        await updateProductStock(cart); // Update stock for each product
      }
      cartProvider.clearCart();
    } catch (error) {}
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      selectedPaymentMethod = '';
    });
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  Future<Map<String, dynamic>> fetchPaymentDetailsFromRazorpay(
      String paymentId) async {
    const String apiKey = 'rzp_test_J3rUJf6igdVikD';
    const String apiSecret = 'q0bAET0MRLqNFcuJFQbmG8B9';
    final String auth = base64Encode(utf8.encode('$apiKey:$apiSecret'));

    try {
      final response = await http.get(
        Uri.parse('https://api.razorpay.com/v1/payments/$paymentId'),
        headers: {'Authorization': 'Basic $auth'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch payment details:');
      }
    } catch (error) {
      throw Exception('Error fetching payment details: $error');
    }
  }

  Future<void> sendPaymentToBackend(String paymentId, String orderId,
      String status, String paymentMethod) async {
    final productList = widget.products.map((cart) => cart.toMap()).toList();

    final paymentDetails = {
      'paymentId': paymentId.isEmpty ? null : paymentId,
      'orderId': orderId,
      'userId': widget.userId,
      'amount': widget.totalAmount,
      'address': widget.selectedAddress,
      'products': productList,
      'status': status,
      'paymentMethod': paymentMethod,
    };

    try {
      final response = await http.post(
        Uri.parse('http://13.203.77.176:5000/api/payments/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(paymentDetails),
      );

      if (response.statusCode == 201) {
        final backendOrderId = jsonDecode(response.body)['orderId'];
        _navigateToReceiptPage(backendOrderId);
      } else {}
    } catch (error) {}
  }

  void _processCashOnDelivery(String orderId) async {
    try {
      String paymentMethod = 'Cash on Delivery';

      await sendPaymentToBackend(
        '',
        orderId,
        'pending',
        paymentMethod,
      );
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      for (var cart in widget.products) {
        await updateProductStock(cart); // Update stock for each product
      }
      cartProvider.clearCart();
    } catch (error) {}
  }

  void _navigateToReceiptPage(String backendOrderId) {
    final productList = widget.products.map((cart) => cart.toMap()).toList();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptPage(
          products: productList,
          orderId: backendOrderId,
        ),
      ),
    );
  }

  Future<void> updateProductStock(Cart cart) async {
    try {
      final url = Uri.parse(
          'http://13.202.96.108/api/user/products/${cart.productId}');

      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'stock':
              cart.stock - cart.number, // Decrease stock by the number ordered
        }),
      );

      if (response.statusCode == 200) {
        print(
            'Product stock updated successfully for product ID: ${cart.productId}');
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception(
          'Failed to update product stock: ${errorResponse['message'] ?? 'Unknown error'}',
        );
      }
    } catch (error) {
      print('Error updating stock for product ID: ${cart.productId}: $error');
      throw Exception('Error updating stock: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Payment Page'),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose a payment method:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _buildPaymentOption('Credit Card'),
                  _buildPaymentOption('Debit Card'),
                  _buildPaymentOption('UPI'),
                  _buildPaymentOption('PhonePe'),
                  _buildPaymentOption('GPay'),
                  _buildPaymentOption('Cash on Delivery'),
                  const SizedBox(height: 20),
                  if (selectedPaymentMethod.isNotEmpty)
                    Text(
                      'Selected Payment Method: $selectedPaymentMethod',
                      style: TextStyle(fontSize: 16),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: selectedPaymentMethod.isEmpty
                        ? null
                        : () => createOrder(widget.totalAmount),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 30.0),
                      backgroundColor: const Color(0xFF34B6B6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Place Order',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPaymentOption(String method) {
    IconData iconData;

    switch (method) {
      case 'Credit Card':
        iconData = Icons.credit_card;
        break;
      case 'Debit Card':
        iconData =
            Icons.credit_card; // You can use the same icon for debit card
        break;
      case 'UPI':
        iconData = Icons.payment; // UPI can be represented with a payment icon
        break;
      case 'PhonePe':
        iconData = Icons.phone_android; // You can use a phone icon for PhonePe
        break;
      case 'GPay':
        iconData = Icons.account_balance_wallet; // Wallet icon for GPay
        break;
      case 'Cash on Delivery':
        iconData = Icons.delivery_dining; // Delivery icon for COD
        break;
      default:
        iconData = Icons.payment; // Default icon in case of an unknown method
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = method;
        });
      },
      child: Card(
        color:
            selectedPaymentMethod == method ? Colors.teal[200] : Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Icon(
            iconData,
            color:
                selectedPaymentMethod == method ? Colors.green : Colors.black,
          ),
          title: Text(method),
          trailing: selectedPaymentMethod == method
              ? const Icon(Icons.check_circle, color: Colors.green)
              : null,
        ),
      ),
    );
  }
}
