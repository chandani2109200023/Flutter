import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/add_delivery_address_page.dart';

class AddressBookPage extends StatefulWidget {
  final Function(Map<String, dynamic>?)? onAddressSelected;

  const AddressBookPage({Key? key, this.onAddressSelected}) : super(key: key);

  @override
  _AddressBookPageState createState() => _AddressBookPageState();
}

class _AddressBookPageState extends State<AddressBookPage> {
  TextEditingController stateController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  List<Map<String, dynamic>> addresses = [];
  Map<String, dynamic>? selectedAddress;
  String token = "";
  String _userId = "";
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void selectAddress(Map<String, dynamic> address) {
    setState(() {
      selectedAddress = address; // Update the selected address
    });
    proceedToPlaceOrder();
  }

  void proceedToPlaceOrder() {
    if (selectedAddress != null) {
      if (widget.onAddressSelected != null) {
        widget.onAddressSelected!(selectedAddress);
      }
      Navigator.pop(context, selectedAddress); // Return the selected address
    } else {
      _showSnackBar('Please select an address');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _checkLoginStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedToken = prefs.getString('token');
      String? savedUserId = prefs.getString('userId');

      if (savedToken != null && savedUserId != null) {
        setState(() {
          token = savedToken;
          _userId = savedUserId;
        });
        fetchAddresses();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in first')),
        );
      }
    } catch (e) {
      print('Error checking login status: $e');
    }
  }

  Future<void> fetchAddresses() async {
    if (_userId.isEmpty) return;

    final url =
        Uri.parse('http://13.203.77.176:5000/api/address/get/$_userId');

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        List<dynamic> responseData = json.decode(response.body);
        setState(() {
          addresses = List<Map<String, dynamic>>.from(responseData);
        });
      } else {
        print('Failed to fetch addresses: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching addresses: $error');
    }
  }

  Future<void> updateAddress(String id, Map<String, dynamic> address) async {
    final url = Uri.parse('http://13.203.77.176:5000/api/address/$id');

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'fullName': address['fullName'],
          'phoneNumber': address['phoneNumber'],
          'pincode': address['pincode'],
          'state': address['state'],
          'city': address['city'],
          'houseDetails': address['houseDetails'],
          'roadDetails': address['roadDetails'],
          'type': address['type'],
        }),
      );

      if (response.statusCode == 200) {
        await fetchAddresses(); // Refresh addresses after update
      } else {
        print('Failed to update address: ${response.statusCode}');
      }
    } catch (error) {
      print('Error updating address: $error');
    }
  }

  Future<void> deleteAddress(String id) async {
    final url =
        Uri.parse('http://13.203.77.176:5000/api/address/delete/$id');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        await fetchAddresses(); // Refresh addresses after deletion
      } else {
        print('Failed to delete address: ${response.statusCode}');
      }
    } catch (error) {
      print('Error deleting address: $error');
    }
  }

  Future<void> fetchStateAndCity(String pincode) async {
    if (pincode.length != 6) {
      setState(() {
        stateController.clear();
        cityController.clear();
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://api.postalpincode.in/pincode/$pincode'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data[0]['Status'] == 'Success') {
          setState(() {
            stateController.text = data[0]['PostOffice'][0]['State'];
            cityController.text = data[0]['PostOffice'][0]['Block'];
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid Pincode')),
          );
          setState(() {
            stateController.clear();
            cityController.clear();
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch state and city')),
        );
      }
    } catch (e) {
      print('Error fetching state and city: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching state and city')),
      );
    }
  }

  void showAddressDialog({required Map<String, dynamic> address}) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController fullNameController =
        TextEditingController(text: address['fullName']);
    final TextEditingController phoneNumberController =
        TextEditingController(text: address['phoneNumber']);
    final TextEditingController pincodeController =
        TextEditingController(text: address['pincode']);
    final TextEditingController houseDetailsController =
        TextEditingController(text: address['houseDetails']);
    final TextEditingController roadDetailsController =
        TextEditingController(text: address['roadDetails']);
    final TextEditingController typeController =
        TextEditingController(text: address['type']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Address'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: fullNameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter full name'
                        : null,
                  ),
                  TextFormField(
                    controller: phoneNumberController,
                    decoration:
                        const InputDecoration(labelText: 'Phone Number'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter phone Number'
                        : null,
                  ),
                  TextFormField(
                    controller: pincodeController,
                    decoration: const InputDecoration(labelText: 'Pincode'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter a pincode'
                        : null,
                    onChanged: (value) {
                      if (value.length == 6) {
                        fetchStateAndCity(
                            value); // Fetch state and city on pincode change
                      }
                    },
                  ),
                  TextFormField(
                    controller: cityController,
                    decoration: const InputDecoration(labelText: 'City'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter a city'
                        : null,
                  ),
                  TextFormField(
                    controller: stateController,
                    decoration: const InputDecoration(labelText: 'State'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter a state'
                        : null,
                  ),
                  TextFormField(
                    controller: houseDetailsController,
                    decoration:
                        const InputDecoration(labelText: 'House Details'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter house details'
                        : null,
                  ),
                  TextFormField(
                    controller: roadDetailsController,
                    decoration:
                        const InputDecoration(labelText: 'Road Details'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter road details'
                        : null,
                  ),
                  TextFormField(
                    controller: typeController,
                    decoration: const InputDecoration(labelText: 'Type'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter the type'
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  final updatedAddress = {
                    'fullName': fullNameController.text,
                    'phoneNumber': phoneNumberController.text,
                    'city': cityController.text,
                    'state': stateController.text,
                    'pincode': pincodeController.text,
                    'houseDetails': houseDetailsController.text,
                    'roadDetails': roadDetailsController.text,
                    'type': typeController.text,
                  };
                  updateAddress(address['_id'], updatedAddress);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Addresses'),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFB8F0C2), // Lighter green
              Color(0xFF6FDCDC), // Lighter teal
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddDeliveryAddressPage(),
                ),
              ).then((_) => fetchAddresses()),
              child: Container(
                color: Colors.green[100],
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  '+ Add a New Address',
                  style: TextStyle(
                    color: Colors.green[800],
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  final address = addresses[index];
                  final isSelected = selectedAddress ==
                      address; // Check if the address is selected

                  return GestureDetector(
                    onTap: () =>
                        selectAddress(address), // Set the address as selected
                    child: Card(
                      color: isSelected
                          ? Colors.green[50]
                          : Colors.white, // Highlight selected address
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      elevation: 3,
                      child: ListTile(
                        title: Text(
                          "${address['fullName']} (${address['type']})",
                          style: TextStyle(
                            color: Colors.green[800],
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal, // Make selected text bold
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "${address['houseDetails']} , ${address['roadDetails']} "),
                            Text(
                                "${address['city']} , ${address['state']} - ${address['pincode']}"),
                            Text("${address['phoneNumber']}"),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              showAddressDialog(address: address);
                            } else if (value == 'delete') {
                              deleteAddress(address['_id']);
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: Colors.green[800]),
                                  const SizedBox(width: 8),
                                  const Text('Edit'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(Icons.delete, color: Colors.red),
                                  const SizedBox(width: 8),
                                  const Text('Delete'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
