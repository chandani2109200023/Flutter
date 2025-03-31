import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../homepage/home_screen.dart';

class ReceiptDeliveryPage extends StatefulWidget {
  final String orderId;
  final List<dynamic> products;

  const ReceiptDeliveryPage(
      {Key? key, required this.orderId, required this.products})
      : super(key: key);

  @override
  State<ReceiptDeliveryPage> createState() => _ReceiptDeliveryPageState();
}

class _ReceiptDeliveryPageState extends State<ReceiptDeliveryPage> {
  bool _isLoading = true;
  bool _hasError = false;
  Map<String, dynamic>? _orderDetails;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
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

  Future<Uint8List> _fetchImage(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load image');
    }
  }

  Future<void> _generateInvoice() async {
    final pdf = pw.Document();

    // Fetch Agrive Mart logo
    final ByteData logoData = await rootBundle.load('assets/images/logo.jpg');
    final Uint8List logoBytes = logoData.buffer.asUint8List();

    // Add PDF content
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Logo at the top
              pw.Center(
                child: pw.Image(
                  pw.MemoryImage(logoBytes),
                  height: 80,
                ),
              ),
              pw.SizedBox(height: 20),

              // Invoice header
              pw.Text(
                'Invoice',
                style:
                    pw.TextStyle(fontSize: 30, fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 20),

              // Order details
              pw.Text('Order ID: ${widget.orderId}',
                  style: pw.TextStyle(fontSize: 16)),
              pw.Text('Amount: Rs${_orderDetails?['amount'] ?? 'N/A'}',
                  style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 20),

              // Products Table
              pw.Text(
                'Ordered Products:',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(4),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  // Table header
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Image',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Product Name',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Price (Rs)',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Quantity',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Product rows
                  ...widget.products.map((product) {
                    return pw.TableRow(
                      children: [
                        // Product image
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.SizedBox(
                            height: 50,
                            width: 50,
                            child: product['imageData'] != null
                                ? pw.Image(pw.MemoryImage(product['imageData']))
                                : pw.Container(
                                    color: PdfColors.grey,
                                    alignment: pw.Alignment.center,
                                    child: pw.Text('No Image',
                                        style: pw.TextStyle(fontSize: 8)),
                                  ),
                          ),
                        ),
                        // Product name
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(product['name'],
                              style: const pw.TextStyle(fontSize: 10)),
                        ),
                        // Product price
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('Rs${product['price']}',
                              style: const pw.TextStyle(fontSize: 10)),
                        ),
                        // Product quantity
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text('${product['number']}',
                              style: const pw.TextStyle(fontSize: 10)),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
              pw.SizedBox(height: 20),

              // Shipping address
              pw.Text(
                'Shipping Address:',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(_orderDetails?['address']['fullName'] ?? 'N/A'),
              pw.Text(
                  '${_orderDetails?['address']['houseDetails']}, ${_orderDetails?['address']['roadDetails']}'),
              pw.Text(
                  '${_orderDetails?['address']['city']}, ${_orderDetails?['address']['state']} - ${_orderDetails?['address']['pincode']}'),
              pw.Text(
                  'Phone: ${_orderDetails?['address']['phoneNumber'] ?? 'N/A'}'),
              pw.SizedBox(height: 20),

              // Terms & Conditions
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Terms & Conditions:',
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'If you have any issues or queries regarding your order, please contact our customer chat at 9775023720 or email us at prabirkumar1992@gmail.com with full details.',
                      style: pw.TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // Save and share the PDF
    await Printing.sharePdf(
        bytes: await pdf.save(), filename: 'invoice_${widget.orderId}.pdf');
  }

  Future<void> _prepareInvoiceData() async {
    for (var product in widget.products) {
      try {
        product['imageData'] = await _fetchImage(product['imageUrl']);
      } catch (e) {
        product['imageData'] = Uint8List(0); // Fallback for image errors
      }
    }
    _generateInvoice();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(-1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(position: offsetAnimation, child: child);
            },
          ),
          (route) => false,
        );
        return false;
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
                Color.fromARGB(255, 66, 226, 226)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _hasError
                  ? const Center(
                      child:
                          Text('Failed to load data. Please try again later.'))
                  : _orderDetails == null || _orderDetails!.isEmpty
                      ? const Center(child: Text('No order details found.'))
                      : SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Order Delivered Successfully',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 20),
                                _buildDeliveryStatusCard(),
                                const SizedBox(height: 20),
                                _buildOrderDetailsCard(),
                                const SizedBox(height: 20),
                                _buildShippingAddressCard(),
                                const SizedBox(height: 20),
                                _buildOrderedProducts(),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: _prepareInvoiceData,
                                  icon: const Icon(Icons.download, size: 20),
                                  label: const Text('Download Invoice'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
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
        leading: const Icon(Icons.local_shipping, color: Colors.teal, size: 40),
        title: Text('Delivery Status',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.teal[900])),
        subtitle: const Text('Delivered', style: TextStyle(fontSize: 16)),
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
            const Text('Order Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            Text('Order ID: ${widget.orderId}',
                style: const TextStyle(fontSize: 16)),
            Text('Amount:Rs${_orderDetails?['amount'] ?? 'N/A'}',
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
            const Text('Shipping Address',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ordered Products:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...widget.products.map((product) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Card(
              color: Colors.white.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: product['imageUrl'] != null
                    ? Image.network(product['imageUrl'],
                        width: 60, height: 60, fit: BoxFit.cover)
                    : const Icon(Icons.image_not_supported, size: 60),
                title:
                    Text(product['name'], style: const TextStyle(fontSize: 16)),
                subtitle: Text(
                    ' Rs${product['price']}/kg x ${product['number']}=${product['price'] * product['number']}'),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
