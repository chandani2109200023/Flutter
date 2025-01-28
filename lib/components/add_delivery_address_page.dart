import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class AddDeliveryAddressPage extends StatefulWidget {
  const AddDeliveryAddressPage({Key? key}) : super(key: key);

  @override
  _AddDeliveryAddressPageState createState() => _AddDeliveryAddressPageState();
}

class _AddDeliveryAddressPageState extends State<AddDeliveryAddressPage> {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController houseController = TextEditingController();
  TextEditingController roadController = TextEditingController();
  String addressType = "Home";
  bool isSaving = false;
  late String token;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedToken = prefs.getString('token');
      if (savedToken != null) {
        setState(() {
          token = savedToken;
        });
      }
    } catch (e) {
      print('Error checking login status: $e');
    }
  }

  final String apiUrl = 'http://13.203.77.176:5000/api/address/add/';

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Placemark placemark = placemarks[0];

      setState(() {
        stateController.text = placemark.administrativeArea ?? '';
        cityController.text = placemark.locality ?? '';
        pincodeController.text = placemark.postalCode ?? '';
        roadController.text =
            "${placemark.subLocality ?? ''}, ${placemark.subAdministrativeArea ?? ''}".trim();
        houseController.clear();
      });
    } catch (e) {
      print('Error fetching location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch location')),
      );
    }
  }

  Future<void> fetchStateAndCity(String pincode) async {
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

  Future<void> addAddress() async {
    setState(() {
      isSaving = true;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode({
          'fullName': fullNameController.text,
          'phoneNumber': phoneController.text,
          'pincode': pincodeController.text,
          'state': stateController.text,
          'city': cityController.text,
          'houseDetails': houseController.text,
          'roadDetails': roadController.text,
          'type': addressType,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address added successfully!')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add address')),
        );
      }
    } catch (error) {
      print('Error adding address: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error adding address')),
      );
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text("Add Delivery Address"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF92E3A9),
                Color(0xFF34B6B6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.location_on, color: Colors.black),
            onPressed: _getCurrentLocation,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Text("Use Current Location", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFB8F0C2),
              Color(0xFF6FDCDC),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: fullNameController,
                label: "Full Name (Required)*",
                icon: Icons.person,
              ),
              _buildTextField(
                controller: phoneController,
                label: "Phone Number (Required)*",
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(
                controller: pincodeController,
                label: "Pincode (Required)*",
                icon: Icons.pin_drop,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  if (value.length == 6) {
                    fetchStateAndCity(value);
                  }
                },
              ),
              _buildTextField(
                controller: stateController,
                label: "State (Auto-filled)*",
                icon: Icons.map,
                enabled: false,
              ),
              _buildTextField(
                controller: cityController,
                label: "City (Auto-filled)*",
                icon: Icons.location_city,
                enabled: false,
              ),
              _buildTextField(
                controller: houseController,
                label: "House No., Building Name (Required)*",
                icon: Icons.home,
              ),
              _buildTextField(
                controller: roadController,
                label: "Road name, Area, Colony (Required)*",
                icon: Icons.directions,
              ),
              _buildAddressTypeDropdown(),
              ElevatedButton(
                onPressed: isSaving ? null : addAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  side: BorderSide(color: Colors.green[800]!),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Save Address", style: TextStyle(color: Colors.green)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.green[800]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green[800]!),
          ),
        ),
      ),
    );
  }

  Widget _buildAddressTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: addressType,
        decoration: InputDecoration(
          labelText: "Address Type",
          prefixIcon: Icon(Icons.category, color: Colors.green[800]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green[800]!),
          ),
        ),
        items: ["Home", "Work", "Hotel"]
            .map((type) => DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            addressType = value!;
          });
        },
      ),
    );
  }
}
