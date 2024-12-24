import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:itq/log/login.dart';

class splashscr extends StatefulWidget {
  const splashscr({super.key});

  @override
  State<splashscr> createState() => _splashscrState();
}

class _splashscrState extends State<splashscr> with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 3))..forward().whenComplete((){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => awloginpage()));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 251, 241, 253),
      body: Center(
        
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            Column(
              children: [
                Image.asset('assets/pslogo.png', height: width*0.09, width: width*9),
                SizedBox(height:width*0.02),
                
                
                Image.asset('assets/spal.png'),
                SizedBox(height:width*0.03),
                Text("User Issue Tracker", style: GoogleFonts.poppins(textStyle: TextStyle(fontSize: width*0.03, color: const Color.fromARGB(255, 1, 211, 211))),),
                Text("IT Department", style: GoogleFonts.josefinSans(textStyle: TextStyle(fontSize: width*0.02, color: const Color.fromARGB(255, 3, 206, 189) )),)
              ],
            ),
          ],
        ),
      ),
    );
  }
}