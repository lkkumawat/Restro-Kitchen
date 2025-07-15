import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:tiffencenter/shared%20preference/PreferenceUtils.dart';

// import '../../../tiffencenter/lib/Dashboard.dart';
import 'Dashboard.dart';
// import '../../../tiffencenter/lib/Forgotpassword.dart';
import 'ForgotPassword.dart';
// import '../../../tiffencenter/lib/Signup.dart'; // Import the package
import 'SignUP.dart';
import 'package:tiffencenter/api_endpoints.dart';
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _passwordVisible = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // mobile validation function
  String? _validateMobileNo(String? value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Please enter your mobile number'),
    ));
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter your password",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return 'Please enter your password';
    }

    // Password must be at least 6 characters
    if (value.length < 6) {
      Fluttertoast.showToast(
        msg: "Password must be at least 6 characters long",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  Future _login() async {
    setState(() {
      _isLoading = true;
      _passwordVisible = false;
    });
    if (_emailController.text.isEmpty){

    }
    try {
      var response = await http.post(
        Uri.parse("${App_endpoints.baseURL}user/login"),
      headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'mobile': _emailController.text.toString(),
          'password': _passwordController.text.toString(),
        }),
      );

      if (response.statusCode == 200) {
        var responsede = jsonDecode(response.body);
        var dataToSend = responsede['data'];
        var firstName = dataToSend['full_name'];

        var strEmailID = dataToSend['email'];
        var strMobileNo = dataToSend['mobile_number'];

        var token = dataToSend['token'].toString();
        var wallet = dataToSend['wallet'].toString();
        await PreferenceUtils.setString("usertoken", token.toString());
        await PreferenceUtils.setString("full_name", firstName.toString());
        await PreferenceUtils.setString("wallet", wallet.toString());

        await PreferenceUtils.setString("saveEmail", strEmailID.toString());
        await PreferenceUtils.setString("saveMobile", strMobileNo.toString());

        await PreferenceUtils.setString(
            "user_id", dataToSend['user_id'].toString());

        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => Dashboard()),
        );
      } else {
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
    } catch (e) {
      print("Error occurred: $e");
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Restro Kitchen'),
          content: Text("$e"),
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

    } finally {
      setState(() {
        _isLoading = false;
      });
    }//google chrome dikha jisme
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
    String? validateForm() {
      if (_emailController.text.trim().isEmpty) return "Mobile Number is required";
      if (_passwordController.text.trim().isEmpty) return "Password is required";
      if (_passwordController.text.trim().length < 6) return "Password must be at least 6 characters";
      return null; // ✅ All good
    }
    return Scaffold(
      extendBodyBehindAppBar: false,

      body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: [
                        Text('LOGIN', textAlign: TextAlign.center, style: TextStyle(fontSize: 30.0, color: Colors.orange), )
                      ],
                    ),
                    SizedBox(height: 50,),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(10), // Limit to 10 digits
                              FilteringTextInputFormatter.digitsOnly, // Only allow digits
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Mobile number is required';
                              if (value.length != 10) return 'Mobile number must be exactly 10 digits';
                              if (!RegExp(r'^\d{10}$').hasMatch(value)) return 'Please enter a valid 10-digit mobile number';
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Mobile Number',
                              hintStyle: TextStyle(
                                color: Colors.white, // Change placeholder color here
                                fontStyle: FontStyle.italic, // Optional: add italic style
                              ),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),

                          SizedBox(height: 20), // Add spacing between the two fields

                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_passwordVisible,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintStyle: TextStyle(
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Password is required';
                              if (value.length < 6) return 'Password must be at least 6 characters';
                              return null;
                            },
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(20),
                              // ✅ Allow letters, numbers, and most special characters (except emoji)
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[ -~]'), // ASCII range from space to tilde (~)
                              ),
                            ],
                          ),
                        ],
                       ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Forgotpassword()),
                            );
                          },
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    _isLoading
                        ? CircularProgressIndicator()
                        : SizedBox(
                        width: double.infinity, height: 48,
                          child: ElevatedButton(
                                                onPressed: () {
                                                  // final error = validateForm();
                                                  // if (error != null) {
                                                  //   showErrorToast(error);
                                                  // } else {
                                                    if (_formKey.currentState!.validate()) {
                                                      _login();
                                                    }
                                                  // }
                                                },
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                                  child: Text('Login',style:  TextStyle(
                                                  fontWeight: FontWeight.normal, color: Colors.white, // Makes the text bold
                                                  fontSize: 16,             // You can also adjust the font size if needed
                                                  ),
                                                  ),
                                                  ),
                                                  ),
                                                  SizedBox(height: 20),
                                                  Center(
                                                  child: SizedBox(
                                                  width: double.infinity, height: 48,
                                                  child: GestureDetector(
                                                  onTap: () {

                                                  Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => Signup()),
                                                  );
                                                },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.green, borderRadius: BorderRadius.circular(24)
                            ),
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white, 
                                // decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: LoginScreen(),
  ));
}