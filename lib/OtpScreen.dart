import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tiffencenter/shared%20preference/PreferenceUtils.dart';
import 'Dashboard.dart';
import 'api_endpoints.dart';

class OtpScreen extends StatefulWidget {
  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final FocusNode _focusNode = FocusNode();
  String _otp = '';
  bool _isLoading = false;
  String registerid = '';
  @override


  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _validateOtp();
      }
    });
    getToken();

    setState(() {

    });
  }




  Future<void> getToken() async {
    registerid = await PreferenceUtils.getString('registerid').toString();
  }


  void _validateOtp() {
    // Check if all fields are filled
    if (_controllers.every((controller) => controller.text.isNotEmpty)) {
      _otp = _controllers.map((controller) => controller.text).join();
      _verifyOtp(_otp); // Call the API to verify OTP
    }
  }

  Future<void> _verifyOtp(String otp) async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    final String apiUrl = '${App_endpoints.baseURL}verify/user'; // Replace with your API endpoint
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'otp': otp,
          'register_id' : registerid,    // Send OTP in the request body
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        var dataToSend = responseData['data'];
        var firstName = dataToSend['full_name'];
        var token = dataToSend['token'].toString();
        var wallet = dataToSend['wallet'].toString();

        await PreferenceUtils.setString("usertoken", token.toString());
        await PreferenceUtils.setString("full_name", firstName.toString());
        await PreferenceUtils.setString("wallet", wallet.toString());
        await PreferenceUtils.setString(
            "user_id", dataToSend['user_id'].toString());

        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => Dashboard()),
        );
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Error'),
            content: Text('Invalid OTP. Please try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      print('Error occurred: $error');
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text('An error occurred while verifying OTP.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 50,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: index == 0 ? _focusNode : null,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (value.length == 1 && index < 5) {
                        FocusScope.of(context).nextFocus(); // Move to next field
                      } else if (value.isEmpty && index > 0) {
                        FocusScope.of(context).previousFocus(); // Move to previous field
                      }
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator() // Show loading indicator while verifying
                : ElevatedButton(
              onPressed: _validateOtp,
              child: Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controllers.forEach((controller) => controller.dispose());
    _focusNode.dispose();
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(
    home: OtpScreen(),
  ));
}
