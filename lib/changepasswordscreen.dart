import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:tiffencenter/shared preference/PreferenceUtils.dart';
import 'package:http/http.dart' as http;
import 'api_endpoints.dart';

class Changepasswordscreen extends StatefulWidget {
  const Changepasswordscreen({super.key});

  @override
  State<Changepasswordscreen> createState() => _ChangepasswordscreenState();
}

class _ChangepasswordscreenState extends State<Changepasswordscreen> {
  final oldPassword = TextEditingController();
  final newPassword = TextEditingController();
  // final confirmNewPassword = TextEditingController();
  final TextEditingController confirmNewPassword = TextEditingController();

  bool _isLoading = false;
  String user_ID = '';
  String token_Main = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    getToken();
    super.initState();
  }
  Future<void>getToken() async{
    var token = await PreferenceUtils.getString('usertoken');
    token_Main = token.toString();
    user_ID = await PreferenceUtils.getString('user_id').toString();
  }

  Future<void> updateChangePassword() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var response = await http.post(
        Uri.parse("${App_endpoints.baseURL}user/password-reset/$user_ID"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token_Main', // Replace token_Main with your actual token variable
        },
        body: jsonEncode({
          'current_password': oldPassword.text.toString(),
          'password': newPassword.text.toString(),
          'password_confirmation': confirmNewPassword.text.toString(),
        }),
      );
      print('Update Profile** ${response.body}');
      Map<String, dynamic> userResponse = jsonDecode(response.body);
      var message = userResponse['message'];

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Restro Kitchen'),
            content: Text(message),
            actions: [
            // Close Button3
            TextButton(
                onPressed: () {
                  print('yes clickon OK');
                  // Perform any action on OK press
                  Navigator.pop(context); // Closes dialog
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else if (response.statusCode == 403) {

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

    String? validateForm() {
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
      if (oldPassword.text.trim().isEmpty) return "Old password is required";
      if (newPassword.text.trim().isEmpty) return "New password is required";
      if (newPassword.text.trim().length < 6) return "Password must be at least 6 characters";
      if (confirmNewPassword.text.trim().isEmpty) return "Confirm new password is required";
      if (newPassword.text.trim() != confirmNewPassword.text.trim()) {
        return "Password and Confirm Password do not match";
      }
      return null; // ✅ All good
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.normal),),
        backgroundColor: Colors.orange,
      ),
      body: Padding(padding: EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: oldPassword,
              decoration: InputDecoration(labelText: 'Old Password'),
              inputFormatters: [
                LengthLimitingTextInputFormatter(20),
                FilteringTextInputFormatter.allow(
                  RegExp(r'[ -~]'),
                ),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) return 'Old password is required';
                if (value.length < 6) return 'Password must be at least 6 characters';
                return null;
              },
            ),
            SizedBox(height: 10,),

            TextFormField(
              controller: newPassword,
              decoration: InputDecoration(labelText: 'New Password'),
              inputFormatters: [
                LengthLimitingTextInputFormatter(20),
                FilteringTextInputFormatter.allow(
                  RegExp(r'[ -~]'),
                ),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) return 'New password is required';
                if (value.length < 6) return 'Password must be at least 6 characters';
                return null;
              },
            ),
            SizedBox(height: 10,),
            TextFormField(
              controller: confirmNewPassword,
              decoration: InputDecoration(labelText: 'Confirm New Password'),
              // validator: (value) {
              //   if (value != confirmNewPassword.text) return 'Passwords do not match';
              //   return null;
              // },
              validator: (value) {
                if (value == null || value.isEmpty) return 'Confirm New Password is required';
                if (value != confirmNewPassword.text) return 'Passwords do not match';
                print('yessss');
                return null;
              },
              inputFormatters: [
                LengthLimitingTextInputFormatter(20),
                FilteringTextInputFormatter.allow(
                  RegExp(r'[ -~]'),
                ),
              ],

            ),
            SizedBox(height: 50),
            _isLoading
                ? CircularProgressIndicator()
                : SizedBox(
              width: double.infinity, height: 48,
              child : ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () async {
                  if (_formKey.currentState!.validate()){
                    if (confirmNewPassword.text.isEmpty) {
                      print('Yes');
                    }
                    // updateChangePassword();
                  }
                },
                child: Text('Update Profile', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
      ),
    );
  }
}
