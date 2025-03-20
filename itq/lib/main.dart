import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:itq/log/login.dart';
import 'package:itq/log/splash.dart';



void main() {
  runApp(const Myhome());
}

class Myhome extends StatelessWidget {
  const Myhome({super.key});

  
                          // ***********************************First Getting Log in*************************************
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
       title: 'Login',
       
      home: const splashscr(),
    );
  }
}

// ******************************************************************END OF MAIN**************************************************************