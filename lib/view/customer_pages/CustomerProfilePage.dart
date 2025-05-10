import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomerProfilePage extends StatelessWidget {
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? address;

  const CustomerProfilePage({
    super.key,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.address,
  });

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate to the login page after successful logout
      Navigator.pushReplacementNamed(
        context,
        '/login',
      ); // Replace '/login' with your actual login route
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error logging out: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Profile', style: GoogleFonts.poppins()),
        actions: [
          // Logout Button in the AppBar
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.exit_to_app, color: Colors.white),
              onPressed: () => _logout(context),
              tooltip: 'Logout',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Attractive Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade800],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    fullName ?? 'Guest User',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (email != null)
                    Text(
                      email!,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Profile Details Section
            Text(
              'Account Details',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 15),
            _buildProfileDetail(
              Icons.person,
              'Full Name',
              fullName ?? 'Not Available',
            ),
            const SizedBox(height: 15),
            _buildProfileDetail(Icons.email, 'Email', email ?? 'Not Available'),
            const SizedBox(height: 15),
            _buildProfileDetail(
              Icons.phone,
              'Phone Number',
              phoneNumber ?? 'Not Available',
            ),
            const SizedBox(height: 15),
            _buildProfileDetail(
              Icons.location_on,
              'Address',
              address ?? 'Not Available',
            ),

            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Add logic for editing profile
                  print('Edit Profile Pressed');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Edit Profile',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: OutlinedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.exit_to_app),
                label: Text(
                  'Logout',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: Colors.red.shade700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red.shade700),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetail(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(icon, color: Colors.blue.shade600),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
        ),
        const Divider(color: Colors.grey),
      ],
    );
  }
}
