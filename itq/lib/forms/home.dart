import 'package:flutter/material.dart';
import 'package:itq/forms/bfortick.dart';
import '../log/logout.dart';
import 'homee.dart';
import 'receivedticket.dart';
import 'submmitedticket.dart';

class home_page extends StatefulWidget {

  final String departmentid;
  final String locationid;
  final String departmentname;
  final String locationname;
  final String targetno;
  final String targetname;
  final String targetpos;

  const home_page({super.key, required this.targetpos,required this.targetno, required this.departmentid, required this.locationid, required this.departmentname, required this.locationname, required this.targetname});

  @override
  State<home_page> createState() => _home_pageState();
}

class _home_pageState extends State<home_page> {
  
   int _currentIndex = 0;
   final PageController _pageController = PageController();
   late final List<Widget> _pages;
  @override

  void initState(){
    super.initState();
    _pages = [
      homeee(
        targetname : widget.targetname,
      ),
      receivedtick(
        departmentid: widget.departmentid,
        departmentname: widget.departmentname,
        locationid: widget.locationid,
      ),
      bforee(
        departmentid: widget.departmentid,
        locationid: widget.locationid,
        departmentname: widget.departmentname,
        locationname: widget.locationname,
        targetno: widget.targetno,
        targetname: widget.targetname,
      ),
      submittedtick(
        departmentid: widget.departmentid,
        departmentname: widget.departmentname,
        locationid: widget.locationid,
      ),
      Qhomepage(
        departmentname: widget.departmentname,
        locationname: widget.locationname,
        targetno: widget.targetno,
        targetname: widget.targetname,
        targetpos : widget.targetpos,
      )
    ];
  }
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

     _pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
  }

  Widget build(BuildContext context) {
    return Scaffold(
  body: PageView(
     controller: _pageController,
    children: _pages,onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },),
  
  bottomNavigationBar: Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
      gradient: LinearGradient(
        colors: [Color(0xFF2EC9DC), Color(0xFF0B6BE9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          spreadRadius: 1,
          blurRadius: 10,
          offset: Offset(0, -2),
        ),
      ],
    ),
    child: BottomNavigationBar(
      backgroundColor: Colors.transparent, 
      elevation: 0, 
      currentIndex: _currentIndex, 
      onTap: _onTabTapped,
      selectedItemColor: const Color.fromARGB(255, 16, 173, 235), 
      unselectedItemColor: const Color.fromARGB(255, 255, 255, 255), 
      
      showSelectedLabels: false,
      showUnselectedLabels: true,
      
      type: BottomNavigationBarType.fixed,
      
      selectedLabelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      unselectedLabelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.normal,
        fontSize: 10,
      ),
      items: [
        BottomNavigationBarItem(icon: _buildIcon(Icons.home_rounded, 0),label: 'Home',),
        BottomNavigationBarItem(icon: _buildIcon(Icons.emoji_people_rounded,1),label: 'Inbox',),
        BottomNavigationBarItem(icon: _buildIcon(Icons.touch_app ,2),label: 'Rise',),
        BottomNavigationBarItem(icon: _buildIcon(Icons.add_to_home_screen,3),label: 'Sent',),
        BottomNavigationBarItem(icon: _buildIcon(Icons.contacts_rounded,4),label: 'Profile',),
      ],
    ),
  ),
);




  }

  Widget _buildIcon(IconData icon, int index) {
  return Container(
    decoration: BoxDecoration(
      color: _currentIndex == index
          ? Color.fromARGB(255, 255, 255, 255) // Change color when selected
          : Colors.transparent, // Transparent for unselected items
      borderRadius: BorderRadius.circular(8),
    ),
    padding: EdgeInsets.all(8), // Padding for the icon
    child: Icon(
      icon,
      color: _currentIndex == index ? const Color.fromARGB(255, 21, 193, 236) : const Color.fromARGB(255, 255, 255, 255),
    ),
  );
}
}
