import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'LoginScreen.dart';
import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';

import 'api_endpoints.dart'; // Import the package

class Forgotpassword extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<Forgotpassword> {
  final _formKey = GlobalKey<FormState>(); // Key to identify the form
  final _emailController = TextEditingController();
  bool _isLoading = false;

  // Email validation function
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter your email",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return 'Please enter your email';
    }
    // Regular expression for validating email
    final emailRegExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegExp.hasMatch(value)) {
      Fluttertoast.showToast(
        msg: "Please enter a valid email",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return 'Please enter a valid email';
    }
    return null;
  }



  Future<void> _login() async {
    // Validate the form fields
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      print("Forgot:--- ${_emailController.text}");
      var response = await http.post(
        Uri.parse("${App_endpoints.baseURL}user/forgot"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': _emailController.text.toString(),
        }),
      );

      print("Forgot.statusCode:--- ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Login successful: ${data['token']}');

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
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => LoginScreen()),
            // );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false, // Removes all previous routes
            );
            },
                child: Text('OK'),
              ),
            ],
          ),
        );

      } else {
        Map<String, dynamic> userResponse = jsonDecode(response.body);
        var message = userResponse['message'];
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

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: _formKey, // Wrap the form fields in a Form widget
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,

            children: <Widget>[
              SizedBox(height: 100,),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                ],
              ),
              SizedBox(height: 70),
              _isLoading
                  ? CircularProgressIndicator()
                  : SizedBox(
                width: double.infinity, height: 48,
                    child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                    onPressed: _login,
                                    child: Text('Submit', style: TextStyle(color: Colors.white, fontSize: 16),) ,
                                  ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Forgotpassword(),
  ));
}
