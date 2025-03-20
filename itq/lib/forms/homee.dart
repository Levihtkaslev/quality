// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/Url_launcher.dart';

class homeee extends StatefulWidget {
  final String targetname;
   homeee({super.key,required this.targetname,});

  @override
  State<homeee> createState() => _homeeeState();
}

 Future<void> makecall(String phonenumber) async{
    final Uri callurinum = Uri(
      scheme : 'tel',
      path : phonenumber
    );

    if(await canLaunchUrl(callurinum)){
      await launchUrl(callurinum);
    }
    else{
      print('Error opening  $phonenumber');
    }
  }

class _homeeeState extends State<homeee> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    // ignore: deprecated_member_use
    return WillPopScope(
       onWillPop: () async {
      bool shouldExit = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Exit', style: GoogleFonts.poppins(fontSize: width * 0.05)),
            content: Text('Are you sure you want to exit?', style: GoogleFonts.poppins(fontSize: width * 0.04)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // Dismiss dialog and don't exit
                child: Text('No', style: GoogleFonts.poppins(color: Colors.red)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true), // Exit the page
                child: Text('Yes', style: GoogleFonts.poppins(color: Colors.green)),
              ),
            ],
          );
        },
      );
      return shouldExit ; 
    },
      child: Scaffold(
        appBar: AppBar(
          
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20),)),
        iconTheme: IconThemeData(color: Colors.white), 
        backgroundColor: const Color.fromARGB(255, 9, 176, 241),
        title: Padding(
          padding:EdgeInsets.only(bottom: width*0.2, top: width*0.2, left: width*0.02),
          child: Text("Home", style: GoogleFonts.poppins(color: Colors.white, fontSize: width*0.06),),
        ),
        actions: [
          Image.asset('assets/imageedit_2_9343474098.png', height: width*0.09, width: width*0.5,)
        ],
        
        ),
        body:  GestureDetector(
          onTap: (){
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(width*0.03),
                    child: Container(
                      padding: EdgeInsets.all(width*0.06),
                      height: height*1,
                          decoration: BoxDecoration( color: const Color.fromARGB(255, 254, 244, 255), border: Border.all(width: width*0.003, color:  Colors.transparent,),borderRadius: BorderRadius.circular(12), boxShadow: [ // Adding a shadow
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5), // Shadow color
                                spreadRadius: 3, // How far the shadow spreads
                                blurRadius: 7,   // How blurry the shadow is
                                offset: const Offset(0, 3), // Position of the shadow (x, y)
                              ),
                            ],),
                    
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  width: width,
                                  height: width*0.2,
                                  padding: EdgeInsets.all(width*0.05),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)), gradient: LinearGradient(
                                    
                                  begin: Alignment.topCenter,
                                  colors: [
                                     Color.fromRGBO(35, 196, 218, 1),
                                  Color.fromRGBO(64, 204, 223, 1) ,
                                  ],
                                  )),
                                  child: Column(
                                    children: [
                                  Text("Hi "+widget.targetname,style: GoogleFonts.poppins(textStyle: TextStyle(color: const Color.fromARGB(255, 248, 248, 248), fontSize: width*0.03))),
                                  Text("We are here to assist U",style: GoogleFonts.poppins(textStyle: TextStyle(color: const Color.fromARGB(255, 247, 252, 252), fontSize: width*0.04)),),
                                  
                                    ],
                                  ),
                                ),
                               SizedBox(height: width*0.001,),
                                Container(
                                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(100))),
                                  
                                  child: Image.asset('assets/548.jpg',height: height*0.5,width: width,)),
                    
                                  
                    
                                  Container(
                                    padding: EdgeInsets.all(width*0.03),
                                    width: width,
                                   decoration: BoxDecoration( gradient: LinearGradient(
                                    
                                  begin: Alignment.topCenter,
                                  colors: [
                                     Color.fromRGBO(35, 196, 218, 1),
                                  Color.fromRGBO(64, 204, 223, 1) ,
                                  ],
                                  ), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15))),
                                    
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      
                                      children: [
                                         Text("Need Support and Help?",style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.white, fontSize: width*0.03)),),
                                            Text("Contact",style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.white, fontSize: width*0.02)),),
                                            Text("Name : Mr. abcd efghij k,",style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.white, fontSize: width*0.02)),),
                                            
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Call: 9677001785", style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.white, fontSize: width*0.02)),),
                                           
                                            Container(
                                              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15))),
                                              child: InkWell(
                                                onTap: (){
                                                  makecall("9677001785");
                                                },
                                                child: Image.asset('assets/phone.gif', height: width*0.07, width: width*0.07,),
                                              ),
                                            )
                                          ],
                                        ),
                                        Center(
                                          child: Column(
                                            children: [
                                              Text("Feel free to call",style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.white, fontSize: width*0.02)),),
                                              Text("Have a nice day",style: GoogleFonts.poppins(textStyle: TextStyle(color: Colors.white, fontSize: width*0.03)),)
                                            ],
                                          ),
                                        )
                                        
                                      ],
                                    ),
                                  )
                              ],
                            ),
                      
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      ),
    );
  }
}