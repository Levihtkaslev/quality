import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/Url_launcher.dart';
import 'login.dart';

class Qhomepage extends StatefulWidget {

  final String departmentname;
  final String locationname;
  final String targetno;
  final String targetname;
  final String targetpos;
 const Qhomepage({super.key, required this.targetpos,required this.targetno, required this.departmentname, required this.locationname, required this.targetname});
  
  @override
  State<Qhomepage> createState() => _QhomepageState();
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



class _QhomepageState extends State<Qhomepage> {

  void Confirmation() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // ignore: unused_local_variable
      double height = MediaQuery.of(context).size.height;
        double width = MediaQuery.of(context).size.width;
      return AlertDialog(
        title: Text("Confirmation"),
        content: Text("Are you sure you want to Logout?"),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 247, 34, 34),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: width*0.01, vertical: width*0.01), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), 
                    side: BorderSide(color: Colors.transparent, width: 2),
                  ),
                  shadowColor: Colors.blueGrey, 
                  elevation: 5, 
                ),
            onPressed: () {
              Navigator.of(context).pop(); 
            },
            child: Text("No"),
          ),
          


          TextButton(
            style: TextButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 4, 172, 158), 
                  foregroundColor: Colors.white, 
                  padding: EdgeInsets.symmetric(horizontal: width*0.01, vertical: width*0.01), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), 
                    side: BorderSide(color: Colors.transparent, width: 2),
                  ),
                  shadowColor: Colors.blueGrey, 
                  elevation: 5, 
                ),
              child: Text('Log out'),
              onPressed: () async{
                 Navigator.of(context).pop();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.remove('auth_token'); 
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => awloginpage()),);
                
                
                
              },
            ),



        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    // ignore: unused_local_variable
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
                onPressed: () => Navigator.of(context).pop(false), 
                child: Text('No', style: GoogleFonts.poppins(color: Colors.red)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true), 
                child: Text('Yes', style: GoogleFonts.poppins(color: Colors.green)),
              ),
            ],
          );
        },
      );
      return shouldExit; 
    },
      child: Scaffold(
        appBar: AppBar(title: Padding(
          padding: EdgeInsets.only(bottom: width*0.2, top: width*0.2, left: width*0.02),
          child: Text('Profile',style: GoogleFonts.poppins(color: Colors.white, fontSize: width*0.06),),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20),)),
          iconTheme: IconThemeData(color: Colors.white), 
          backgroundColor: const Color.fromARGB(255, 9, 176, 241),
        ),
        
        body: GestureDetector(
          onTap: (){
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: SingleChildScrollView(
            child: Padding(
              padding:  EdgeInsets.all(width*0.03),
              child: SingleChildScrollView(
                child: Container(
                   padding: EdgeInsets.all(width*0.06),
                      decoration: BoxDecoration( color: const Color.fromARGB(255, 254, 244, 255), border: Border.all(width: width*0.003, color:  Colors.transparent,),borderRadius: BorderRadius.circular(12), boxShadow: [ // Adding a shadow
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5), 
                            spreadRadius: 3, 
                            blurRadius: 7,   
                            offset: const Offset(0, 3),
                          ),
                        ],),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: width*0.03,),
                      Text("Name", style: GoogleFonts.poppins(textStyle:TextStyle(  fontSize: width*0.04, color: const Color.fromARGB(255, 85, 84, 84) ) ),),
                      Padding(
                        padding:  EdgeInsets.only(bottom:width*0.03),
                        child: Text(widget.targetname, style: GoogleFonts.poppins(textStyle:TextStyle(  fontSize: width*0.03,color: Colors.green ) ),),
                      ),
                      
                      Text("Position",style: GoogleFonts.poppins(textStyle:TextStyle( fontSize: width*0.04 ,color: const Color.fromARGB(255, 85, 84, 84)) )),
                      Padding(
                        padding:  EdgeInsets.only(bottom:width*0.03),
                        child: Text(widget.targetpos, style: GoogleFonts.poppins(textStyle:TextStyle(  fontSize: width*0.03 ,color: Colors.green )) ),),
                      
                      
                      Text("Department",style: GoogleFonts.poppins(textStyle:TextStyle( fontSize: width*0.04,color: const Color.fromARGB(255, 85, 84, 84) ) )),
                      Padding(
                        padding:EdgeInsets.only(bottom:width*0.03),
                        child: Text(widget.departmentname, style: GoogleFonts.poppins(textStyle:TextStyle(  fontSize: width*0.03 ,color: Colors.green ) )),
                      ),
                      
                      Text("Location",style: GoogleFonts.poppins(textStyle:TextStyle( fontSize: width*0.04,color: const Color.fromARGB(255, 85, 84, 84) ) )),
                      Padding(
                        padding: EdgeInsets.only(bottom:width*0.03),
                        child: Text(widget.locationname,style: GoogleFonts.poppins(textStyle:TextStyle(  fontSize: width*0.03,color: Colors.green  ) ),),
                      ),
                      
                      Text("Mobie",style: GoogleFonts.poppins(textStyle:TextStyle( fontSize: width*0.04 ,color: const Color.fromARGB(255, 85, 84, 84)) )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom:width*0.03),
                            child: Text(widget.targetno,style: GoogleFonts.poppins(textStyle:TextStyle(  fontSize: width*0.03,color: Colors.green  ) ),),
                          ),
                          // ElevatedButton.icon(onPressed: () => makecall(widget.targetno),  icon: Icon(Icons.phone), label: Text("Call"),
                          //  )
                        ],
                      ),
                      
                  
                      Center(
                        child: ElevatedButton(
                         style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 167, 167),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: width*0.03, vertical: width*0.04),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),
                        shadowColor: Colors.grey,
                        elevation: 5,
                      ),
                          onPressed: Confirmation,
                          child: Text('Log out'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// ***********************************************************END OF LOGIN AND OUT PROCESS************************************************************************