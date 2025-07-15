import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tiffencenter/shared%20preference/PreferenceUtils.dart';

import 'api_endpoints.dart';

class WalletScreen extends StatefulWidget {
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool _isLoading = false;
  String isUserID = '';
  String isToken = '';

  final TextEditingController _amountController = TextEditingController();
  double walletAmount = 0;

  @override
  void initState() {
    super.initState();

    getToken();

    // Start a periodic timer to update the date and time every second
    // Timer.periodic(Duration(seconds: 1), (Timer t) => _updateDateTime());
  }

  Future<void> getToken() async {
    var token = await PreferenceUtils.getString('usertoken');
    isUserID = await PreferenceUtils.getString('user_id').toString();
    if (token != null && token.isNotEmpty) {
      isToken =  token.toString();
    }
  }

  void _addAmount() {
    int amount = int.tryParse(_amountController.text) ?? 0;
    if (amount > 99) {
      setState(() {
        walletAmount += amount;
        _updateWalletInBackend(isToken , isUserID);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter minimum 100 Rupees')),
      );
    }
  }

  Future<void> _updateWalletInBackend(String authToken, String userID ) async {
    setState(() {
      _isLoading = true;
    });
    int amount = int.tryParse(_amountController.text) ?? 0;
    final response = await http.post(
      Uri.parse('${App_endpoints.baseURL}user/fund/request/$userID'), // Replace with your API endpoint
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({
        'amount': amount
      }),
    );

    if (response.statusCode == 200) {
      _amountController.clear();
      Map<String, dynamic> parsedJson = jsonDecode(response.body);
      String message = parsedJson['message'];
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(message),
          content: Text(''),
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
    setState(() {
      _isLoading = false;
    });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                LengthLimitingTextInputFormatter(4), // Limits input to 4 characters
                FilteringTextInputFormatter.digitsOnly, // Allows only digits
              ],
              decoration: InputDecoration(
                labelText: 'Recharge Wallet',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: _isLoading ? null : _addAmount, // Disable button when loading
              child: _isLoading
                  ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Text(
                'Add Amount',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(
  home: WalletScreen(),
));

