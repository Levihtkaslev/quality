import 'dart:ui';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// ignore: unused_import
import 'package:itq/forms/homee.dart';
import 'package:itq/statics.dart';
import 'package:quickalert/quickalert.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';


class risetick extends StatefulWidget {
  
  final String departmentid;
  final String locationid;
  final String departmentname;
  final String locationname;
  final String targetno;
  final String targetname;

  const risetick({required this.targetname, super.key, required this.targetno, required this.departmentid, required  this.locationid, required this.departmentname, required this.locationname});
  @override
  State<risetick> createState() => _risetickState();
}

class _risetickState extends State<risetick> {

  String? todepartmentid;
  String? todepartment;
  String subject = '';
  String description = '';
  String clinical = "no";
  String operatinal = "no";
  String patimpact = "no";
  String finimpact = "no";
  String severity = "";
  List<String> personsinvolved = [];
  List departments = [];

  @override
  void initState(){
    super.initState();
    getdepartments();
  }

  void showQuickAlert(BuildContext context) {
  QuickAlert.show(
    context: context,
    type: QuickAlertType.success,
    title: 'Success!',
    text: 'Hey! Your Ticket has been ',
    confirmBtnText: 'Raised!',
    onConfirmBtnTap: () {
      Navigator.of(context).pop();
    },
  );
}

  // ****************************************************Department Fetching***************************************************

   Future<void> getdepartments() async {
    final response = await http.get(Uri.parse('$backendurl/departments?locationid=${widget.locationid}'));
    if (response.statusCode == 200) {
      setState(() {
        departments = jsonDecode(response.body);
        print('Departments data: $departments');
      });
    } else {
      print('Failed to load departments');
    }
  }






  // ****************************************************Confirmation Dialog***************************************************

void Confirmation() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
        // ignore: unused_local_variable
        double height = MediaQuery.of(context).size.height;
        double width = MediaQuery.of(context).size.width;
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        
        child: Container(
          color: Colors.white.withOpacity(0.2),
          child: AlertDialog(
            title: Text("Confirmation"),
            content: Text("Are you sure you want to Raise?"),
            actions: [
              TextButton(
                 style: TextButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 231, 30, 47), // Background color
                  foregroundColor: Colors.white, // Text color
                  padding: EdgeInsets.symmetric(horizontal: width*0.01, vertical: width*0.01), // Padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                    side: BorderSide(color: Colors.transparent, width: 2), // Border
                  ),
                  shadowColor: Colors.blueGrey, // Shadow color
                  elevation: 5, // Shadow elevation
                ),
                onPressed: () {
                  Navigator.of(context).pop(); 
                },
                child: Text("Cancel"),
              ),
              
          
          
              TextButton(
                 style: TextButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 155, 134), // Background color
                  foregroundColor: Colors.white, // Text color
                  padding: EdgeInsets.symmetric(horizontal: width*0.01, vertical: width*0.01), // Padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                    side: BorderSide(color: Colors.transparent, width: 2), // Border
                  ),
                  shadowColor: Colors.blueGrey, // Shadow color
                  elevation: 5, // Shadow elevation
                ),
                  child: Text('Rise'),
                  onPressed: () async{
                     Navigator.of(context).pop();
                    await submitform(); 
                    // showQuickAlert(context);
                    
                    
                  },
                ),
          
          
          
            ],
          ),
        ),
      );
    },
  );
}




  // *********************************************************Ticket Posting***************************************************


  Future<void> submitform() async {
    final response = await http.post(
      Uri.parse('$backendurl/form'),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode({
        'fromdepartment': widget.departmentname,
        'todepartmentid' : widget.departmentid,
        'todepartment': todepartment,
        'locationid' : widget.locationid,
        'locationname' : widget.locationname,
        'subject': subject,
        'description': description,
        'clinical': clinical,
        'operatinal' : operatinal,
        'patimpact' : patimpact,
        'finimpact' : finimpact,
        'severity' : severity,
        'personsinvolved': personsinvolved,
        'targetno' : widget.targetno,
        'targetname' : widget.targetname
        }
         
      ),
    );
 
    if (response.statusCode == 201) {
      Navigator.pop(context);
      print(widget.locationname); 
      print(todepartment);
      print(subject);
      print(description);
      print(clinical);
      print(widget.departmentid);
      print(personsinvolved);
      } else {
      print('Failed to submit form');
    }
  }
  
//******************************************************Interface******************************************* */

@override
  Widget build(BuildContext context) {
    print('Current selected department: $todepartment');
    print('Departments loaded: ${departments.length} items');
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20),)),
        title: Padding(
        padding: EdgeInsets.only(bottom: width*0.2, top: width*0.2, left: width*0.02),
        child: Text("Rise Ticket",style: GoogleFonts.poppins(color: Colors.white, fontSize: width*0.06),),
      ),
      iconTheme: IconThemeData(color: Colors.white), 
      backgroundColor: const Color.fromARGB(255, 9, 176, 241),),
      body:GestureDetector(
        onTap: (){
          
          
          FocusScope.of(context).requestFocus(FocusNode());
        
        },
        child: SingleChildScrollView(
          
          child: Padding(padding: EdgeInsets.all(width*0.03),
        
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
                  
                    //******************************************Choose to deppartment******************************* */
                  
                  Text("To", style:GoogleFonts.poppins(fontSize: width*0.05),),
              
                  
                 Container(
                  margin: EdgeInsets.only(top: width*0.02, bottom: width*0.05),
                   child: DropdownSearch<String>(
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            hintText: 'Search Department',
                          ),
                        ),
                      ),
                      items: departments.map<String>((eachdepartment) {
                        return eachdepartment['departmentname'];
                      }).toList(),
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          
                          
                          contentPadding: EdgeInsets.symmetric(horizontal: width*0.02, vertical: width*0.001),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),),
                          
                          focusedBorder: OutlineInputBorder(
                                       
                                          borderSide: BorderSide(color:  Colors.green, width: 2),
                                        ),
                        ),
                      ),
                   dropdownBuilder: (context, selectedItem) {
                    return Text(
                      selectedItem ?? "Select a location", 
                      style: TextStyle(
                        color: const Color.fromARGB(255, 37, 36, 36), 
                        fontSize: width * 0.03,
                      ),
                    );
                  },
                      onChanged: (value) {
                        setState(() {
                          todepartment = value;
                          
                        });
                      },
                      selectedItem: todepartment,
                    ),
                 ),
              
                  
                    
                   //*************************************************Subject****************************************** */
                  Text("Subject", style: GoogleFonts.poppins(fontSize: width*0.04)),
                    Padding(
                      padding:  EdgeInsets.only(bottom: width*0.03, top:width*0.03  ),
                      child: TextField(
                        minLines: 1,
                        maxLines: null,
                        style: GoogleFonts.poppins(fontSize: width*0.03, color: Colors.grey),
                        keyboardType: TextInputType.multiline,
                        
                        decoration: InputDecoration( hintText: "Subject", border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),focusedBorder: OutlineInputBorder(
                                      
                            borderSide: const BorderSide(
                              color: Colors.green, // Border color when focused
                            
                            ),
                          ),),
                        onChanged: (value) {
                          setState(() {
                            subject = value;
                          });
                        },
                      ),
                    ),
                  
                  //*************************************************Description****************************************** */
                  Text("Description", style: GoogleFonts.poppins(fontSize: width*0.04),),
                    Padding(
                      padding:EdgeInsets.only(bottom: width*0.03, top:width*0.03  ),
                      child: TextField(
                        style: GoogleFonts.poppins(fontSize: width*0.03, color: Colors.grey),
                        minLines: 1,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration:  InputDecoration(hintText: "Enter Description",  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),focusedBorder: OutlineInputBorder(
                                      
                                      borderSide: const BorderSide(
                                        color: Colors.green, // Border color when focused
                                       
                                      ),
                                    ),),
                        onChanged: (value) {
                          setState(() {
                            description = value;
                          });
                        },
                      ),
                    ),
                  
                  //*************************************************Clinical****************************************** */
                  
                   Container(
                    margin: EdgeInsets.only(top: width*0.02, bottom: width*0.05),
                     child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                          Container(
                            margin: EdgeInsets.only(bottom: width*0.02),
                            child: Text("Clinical Imapact" ,style: GoogleFonts.poppins(fontSize: width*0.04))),
                          RadioMenuButton(value: "Yes", groupValue: clinical, onChanged: (value){
                            setState(() {
                              clinical = value!;
                            });
                          },child:Text("Yes", style: GoogleFonts.poppins(color:Colors.green),)),
                                   
                          RadioMenuButton(value: "No", groupValue: clinical, onChanged: (value){
                            setState(() {
                              clinical = value!;
                            });
                          },child:Text("No", style: GoogleFonts.poppins(color:Colors.red),)),
                        ],
                      ),
                   ),
                  
                  //********************************************Operational Impact************************************* */
                  
                    Container(
                      margin: EdgeInsets.only(top: width*0.02, bottom: width*0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: width*0.02),
                            child: Text("Operational Impact", style: GoogleFonts.poppins(fontSize: width*0.04))),
                          RadioMenuButton(value: "Low", groupValue: operatinal, onChanged: (value){
                            setState(() {
                              operatinal = value!;
                            });
                          },child: Text("Low",style: GoogleFonts.poppins(color:const Color.fromARGB(255, 24, 199, 184)),),),
                                    
                          RadioMenuButton(value: "Low to Medium", groupValue: operatinal, onChanged: (value){
                            setState(() {
                              operatinal = value!;
                            },);
                          },  child: Text("Low to Medium",style: GoogleFonts.poppins(color:const Color.fromARGB(255, 16, 197, 182)),),),
                                    
                          RadioMenuButton(value: "Medium", groupValue: operatinal, onChanged: (value){
                            setState(() {
                              operatinal = value!;
                            });
                          },child: Text("Medium",style: GoogleFonts.poppins(color:const Color.fromARGB(255, 226, 128, 15)),),),
                                    
                          RadioMenuButton(value: "Medium to High", groupValue: operatinal, onChanged: (value){
                            setState(() {
                              operatinal = value!;
                            });
                          },child: Text("Medium to High",style: GoogleFonts.poppins(color:const Color.fromARGB(255, 255, 95, 56)),),),
                                    
                          RadioMenuButton(value: "High", groupValue: operatinal, onChanged: (value){
                            setState(() {
                              operatinal = value!;
                            });
                          },child: Text("High",style: GoogleFonts.poppins(color:Colors.red),),),
                        ],
                      ),
                    ),
                  
                  //********************************************Patient Impact************************************* */
                  
                    Container(
                      margin: EdgeInsets.only(top: width*0.02, bottom: width*0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: width*0.02),
                            child: Text("Patient Impact", style: TextStyle(fontSize: width*0.04))),
                          RadioMenuButton(value: "Low", groupValue: patimpact, onChanged: (value){
                            setState(() {
                              patimpact = value!;
                            });
                          },child: Text("Low",style: GoogleFonts.poppins(color:const Color.fromARGB(255, 24, 199, 184)),),),
                                    
                          RadioMenuButton(value: "Low to Medium", groupValue: patimpact, onChanged: (value){
                            setState(() {
                              patimpact = value!;
                            });
                          },child: Text("Low to Medium",style: GoogleFonts.poppins(color:const Color.fromARGB(255, 16, 197, 182))),),
                                    
                          RadioMenuButton(value: "Medium", groupValue: patimpact, onChanged: (value){
                            setState(() {
                              patimpact = value!;
                            });
                          },child:Text("Medium",style: GoogleFonts.poppins(color:const Color.fromARGB(255, 226, 128, 15)),)),
                                    
                          RadioMenuButton(value: "Medium to High", groupValue: patimpact, onChanged: (value){
                            setState(() {
                              patimpact = value!;
                            });
                          },child: Text("Medium to High",style: GoogleFonts.poppins(color:const Color.fromARGB(255, 219, 104, 26))),),
                                    
                          RadioMenuButton(value: "High", groupValue: patimpact, onChanged: (value){
                            setState(() {
                              patimpact = value!;
                            });
                          },child: Text("High",style: GoogleFonts.poppins(color:Colors.red),),),
                        ],
                      ),
                    ),
                  
                    //********************************************Finance Impact************************************* */
                  
                    Container(
                      margin: EdgeInsets.only(top: width*0.02, bottom: width*0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: width*0.02),
                            child: Text("Financil impact", style: TextStyle(fontSize: width*0.04))),
                          RadioMenuButton(value: "Yes", groupValue: finimpact, onChanged: (value){
                            setState(() {
                              finimpact = value!;
                            });
                          },child: Text("Yes",style: GoogleFonts.poppins(color:Colors.green)),),
                                    
                          RadioMenuButton(value: "No", groupValue: finimpact, onChanged: (value){
                            setState(() {
                              finimpact = value!;
                            });
                          },child: Text("No",style: GoogleFonts.poppins(color:Colors.red)),),
                        ],
                      ),
                    ),
                  
                    //*****************************************Severiety of Problem*********************************** */
                    
                    Container(
                      margin: EdgeInsets.only(top: width*0.02, bottom: width*0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: width*0.02),
                            child: Text("Severity of Problem", style: TextStyle(fontSize: width*0.04))),
                          RadioMenuButton(value: "Mild", groupValue: severity, onChanged: (value){
                            setState(() {
                              severity = value!;
                            });
                          },child: Text("Mild",style: GoogleFonts.poppins(color:const Color.fromARGB(255, 24, 199, 184)),),),
                                    
                          RadioMenuButton(value: "Moderate", groupValue: severity, onChanged: (value){
                            setState(() {
                              severity = value!;
                            });
                          },child: Text("Moderate",style: GoogleFonts.poppins(color:const Color.fromARGB(255, 16, 197, 182))),),
                                    
                          RadioMenuButton(value: "Severe", groupValue: severity, onChanged: (value){
                            setState(() {
                              severity = value!;
                            });
                          },child: Text("Severe",style: GoogleFonts.poppins(color:const Color.fromARGB(255, 226, 128, 15)),),),
                                    
                          RadioMenuButton(value: "Critical", groupValue: severity, onChanged: (value){
                            setState(() {
                              severity = value!;
                            });
                          },child: Text("Critical",style: GoogleFonts.poppins(color:Colors.red),),),
                        ],
                      ),
                    ),
                  
                    //******************************************Persons involved************************************ */
                  
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Persons Involved:", style: GoogleFonts.poppins(fontSize: width*0.04)),
        
                    ElevatedButton(onPressed: 
                    () {
                      showDialog(context: context, 
                      builder: (BuildContext context){
                        TextEditingController person =TextEditingController();
                        return AlertDialog(
                          title: Text("Add Person"),
                          content: TextField(
                            controller: person,
                                decoration: InputDecoration(labelText: 'Person Name'),
                          ),
                          actions: [
                            TextButton(onPressed: (){
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'),),
                  
                            TextButton(onPressed: () {
                              setState(() {
                                personsinvolved.add(person.text);
                              });
                              Navigator.of(context).pop();
                            }, child: Text("Add"))
                          ],
                        );
                      });
                    }, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 4, 203, 230),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),
                      shadowColor: Colors.grey,
                      elevation: 5,
                    ),
                    child: Text('Add Person Involved'),),
                      ],
                    ),
                  
                    
              
                    Container(
                      height: width*0.2,
                      child: ListView.builder(itemCount: personsinvolved.length
                   ,itemBuilder: (context,index){
                    return ListTile(
                      title: Text(personsinvolved[index]),
                    );
                   })),
                   
                   
                   
                    
                  //********************************************Confirmation************************************* */  
                  Container(
                    margin: EdgeInsets.only(right: width*0.1, left:width*0.3),
                    
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
                        child: Text('Submit Form'),
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