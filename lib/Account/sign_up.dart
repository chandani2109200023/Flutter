import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String errorMessage = '';
  String successMessage = '';
  bool isLoading = false;
  bool _isPasswordVisible = false; // Manage password visibility

  final String signupUrl = 'http://13.203.77.176:5000/api/user/register';

  InputDecoration buildInputDecoration(String hintText, {Widget? suffixIcon}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.green[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
        borderSide: BorderSide.none,
      ),
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[600]),
      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      suffixIcon: suffixIcon, // Add suffixIcon
    );
  }

  Future<void> signupUser() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text;

    // Validate inputs
    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'All fields are required';
      });
      return;
    }

    // Basic email validation
    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
        .hasMatch(email)) {
      setState(() {
        errorMessage = 'Invalid email format';
      });
      return;
    }

    // Basic phone validation
    if (!RegExp(r"^[0-9]{10}$").hasMatch(phone)) {
      setState(() {
        errorMessage = 'Invalid phone number';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
      successMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse(signupUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        setState(() {
          successMessage =
              'User registered successfully. Redirecting to login...';
        });

        await Future.delayed(Duration(seconds: 2));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
      } else if (response.statusCode == 400) {
        final responseBody = jsonDecode(response.body);
        setState(() {
          errorMessage = responseBody['message'] ?? 'User already exists';
        });
      } else {
        setState(() {
          errorMessage = 'Registration failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: AppBar(
    title: Text(
      "Sign Up",
      style: TextStyle(color: Colors.white),
    ),
    iconTheme: IconThemeData(color: Colors.green),
    elevation: 0,
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
    height: MediaQuery.of(context).size.height,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFFB8F0C2), // Lighter green
          Color(0xFF6FDCDC), // Lighter teal
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Create Account",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 45), // Increased space between title and input fields
            TextField(
              controller: nameController,
              decoration: buildInputDecoration('Enter your full name'),
            ),
            SizedBox(height: 30), // Increased space between input fields
            TextField(
              controller: emailController,
              decoration: buildInputDecoration('Enter your email address'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 30), // Increased space between input fields
            TextField(
              controller: phoneController,
              decoration: buildInputDecoration('Enter your phone number'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height:30), // Increased space between input fields
            TextField(
              controller: passwordController,
              obscureText: !_isPasswordVisible, // Toggle visibility
              decoration: buildInputDecoration(
                'Enter your password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 30), // Increased space between input fields
            if (errorMessage.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            if (successMessage.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  successMessage,
                  style: TextStyle(color: Colors.green, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ElevatedButton(
              onPressed: isLoading ? null : signupUser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: isLoading
                  ? CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Text(
                      "Sign Up",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
            SizedBox(height: 35),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text(
                "Already have an account? Login",
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);
 }
}
