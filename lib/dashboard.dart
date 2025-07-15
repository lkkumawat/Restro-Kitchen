import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tiffencenter/OrderHistory.dart';
import 'package:tiffencenter/WalletScreen.dart';
import 'package:tiffencenter/TransitionHistory.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:tiffencenter/shared%20preference/PreferenceUtils.dart';
import 'package:tiffencenter/shared%20preference/Catgorymodal.dart';
import 'LoginScreen.dart';
import 'userprofilescreen.dart';
import 'api_endpoints.dart';
import 'package:get/get.dart';
class Dashboard extends StatefulWidget {
  Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}
class Product {
  final int id;
  final String product;
  final int categoryId;
  final String price;
  final String discount;
  final String gst;
  final String otherTax;
  final String short;
  final int status;
  final String image;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.product,
    required this.categoryId,
    required this.price,
    required this.discount,
    required this.gst,
    required this.otherTax,
    required this.short,
    required this.status,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      product: json['product'],
      categoryId: json['category_id'],
      price: json["price"],
      discount: json["discount"],
      gst: json["gst"],
      otherTax: json["other_tax"],
      short: json["short"],
      status: json["status"],
      image: json["image"],
      createdAt: DateTime.parse(json["created_at"]),
      updatedAt: DateTime.parse(json["updated_at"]),
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, product: $product, price: $price, categoryId: $categoryId, image: $image, short: $short)';
  }
}

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin {
  RxBool isLoading = false.obs;
  String _currentDateTime = '';
  String isUserID = '';
  String userName = '';

  double walletBalance = 0.0;
  late Catgorymodal catgorymodal;
  List<ProductCategory> catagorylist = [];
  String token_Main = '';
  int? selectedIndex = 0;
  List<bool> isCheckedList = [];
  late TabController _tabController; // TabController to manage tab changes
  List<Product> productList = [];
  List<int> plateCounts = [];
 int totalAmountOrder = 0;

  Color _iconColor(int index) {
    return selectedIndex == index ? Colors.orange : Colors.grey;
  }
  List<bool> selectedProducts = [];
  List<int> arrSelectedIDs = [];
  List<Map<String, dynamic>> dicAddProducts = [];
  bool isChecked = false;
  int isSelectedTab = 1;
  @override
  void initState() {
    super.initState();
    getToken();
    _tabController = TabController(length: 4, vsync: this);

    _tabController.addListener(() {
      setState(() {
        selectedIndex = _tabController.index;
      });
    });

    _tabController.addListener(() {
      if (_tabController.indexIsChanging == false) {
        getToken();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose TabController when done
    super.dispose();
  }

  void _updateDateTime() {
    final now = DateTime.now();
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    setState(() {
      _currentDateTime = formatter.format(now);
    });
  }

  Future<void> getToken() async {
    userName = await PreferenceUtils.getString('full_name').toString();
    var token = await PreferenceUtils.getString('usertoken');
    token_Main = token.toString();
    isUserID = await PreferenceUtils.getString('user_id').toString();
    // var amount = PreferenceUtils.getString('wallet').toString();
    // walletBalalnce = double.parse(amount);

    if (token != null && token.isNotEmpty) {
      getWalletAmount(token, isUserID);
      getAllCategory(token, isUserID);
      _fetchProducts();
    }
  }

  Future<void> getAllCategory(String authToken, String userID) async {
    setState(() {
      isLoading = true.obs;
    });
    final url = '${App_endpoints.baseURL}product/category/list';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken', // Include the auth_token here
        },
      );
      if (response.statusCode == 200) {
        isLoading = false.obs;
        final data = jsonDecode(response.body);
        catagorylist = (data["product_category"] as List<dynamic>)
            .map((item) => ProductCategory.fromJson(item))
            .toList();
        isCheckedList = List<bool>.filled(catagorylist.length, false); // Initialize checkbox list
      } else if (response.statusCode == 401) {
        await PreferenceUtils.remove("usertoken");
        await PreferenceUtils.clear();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
        throw Exception('Unauthorized - redirected to login'); // ✅ Fix: Throw here
      }
    } catch (error) {
    } finally {
      setState(() {
        isLoading = false.obs;
      });
    }
  }

  Future<void> getWalletAmount(String authToken, String userID) async {
    setState(() {
      isLoading = true.obs;
    });
    final url = '${App_endpoints.baseURL}user/wallet/$userID';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        var dataToSend = data['wallet'];
        walletBalance = (dataToSend[0]['wallet']).toDouble();
      }
    } catch (e) {
      print('An error occurred: $e');
    } finally {
      setState(() {
        isLoading = false.obs;
      });
    }
  }

  Future<void> _fetchProducts() async {
    setState(() {
      isLoading = true.obs; // Start loading
    });
    final url = '${App_endpoints.baseURL}product/list/${isSelectedTab}';
    // Define headers, including authorization
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token_Main', // Replace token_Main with your actual token variable
    };
    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        productList = [];
        final data = json.decode(response.body);
        var productListMain = (data['product_list'] as List)
            .map((productData) => Product.fromJson(productData))
            .toList();
        setState(() {
          productList = productListMain;
          isLoading = false.obs; // Stop loading
          // selectedProducts = List.generate(productList.length, (index) => false); // Initial state
          // plateCounts = List.generate(productList.length, (index) => 0); // Default 1 plate
          selectedProducts = List<bool>.filled(productList.length, false);
          plateCounts = List<int>.filled(productList.length, 0);

        });
      }
    } catch (e) {
      print('Error occurred while fetching products: $e');
      setState(() {
        isLoading = false.obs; // Stop loading on error
      });
    }
  }

  void allFoodCategoryAPICall(){
    if (token_Main != null && token_Main.isNotEmpty) {
      // getAllCategory(token_Main, isUserID);
      _fetchProducts();
    }
  }

  Future _submit() async {
    String productJson = jsonEncode(dicAddProducts);

    if (dicAddProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a item'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true.obs;
    });
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token_Main',
      };
      final response = await http.post(
        Uri.parse('${App_endpoints.baseURL}user/order/$isUserID'),
        headers: headers,
        body: jsonEncode({
          'products': productJson,
          // 'discount': '40',
          // 'price': productList[0].price.toString(),
          // 'quntity': _numberOfPlates,
        }),
      );

      var responsede = jsonDecode(response.body);
      var message = responsede['message'];

      if (response.statusCode == 200) {
        getWalletAmount(token_Main, isUserID);
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Restro Kitchen'),
            content: Text(message),
            actions: [
              // Close Button
              TextButton(
                onPressed: () {
                  _fetchProducts();
                  arrSelectedIDs = [];
                  dicAddProducts = [];
                  selectedProducts = [];
                  plateCounts = [];
                  totalAmountOrder = 0;
                  // setState(() {
                  //
                  // });
                  Navigator.of(context).pop();  // Closes the dialog
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      }else if (response.statusCode == 205) {
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
      else if (response.statusCode == 401) {
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
      }else{
        var failresponse = jsonDecode(response.body);
        var dataToSend = failresponse['data'];
        var message = dataToSend['message'];
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
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Restro Kitchen"),
          content: Text('Order Failed'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Closes the dialog
              },
              child: Text('OK'),
            ),
          ],
        ),
      );

    } finally {
      setState(() {
        isLoading = false.obs;
      });
    }
  }

  void addProduct(int productId, String amount, int qty, [String? discount]) {
    Map<String, dynamic> product = {
      "product_id": productId,
      "amount": amount,
      "qty": qty,
    };
    if (discount != null) {
      product["discount"] = discount;
    }
    dicAddProducts.add(product);
  }

  void addProductNew(int productId, String amount, int qty, [String? discount]) {
    // Check if product already exists
    final index = dicAddProducts.indexWhere((product) => product["product_id"] == productId);

    if (index != -1) {
      dicAddProducts[index]["qty"] = qty;
    } else {
      Map<String, dynamic> product = {
        "product_id": productId,
        "amount": amount,
        "qty": qty,
      };
      if (discount != null) {
        product["discount"] = discount;
      }
      dicAddProducts.add(product);
    }
  }

  // Build Dashboard
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.orange,
        centerTitle: true,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // (_tabController.index == 3)
            // ? Text('All Transactions')
            // : Text('Welcome $userName'),
            buildWelcomeMessage(),
            const SizedBox(height: 4.0), // Space between the title and balance
            Text(
              'Available Balance: ₹$walletBalance', // Update this with your balance variable
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w400,
                fontSize: 14.0,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              IconButton(
                // icon: const Icon(Icons.logout,),
                icon: const Icon(Icons.person_2_rounded,),
                iconSize: 30, color: Colors.white,
                onPressed: () {
                  Navigator.push(
                      context,
                  MaterialPageRoute(builder: (context) => Userprofilescreen()));
                },
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30.0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
          ),
        ),
      ),


      body: TabBarView(
        controller: _tabController, // Control Tab changes
        children: [
          buildFoodOrderTab(),  // Tab 1 content: Food Order Tab
          Container(            // Tab 2 content
            child: WalletScreen(),
          ),
          Container(            // Tab 3 content
            child: OrderHistory(),//Center(child: Text("Tab 3 content")),
          ),
          Container(            // Tab 4 content
            child: TransitionHistory()//Center(child: Text("Tab 4 content")),
          ),
        ],
      ),

      bottomNavigationBar: Material(
        color: Colors.white,
        child: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(Icons.fastfood,color: _iconColor(0)),
              text: "Home",
            ),
            Tab(
              icon: Icon(Icons.account_balance_wallet,color: _iconColor(1)),
              text: "Wallet",
            ),
            Tab(
              icon: Icon(Icons.reorder,color: _iconColor(2)),
              text: "Order",
            ),
            Tab(
              icon: Icon(Icons.money,color: _iconColor(3)),
              text: "Transaction",
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildPlateCounter(int index) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.remove),
          onPressed: () {
            setState(() {
              if (plateCounts[index] <= 1) {
                return;
              }
              plateCounts[index]--;
              totalAmountOrder -= int.tryParse(productList[index].price) ?? 0;
              addProductNew(
                productList[index].id,
                productList[index].price,
                plateCounts[index],
                productList[index].discount,
              );
            });
          },
        ),
        Text(
          '${plateCounts[index]}',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            setState(() {
              if (plateCounts[index] >= 5) {
                return;
              }
              selectedProducts[index] = true;
              plateCounts[index]++;
              addProductNew(
                productList[index].id,
                productList[index].price,
                plateCounts[index],
                productList[index].discount,
              );
              print("PLates ${plateCounts[index]}");
              final price = int.tryParse(productList[index].price) ?? 0;
              totalAmountOrder += price;
            });
            },
        ),
      ],
    );
  }
  Widget buildFoodOrderTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          // Fixed Toggle Buttons at the top
          Center(
            child: ToggleButtons(
              isSelected: [isSelectedTab == 1, isSelectedTab == 2, isSelectedTab == 3],
              onPressed: (int index) {
                setState(() {
                  isSelectedTab = index + 1;
                  arrSelectedIDs = [];
                  dicAddProducts = [];
                  selectedProducts = [];
                  plateCounts = [];
                  totalAmountOrder = 0;
                  allFoodCategoryAPICall();
                });
              },
              borderRadius: BorderRadius.circular(12),
              borderWidth: 1,
              borderColor: Colors.green,
              selectedColor: Colors.white,
              fillColor: Colors.blue,
              color: Colors.black,
              constraints: const BoxConstraints(minHeight: 40.0, minWidth: 110.0),
              children: const [
                Text("Break Fast"),
                Text("Lunch"),
                Text("Dinner"),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Scrollable middle content
          Expanded(
            child: Obx(
                  () => isLoading==true
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                child: _buildCategoryItems(),
              ),
            ),
          ),

          // Fixed Submit Button at the bottom
          const SizedBox(height: 20),
          _buildSubmitButton(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
  Widget buildWelcomeMessage() {
    switch (_tabController.index) {
      case 0:
        return Text('Today Menu', style: TextStyle(color: Colors.white));
      case 1:
        return Text('Wallet', style: TextStyle(color: Colors.white));
      case 2:
        return Text('Order History', style: TextStyle(color: Colors.white));
      case 3:
        return Text('Transactions History', style: TextStyle(color: Colors.white));
      default:
        return Text('Welcome $userName');
    }
  }
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity, height: 48,

      child:
      productList.length > 0
      ? ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Quantity text
            const Text(
              'Submit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
              ),
            ),
            const SizedBox(width: 0), // space between quantity and text
            if (totalAmountOrder > 0)
            Container(
                padding: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 40), // space between quantity and text
                    Text(
                      'Amount: $totalAmountOrder',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      )

          : SizedBox(),
    );

  }
  Widget _buildCategoryItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 16.0),
        Column(
          children: List.generate(productList.length, (index) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12), // 20% of 60
                        child: (productList[index].image != null &&
                            productList[index].image.toString().isNotEmpty)
                            ? Image.network(
                          productList[index].image.toString(),
                          fit: BoxFit.cover, // Use cover for better rounded image appearance
                          alignment: Alignment.center,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.broken_image);
                          },
                        )
                            : const Icon(Icons.image_not_supported),
                      ),
                    ),
                    // SizedBox(
                    //   width: 65, // Set the desired width for the image
                    //   height: 65, // Set the desired height for the image
                    //   child: (productList[index].image != null && productList[index].image.isNotEmpty)
                    //       ? Image.network(
                    //     productList[index].image.toString(),
                    //     fit: BoxFit.fill,
                    //     alignment: Alignment.centerLeft,// Ensure image covers the available space
                    //     errorBuilder: (context, error, stackTrace) {
                    //       return Icon(Icons.broken_image); // Fallback icon for broken image link
                    //     },
                    //   )
                    //       : Icon(Icons.image_not_supported), // Fallback icon if no image
                    // ),
                        SizedBox(
                          width: 180,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Text(
                              //   '  ${productList[index].product}', // Display the amount
                              //   style: TextStyle(
                              //     overflow: TextOverflow.ellipsis,
                              //     color: Colors.black, // Set grey color for the amount
                              //     fontSize: 16, fontWeight: FontWeight.bold // Optional: adjust font size
                              //   ),
                              // ),
                              // const SizedBox(height: 4),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${productList[index].product} ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.green,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '(${productList[index].short})',
                                      style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              _buildPlateCounter(index), // 👈 pass index here
                            ],
                          ),

                        ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("₹${productList[index].price.toString()}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),

                        SizedBox(
                          width: 30,
                          child: Checkbox(
                            activeColor: Colors.green,
                            value: selectedProducts[index],
                            onChanged: (bool? value) {
                              setState(() {
                                selectedProducts[index] = value ?? false;

                                if (value == true) {
                                  if (!arrSelectedIDs.contains(productList[index].id)) {
                                    arrSelectedIDs.add(productList[index].id);
                                    plateCounts[index]++;
                                    totalAmountOrder += int.parse(productList[index].price);
                                    addProduct(productList[index].id, productList[index].price,1,productList[index].discount);
                                  }
                                } else {
                                  arrSelectedIDs.remove(productList[index].id);
                                  totalAmountOrder -= (plateCounts[index] * int.parse((productList[index].price)));//int.parse((productList[index].price));
                                  if (arrSelectedIDs.length == 0) {
                                    totalAmountOrder = 0;
                                  }
                                  plateCounts[index] = 0;
                                  dicAddProducts.removeWhere((item) => item['product_id'] == productList[index].id);
                                }
                              }
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Divider(),
                SizedBox(height: 10,)
              ],
            );
          }),
        ),
      ],
    );
  }
}