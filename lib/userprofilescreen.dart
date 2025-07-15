import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tiffencenter/changepasswordscreen.dart';
import 'package:tiffencenter/editprofilescreen.dart';
import 'package:tiffencenter/shared%20preference/PreferenceUtils.dart';

// import '../../kitchen_office/lib/AllViews/LoginScreen.dart';
import 'api_endpoints.dart';
import 'package:http/http.dart' as http;
import 'LoginScreen.dart';
class Userprofilescreen extends StatefulWidget {
  const Userprofilescreen({super.key});

  @override
  State<Userprofilescreen> createState() => _UserprofilescreenState();
}

class _UserprofilescreenState extends State<Userprofilescreen> {
  String token_Main = '';
  bool _isLoading = false;

  Future<void> _userLogout() async {
    setState(() {
      _isLoading = true;
    });
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token_Main',
    };
    final response = await http.post(
      Uri.parse('${App_endpoints.baseURL}user/logout'),
      headers: headers,
    );
    if (response.statusCode == 200) {

    }
    await PreferenceUtils.remove("usertoken");
    await PreferenceUtils.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
    setState(() {
      _isLoading = false;
    });
  }

  userLogoutClick(){
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Restro Kitchen'),
        content: Text('Are you sure want to logout ?'),
        actions: [
          // Close Button
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();  // Closes the dialog
            },
            child: Text('Close'),
          ),
          // OK Button
          TextButton(
            onPressed: () {
              // Perform any action on OK press
              _userLogout(); // Closes the dialog
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('User Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize:20),),
      ),
      body: Padding(
          padding: EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              onTap: (){
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => Editprofilescreen())
              );
              },
              // contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              title: Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: Colors.black),),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            Divider(),
            SizedBox(height: 10,),
            ListTile(
              onTap: (){
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Changepasswordscreen()));
              },
              // contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              title: Text('Change Password', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: Colors.black),),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            Divider(),
            SizedBox(height: 10,),
            ListTile(
              onTap: (){
                userLogoutClick();
              },
              // contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              title: Text('Log Out', style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: Colors.black),),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            Divider(),
            SizedBox(height: 10,),
          ],
      ),
      ),
    );
  }
}
