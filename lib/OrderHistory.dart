import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tiffencenter/shared%20preference/PreferenceUtils.dart';
import 'package:get/get.dart';
import 'api_endpoints.dart';
import 'LoginScreen.dart';
import 'package:intl/intl.dart';

class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

 class _OrderHistoryState extends State<OrderHistory> {
   double walletAmount = 0.0;
   RxBool isLoading = false.obs;
   String _currentDateTime = '';
   String isUserID = '';
   int walletBalalnce = 0;
   String token_Main = '';
   List<dynamic> dataAll = [].obs;
   int isSelectedTab = 1;

   @override
   void initState() {
     /// wait
     setState(() {
       getToken();
     });
     super.initState();
   }

   void getToken() {
     var token = PreferenceUtils.getString('usertoken');
     isUserID = PreferenceUtils.getString('user_id').toString();
     token_Main = token.toString();
     fetchOrderRequests();
   }

   Future fetchOrderRequests() async {
     setState(() {
       isLoading = true.obs;
     });

     final headers = {
       'Content-Type': 'application/json',
       'Authorization': 'Bearer $token_Main',
     };
     var strValues = '';
     if (isSelectedTab == 1) {
       strValues = 'today';
     }else {
       strValues = '';
     }
     final response = await http.get(
       Uri.parse('${App_endpoints.baseURL}user/order/list${strValues}/$isUserID'),
       // Corrected variable name
       headers: headers,
     );
     if (response.statusCode == 200) {
       Map<String, dynamic> jsonResponse = jsonDecode(response.body);
       if (jsonResponse.containsKey('order_list')) {
         setState(() {
           dataAll = jsonResponse['order_list'];
         });
         if (dataAll.isEmpty) {
           throw Exception('No data found');
         }
       } else {
         throw Exception('order_list key not found');
       }
     } else if (response.statusCode == 401) {
       await PreferenceUtils.remove("usertoken");
       await PreferenceUtils.clear();
       Navigator.pushReplacement(
         context,
         MaterialPageRoute(builder: (context) => LoginScreen()),
       );
       throw Exception(
           'Unauthorized - redirected to login'); // ✅ Fix: Throw here
     }
     else {
       throw Exception('Failed to load order requests: ${response.statusCode}');
     }
   }

   // void cancelapi(BuildContext context, String order_id, ) async {
   //   final headers = {
   //     'Content-Type': 'application/json',
   //     'Authorization': 'Bearer $token_Main',
   //   };
   //
   //   final response = await http.get(
   //     Uri.parse('${App_endpoints.baseURL}user/order/cancel/$order_id'), // Corrected variable name
   //     headers: headers,
   //   );
   //
   //   if (response.statusCode == 200) {
   //     // Parse the response body
   //     Map<String, dynamic> jsonResponse = jsonDecode(response.body);
   //     var message = jsonResponse['message'];
   //     showDialog(
   //       context: context,
   //       builder: (_) => AlertDialog(
   //         title: Text('Restro Kitchen'),
   //         content: Text(message),
   //         actions: [
   //           // Close Button
   //           TextButton(
   //             onPressed: () {
   //               // Perform any action on OK press
   //               // userOrderRequests = fetchOrderRequests(token_Main.toString(), isUserID);
   //               Navigator.of(context).pop();  // Closes the dialog
   //             },
   //             child: Text('OK'),
   //           ),
   //         ],
   //       ),
   //     );
   //
   //     // if (jsonResponse.containsKey('order_list')) {
   //     //   List<dynamic> data = jsonResponse['order_list'];
   //     //   print('Transition data: $data'); // Check the data
   //     //   // return data.map((item) => UserOrderRequest.fromJson(item)).toList();
   //     // } else {
   //     //   throw Exception('order_list key not found');
   //     // }
   //
   //   } else {
   //     throw Exception('Failed to load order requests: ${response.statusCode}');
   //   }
   // }
   // String formatDate(String inputDate) {
   //   DateTime date = DateTime.parse(inputDate);
   //   return DateFormat('dd MMM yyyy').format(date);
   // }
   String formatDateTime(String dateTimeString) {
     DateTime dateTime = DateTime.parse(dateTimeString);
     return DateFormat('dd MMM yyyy hh:mm a').format(dateTime);
   }
   void _showOrderDialog(BuildContext context, requestData) {
     showDialog(
       context: context,
       builder: (context) {
         return Dialog(
           insetPadding: const EdgeInsets.all(16),
           child: ConstrainedBox(
             constraints: BoxConstraints(
               maxHeight: MediaQuery
                   .of(context)
                   .size
                   .height * 0.7,
             ),
             child: Padding(
               padding: const EdgeInsets.all(16),
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Text("Order ID: ${requestData['order_number']}",
                       style: TextStyle(fontSize: 16)),
                   const SizedBox(height: 8),
                   Text("Total Quantity: ${requestData['total_quantity']}",
                       style: TextStyle(fontSize: 16)),
                   const SizedBox(height: 8),
                   Text("Order Amount: ₹${requestData['total_amount']}",
                       style: TextStyle(fontSize: 16)),
                   const SizedBox(height: 8),
                 Text(
                   'Date: ${formatDateTime(requestData['created_at'])}',
                   style: TextStyle(fontSize: 16),
                 ),
                   const SizedBox(height: 10),
                   // Image.network(
                   //   requestData['imageUrl'],
                   //   width: 130,
                   //   height: 130,
                   //   fit: BoxFit.cover,
                   // ),
                   const SizedBox(height: 10),
                   Divider(),

                   // ✅ Wrap list in Expanded to avoid unbounded height
                   Expanded(
                       child:
                       ListView.separated(
                         itemCount: requestData['items'].length,
                         separatorBuilder: (_, __) => Divider(),
                         itemBuilder: (context, index) {
                           final getData = requestData['items'];
                           return Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Row(
                                 mainAxisAlignment: MainAxisAlignment
                                     .spaceBetween,
                                 children: [
                                   // Text('Order No: 111', style: TextStyle(color: Colors.green)),
                                   Text(
                                       'Item Name: ${getData[index]['product_name']}',
                                       style: TextStyle(color: Colors.green,
                                           fontWeight: FontWeight.bold)),
                                   Text('Price: ₹${getData[index]['price']}'),
                                 ],
                               ),
                               const SizedBox(height: 8),
                               Row(
                                 mainAxisAlignment: MainAxisAlignment
                                     .spaceBetween,
                                 children: [
                                   // Text('Order No: 111', style: TextStyle(color: Colors.green)),
                                   Text('Quantity: ${getData[index]['qty']}'),
                                   Text(
                                       'Discount: ${getData[index]['discount']}'),
                                 ],
                               ),
                             ],
                           );
                         },
                       )
                     // }),
                   ),

                   const SizedBox(height: 16),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                     children: [
                       SizedBox(
                         width: 200,
                         child: ElevatedButton(style: ElevatedButton.styleFrom(
                             backgroundColor: Colors.green),
                           onPressed: () => Navigator.pop(context),
                           child: const Text("OK",
                               style: TextStyle(color: Colors.white)),
                         ),
                       ),
                     ],
                   )
                 ],
               ),
             ),
           ),
         );
       },
     );
   }

   Widget buildFoodOrderTab() {
     return Padding(
       padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 0.0),
       // Increase top padding
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.stretch,
         children: [
           Column(
             children: [
               SizedBox(height: 20,),
               Center(
                 child: ToggleButtons(
                   isSelected: [
                     isSelectedTab == 1,
                     isSelectedTab == 2,
                   ],
                   onPressed: (int index) {
                     setState(() {
                       isSelectedTab  = index + 1;
                       dataAll = [];
                       fetchOrderRequests();
                     });
                   },
                   borderRadius: BorderRadius.circular(12),
                   borderWidth: 1,
                   borderColor: Colors.green,
                   selectedColor: Colors.white,
                   fillColor: Colors.blue,
                   color: Colors.black,
                   constraints: const BoxConstraints(
                       minHeight: 40.0, minWidth: 110.0),
                   children: [
                     Text("Today"),
                     Text("All"),
                     // Text("Dinner"),
                     // Text("${catagorylist[0].category}")
                   ],
                 ),
               ),
             ],
           ),
           _buildAllData(context),
           // Obx(
           //       () =>
           //   isLoading == true ?
           //   Center(child: CircularProgressIndicator(),) :
           //   Column(
           //       children: [
           //         _buildAllData(
           //             // child: _buildAllData()
           //         ),
           //         const SizedBox(height: 20.0),
           //         // _buildSubmitButton(),
           //       ]),
           // ),

         ],
       ),
     );
   }
   @override
   Widget build(BuildContext context) {
     return Scaffold(
       backgroundColor: Colors.white,
       body: SafeArea(
         child: SingleChildScrollView(
           child: buildFoodOrderTab(),
         ),
       ),
     );
   }

   Widget _buildAllData(BuildContext context) {
     return dataAll.isEmpty
         ? const Center(child: Text('No data found'))
         : SingleChildScrollView(
       scrollDirection: Axis.horizontal,
       child: ConstrainedBox(
         constraints: BoxConstraints(
           minWidth: MediaQuery.of(context).size.width,
         ),
         child: SingleChildScrollView(
           scrollDirection: Axis.vertical,
           child: DataTable(
             columnSpacing: 1,
             columns: const <DataColumn>[
               DataColumn(label: Text('Order ID')),
               DataColumn(label: Text('View')),
               DataColumn(label: Text('Status')),
             ],
             rows: List.generate(dataAll.length, (index) {
               final item = dataAll[index];
               final orderNumber = item['order_number'] ?? 'N/A';
               final status = item['status'] ?? 0;

               return DataRow(cells: <DataCell>[
                 DataCell(Text(orderNumber)),
                 DataCell(
                   Center(
                     child: GestureDetector(
                       onTap: () {
                         _showOrderDialog(context, item);
                       },
                       child: Container(
                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                         decoration: BoxDecoration(
                           color: status == 0 ? Colors.white : Colors.green,
                           border: Border.all(color: Colors.red, width: 1),
                           borderRadius: BorderRadius.circular(8),
                         ),
                         height: 30,
                         width: 70,
                         alignment: Alignment.center,
                         child: Text(
                           _getButtonText2(status.toString()),
                           style: TextStyle(
                             color: status == 0 ? Colors.black : Colors.white,
                             fontSize: 12,
                           ),
                         ),
                       ),
                     ),
                   ),
                 ),
                 DataCell(
                   Center(
                     child: GestureDetector(
                       onTap: () {
                         if (status == 2) {
                           // cancelapi(context, orderNumber.toString());
                         }
                       },
                       child: Container(
                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                         decoration: BoxDecoration(
                           color: status == 0 ? Colors.white : Colors.green,
                           border: Border.all(color: Colors.red, width: 1),
                           borderRadius: BorderRadius.circular(8),
                         ),
                         height: 30,
                         width: 70,
                         alignment: Alignment.center,
                         child: Text(
                           _getButtonText(status.toString()),
                           style: TextStyle(
                             color: status == 0 ? Colors.black : Colors.white,
                             fontSize: 12,
                           ),
                         ),
                       ),
                     ),
                   ),
                 ),
               ]);
             }),
           ),
         ),
       ),
     );
   }

   String _getButtonText(String status) {
     switch (status) {
       case "0":
         return "Pending";
       case "1":
         return "Accept";
       case "2":
         return "Cancel";
       case "3":
         return "Rejected";
       default:
         return "Unknown"; // Fallback text in case of unexpected status
     }
   }

   String _getButtonText2(String status) {
     switch (status) {
       case "0":
         return "View All";
       case "1":
         return "View All";
       case "2":
         return "View All";
       case "3":
         return "View All";
       default:
         return "View All"; // Fallback text in case of unexpected status
     }
   }
 }

