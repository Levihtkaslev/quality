import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:itq/statics.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../forms/home.dart';
import 'package:dropdown_search/dropdown_search.dart';


// ignore: camel_case_types
class awloginpage extends StatefulWidget {
  const awloginpage({super.key});
  @override
  State<awloginpage> createState() => _awloginpageState();
}


// ****************************************Variables***************************************
// ignore: camel_case_types
class _awloginpageState extends State<awloginpage> {
    String? setlocation;
    String? setdepartment;
    String? setdepartmentname;
    String? password;
    String? departmentid;
    String? locationid;
    String? departmentname;
    String? locationname;
    String? phonenum;
    String? targetname;
    String? targetpos;
    List<Map<String, String>> locations = [];
    List<Map<String, String>> departments = [];
    bool _isLoading = true; 
    bool isLoggedIn = false;
    bool _obscureText = true;


  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    getlocations();
  }

Future<void> _checkLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  setState(() {
    isLoggedIn = prefs.getString('auth_token') != null;
    if (isLoggedIn) {
      departmentid = prefs.getString('departmentid');
      locationid = prefs.getString('locationid');
      departmentname = prefs.getString('departmentname');
      locationname = prefs.getString('locationname');
      phonenum = prefs.getString('targetno');
      targetname = prefs.getString('targetname');
      targetpos = prefs.getString('targetpos');
    }
  });
}


// ***********************************Location Fetching*************************************

 Future<void> getlocations() async {
      try {
        final response = await http.get(Uri.parse('$backendurl/locations'));

        if (response.statusCode == 200) {
          setState(() {
            
            locations = List<Map<String, String>>.from(
              json.decode(response.body).map((loc) => {
                'locationid': loc['_id'].toString(), 
                'locationname': loc['locationname'].toString(),  
              })
            );
            _isLoading = false;  
          });
         }
      } catch (e) {
        print('Error fetching locations: $e');
        setState(() {
          _isLoading = false;
        });
      }
     }

// ***********************************Department Fetching***********************************

Future<void> getdepartments(String locationid) async {
  try {
    final response = await http.get(Uri.parse('$backendurl/departments?locationid=$locationid'));

    if (response.statusCode == 200) {
      print('Department information: ${response.body}');
      setState(() {
        departments = List<Map<String, String>>.from(
          json.decode(response.body).map((dept) => {
            'departmentid': dept['_id'].toString(), 
            'departmentname': dept['departmentname'].toString(),
          }),
        );
      });
    } else {
      print('Failed to load departments, status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error loading departments: $e');
  }
}

// *******************************Log in Process And fetching*********************************

Future<void> login() async {
  if (setlocation == null || setdepartment == null || password == null || password!.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields!')));
    return;
  }
  
  try {
    final response = await http.post(
      Uri.parse('$backendurl/applogin'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'locationid': setlocation!,
        '_id': setdepartment!,
        'password': password!,
      }),
    );


    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final token = responseData['token'];
      final departmentid = responseData['getdepartment']['_id'];
      final locationid = responseData['getdepartment']['locationid'];
      final departmentname = responseData['getdepartment']['departmentname'];
      final locationname = responseData['getlocation']['locationname'];
      final phonenum = responseData['getdepartment']['targetno'];
      final targetname = responseData['getdepartment']['targetname'];
      final targetpos = responseData['getdepartment']['targetpos'];



      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token); 
      await prefs.setString('departmentid', departmentid);
      await prefs.setString('locationid', locationid);
      await prefs.setString('departmentname', departmentname);
      await prefs.setString('locationname', locationname);
      await prefs.setString('targetno', phonenum);
      await prefs.setString('targetname', targetname);
      await prefs.setString('targetpos', targetpos);
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => home_page(departmentid: departmentid, locationid : locationid, departmentname : departmentname, locationname : locationname, targetno : phonenum, targetname : targetname, targetpos : targetpos)),
      );
    } else {
      setState(() {
        isLoggedIn = false;
      });
      print('Login failed: ${response.statusCode} - ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed! ${response.body}')));
    }
  } catch (e) {
    setState(() {
        isLoggedIn = false;
      });
    print('Error while login: $e');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred!')));
  }
}


// ***************************************Log in Interface Starts here**************************

@override
Widget build(BuildContext context) {
  double height = MediaQuery.of(context).size.height;
  double width = MediaQuery.of(context).size.width;

  return Scaffold(
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : isLoggedIn
            ? home_page(
                departmentid: departmentid ?? '',
                locationid: locationid ?? '',
                departmentname: departmentname ?? '',
                locationname: locationname ?? '',
                targetno: phonenum ?? '',
                targetname: targetname ?? '',
                targetpos: targetpos ?? '',
              )
            : loginform(height, width),
  );
}


  Container loginform(double height, double width) {
    return Container(
            height: height,
            width: width,
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, colors: [
              Color.fromRGBO(35, 196, 218, 1),
              Color.fromRGBO(64, 204, 223, 1),
              Color.fromRGBO(95, 223, 240, 1),
              Color.fromRGBO(113, 229, 245, 1),
              ]  )
            ),
            
            child:  SingleChildScrollView(
              child: Container(
                height: height,
                width: width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
                    SizedBox(height: height*0.1,),
                      Padding(
                      padding: EdgeInsets.all(width*0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Login", style: GoogleFonts.poppins(color: Colors.white, fontSize: width*0.09 ,)),
                          SizedBox(height: width*0.01,),
                          Text("Welcome here", style: GoogleFonts.poppins(color: Colors.white, fontSize: width*0.04 ),),
                          SizedBox(height: height*0.09),
                              ],
                            ),
                          ),
                
                          SizedBox(height: width*0.2),
                
                    Expanded(child: Container(
                      decoration: BoxDecoration(color: Colors.white,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(width*0.1), topRight: Radius.circular(width*0.1)),
                      boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 168, 170, 170).withOpacity(0.5), 
                        spreadRadius: 5, 
                        blurRadius: 5, 
                        offset: Offset(2, 3), 
                      ),
                    ],
                      ),
                      child: Padding(
                        padding : EdgeInsets.only(top: width*0.1, right: width*0.1, left: width*0.1),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                
                              Text("Location",style: GoogleFonts.poppins(fontSize: width*0.04, color: Color.fromRGBO(46, 201, 220, 1), )),
                              SizedBox(height: width*0.04,),
                              Container(
                               
                                decoration: BoxDecoration( 
                                  
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2), 
                                        spreadRadius: 2, 
                                        blurRadius: 5, 
                                        offset: Offset(0, 4), 
                                      ),
                                    ],),
                                child: DropdownSearch<Map<String, String>>(
                                  popupProps: PopupProps.menu(
                                    showSearchBox: true, 
                                    searchFieldProps: TextFieldProps(
                                      decoration: InputDecoration(
                                        
                                        hintText: "Type to search",
                                         fillColor: const Color.fromARGB(255, 254, 248, 255),filled: true,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(100), 
                                          borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)), 
                                        ),
                                        
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(100),
                                          borderSide: BorderSide(color: const Color.fromARGB(255, 202, 202, 202), width: 1.5), 
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(100),
                                          borderSide: BorderSide(color: const Color.fromARGB(255, 143, 143, 143), width: 1.5),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(horizontal: width*0.02, vertical: width*0.02), 
                                        suffixIcon: Icon(Icons.search, color: const Color.fromARGB(255, 138, 138, 138)), 
                                      ),
                                      style: GoogleFonts.poppins(fontSize: width*0.03), 
                                    ),
                                    menuProps: MenuProps(
                                      borderRadius: BorderRadius.circular(width*0.03), 
                                    
                                     backgroundColor: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.9),
                                      elevation: 4, 
                                    ),
                                  ),
                                
                                
                                  items: locations,
                                  
                                   
                                  itemAsString: (Map<String, String> item) => item['locationname']!, 
                                  dropdownDecoratorProps: DropDownDecoratorProps(
                                    
                                    dropdownSearchDecoration: InputDecoration(
                                      prefixIcon:  Icon(Icons.add_location, color: Colors.white),
                                      hintText: "Location",
                                      
                                      
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(100), 
                                        borderSide: BorderSide(color: Colors.grey), 
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(100),
                                        borderSide: BorderSide(color:  Colors.white, width: 2),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(100),
                                        borderSide: BorderSide(color:  Colors.transparent, width: 1.5),
                                      ),  
                                      contentPadding: EdgeInsets.symmetric(horizontal: width*0.09, vertical: width*0.02), 
                                      suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.white),
                                       fillColor: Color.fromRGBO(46, 201, 220, 1),filled: true, 
                                    ),
                                  ),
                                
                                    dropdownBuilder: (context, selectedItem) {
                                      return Text(
                                        selectedItem?['locationname'] ?? "Select a location",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white, // Set text color for selected field
                                          fontSize: width*0.03,
                                        ),
                                      );
                                    },
                                  
                                  dropdownButtonProps: DropdownButtonProps(
                                    splashRadius: 24, 
                                  ),
                                
                                  onChanged: (Map<String, String>? selectedLocation) {
                                    setState(() {
                                      setlocation = selectedLocation?['locationid'];
                                      if (setlocation != null) {
                                        getdepartments(setlocation!);
                                      }
                                    });
                                  },
                                ),
                              ),
                
                
                              SizedBox(height: height*0.04,),
                    
                            Text("Department",style: GoogleFonts.poppins(fontSize: width*0.04, color: Color.fromRGBO(46, 201, 220, 1),)),
                            // ***********************************Department Dropdown*************************************
                            SizedBox(height: width*0.04,),
                              Container(
                                decoration: BoxDecoration( 
                                  
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2), // Shadow color
                                        spreadRadius: 2, // Spread radius
                                        blurRadius: 5, // Blur radius
                                        offset: Offset(0, 4), // Position of the shadow
                                      ),
                                    ],),
                                child: DropdownSearch<Map<String, String>>(
                                  popupProps: PopupProps.menu(
                                    showSearchBox: true, 
                                    searchFieldProps: TextFieldProps(
                                      decoration: InputDecoration(
                                        
                                        hintText: "Type to search",
                                         fillColor: const Color.fromARGB(255, 254, 248, 255),filled: true,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(100), 
                                          borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)), 
                                        ),
                                        
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(100),
                                          borderSide: BorderSide(color: const Color.fromARGB(255, 202, 202, 202), width: 1.5), 
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(100),
                                          borderSide: BorderSide(color: const Color.fromARGB(255, 143, 143, 143), width: 1.5),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(horizontal: width*0.03, vertical: width*0.03), 
                                        suffixIcon: Icon(Icons.search, color: const Color.fromARGB(255, 138, 138, 138)), 
                                      ),
                                      style: GoogleFonts.poppins(fontSize: width*0.03), 
                                    ),
                                    menuProps: MenuProps(
                                      borderRadius: BorderRadius.circular(width*0.03), 
                                    
                                     backgroundColor: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.9),
                                      elevation: 4, 
                                    ),
                                  ),
                                
                                  items: departments,
                                
                                   dropdownBuilder: (context, selectedItem) {
                                      return Text(
                                        selectedItem?['departmentname'] ?? "Choose a Department",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white, // Set text color for selected field
                                          fontSize: width*0.03,
                                        ),
                                      );
                                    },
                                  
                                   // List of departments
                                  itemAsString: (Map<String, String> item) => item['departmentname']!, // Display department name
                                  dropdownDecoratorProps: DropDownDecoratorProps(
                                    dropdownSearchDecoration: InputDecoration(
                                      prefixIcon:  Icon(Icons.folder_shared_rounded, color: Colors.white),
                                      hintText: "Department",
                                      
                                      
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(100), 
                                        borderSide: BorderSide(color: Colors.grey), 
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(100),
                                         borderSide: BorderSide(color:  Colors.white, width: 2),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(100),
                                        borderSide: BorderSide(color:  Colors.transparent, width: 1.5),
                                      ),  
                                      contentPadding: EdgeInsets.symmetric(horizontal: width*0.03, vertical: width*0.03), 
                                      suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.white),
                                       fillColor: Color.fromRGBO(46, 201, 220, 1),filled: true, 
                                    ),
                                  ),
                                  onChanged: (Map<String, String>? selectedDepartment) {
                                    setState(() {
                                      setdepartment = selectedDepartment?['departmentid'];
                                      setdepartmentname = selectedDepartment?['departmentname'];
                                    });
                                  },
                                ),
                              ),
                
                              SizedBox(height: height*0.05,),
                    
                            // ****************************************Password Area *************************************
                    
                            Container(
                              
                              decoration: BoxDecoration( 
                                  
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2), // Shadow color
                                        spreadRadius: 2, // Spread radius
                                        blurRadius: 5, // Blur radius
                                        offset: Offset(0, 4), // Position of the shadow
                                      ),
                                    ],),
                              child: TextField(
                                obscureText: _obscureText,
                                cursorColor: Colors.white,
                                decoration: InputDecoration(
                                  
                                  hintText: 'Password',
                                  
                                  hintStyle: GoogleFonts.poppins(
                                    color: const Color.fromARGB(255, 255, 255, 255),
                                  ),
                                  filled: true,
                                  fillColor: Color.fromRGBO(46, 201, 220, 1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(100),
                                    borderSide: BorderSide.none, // Removes the outline border
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(100),
                                    borderSide: BorderSide(color: Color.fromRGBO(46, 201, 220, 1), width: 2), // Adds focus effect
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(100),
                                    borderSide: BorderSide(color: Color.fromRGBO(84, 223, 241, 1),),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureText ? Icons.visibility_off : Icons.visibility,
                                      color: const Color.fromARGB(255, 255, 255, 255), // Icon color
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureText = !_obscureText; // Toggle visibility
                                      });
                                    },
                                  ),
                              
                                  prefixIcon: Icon(Icons.shield_sharp,color: const Color.fromARGB(255, 255, 255, 255), ),
                                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    password = value;
                                  });
                                },
                                style: GoogleFonts.poppins(
                                  color:  Color.fromARGB(255, 255, 255, 255), // Input text color
                                  fontSize: 16,
                                ),
                              ),
                            ),
                
                    
                              SizedBox(height: height*0.06,),
                    
                            // *****************************************Log in******************************************
                    
                              Container(
                                width: width*1,
                                child: ElevatedButton(
                                  onPressed: setlocation != null && setdepartment != null && (password?.isNotEmpty ?? false)
                                      ? login
                                      : null,
                                       style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.white, backgroundColor: Colors.green, // Text color
                                              elevation: 5, // Shadow elevation
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(100), // Rounded corners
                                              ),
                                              padding: EdgeInsets.symmetric(horizontal: height*0.01, vertical: width*0.04), // Padding
                                            ),
                                  child: Text('Login', style: GoogleFonts.poppins()),
                                  
                                ),
                              ),
                            ],
                          ),
                        ),
                    
                    ))
                  
                
                          
                          ],
                          
                        
                ),
              ),
            ),
          );
  }
}



// ***********************************************************END OF LOGIN AND OUT PROCESS************************************************************************