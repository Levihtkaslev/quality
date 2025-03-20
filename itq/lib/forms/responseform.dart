// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:itq/statics.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'dart:convert';
// ignore: unused_import
import 'package:neumorphic_button/neumorphic_button.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class resform extends StatefulWidget {

  final String ticketid;

  const resform({super.key, required this.ticketid});

  @override
  State<resform> createState() => _resformState();
}

//*******************************************************Variables****************************************************

class _resformState extends State<resform> {
  String explanation = '';
  String causes = '';
  bool isprevented = false;
  String? notprereason;
  String futurepreaction = '';
  String immediate ='';
  List<String> actiontype = [];
  String resofimple = '';
  String capa = '';

//**********************************************************Submit Response*************************************** */



    void showQuickAlert(BuildContext context) {
  QuickAlert.show(
    context: context,
    type: QuickAlertType.success,
    title: 'Success!',
    text: 'Hey! Your Response has been',
    confirmBtnText: 'Submitted!',
    onConfirmBtnTap: () {
      Navigator.of(context).pop();
    },
  );
}


//**************************************************Confirmation Dialog******************************************* */

void Confirmation(){
  showDialog(context: context, 
    builder: (BuildContext context){
      double height = MediaQuery.of(context).size.height;
        double width = MediaQuery.of(context).size.width;
      return AlertDialog(
        title: Text("Submit response"),
        content: Text("Are you sure want to response?"),
        actions: [
          TextButton(
             style: TextButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 245, 54, 70), // Background color
                  foregroundColor: Colors.white, // Text color
                  padding: EdgeInsets.symmetric(horizontal: width*0.01, vertical: width*0.01), // Padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                    side: BorderSide(color: Colors.transparent, width: 2), // Border
                  ),
                  shadowColor: Colors.blueGrey, // Shadow color
                  elevation: 5, // Shadow elevation
                ),
            onPressed: (){
            
                Navigator.of(context).pop();
              
          }, child: Text("Cancel")),
          TextButton(
             style: TextButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 158, 137), 
                  foregroundColor: Colors.white, 
                  padding: EdgeInsets.symmetric(horizontal: width*0.01, vertical: width*0.01),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), 
                    side: BorderSide(color: Colors.transparent, width: 2), 
                  ),
                  shadowColor: Colors.blueGrey, 
                  elevation: 5, 
                ),
              child: Text('Respond'),
              onPressed: () async{
                Navigator.of(context).pop();
                await submitresponse(); 
                
              },
            ),
            
        ],
      );
    });
}



    Future<void> submitresponse() async {
    final response = await http.post(
      Uri.parse('$backendurl/response'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'reqformid': widget.ticketid,
        'explanation': explanation,
        'causes': causes,
        'isprevented': isprevented,
        'notprereason': notprereason,
        'futurepreaction': futurepreaction,
        'immediate' : immediate,
        'actiontype': actiontype,
        'resofimple': resofimple,
        'capa': capa,
      }),
    );
    if (response.statusCode == 201) {
      Navigator.pop(context);
      print("Response Submitted");
    } else {
      print("Failed to submit response");
    }
  }

//*********************************************************Interface**************************************************** */

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20),)),
        iconTheme: IconThemeData(color: Colors.white), 
        backgroundColor:const Color.fromARGB(255, 9, 176, 241),
        title: Padding(
        padding:EdgeInsets.only(bottom: width*0.2, top: width*0.2, left: width*0.02),
        child: Text("Submit response",style: GoogleFonts.poppins(color: Colors.white, fontSize: width*0.06),),
      ),),
      
      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(width*0.03),
            child: SingleChildScrollView(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                        
                  //**************************************Explanation*************************************** */
                    Text("Explanation", style: GoogleFonts.poppins(fontSize: width*0.03)),
                    Padding(
                      padding: EdgeInsets.only(bottom: width*0.04, top:width*0.03  ),
                      child: TextField(
                        minLines: 1,
                        maxLines: null,
                        style: GoogleFonts.poppins(fontSize: width*0.03, color: Colors.grey),
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(hintText: "Explanation", border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),focusedBorder: OutlineInputBorder(
                                    
                            borderSide: const BorderSide(
                              color: Colors.green, // Border color when focused
                            
                            ),
                          ),),
                        onChanged: (value) => explanation = value,
                      ),
                    ),
                        
                  //****************************************Causes***************************************** */
                    Text("What is the Possible Causes", style: GoogleFonts.poppins(fontSize: width*0.03)),
                    Padding(
                      padding: EdgeInsets.only(bottom: width*0.04, top:width*0.03  ),
                      child: TextField(
                        minLines: 1,
                        maxLines: null,
                        style: GoogleFonts.poppins(fontSize: width*0.03, color: Colors.grey),
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(hintText: "Causes", border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),focusedBorder: OutlineInputBorder(
                                    
                            borderSide: const BorderSide(
                              color: Colors.green, // Border color when focused
                            
                            ),
                          ),),
                        onChanged: (value) => causes = value,
                      ),
                    ),
                        
                  //****************************************Prevented*************************************** */
                        
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Is it prevented?', style: GoogleFonts.poppins(fontSize: width*0.03),),
                        SizedBox(height: width*0.03,),
                        Row(children: [
                          Radio(
                        value: true, 
                        groupValue: isprevented, 
                        onChanged: (value) {
                          setState(() {
                            isprevented = value as bool;
                            if (!isprevented) notprereason = null;
                          });
                        }
                        ),
                        Text("Yes",style: GoogleFonts.poppins(color: Colors.green),),
                        ],),
                        Row(children: [Radio(
                        value: false, 
                        groupValue: isprevented, 
                        onChanged: (value) {
                          setState(() {
                            isprevented = value as bool;
                          });
                        }
                        ),
                        Text("No",style: GoogleFonts.poppins(color: Colors.red),),],),
                        SizedBox(height: width*0.03,),
                      ],
                    ),
                        
                  //**************************************If yes allow to enter details*************************************** */
                        
                    if (isprevented)
                      
                      Padding(
                        padding: EdgeInsets.only(bottom: width*0.04, top:width*0.01  ),
                        child: TextField(
                          minLines: 1,
                              maxLines: null,
                              style: GoogleFonts.poppins(fontSize: width*0.03, color: Colors.grey),
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(hintText: "Why not prevented", border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),focusedBorder: OutlineInputBorder(
                                          
                                  borderSide: const BorderSide(
                                    color: Colors.green, // Border color when focused
                                  
                                  ),
                                ),),
                          onChanged: (value) => notprereason = value,
                        ),
                      ),
                        
                  //***********************************************Action Taken*************************************** */
                      Text("Immediate Action Taken", style: GoogleFonts.poppins(fontSize: width*0.03)),
                      Padding(
                        padding: EdgeInsets.only(bottom: width*0.04, top:width*0.03  ),
                        child: TextField(
                          minLines: 1,
                            maxLines: null,
                            style: GoogleFonts.poppins(fontSize: width*0.03, color: Colors.grey),
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(hintText: "Action Taken", border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),focusedBorder: OutlineInputBorder(
                                        
                                borderSide: const BorderSide(
                                  color: Colors.green, // Border color when focused
                                
                                ),
                              ),),
                          onChanged: (value) => futurepreaction = value,
                        ),
                      ),
                      Text("Type Of Action", style: GoogleFonts.poppins(fontSize: width*0.03)),
        
                                Container(
                                  margin: EdgeInsets.only(bottom: width*0.04, top: width*0.02),
                                  padding: EdgeInsets.all(width*0.02),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15))  , // Adding a shadow
                      color: Color.fromARGB(255, 254, 244, 255), 
            
             boxShadow: [
              // Dark shadow for bottom-right
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: Offset(-5, -5),
                blurRadius: 10,
                spreadRadius: -5,
              ),
              // Light shadow for top-left
              BoxShadow(
                color: const Color.fromARGB(255, 163, 163, 163).withOpacity(0.7),
                offset: Offset(5, 5),
                blurRadius: 10,
                spreadRadius: -5,
              ),
            ],
                      ),
                                  child: Wrap(
                                    
                                                      children: [
                                                        CheckboxListTile(
                                                          title: Text("Technical Skill Development"),
                                                          value: actiontype.contains("Technical Skill Development"),
                                                          onChanged: (isSelected) {
                                                            setState(() {
                                                              isSelected!
                                    ? actiontype.add("Technical Skill Development")
                                    : actiontype.remove("Technical Skill Development");
                                                            });
                                                          },
                                                        ),
                                                        CheckboxListTile(
                                                          title: Text("Soft Skill Development"),
                                                          value: actiontype.contains("Soft Skill Development"),
                                                          onChanged: (isSelected) {
                                                            setState(() {
                                                              isSelected!
                                    ? actiontype.add("Soft Skill Development")
                                    : actiontype.remove("Soft Skill Development");
                                                            });
                                                          },
                                                        ),
                                                        CheckboxListTile(
                                                          title: Text("Verification"),
                                                          value: actiontype.contains("Verification"),
                                                          onChanged: (isSelected) {
                                                            setState(() {
                                                              isSelected!
                                    ? actiontype.add("Verification")
                                    : actiontype.remove("Verification");
                                                            });
                                                          },
                                                        ),
                                                        CheckboxListTile(
                                                          title: Text("Escalation"),
                                                          value: actiontype.contains("Escalation"),
                                                          onChanged: (isSelected) {
                                                            setState(() {
                                                              isSelected!
                                    ? actiontype.add("Escalation")
                                    : actiontype.remove("Escalation");
                                                            });
                                                          },
                                                        ),
                                                        CheckboxListTile(
                                                          title: Text("Policy change"),
                                                          value: actiontype.contains("Policy change"),
                                                          onChanged: (isSelected) {
                                                            setState(() {
                                                              isSelected!
                                    ? actiontype.add("Policy change")
                                    : actiontype.remove("Policy change");
                                                            });
                                                          },
                                                        ),
                                                        CheckboxListTile(
                                                          title: Text("Process Change"),
                                                          value: actiontype.contains("Process Change"),
                                                          onChanged: (isSelected) {
                                                            setState(() {
                                                              isSelected!
                                    ? actiontype.add("Process Change")
                                    : actiontype.remove("Process Change");
                                                            });
                                                          },
                                                        ),
                                                        CheckboxListTile(
                                                          title: Text("Recruitment"),
                                                          value: actiontype.contains("Recruitment"),
                                                          onChanged: (isSelected) {
                                                            setState(() {
                                                              isSelected!
                                    ? actiontype.add("Recruitment")
                                    : actiontype.remove("Recruitment");
                                                            });
                                                          },
                                                        ),
                                                        CheckboxListTile(
                                                          title: Text("Regular Equipment check"),
                                                          value: actiontype.contains("Regular Equipment check"),
                                                          onChanged: (isSelected) {
                                                            setState(() {
                                                              isSelected!
                                    ? actiontype.add("Regular Equipment check")
                                    : actiontype.remove("Regular Equipment check");
                                                            });
                                                          },
                                                        ),
                                                        
                                                      ],
                                                    ),
                                ),
                        
                  //**************************************Immediate*************************************** */
                    Text("Immediate Action Taken", style: GoogleFonts.poppins(fontSize: width*0.03)), 
                    Padding(
                      padding: EdgeInsets.only(bottom: width*0.04, top:width*0.03  ),
                      child: TextField(
                         minLines: 1,
                            maxLines: null,
                            style: GoogleFonts.poppins(fontSize: width*0.03, color: Colors.grey),
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(hintText: "Action Taken", border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),focusedBorder: OutlineInputBorder(
                                        
                                borderSide: const BorderSide(
                                  color: Colors.green, // Border color when focused
                                
                                ),
                              ),),
                        onChanged: (value) => immediate = value,
                      ),
                    ),
                        
                  //**************************************Responsible*************************************** */
                    Text("Who is responsible for implementing preventive Action", style: GoogleFonts.poppins(fontSize: width*0.03)),
                    Padding(
                      padding:EdgeInsets.only(bottom: width*0.04, top:width*0.03  ),
                      child: TextField(
                         minLines: 1,
                            maxLines: null,
                            style: GoogleFonts.poppins(fontSize: width*0.03, color: Colors.grey),
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(hintText: "Action Taken", border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),focusedBorder: OutlineInputBorder(
                                        
                                borderSide: const BorderSide(
                                  color: Colors.green, // Border color when focused
                                
                                ),
                              ),),
                        onChanged: (value) => resofimple = value,
                      ),
                    ),
                    
                  //******************************************Done by*************************************** */
                    Text("CAPA Done by", style: GoogleFonts.poppins(fontSize: width*0.03)),
                    Padding(
                      padding: EdgeInsets.only(bottom: width*0.04, top:width*0.03  ),
                      child: TextField(
                         minLines: 1,
                            maxLines: null,
                            style: GoogleFonts.poppins(fontSize: width*0.03, color: Colors.grey),
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(hintText: "Action Taken", border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),focusedBorder: OutlineInputBorder(
                                        
                                borderSide: const BorderSide(
                                  color: Colors.green, // Border color when focused
                                
                                ),
                              ),),
                        onChanged: (value) => capa = value,
                      ),
                    ),
                        
                  //**************************************Confirmation*************************************** */
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
                        child: Text('Submit Response'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}