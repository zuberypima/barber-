import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class QueueManagerPage extends StatefulWidget {
  const QueueManagerPage({super.key});

  @override
  State<QueueManagerPage> createState() => _QueueManagerPageState();
}

class _QueueManagerPageState extends State<QueueManagerPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool _showTodayOnly = true;
  bool _isLoading = true;
  List<Map<String, dynamic>> _bookings = [];

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() => _isLoading = true);
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'User not logged in';
      }

      // Fetch bookings for the barber
      Query<Map<String, dynamic>> query = _firestore
          .collection('Bookings')
          .where('barberEmail', isEqualTo: user.email)
          .where(
            'dateTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()),
          )
          .orderBy('dateTime', descending: false);

      if (_showTodayOnly) {
        final today = DateTime.now();
        final tomorrow = DateTime(today.year, today.month, today.day + 1);
        query = query.where(
          'dateTime',
          isLessThan: Timestamp.fromDate(tomorrow),
        );
      }

      final bookingSnapshot = await query.get().timeout(
        const Duration(seconds: 5),
      );

      // Fetch customer details for each booking
      final bookings = <Map<String, dynamic>>[];
      for (var doc in bookingSnapshot.docs) {
        final data = doc.data();
        data['bookingId'] = doc.id;

        // Fetch customer name
        final customerDoc = await _firestore
            .collection('CustomersDetails')
            .doc(data['customerEmail'])
            .get()
            .timeout(const Duration(seconds: 3));
        data['customerName'] =
            customerDoc.exists
                ? customerDoc.data()!['fullName'] ?? data['customerEmail']
                : data['customerEmail'];

        bookings.add(data);
      }

      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load queue: $e')));
      }
    }
  }

  Future<void> _updateBookingStatus(String bookingId, String newStatus) async {
    try {
      await _firestore
          .collection('Bookings')
          .doc(bookingId)
          .update({'status': newStatus.toLowerCase()})
          .timeout(const Duration(seconds: 5));
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Booking marked as $newStatus')));
      }
      await _fetchBookings(); // Refresh queue
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update status: $e')));
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green.shade600;
      case 'completed':
        return Colors.blue.shade600;
      case 'cancelled':
        return Colors.red.shade600;
      case 'pending':
      default:
        return Colors.orange.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Queue Manager',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.blue.shade800,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Toggle Today/All
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _showTodayOnly ? 'Today\'s Queue' : 'All Upcoming',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue.shade800,
                  ),
                ),
                Switch(
                  value: _showTodayOnly,
                  onChanged: (value) {
                    setState(() => _showTodayOnly = value);
                    _fetchBookings();
                  },
                  activeColor: Colors.blue.shade800,
                ),
              ],
            ),
          ),
          // Queue List
          Expanded(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(color: Colors.blue),
                    )
                    : _bookings.isEmpty
                    ? Center(
                      child: Text(
                        'No bookings in queue',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _bookings.length,
                      itemBuilder: (context, index) {
                        final booking = _bookings[index];
                        final dateTime =
                            (booking['dateTime'] as Timestamp).toDate();
                        final isUrgent =
                            dateTime.difference(DateTime.now()).inHours <= 1 &&
                            booking['status'] != 'completed' &&
                            booking['status'] != 'cancelled';
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side:
                                isUrgent
                                    ? BorderSide(
                                      color: Colors.red.shade600,
                                      width: 2,
                                    )
                                    : BorderSide.none,
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Queue Number and Customer
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Queue #${index + 1}',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                    Chip(
                                      label: Text(
                                        (booking['status'] as String)
                                            .capitalize(),
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                      backgroundColor: _getStatusColor(
                                        booking['status'],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  booking['customerName'],
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  booking['service']['name'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Date and Time
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Colors.blue.shade600,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat(
                                        'EEE, MMM d, y',
                                      ).format(dateTime),
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: Colors.blue.shade600,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat('h:mm a').format(dateTime),
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Special Instructions
                                if (booking['specialInstructions']
                                        ?.isNotEmpty ??
                                    false)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Special Instructions:',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        booking['specialInstructions'],
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                // Action Buttons
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    if (booking['status'] != 'confirmed')
                                      _buildActionButton(
                                        label: 'Confirm',
                                        color: Colors.green.shade600,
                                        onPressed:
                                            () => _updateBookingStatus(
                                              booking['bookingId'],
                                              'confirmed',
                                            ),
                                      ),
                                    if (booking['status'] != 'completed')
                                      _buildActionButton(
                                        label: 'Complete',
                                        color: Colors.blue.shade600,
                                        onPressed:
                                            () => _updateBookingStatus(
                                              booking['bookingId'],
                                              'completed',
                                            ),
                                      ),
                                    if (booking['status'] != 'cancelled')
                                      _buildActionButton(
                                        label: 'Cancel',
                                        color: Colors.red.shade600,
                                        onPressed:
                                            () => _updateBookingStatus(
                                              booking['bookingId'],
                                              'cancelled',
                                            ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return isEmpty ? this : this[0].toUpperCase() + substring(1).toLowerCase();
  }
}
