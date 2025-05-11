import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shimmer/shimmer.dart';

class NearbyBarbersMapPage extends StatefulWidget {
  const NearbyBarbersMapPage({super.key});

  @override
  State<NearbyBarbersMapPage> createState() => _NearbyBarbersMapPageState();
}

class _NearbyBarbersMapPageState extends State<NearbyBarbersMapPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  Position? _currentPosition;
  List<QueryDocumentSnapshot> _barbers = [];
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  Map<String, dynamic>? _selectedBarber;
  String? _errorMessage;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194), // Default: San Francisco
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final user = _auth.currentUser;
      if (user == null) {
        throw 'No user logged in';
      }
      print('User: ${user.email}');

      // Get current location
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled. Please enable them in settings.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permission denied. Please allow location access.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permission permanently denied. Please enable in settings.';
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 10));

      // Fetch barbers
      final barbersSnapshot = await _firestore
          .collection('BarbersDetails')
          .get()
          .timeout(const Duration(seconds: 5));

      print('Barbers snapshot size: ${barbersSnapshot.docs.length}');
      final filteredBarbers =
          barbersSnapshot.docs
              .where(
                (doc) =>
                    doc['location'] != null &&
                    doc['location']['latitude'] != null &&
                    doc['location']['longitude'] != null,
              )
              .toList();
      print('Filtered barbers: ${filteredBarbers.length}');

      setState(() {
        _currentPosition = position;
        _barbers = filteredBarbers;
        _isLoading = false;
      });

      // Update map
      if (_currentPosition != null && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
              ),
              zoom: 14,
            ),
          ),
        );
      }

      // Add markers
      _markers.clear();
      for (var barber in _barbers) {
        final location = barber['location'] as Map<String, dynamic>;
        _markers.add(
          Marker(
            markerId: MarkerId(barber.id),
            position: LatLng(
              location['latitude'] as double,
              location['longitude'] as double,
            ),
            infoWindow: InfoWindow(
              title: barber['fullName'] ?? 'Unknown',
              snippet: barber['address'] ?? 'No address',
              onTap: () {
                setState(() {
                  _selectedBarber = barber.data() as Map<String, dynamic>;
                  _selectedBarber!['email'] = barber.id;
                });
              },
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          ),
        );
      }
      setState(() {}); // Ensure markers update
    } catch (e) {
      print('Error in _fetchData: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load data: $e')));
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
            zoom: 14,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nearby Barbers',
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
      body:
          _isLoading
              ? _buildSkeletonLoader(context)
              : _errorMessage != null || _barbers.isEmpty
              ? _buildEmptyState()
              : Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.blue.shade50, Colors.white],
                      ),
                    ),
                    child: GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: _initialPosition,
                      markers: _markers,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      mapType: MapType.normal,
                    ),
                  ),
                  if (_selectedBarber != null)
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.blue.shade100,
                                    backgroundImage:
                                        _selectedBarber!['profileImageUrl'] !=
                                                null
                                            ? NetworkImage(
                                              _selectedBarber!['profileImageUrl'],
                                            )
                                            : null,
                                    child:
                                        _selectedBarber!['profileImageUrl'] ==
                                                null
                                            ? Icon(
                                              Icons.person,
                                              color: Colors.blue.shade800,
                                              size: 20,
                                            )
                                            : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _selectedBarber!['fullName'] ?? 'Unknown',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _selectedBarber!['address'] ?? 'No address',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.yellow.shade700,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_selectedBarber!['rating']?.toStringAsFixed(1) ?? 'N/A'} (${_selectedBarber!['totalRatings'] ?? 0} reviews)',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/book',
                                      arguments: {
                                        'barberEmail':
                                            _selectedBarber!['email'],
                                      },
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade800,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Book Now',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 80, color: Colors.blue.shade300),
            const SizedBox(height: 16),
            Text(
              _errorMessage != null
                  ? 'Error Loading Barbers'
                  : 'No Barbers Found',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage != null
                  ? _errorMessage!
                  : 'No barbers with location data available. Try again or check your location settings.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade800,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Stack(
          children: [
            Container(
              width: screenWidth,
              height: screenHeight,
              color: Colors.white,
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(width: 150, height: 18, color: Colors.white),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(width: 200, height: 14, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(width: 100, height: 14, color: Colors.white),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 40,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
