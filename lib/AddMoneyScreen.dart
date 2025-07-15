import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tiffencenter/shared%20preference/PreferenceUtils.dart';

class AddMoneyScreen extends StatefulWidget {
  @override
  _AddMoneyScreenState createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  double _walletBalance = 0.0; // Initial balance
  String isUserID = '';
  String userName = 'abc';
  // String token_Main = '';
  // Replace with your API endpoint
  final String _apiUrl = 'https://yourapi.com/wallet/add'; // Add money API
  final String _walletBalanceUrl = 'https://yourapi.com/wallet/balance'; // Get wallet balance API

  @override
  void initState() {
    super.initState();
    //_fetchWalletBalance(); // Fetch initial balance
  }

  Future<void> getToken() async {
    userName = await PreferenceUtils.getString('full_name').toString();
    // var token = await PreferenceUtils.getString('usertoken');
    // token_Main = token.toString();
    isUserID = await PreferenceUtils.getString('user_id').toString();
    var amount = PreferenceUtils.getString('wallet').toString();
    print('wallet balance first ---- $amount');
    _walletBalance = double.parse(amount);
  }

  // Fetch the wallet balance from the server
  Future<void> _fetchWalletBalance() async {
    try {
      final response = await http.get(Uri.parse(_walletBalanceUrl));
      if (response.statusCode == 200) {
        setState(() {
          _walletBalance = json.decode(response.body)['balance']; // Assuming response has a 'balance' field
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch balance';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error occurred: $e';
      });
    }
  }

  // Add money to wallet API call
  Future<void> _addMoneyToWallet(double amount) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'amount': amount}),
      );
  print("response.statusCode ${response.statusCode}");
      print("_apiUrl ${_apiUrl}");

      if (response.statusCode == 200) {
        // Successfully added money, update balance
        _fetchWalletBalance();
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Money added successfully')),
        );
      } else {
        setState(() {
          _errorMessage = 'Failed to add money';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error occurred: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Show a dialog to input the amount to add
  void _showAddMoneyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(''),
          content: TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: 'Enter amount'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final amount = double.tryParse(_amountController.text);
                if (amount != null && amount > 0) {
                  _addMoneyToWallet(amount);
                } else {
                  setState(() {
                    _errorMessage = 'Please enter a valid amount';
                  });
                }
              },
              child: _isLoading ? CircularProgressIndicator() : Text('Add Money'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align content to the start (top)
          children: [
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showAddMoneyDialog,
              child: Text('Add Money'),
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(
    // home: AddMoneyScreen(),
  ));
}
