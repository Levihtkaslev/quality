import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:itq/statics.dart';
import 'ticketdetails.dart';

class submittedtick extends StatefulWidget {
  final String departmentid;
  final String departmentname;
  final String locationid;

  const submittedtick({
    Key? key,
    required this.departmentid,
    required this.departmentname,
    required this.locationid,
  }) : super(key: key);

  @override
  State<submittedtick> createState() => _SubmittedTickPageState();
}

class _SubmittedTickPageState extends State<submittedtick>
    with SingleTickerProviderStateMixin {
  List forms = [];
  List pendingForms = [];
  List completedForms = [];
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
    fetchSubmittedForms();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchSubmittedForms() async {
    try {
      final response = await http.get(
        Uri.parse("$backendurl/formsubmitted/${widget.departmentname}"),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          forms = data.isNotEmpty ? data : [];
          applyFilters();
        });
      } else {
        print('Failed to load submitted forms. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching submitted forms: $e');
    }
  }

  void applyFilters() {
    setState(() {
      DateTime startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);
      DateTime endOfDay(DateTime date) => DateTime(date.year, date.month, date.day, 23, 59, 59);

      final fromDateFilter = fromDate != null ? startOfDay(fromDate!) : null;
      final toDateFilter = toDate != null ? endOfDay(toDate!) : null;

      pendingForms = forms.where((form) {
        DateTime createdTime = _parseDate(form['createdtime']);
        bool matchesDateFilter = (fromDateFilter == null || createdTime.isAfter(fromDateFilter.subtract(Duration(seconds: 1)))) &&
            (toDateFilter == null || createdTime.isBefore(toDateFilter.add(Duration(seconds: 1))));
        bool matchesDepartmentFilter = selectedDepartment == null || form['todepartment'] == selectedDepartment;
        bool matchesSubjectFilter = form['subject'].toLowerCase().contains(searchQuery.toLowerCase());

        return form['status'] == 'Pending' && matchesDateFilter && matchesDepartmentFilter && matchesSubjectFilter;
      }).toList();

      completedForms = forms.where((form) {
        DateTime createdTime = _parseDate(form['createdtime']);
        bool matchesDateFilter = (fromDateFilter == null || createdTime.isAfter(fromDateFilter.subtract(Duration(seconds: 1)))) &&
            (toDateFilter == null || createdTime.isBefore(toDateFilter.add(Duration(seconds: 1))));
        bool matchesDepartmentFilter = selectedDepartment == null || form['todepartment'] == selectedDepartment;
        bool matchesSubjectFilter = form['subject'].toLowerCase().contains(searchQuery.toLowerCase());

        return form['status'] == 'Completed' && matchesDateFilter && matchesDepartmentFilter && matchesSubjectFilter;
      }).toList();
    });
  }

  DateTime _parseDate(String dateString) {
    try {
      return DateFormat("MM/dd/yyyy, h:mm:ss a").parse(dateString);
    } catch (e) {
      print('Error parsing date: $e');
      return DateTime.now();
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

  Future<void> pickDepartment(BuildContext context) async {
    try {
      final response = await http.get(
        Uri.parse("$backendurl/departments/${widget.locationid}"),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<String> departments =
            data.map((dept) => dept['departmentname'] as String).toList();
        final selected = await showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: const Text('Select Department'),
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

  Future<void> openFilterDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filter Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () => pickDateRange(context),
                child: const Text('Select Date Range'),
              ),
              ElevatedButton(
                onPressed: () => pickDepartment(context),
                child: const Text('Select Department'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close"),
            )
          ],
        );
      },
    );
  }

  void startSearch() {
    setState(() {
      isSearching = true;
    });
  }

  void stopSearch() {
    setState(() {
      isSearching = false;
      searchQuery = '';
      applyFilters();
    });
  }

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
        appBar: AppBar(
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20),)),
          iconTheme: IconThemeData(color: Colors.white), 
          backgroundColor: const Color.fromARGB(255, 9, 176, 241),
          title: isSearching
              ? Padding(
                padding: EdgeInsets.only(bottom: width*0.2, top: width*0.2, left: width*0.02),
                child: TextField(
                    autofocus: true,
                    decoration:  InputDecoration(
                      hintText: 'Search by subject...',
                      hintStyle: GoogleFonts.poppins(color: Colors.white, fontSize: width*0.06),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                        applyFilters();
                      });
                    },
                  ),
              )
              : Padding(
                padding: EdgeInsets.only(bottom: width*0.2, top: width*0.2, left: width*0.02),
                child:  Text("Submitted Forms", style: GoogleFonts.poppins(color: Colors.white, fontSize: width*0.06),),
              ),
          actions: [
            isSearching
                ? IconButton(
                    onPressed: stopSearch,
                    icon: const Icon(Icons.clear),
                  )
                : IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: startSearch,
                  ),
            IconButton(
              icon: const Icon(Icons.filter_alt),
              onPressed: openFilterDialog,
            ),
          ],
          bottom: PreferredSize(preferredSize: Size.fromHeight(width*0.1), child: TabBar(controller: _tabController, 
          tabs: [
            Tab(text: "Pending"),
            Tab(text: "Completed",)],
          labelColor: const Color.fromARGB(255, 255, 255, 255),
          indicatorColor: Colors.white,
           )
          ),
        ),
      
        body: GestureDetector(
          onTap: (){
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Column(
            children: [
              
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(color:  Color.fromRGBO(251, 247, 252, 1), borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10, offset: Offset(0, 4)
                  )]),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildFormList(pendingForms, Colors.red),
                      _buildFormList(completedForms, Colors.green),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormList( forms,Color itemColor) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    
    return ListView.builder(
      
      itemCount: forms.length,
      itemBuilder: (context, index) {
        final form = forms[index];
        bool isUnopened = form['opened'] == null || !form['opened'];
     
        return Container(
          margin: EdgeInsets.all(width*0.03),
          padding: EdgeInsets.all(width*0.009),
          decoration: BoxDecoration(color: const Color.fromARGB(255, 253, 249, 252), 
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: Offset(0, 3),
            blurRadius: 5
          )],
          border: Border.all(
            color: const Color.fromARGB(255, 206, 207, 207),
          )
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: width*0.02, vertical: 8),
            leading: Icon(Icons.receipt_long, color: Colors.green,),
            title: Row(
              children: [
                Padding(
                  padding:  EdgeInsets.only(bottom: height*0.01),
                  child: Text(form['subject'], maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: width*0.03, color: itemColor)),
                ),
                if (isUnopened)
                  Container(
                    height: width*0.03, width: width*0.03,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    
                  )
              ],
            ),

            
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('From: ${form['fromdepartment']}',maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: width*0.03)),
                SizedBox(height: width*0.01,),
                Text('Date: ${form['createdtime']}',maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: width*0.03)),
              ],
            ),
            trailing: Icon(Icons.arrow_circle_right, color: itemColor,),
            onTap: () async {
              final refresh = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => formdeepview(
                    formid: form['_id'],
                    receivedform: 0,
                    formStatus: form['status'],
                  ),
                ),
              );
              if (refresh == true) {
                fetchSubmittedForms();
              }
            },
          ),
        );
      },
    );
  }
}
