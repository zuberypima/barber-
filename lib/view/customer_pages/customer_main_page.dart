import 'package:barber/view/customer_home.dart';
import 'package:barber/view/customer_pages/CustomerProfilePage.dart';
import 'package:flutter/material.dart';

class CustomerMainPage extends StatefulWidget {
  const CustomerMainPage({super.key});

  @override
  State<CustomerMainPage> createState() => _CustomerMainPageState();
}

class _CustomerMainPageState extends State<CustomerMainPage> {
  int _selectedScreen = 0;
  List<Widget> _screenList = [CustomerHomePage(), CustomerProfilePage()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screenList.elementAt(_selectedScreen),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          setState(() {
            _selectedScreen = value;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.spoke_outlined),
            label: 'My Booking',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
