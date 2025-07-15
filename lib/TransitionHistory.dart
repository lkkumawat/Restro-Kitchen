
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tiffencenter/shared%20preference/PreferenceUtils.dart';
import 'package:intl/intl.dart';

// import '../../kitchen_office/lib/AllViews/LoginScreen.dart';
import 'api_endpoints.dart';
import 'LoginScreen.dart';

class TransitionHistory extends StatefulWidget {
  @override
  _TransitionHistoryState createState() => _TransitionHistoryState();
}

class _TransitionHistoryState extends State<TransitionHistory> {
  // Declare userFundRequests as a nullable Future
  Future<List<UserFundRequest>>? userFundRequests;
  // List<dynamic>?  userList;
  double walletAmount = 0.0;
  bool _isLoading = false;
  String _currentDateTime = '';
  String isUserID = '';
  int walletBalalnce = 0;

  @override
  void initState() {
    super.initState();
    getToken();


  }

  Future<void> getToken() async {
    var token_firstName = await PreferenceUtils.getString('full_name');
    var token = await PreferenceUtils.getString('usertoken');
    isUserID = await PreferenceUtils.getString('user_id').toString();
    if (token != null && token.isNotEmpty) {
      userFundRequests = fetchFundRequests(token, isUserID);
    }
  }

  Future<void> _refreshData() async {
    var token = await PreferenceUtils.getString('usertoken');
    var userId = await PreferenceUtils.getString('user_id');
    if (token != null && userId != null) {
      setState(() {
        userFundRequests = fetchFundRequests(token, userId);
      });
    }
  }

  // Fetch the web service response
  Future<List<UserFundRequest>> fetchFundRequests(String authToken, String userID) async {
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $authToken',
    };
    print('${App_endpoints.baseURL}user/fund/request/list/$isUserID');
    final response = await http.get(
      Uri.parse('${App_endpoints.baseURL}user/fund/request/list/$isUserID'),
      headers: headers,
    );


    if (response.statusCode == 200) {
      // Parse the response body
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if (jsonResponse.containsKey('user_fund_request')) {
        List<dynamic> data = jsonResponse['user_fund_request'];
        if (data == null || data.isEmpty) {
          throw Exception('No data found');
        }
        return data.map((item) => UserFundRequest.fromJson(item)).toList();
      } else {
        throw Exception('user_fund_request key not found');
      }
    }else if (response.statusCode == 401) {
      await PreferenceUtils.remove("usertoken");
      await PreferenceUtils.clear();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      throw Exception('Unauthorized - redirected to login'); // ✅ Fix: Throw here
    }
    else {
      throw Exception('Failed to load fund requests');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _refreshData(),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(0.0),  // Add padding around the entire container
          child: FutureBuilder<List<UserFundRequest>>(
            future: userFundRequests,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),  // Center the loader
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.red, fontSize: 14),  // Style error message
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    'No data found',
                    style: TextStyle(color: Colors.grey, fontSize: 14),  // Style 'no data' message
                  ),
                );
              }
        
              // Create a DataTable with the fetched data
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!, width: 1),  // Add outer border for table
                    borderRadius: BorderRadius.circular(8),  // Optional: Add rounded corners
                  ),
                  padding: const EdgeInsets.all(0.0),  // Padding around the DataTable
                  child: DataTable(
                    columnSpacing: 10,
                    columns: const <DataColumn>[
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Phone')),
                      DataColumn(label: Text('Amount')),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: snapshot.data!.map((request) {
                      String formattedDate = DateFormat('dd/MM/yyyy HH:mm')
                          .format(DateTime.parse(request.createddat.toString()));
        
                      return DataRow(cells: <DataCell>[
                        DataCell(Text(formattedDate)),
                        DataCell(Text(request.requestNumber ?? 'N/A')),
                        DataCell(Text(request.amount)),
                        DataCell(
                          Text(
                            request.status == 0
                                ? 'Pending'
                                : request.status == 1
                                ? 'Completed'
                                : 'Rejected',
                            style: TextStyle(
                              color: request.status == 0
                                  ? Colors.orange
                                  : request.status == 1
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ),
                        // DataCell(Text(request.status == 0 ? 'Pending' : 'Completed', style: TextStyle(color: request.status == 0 ? Colors.red : Colors.green),)),
                      ]);
        
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

}

// Model Class
class UserFundRequest {
  final int id;
  final int userId;
  final String? requestNumber;
  final String amount;
  final int status;
  final String createddat;

  UserFundRequest({
    required this.id,
    required this.userId,
    this.requestNumber,
    required this.amount,
    required this.status,
    required this.createddat
  });

  factory UserFundRequest.fromJson(Map<String, dynamic> json) {
    return UserFundRequest(
      id: json['id'],
      userId: json['user_id'],
      requestNumber: json['request_number'],
      amount: json['amount'],
      status: json['status'],
      createddat: json['created_at'],
    );
  }
}











