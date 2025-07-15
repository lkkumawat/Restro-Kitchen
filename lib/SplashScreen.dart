import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tiffencenter/Dashboard.dart';
// import '../../kitchen_office/lib/AllViews/LoginScreen.dart';
import 'package:tiffencenter/shared%20preference/PreferenceUtils.dart';
import 'LoginScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startSplashScreen();
  }

  startSplashScreen() async {
    await Future.delayed(const Duration(seconds: 3), () async {
      var userToken = await PreferenceUtils.getString("usertoken");

      if (userToken != null && userToken.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Dashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Add your logo here
                Image.asset(
                  'assets/images/splashscreen_new.png',
                  fit: BoxFit.cover, // Path to your logo
                ),
                const SizedBox(height: 20),
                const Text(
                  "Tiffen Center",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                // const CircularProgressIndicator(), // Loader
              ],
            ),
          ),
        ),
      ),
    );
  }
}
