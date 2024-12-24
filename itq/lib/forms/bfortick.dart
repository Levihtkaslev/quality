import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'ticketrise.dart';

class bforee extends StatefulWidget {
  final String departmentid;
  final String locationid;
  final String departmentname;
  final String locationname;
  final String targetno;
  final String targetname;

  const bforee({
    required this.targetname,
    super.key,
    required this.targetno,
    required this.departmentid,
    required this.locationid,
    required this.departmentname,
    required this.locationname,
  });

  @override
  State<bforee> createState() => _bforeeState();
}

class _bforeeState extends State<bforee> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    // ignore: unused_local_variable
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20),)),
        iconTheme: IconThemeData(color: Colors.white), 
        backgroundColor: const Color.fromARGB(255, 9, 176, 241),
        title: Padding(
          padding: EdgeInsets.only(bottom: width*0.2, top: width*0.2, left: width*0.02),
          child: Text("Ticket Rise",style: GoogleFonts.poppins(color: Colors.white, fontSize: width*0.06),),
        ),),
      
        body: GestureDetector(
          onTap: (){
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Container(
          padding:  EdgeInsets.all(width*0.03),
          child: Container(
             padding: EdgeInsets.all(width*0.06),
                      decoration: BoxDecoration( color: const Color.fromARGB(255, 254, 244, 255), border: Border.all(width: width*0.003, color:  Colors.transparent,),borderRadius: BorderRadius.circular(12), boxShadow: [ // Adding a shadow
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5), // Shadow color
                            spreadRadius: 3, // How far the shadow spreads
                            blurRadius: 7,   // How blurry the shadow is
                            offset: const Offset(0, 3), // Position of the shadow (x, y)
                          ),
                        ],),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Give Clear input While rising", style: GoogleFonts.poppins(textStyle: TextStyle(fontSize: width*0.03, color: const Color.fromARGB(255, 11, 184, 169))),),
                Image.asset(
                  'assets/rise.png',
                 
                ),
                Container(
                  height: width*0.09,
                    width: width*0.7,
                  child: SlideAction(
                    
                    onSubmit: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => risetick(
                            targetname: widget.targetname,
                            targetno: widget.targetno,
                            departmentid: widget.departmentid,
                            locationid: widget.locationid,
                            departmentname: widget.departmentname,
                            locationname: widget.locationname,
                          ),
                        ),
                      );
                    },
                    text: "Slide to Start Rising",
                    textStyle: GoogleFonts.poppins(fontSize: width*0.03, color: Colors.white),
                    innerColor: Colors.white,
                    outerColor: Colors.blue,
                    sliderButtonIcon: Icon(
                      size: width*0.03,
                      Icons.arrow_forward,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
                ),
        ),
    );
  }
}
