import 'package:barber/view/BarberDetailsPage.dart';
import 'package:barber/view/barber_pages.dart/BarberRegistrationPage.dart';
import 'package:barber/view/BookingPage.dart';
import 'package:barber/view/CreateBookingPage.dart';
import 'package:barber/view/UserTypeSelectionPage.dart';
import 'package:barber/view/barber_pages.dart/BarberShopsPage.dart';
import 'package:barber/view/barber_pages.dart/BarberStatsPage.dart';
import 'package:barber/view/barber_pages.dart/ManageServicesPage.dart';
import 'package:barber/view/barber_pages.dart/barberOwnerHomePage.dart';
import 'package:barber/view/barber_pages.dart/RegisterBarberEmail.dart';
import 'package:barber/view/customer_home.dart';
import 'package:barber/view/customer_pages/CustomerProfilePage.dart';
import 'package:barber/view/customer_pages/NearbyBarbersPage.dart';
import 'package:barber/view/customer_pages/customer_details.dart';
import 'package:barber/view/customer_pages/customer_main_page.dart';
import 'package:barber/view/customer_pages/customer_signin.dart';
import 'package:barber/view/login_page.dart';
import 'package:barber/view/profile_page.dart';
import 'package:barber/view/registerUser.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyDIFN3S14EMn9fWKF5XRXa-5T95slCWHzc",
      appId: "1:738264923480:android:10b0d55d9edf694547b92d",
      messagingSenderId: "738264923480",
      projectId: "barber-a09aa",
      storageBucket: "barber-a09aa.firebasestorage.app",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home:
          //  ManageServicesPage(),
          //  BarberStatsPage(),
          //  BarberShopsPage(),
          // CreateBookingPage(selectedBarber: selectedBarber)
          //  Registerbarberemail(),
          // NearbyBarbersPage(),
          //  CustomerMainPage(),
          //  CustomerProfilePage(),
          // CustomerDetails(email: 'email', password: 'password'),
          // RegisterCustomer(),
          //  UserTypeSelectionPage(),
          // BarberRegistrationPage(email: 'kayoko11@g.com', password: 'Qq1234'),
          // BarberDetailsPage(barberEmail: 'bosspima@gmail.com'),
          BarberOwnerHomePage(),
      // Registeruser(),
      // BarberBookingPage(),
      // BarberOwnerHomePage(),
      // CustomerHomePage(),
      // ProfilePage(isBarber: false),
      // LoginPage(),
    );
  }
}
