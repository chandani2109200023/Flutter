import 'package:agrive_mart/helper/storage_service.dart';
import 'package:flutter/foundation.dart';
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

  final _formKey = GlobalKey<FormState>(); // Add form key for validation

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
  try {
    String? savedToken;
    String? savedUserId;

    if (kIsWeb) {
      // Get data from localStorage (Web)
      savedToken = await StorageService.getItem('token');
      savedUserId = await StorageService.getItem('userId');
    } else {
      // Get data from SharedPreferences (Mobile)
      SharedPreferences prefs = await SharedPreferences.getInstance();
      savedToken = prefs.getString('token');
      savedUserId = prefs.getString('userId');
    }

    if (savedToken != null && savedUserId != null) {
      setState(() {
        token = savedToken!;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in first')),
      );
    }
  } catch (e) {
    print('Error checking login status: $e');
  }
}

  final String apiUrl = 'http://13.202.96.108/api/address/add/';

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
            "${placemark.subLocality ?? ''}, ${placemark.subAdministrativeArea ?? ''}"
                .trim();
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
    if (_formKey.currentState!.validate()) {
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
                Color(0xFFB2E59C), // Light Green
                Color(0xFFFFF9C4), // Soft Yellow
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
            child: Text("Use Current Location",
                style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 209, 240, 184),
              Color.fromARGB(255, 111, 220, 175),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey, // Add Form widget with key
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  controller: fullNameController,
                  label: "Full Name (Required)*",
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Full Name is required';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: phoneController,
                  label: "Phone Number (Required)*",
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Phone Number is required';
                    }
                    return null;
                  },
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pincode is required';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: stateController,
                  label: "State (Auto-filled)*",
                  icon: Icons.map,
                  enabled: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'State is required';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: cityController,
                  label: "City (Auto-filled)*",
                  icon: Icons.location_city,
                  enabled: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'City is required';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: houseController,
                  label: "House No., Building Name (Required)*",
                  icon: Icons.home,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'House Details are required';
                    }
                    return null;
                  },
                ),
                _buildTextField(
                  controller: roadController,
                  label: "Road name, Area, Colony (Required)*",
                  icon: Icons.directions,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Road Details are required';
                    }
                    return null;
                  },
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
                  child: const Text("Save Address",
                      style: TextStyle(color: Colors.green)),
                ),
              ],
            ),
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
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        // Change to TextFormField for validation
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
        onChanged: onChanged,
        validator: validator, // Add validator for each field
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
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: addressType,
        onChanged: (String? newValue) {
          setState(() {
            addressType = newValue!;
          });
        },
        items: <String>['Home', 'Work', 'Other']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: 'Address Type',
          prefixIcon: Icon(Icons.home, color: Colors.green[800]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green[800]!),
          ),
        ),
      ),
    );
  }
}
