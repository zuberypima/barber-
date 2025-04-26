import 'package:barber/view/BarberDetailsPage.dart';
import 'package:barber/view/BarberRegistrationPage.dart';
import 'package:barber/view/BookingPage.dart';
import 'package:barber/view/CreateBookingPage.dart';
import 'package:barber/view/UserTypeSelectionPage.dart';
import 'package:barber/view/barberOwnerHomePage.dart';
import 'package:barber/view/customer_home.dart';
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
      home: RegisterCustomer(),
      //  UserTypeSelectionPage(),
      // BarberRegistrationPage(email: 'master@g.com', password: 'Qq1234'),
      // BarberDetailsPage(barberEmail: 'zuberypima@gmail.com'),
      // BarberOwnerHomePage(),
      // Registeruser(),
      // BarberBookingPage(),
      // BarberOwnerHomePage(),
      // CustomerHomePage(),
      // ProfilePage(isBarber: false),
      // LoginPage(),
    );
  }
}
