import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Import the package
import 'package:tiffencenter/shared preference/PreferenceUtils.dart';
import 'package:http/http.dart' as http;

import 'api_endpoints.dart';

class Editprofilescreen extends StatefulWidget {
  const Editprofilescreen({super.key});

  @override
  State<Editprofilescreen> createState() => _EditprofilescreenState();
}

class _EditprofilescreenState extends State<Editprofilescreen> {
  final TextEditingController _emailAddress = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _mobileNo = TextEditingController();
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String user_ID = '';
  String token_Main = '';

  @override
  void initState() {
    // TODO: implement initState
    getToken();
    super.initState();
  }
  Future<void>getToken() async{
    _name.text = await PreferenceUtils.getString('full_name').toString();
    var token = await PreferenceUtils.getString('usertoken');
    token_Main = token.toString();
    user_ID = await PreferenceUtils.getString('user_id').toString();
    _emailAddress.text = await PreferenceUtils.getString('saveEmail').toString();
    _mobileNo.text = await PreferenceUtils.getString('saveMobile').toString();
  }
  Future<void> updateUserProfile() async {
      setState(() {
        _isLoading = true;
      });
      try {
        var response = await http.post(
          Uri.parse("${App_endpoints.baseURL}user/profile-update/$user_ID"),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token_Main', // Replace token_Main with your actual token variable
          },
          body: jsonEncode({
            'name': _name.text.toString(),
          }),
        );
        if (response.statusCode == 200) {
          Navigator.pop(context);
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

    String? validateForm() {
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
      if (_name.text.trim().isEmpty) return "Name is required";
      if (_mobileNo.text.trim().isEmpty) return "Mobile number is required";
      if (_emailAddress.text.trim().isEmpty) return "Email is required";
      if (!emailRegex.hasMatch(_emailAddress.text.trim())) return "Please enter a valid email";
      return null; // ✅ All good
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Update Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize:20),),
      ),
      body: Padding(padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20,),
            TextFormField(
              controller: _name,
              decoration: InputDecoration(labelText: 'Name'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) => value == null || value.trim().isEmpty ? 'Name is required' : null,
              inputFormatters: [
                LengthLimitingTextInputFormatter(30),
                // ✅ Allow letters, numbers, and most special characters (except emoji)
                FilteringTextInputFormatter.allow(
                  RegExp(r'[ -~]'), // ASCII range from space to tilde (~)
                ),
              ],
            ),
            TextFormField(
              controller: _mobileNo,
              inputFormatters: [
                LengthLimitingTextInputFormatter(10), // Limit to 10 digits
                FilteringTextInputFormatter.digitsOnly, // Only allow digits
              ],
              decoration: InputDecoration(labelText: 'Mobile Number'),
              keyboardType: TextInputType.number,
              enabled: false,
            ),
            TextFormField(
              controller: _emailAddress,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              enabled: false,
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
                    updateUserProfile();
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
