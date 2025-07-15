import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart'; // Import the package
import 'package:tiffencenter/OtpScreen.dart';
import 'package:tiffencenter/shared%20preference/PreferenceUtils.dart';

import 'api_endpoints.dart';

class Signup extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}
class UserResponse {
  final bool status;
  final String message;
  final String otp;
  final int registerId;

  UserResponse({required this.status, required this.message, required this.otp, required this.registerId});

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      status: json['status'],
      message: json['message'],
      otp: json['otp'],
      registerId: json['register_id'],
    );
  }
}
class _LoginScreenState extends State<Signup> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _mobileNo = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordcontroller = TextEditingController();

  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  Future _signup() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var response = await http.post(
        Uri.parse("${App_endpoints.baseURL}user/register"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': _emailController.text.toString(),
          'name': _name.text.toString(),
          'mobile': _mobileNo.text,
          'password': _passwordController.text.toString(),
          'password_confirmation': _confirmpasswordcontroller.text.toString(),
        }),
      );

      if (response.statusCode == 200) {
        try {
          final decoded = jsonDecode(response.body);

          if (decoded is Map<String, dynamic>) {
            int registerId = decoded['register_id'];
            await PreferenceUtils.setString("registerid", registerId.toString());
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => OtpScreen()),
            );
          } else {
          }
        } catch (e) {
          print('JSON decode error: $e');
        }
      } else if (response.statusCode == 403) {
        Map<String, dynamic> userResponse = jsonDecode(response.body);
        var message = userResponse['message'];

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Restro Kitchen'),
            content: Text(message),
            actions: [
              // Close Button
              TextButton(
                onPressed: () {
                  // Perform any action on OK press
                  Navigator.of(context).pop();  // Closes the dialog
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {

    void showErrorToast(String message) {
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(

          'Sign Up',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.deepOrangeAccent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _name,
                    decoration: InputDecoration(labelText: 'Name'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Name is required' : null,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(30),
                      FilteringTextInputFormatter.allow(RegExp(r'[ -~]')),
                    ],
                  ),
                  TextFormField(
                    controller: _mobileNo,
                    decoration: InputDecoration(labelText: 'Mobile Number'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Mobile number is required';
                      if (value.length != 10) return 'Mobile number must be exactly 10 digits';
                      if (!RegExp(r'^\d{10}$').hasMatch(value)) return 'Please enter a valid 10-digit mobile number';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                      if (value == null || value.trim().isEmpty) return 'Email is required';
                      if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Password is required';
                      if (value.length < 6) return 'Password must be at least 6 characters';
                      return null;
                    },
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(20),
                      FilteringTextInputFormatter.allow(RegExp(r'[ -~]')),
                    ],
                  ),
                  TextFormField(
                    controller: _confirmpasswordcontroller,
                    decoration: InputDecoration(labelText: 'Confirm Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value != _passwordController.text) return 'Passwords do not match';
                      return null;
                    },
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(20),
                      FilteringTextInputFormatter.allow(RegExp(r'[ -~]')),
                    ],
                  ),
                  SizedBox(height: 50),
                  _isLoading
                      ? CircularProgressIndicator()
                      : SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () async {
                        // Validate form first
                        if (_formKey.currentState!.validate()) {
                          _signup();
                        }
                      },
                      child: Text('Sign Up', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}