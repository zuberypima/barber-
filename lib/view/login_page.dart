import 'package:barber/constants/constants.dart';
import 'package:barber/services/navigator.dart';
import 'package:barber/view/UserTypeSelectionPage.dart';
import 'package:barber/view/registerUser.dart';
import 'package:barber/widget/customeButton.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image with overlay (same as register page)
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/backgroun.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3),
                  BlendMode.darken,
                ),
              ),
            ),
          ),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              ),
            ),
          ),

          // Content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 80),

                  // App Logo/Title (consistent with register page)
                  Column(
                    children: [
                      Icon(Icons.cut, size: 50, color: Colors.white),
                      SizedBox(height: 10),
                      Text(
                        'THE BARBER',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Premium Grooming Experience',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),

                  // Login Card
                  Card(
                    color: Colors.white.withOpacity(0.9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Column(
                        children: [
                          Text(
                            'Welcome Back',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: mainColor,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Sign in to continue',
                            style: GoogleFonts.poppins(color: Colors.grey[600]),
                          ),
                          SizedBox(height: 30),

                          _textFormFieldOne('Email'),
                          SizedBox(height: 20),
                          _textFormFieldOne('Password'),
                          SizedBox(height: 10),

                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: Text(
                                'Forgot Password?',
                                style: GoogleFonts.poppins(
                                  color: mainColor,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 20),

                          // Login Button
                          Container(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mainColor,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'LOGIN',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 25),

                  // Don't have account section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account?',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () {
                          push_next_page(context, UserTypeSelectionPage());
                        },
                        child: Text(
                          'Register',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            color: mainColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _textFormFieldOne(String label) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: GoogleFonts.poppins(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextFormField(
          obscureText: label == 'Password',
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            border: InputBorder.none,
            filled: false,
            suffixIcon:
                label == 'Password'
                    ? Icon(Icons.visibility_off, color: Colors.grey)
                    : null,
          ),
        ),
      ),
    ],
  );
}
