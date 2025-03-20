import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:itq/statics.dart';
import 'ticketdetails.dart';



class receivedtick extends StatefulWidget {
  final String departmentid;
  final String departmentname;
  final String locationid;

   const receivedtick({
    Key? key,
    required this.departmentid,
    required this.departmentname,
    required this.locationid,
  }) : super(key: key);
  

  @override
  State<receivedtick> createState() => _receivedtickState();
}

class _receivedtickState extends State<receivedtick>with SingleTickerProviderStateMixin {

  List forms = [];
  List pendingforms = [];
  List compltedform = [];
  String? selectedDepartment;
  
  DateTime? fromDate;
  DateTime? toDate; 
  String searchQuery = '';
  bool isSearching = false;

  late TabController _tabController;
  @override

  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchreceivedforms();
  }

  @override
    void dispose() {
    _tabController.dispose();
    super.dispose();
  }

//******************************************Submitted Form Listing*************************************************** */

 Future<void> fetchreceivedforms() async {
  try {
    final response = await http.get(Uri.parse("$backendurl/formsreceived/${widget.departmentname}"));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        forms = data.isNotEmpty ? data : [];
        applyFilters();
      });
    } else {
      print('Failed to load received forms. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching received forms: $e');
  }
}

//**********************************************************Filters*************************************************** */

void applyFilters() {
  setState(() {
    DateTime startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);
    DateTime endOfDay(DateTime date) => DateTime(date.year, date.month, date.day, 23, 59, 59);

    final fromDateFilter = fromDate != null ? startOfDay(fromDate!) : null;
    final toDateFilter = toDate != null ? endOfDay(toDate!) : null;

    pendingforms = forms.where((form) {
      // Date filter
      DateTime createdTime = _parseDate(form['createdtime']);
      bool matchesDateFilter = (fromDateFilter == null || createdTime.isAfter(fromDateFilter.subtract(Duration(seconds: 1)))) &&
                               (toDateFilter == null || createdTime.isBefore(toDateFilter.add(Duration(seconds: 1))));
      // Department filter
      bool matchesDepartmentFilter = selectedDepartment == null || form['fromdepartment'] == selectedDepartment;
      // Subject Filter
      bool matchesSubjectFilter = form['subject'].toLowerCase().contains(searchQuery.toLowerCase());
      //Show result
      return form['status'] == 'Pending' && matchesDateFilter && matchesDepartmentFilter && matchesSubjectFilter;
    }).toList();

    compltedform = forms.where((form) {
      // Date filter
      DateTime createdTime = _parseDate(form['createdtime']);
      bool matchesDateFilter = (fromDateFilter == null || createdTime.isAfter(fromDateFilter.subtract(Duration(seconds: 1)))) &&
                               (toDateFilter == null || createdTime.isBefore(toDateFilter.add(Duration(seconds: 1))));
      // Department filter
      bool matchesDepartmentFilter = selectedDepartment == null || form['fromdepartment'] == selectedDepartment;
      // Subject filter
      bool matchesSubjectFilter = form['subject'].toLowerCase().contains(searchQuery.toLowerCase());
      //Show result
      return form['status'] == 'Completed' && matchesDateFilter && matchesDepartmentFilter && matchesSubjectFilter;
    }).toList();
  });
}

//******************************************************Date filter process*********************************************************

DateTime _parseDate(String dateString) {
  try {
    // Try parsing the date using a custom format
    return DateFormat("MM/dd/yyyy, h:mm:ss a").parse(dateString);
  } catch (e) {
    print('Error parsing date: $e');
    return DateTime.now();  // Fallback to the current date if parsing fails
  }
}
  Future<void> pickDateRange(BuildContext context) async {
    final DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
    );

    if (pickedRange != null) {
      setState(() {
        fromDate = pickedRange.start;
        toDate = pickedRange.end;
      });
      applyFilters();
    }
  }

//******************************************************Department*********************************************************

Future<void> pickDepartment(BuildContext context) async {
  try {
    final response = await http.get(Uri.parse("$backendurl/departments?locationid=${widget.locationid}"));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final List<String> departments = data.map((dept) => dept['departmentname'] as String).toList();
      final selected = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text('Select Department'),
            children: departments.map((dept) {
              return SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, dept);
                },
                child: Text(dept),
              );
            }).toList(),
          );
        },
      );

      if (selected != null) {
        setState(() {
          selectedDepartment = selected;
        });
        applyFilters();  
      }
    } else {
      print('Failed to load departments. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching departments: $e');
  }
}

//******************************************************FIlter dialog********************************************************

Future<void> openfilterdialog() async{
  showDialog(context: context, 
  builder: (BuildContext context){
    return AlertDialog(
      title: Text('Filter Options'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(onPressed: ()=> pickDateRange(context), child: Text('Select Date Range'),
          ),
          ElevatedButton(onPressed: ()=> pickDepartment(context), child: Text('Select Department'),
              ),
        ],
      ),
      actions: [
        TextButton(onPressed: (){
          Navigator.pop(context);
        }, child: Text("Close"))
      ],
    );
  });
}

//******************************************************Subject search state*******************************************************

void startsearch(){
  setState(() {
    isSearching = true;
  });
}

void stopsearch() {
  setState(() {
    isSearching = false;
    searchQuery = '';
    applyFilters();
  });
}

//***************************************************************Opene checking*********************************************************

Future<void> markasopened(String formid) async {
  try {
    final response = await http.put(
      Uri.parse("$backendurl/opened/$formid"),
      body: jsonEncode({'opened': true}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      fetchreceivedforms();
    } else {
      print("Failed to update form status. Status code: ${response.statusCode}");
    }
  } catch (e) {
    print("Error updating form status: $e");
  }
}

  //***************************************************************Interface*********************************************************

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
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
      return shouldExit; 
    },
      child: Scaffold(
      
        // ************************************************App bar searching**********************************************************
      
        appBar: AppBar(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20),)),
          iconTheme: IconThemeData(color: Colors.white), 
          backgroundColor: const Color.fromARGB(255, 9, 176, 241),
          title: 
          Padding(
            padding:  EdgeInsets.only(bottom: width*0.2, top: width*0.2, left: width*0.02),
            child: isSearching?TextField(
              
              autofocus: true,
              decoration: InputDecoration(
                      hintText: 'Search by subject...',
                      border: InputBorder.none,
                      hintStyle: GoogleFonts.poppins(color: Colors.white, fontSize: width*0.03),
                    ),
                    onChanged: (value){
                      setState(() {
                        searchQuery = value;
                        applyFilters();
                      });
                    },
            ):Text("Received Forms",style: GoogleFonts.poppins(color: Colors.white, fontSize: width*0.06),),
          ),
          actions: [
            isSearching?IconButton(onPressed: stopsearch, icon: Icon(Icons.clear)): IconButton(
                    icon: Icon(Icons.search),
                    onPressed: startsearch,
                  ),
            IconButton(
              icon: Icon(Icons.filter_alt),
              onPressed: openfilterdialog,
            ),
          ],
          bottom: PreferredSize(preferredSize: Size.fromHeight(width*0.1), child: TabBar(controller: _tabController,
          tabs: [
            Tab(text: "Pending"),
            Tab(text: "Completed",)],
            labelColor: const Color.fromARGB(255, 255, 255, 255),
            indicatorColor: Colors.white,
          ),
          ),
        ),
      
      // ****************************************************Body Interface********************************************************
        body: GestureDetector(
          onTap: (){
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Column(
            children: [
          
               //***********************************Pending Complete Tab***************************** */
          
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     ElevatedButton(onPressed: () {
              //       setState(() {
              //         pendingselected = true; 
              //       });
              //     }, child: Text("Pending")),
              //     SizedBox(width: 10,),
              //      ElevatedButton(
              //       onPressed: () {
              //         setState(() {
              //           pendingselected = false;
              //         });
              //       },
              //       child: Text('Completed'),
              //     ),
              //   ],
              // ),
          
            //*****************************************Listing  Forms******************************** */
          
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Color.fromRGBO(251, 247, 252, 1), borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10, offset: Offset(0, 4)
                  )]),
          
                  child : TabBarView(
                    controller: _tabController,
                    children: [
                      buildformlist(pendingforms, Colors.red),
                      buildformlist(compltedform, Colors.green),
                    ]
                  )
                 
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  
  Widget buildformlist(forms,Color itemColor) {
    
    return ListView.builder(
            
            itemCount: forms.length,
            itemBuilder: (context, index){
              final eachform = forms[index];
              bool isunopened = eachform['opened'] == null || !eachform['opened'];
              double height = MediaQuery.of(context).size.height;
              double width = MediaQuery.of(context).size.width;
              return Container(
                margin: EdgeInsets.all(width*0.03),
                padding: EdgeInsets.all(width*0.009),
                decoration: BoxDecoration(color: const Color.fromARGB(255, 253, 249, 252), 
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(
                  color: const Color.fromARGB(255, 61, 61, 61).withOpacity(0.3),
                  offset: Offset(0, 3),
                  blurRadius: 5
                )],
                border: Border.all(
                  color: Colors.transparent,
                )
                ),

                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  leading: Icon(Icons.receipt_long, color: Colors.green,),
                  title: Row(
                    children: [
                      Padding(
                        padding:  EdgeInsets.only(bottom: height*0.01),
                        child: Text(eachform['subject'],maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: width*0.03, color: itemColor),),
                      ),
                     
                      if(isunopened)
                      Container(
                         height: width*0.04, width: width*0.2,
                         
                         decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Unopened',
                            style: TextStyle(
                              color: Colors.white,
                              
                            ),
                          ),
                      )
                    ],
                  ),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('From: ${eachform['fromdepartment']}',maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: width*0.03),),
                      SizedBox(height: width*0.01,),
                      Text('Date: ${eachform['createdtime']}',maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: width*0.03),),
                    ],
                  ),
                  trailing: Icon(Icons.arrow_circle_right, color: itemColor,),
                  onTap: () async {
                    await markasopened(eachform['_id']);
                    final refresh = await Navigator.push(
                      context, MaterialPageRoute(builder: (context) => formdeepview(formid : eachform['_id'], receivedform: 1, formStatus: eachform['status']),
                      
                     )
                    );
                    if (refresh == true){
                      fetchreceivedforms();
                    }
                  },
                ),
              );
            }
           );
  }
}