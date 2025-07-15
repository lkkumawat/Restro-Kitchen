import 'package:flutter/material.dart';
import 'package:tiffencenter/SplashScreen.dart';
import 'package:tiffencenter/shared%20preference/PreferenceUtils.dart';

// import '../../kitchen_office/lib/AllViews/LoginScreen.dart';
import 'LoginScreen.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await PreferenceUtils.init(); // Initialize SharedPreferences

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',

      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen()
    );
  }
}

