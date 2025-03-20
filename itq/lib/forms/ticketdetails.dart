import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:itq/statics.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';
import "dart:convert";
import 'responseform.dart';
import 'package:url_launcher/Url_launcher.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:printing/printing.dart';

class formdeepview extends StatefulWidget {

  final String formid;
  final int receivedform;
  final String formStatus;

  const formdeepview({super.key, required this.formid, required this.receivedform, required this.formStatus});
  @override
  State<formdeepview> createState() => _formdeepviewState();
}


class _formdeepviewState extends State<formdeepview> {
Map<String, dynamic>? formdetails;
Map<String, dynamic>? responseddetails;
  @override
  void initState() {
    super.initState();
    fetchformdetails(); 
      if(widget.formStatus == "Completed"){
      responsedformdetails();
    }
  }

//***************************************************Submitted forms fetching******************************************** */

 Future<void> fetchformdetails() async {
    final response = await http.get(Uri.parse('$backendurl/formdetails/${widget.formid}'));
    if (response.statusCode == 200) {
      setState(() {
        formdetails = jsonDecode(response.body);
      });
    } else {
      print('Failed to load form details');
    }
  }

//***************************************************Responded forms******************************************************* */

  Future<void> responsedformdetails() async {
    final response = await http.get(Uri.parse('$backendurl/respondiew/${widget.formid}'));
    if (response.statusCode == 200) {
      setState(() {
        responseddetails = jsonDecode(response.body);
      });
    }else {
      print("Failed to load Responsed form details");
    }
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



  Future<void> generatepdf(Map<String, dynamic> formDetails) async {
  if (formdetails == null) {
    print("Form details not loaded yet!");
    return;
  }

  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Container(
          padding: pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(  border: pw.Border.all(width: 2, ),borderRadius: pw.BorderRadius.circular(12), boxShadow: [ // Adding a shadow
                      pw.BoxShadow(
                         // Shadow color
                        spreadRadius: 3, // How far the shadow spreads
                        blurRadius: 7,   // How blurry the shadow is
                        // Position of the shadow (x, y)
                      ),
                    ],),
          child: pw.Column(
            children: [
          pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('From: ${formdetails!['fromdepartment'] ?? 'N/A'}'),
            pw.Text('To: ${formdetails!['todepartment'] ?? 'N/A'}'),
            pw.Text('Location: ${formdetails!['locationname'] ?? 'N/A'}'),
            pw.Text('Subject: ${formdetails!['subject'] ?? 'N/A'}'),
            pw.Text('Description: ${formdetails!['description'] ?? 'N/A'}'),
            pw.Text('Clinical: ${formdetails!['clinical']}'),
            pw.Text("Operational Impact: ${formdetails!['operatinal'] ?? 'N/A'}"),
            pw.Text("Patient Impact: ${formdetails!['patimpact'] ?? 'N/A'}"),
            pw.Text("Financial Impact: ${formdetails!['finimpact'] ?? 'N/A'}"),
            pw.Text("Severity of the Problem: ${formdetails!['severity'] ?? 'N/A'}"),
            pw.Text('Persons Involved: ${(formdetails!['personsinvolved'] ?? []).join(', ')}'),
            pw.Text('Raised at: ${formdetails!['createdtime'] ?? 'N/A'}'),
            if (widget.formStatus == "Completed" && responseddetails != null) ...[
              pw.Text("Explanation: ${responseddetails!['explanation'] ?? ''}"),
              pw.Text("Causes: ${responseddetails!['causes'] ?? ''}"),
              pw.Text("Is Prevented: ${responseddetails!['isprevented'] == true ? "Yes" : "No"}"),
              if (responseddetails!['isprevented'] == true)
                pw.Text("Not Prevented Reason: ${responseddetails!['notprereason'] ?? ''}"),
              pw.Text("Immediate Action Taken: ${responseddetails!['immediate'] ?? ''}"),
              pw.Text("Responsible for Implementation: ${responseddetails!['resofimple'] ?? ''}"),
              pw.Text("Done By: ${responseddetails!['capa'] ?? ''}"),
            ]
          ],
        )
            ]
          )
        );
      },
    ),
  );

  // Save PDF to file or print
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
  final directory = await getTemporaryDirectory();
  final filePath = '${directory.path}/form_${formDetails['formid']}.pdf';
  final file = File(filePath);
  await file.writeAsBytes(await pdf.save());

  // Share the PDF
 Share.shareXFiles([XFile(filePath)], text: 'Here is the form details in PDF.');

}


//**********************************************Submitted Interface******************************************************* */

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
          child: Text("Form view",style: GoogleFonts.poppins(color: Colors.white, fontSize: width*0.06),),
        ),
        actions: [
          IconButton(
      icon: Icon(Icons.picture_as_pdf),
      onPressed: () => generatepdf(formdetails!), 
      tooltip: "Download as PDF",
    ),
    IconButton(
      icon: Icon(Icons.share),
      onPressed: () {
        if (formdetails == null) {
          print("Form details not loaded yet!");
          return;
        }
        generatepdf(formdetails!); 
      },
      tooltip: "Share PDF",
    ),
        ],
      ),
      body: formdetails == null?
      Center(child: CircularProgressIndicator()) : 
      SingleChildScrollView(
        child: Padding(
         padding:  EdgeInsets.all(width*0.03),
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
                  
                   Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Text("From ", style: GoogleFonts.poppins(fontSize: width*0.04),),
                          Padding(
                            padding:  EdgeInsets.only(bottom: width*0.02),
                            child: Text("${formdetails!['fromdepartment'] ?? 'N/A'}",style: GoogleFonts.poppins(fontSize: width*0.03, color: Colors.blue),),
                          ),
                          Text("To",style: GoogleFonts.poppins(fontSize: width*0.04),),
                          Padding(
                            padding:  EdgeInsets.only(bottom: width*0.02),
                            child: Text('${formdetails!['todepartment'] ?? 'N/A'}',style: GoogleFonts.poppins(fontSize: width*0.03, color: Colors.blue),),
                          ),
                          Text("Name",style: GoogleFonts.poppins(fontSize: width*0.03),),
                          Padding(
                            padding:  EdgeInsets.only(bottom: width*0.02),
                            child: Text("${formdetails!['targetname'] ?? 'N/A'}", style: GoogleFonts.poppins(fontSize: width*0.03, color: Colors.blue),),
                          ),
                          ],),
              
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Row(
                            children: [
                              Text("Location: ",style: GoogleFonts.poppins(fontSize: width*0.04)),
                              Text('${formdetails!['locationname'] ?? 'N/A'}',style: GoogleFonts.poppins(fontSize: width*0.03, color: Colors.blue),),
                            ],
                          ),
                           Row(children: [
                            Text("Date: ",style: GoogleFonts.poppins(fontSize: width*0.04)),
                            Text('${formdetails!['createdtime'] }',style: GoogleFonts.poppins(fontSize: width*0.03, color: Colors.blue),),
                           ],),
                           
                        ],)
                      ],
                    ),
                    Text("Subject",style: GoogleFonts.poppins(fontSize: width*0.04)),
                    Padding(
                     padding:  EdgeInsets.only(bottom: width*0.02),
                      child: Text('${formdetails!['subject'] ?? 'N/A'}',style: GoogleFonts.poppins(fontSize: width*0.03, color: Colors.blue),),
                    ),
                    Text("Description",style: GoogleFonts.poppins(fontSize: width*0.04)),
                    Padding(
                      padding:  EdgeInsets.only(bottom: width*0.02),
                      child: Text('${formdetails!['description'] ?? 'N/A'}',style: GoogleFonts.poppins(fontSize: width*0.03, color: Colors.blue),),
                    ),
                    Text("Clinical",style: GoogleFonts.poppins(fontSize: width*0.04)),
                    Padding(
                     padding:  EdgeInsets.only(bottom: width*0.02),
                      child: Text('${formdetails!['clinical']}',style: GoogleFonts.poppins(fontSize: width*0.03, color: Colors.blue),),
                    ),
                    Text("Operational Impact",style: GoogleFonts.poppins(fontSize: width*0.04)),
                    Padding(
                     padding:  EdgeInsets.only(bottom: width*0.02),
                      child: Text("${formdetails!['operatinal']}",style: GoogleFonts.poppins(fontSize: width*0.03, color: Colors.blue),),
                    ),
                    Text("Patient impact",style: GoogleFonts.poppins(fontSize: width*0.04)),
                    Padding(
                      padding:  EdgeInsets.only(bottom: width*0.02),
                      child: Text("${formdetails!['patimpact']}",style: GoogleFonts.poppins(fontSize: width*0.03, color: Colors.blue),),
                    ),
                    Text("Financial Impact",style: GoogleFonts.poppins(fontSize: width*0.04)),
                    Padding(
                      padding:  EdgeInsets.only(bottom: width*0.02),
                      child: Text("${formdetails!['finimpact']}",style: GoogleFonts.poppins(fontSize: width*0.03, color: Colors.blue),),
                    ),
                    Text("Severity Impact",style: GoogleFonts.poppins(fontSize: width*0.04)),
                    Padding(
                      padding:  EdgeInsets.only(bottom: width*0.02),
                      child: Text("${formdetails!['severity']}",style: GoogleFonts.poppins(fontSize: width*0.03, color: Colors.blue),),
                    ),
                    Text("Persons involved",style: GoogleFonts.poppins(fontSize: width*0.04)),
                    Padding(
                      padding:  EdgeInsets.only(bottom: width*0.02),
                      child: Text('${(formdetails!['personsinvolved']?? []).join(', ')}',style: GoogleFonts.poppins(fontSize: width*0.03, color: Colors.blue),),
                    ),
                    
                  
                    // Row(
                    //   children: [
                    //     Expanded(child:Text("Phone : ${formdetails!['targetno'] ?? 'N/A'}"),),
                    //     if(formdetails!['targetno'] != null)
                    //     ElevatedButton.icon(onPressed: () => makecall(formdetails!['targetno']),  icon: Icon(Icons.phone), label: Text("Call"),
                    //     )
                    //   ],
                    // ),
                    ],),
              
                  //*************************Check is pending or cleared********************************* */
              
                  if (widget.formStatus == 'Pending' && widget.receivedform == 1)
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
                        onPressed: () async{
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => resform(ticketid: formdetails!['_id']),
                            ),
                          );
                          Navigator.pop(context, true);
                        },
                        child: Text('Respond'),
                        
                      ),
                    ),
              
                    //****************************Completed will show 2nd Forms************************** */
              
                  if (widget.formStatus == "Completed" && responseddetails != null )(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:  EdgeInsets.only(top: width*0.04, bottom: width*0.03),
                          child: Text("Responsed Form",style: GoogleFonts.poppins(fontSize: width*0.06, color: const Color.fromARGB(255, 1, 148, 136))),
                        ),
                        Text("Responded Time",style: GoogleFonts.poppins(fontSize: width*0.04)),
                        Padding(
                          padding:  EdgeInsets.only(bottom: width*0.02),
                          child: Text('Submitted At: ${responseddetails!['createdtime'] }',style: GoogleFonts.poppins(fontSize: width*0.03,color: const Color.fromARGB(255, 1, 148, 136))),
                        ),
                        Text("Explanation",style: GoogleFonts.poppins(fontSize: width*0.04)),
                        Padding(
                          padding:  EdgeInsets.only(bottom: width*0.02),
                          child: Text("${responseddetails!['explanation'] ?? ""}",style: GoogleFonts.poppins(fontSize: width*0.03, color: const Color.fromARGB(255, 1, 148, 136))),
                        ),
                        Text("Causes",style: GoogleFonts.poppins(fontSize: width*0.04)),
                        Padding(
                          padding:  EdgeInsets.only(bottom: width*0.02),
                          child: Text("${responseddetails!['causes'] ?? ''}",style: GoogleFonts.poppins(fontSize: width*0.03,color: const Color.fromARGB(255, 1, 148, 136))),
                        ),
                        Text("Is prevented",style: GoogleFonts.poppins(fontSize: width*0.04)),
                        Padding(
                          padding:  EdgeInsets.only(bottom: width*0.02),
                          child: Text("${responseddetails!['isprevented'] == true? "Yes" : "No" }",style: GoogleFonts.poppins(fontSize: width*0.03, color: const Color.fromARGB(255, 1, 148, 136))),
                        ),
                        if (responseddetails!['isprevented'] == true)
                            Text("Not prevented Reason",style: GoogleFonts.poppins(fontSize: width*0.04)),
                            Padding(
                             padding:  EdgeInsets.only(bottom: width*0.02),
                              child: Text("${responseddetails!['notprereason'] ?? ''}",style: GoogleFonts.poppins(fontSize: width*0.03, color: const Color.fromARGB(255, 1, 148, 136))),
                            ),
                        Text("Future prevented reason",style: GoogleFonts.poppins(fontSize: width*0.04)),
                        Padding(
                          padding:  EdgeInsets.only(bottom: width*0.02),
                          child: Text("${responseddetails!['futurepreaction'] ?? ''}",style: GoogleFonts.poppins(fontSize: width*0.03, color: const Color.fromARGB(255, 1, 148, 136))),
                        ),
                        Text("Immediate action taken ",style: GoogleFonts.poppins(fontSize: width*0.04)),
                        Padding(
                          padding:  EdgeInsets.only(bottom: width*0.02),
                          child: Text("${responseddetails!['immediate'] ?? ''}",style: GoogleFonts.poppins(fontSize: width*0.03, color: const Color.fromARGB(255, 1, 148, 136))),
                        ),
                        Text("Types of actin taken",style: GoogleFonts.poppins(fontSize: width*0.04)),
                        Padding(
                          padding:  EdgeInsets.only(bottom: width*0.02),
                          child: Text("${responseddetails!['actiontype'] ?? ''}",style: GoogleFonts.poppins(fontSize: width*0.03, color: const Color.fromARGB(255, 1, 148, 136))),
                        ),
                        Text("Responsible for implementation",style: GoogleFonts.poppins(fontSize: width*0.04)),
                        Padding(
                          padding:  EdgeInsets.only(bottom: width*0.02),
                          child: Text("${responseddetails!['resofimple'] ?? ''}",style: GoogleFonts.poppins(fontSize: width*0.03, color: const Color.fromARGB(255, 1, 148, 136))),
                        ),
                        Text("Done by",style: GoogleFonts.poppins(fontSize: width*0.04)),
                        Padding(
                          padding:  EdgeInsets.only(bottom: width*0.02),
                          child: Text("${responseddetails!['capa'] ?? ''}",style: GoogleFonts.poppins(fontSize: width*0.03, color: const Color.fromARGB(255, 1, 148, 136))),
                        ),
                        
                      ],
                    )
                  )
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}



//********************************************END OF RESPOND FORM*************************************************** */