import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

class NearbyBarbersPage extends StatefulWidget {
  const NearbyBarbersPage({super.key});

  @override
  State<NearbyBarbersPage> createState() => _NearbyBarbersPageState();
}

class _NearbyBarbersPageState extends State<NearbyBarbersPage> {
  Position? _currentPosition;
  List<DocumentSnapshot> _nearbyBarbers = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _getCurrentLocationAndFetchBarbers();
  }

  Future<void> _getCurrentLocationAndFetchBarbers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Location services are disabled.';
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permissions are denied.';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage =
              'Location permissions are permanently denied, we cannot request permissions.';
          _isLoading = false;
        });
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition();
      await _fetchNearbyBarbers();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting location: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchNearbyBarbers() async {
    if (_currentPosition == null) {
      return;
    }

    try {
      // Assuming your barber details are stored in a 'BarbersDetails' collection
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('BarbersDetails').get();

      setState(() {
        _nearbyBarbers =
            snapshot.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>?;
              if (data != null &&
                  data.containsKey('latitude') &&
                  data.containsKey('longitude')) {
                final barberLatitude = data['latitude'] as double?;
                final barberLongitude = data['longitude'] as double?;

                if (barberLatitude != null && barberLongitude != null) {
                  final distanceInMeters = Geolocator.distanceBetween(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                    barberLatitude,
                    barberLongitude,
                  );
                  // Define your desired search radius (e.g., 5 kilometers)
                  return distanceInMeters <= 5000; // 5000 meters = 5 km
                }
              }
              return false;
            }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching barbers: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barbers Near You', style: GoogleFonts.poppins()),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              )
              : _nearbyBarbers.isEmpty
              ? Center(
                child: Text(
                  'No barbers found near your location.',
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
              )
              : ListView.builder(
                itemCount: _nearbyBarbers.length,
                itemBuilder: (context, index) {
                  final barberData =
                      _nearbyBarbers[index].data() as Map<String, dynamic>?;

                  if (barberData == null) {
                    return const SizedBox.shrink();
                  }

                  final fullName = barberData['fullName'] as String? ?? 'N/A';
                  final shopName = barberData['shopName'] as String? ?? 'N/A';
                  final profileImageUrl =
                      barberData['profileImageUrl'] as String?;
                  final latitude = barberData['latitude'] as double?;
                  final longitude = barberData['longitude'] as double?;

                  double? distance;
                  if (_currentPosition != null &&
                      latitude != null &&
                      longitude != null) {
                    distance = Geolocator.distanceBetween(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                      latitude,
                      longitude,
                    );
                  }

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage:
                            profileImageUrl != null
                                ? NetworkImage(profileImageUrl)
                                : const AssetImage(
                                      'assets/default_profile.png',
                                    ) // Replace with your default asset
                                    as ImageProvider<Object>?,
                        child:
                            profileImageUrl == null
                                ? const Icon(Icons.person, size: 30)
                                : null,
                      ),
                      title: Text(
                        fullName,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shopName,
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                          if (distance != null)
                            Text(
                              '${(distance / 1000).toStringAsFixed(1)} km away',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                      onTap: () {
                        // Navigate to the barber's detailed profile page
                        Navigator.pushNamed(
                          context,
                          '/barber-details',
                          arguments: _nearbyBarbers[index].id,
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }
}
