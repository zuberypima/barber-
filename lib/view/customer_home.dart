import 'package:barber/services/navigator.dart';
import 'package:barber/view/barber_pages.dart/BarberShopsPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class CustomerHomePage extends StatelessWidget {
  const CustomerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Find Your Barber', style: GoogleFonts.poppins()),
        actions: [
          IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
          IconButton(icon: Icon(Icons.person), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location-based search
            Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find nearby barbers',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search by location or name',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      IconButton(
                        icon: Icon(Icons.my_location),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          // Get current location
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Featured Barbershops
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Featured Barbershops',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        child: Text('See all'),
                        onPressed: () {
                          push_next_page(context, BarberShopsPage());
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('BarbersDetails')
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                          height: 180,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 3, // Show 3 skeleton cards
                            itemBuilder: (context, index) {
                              return _buildFeaturedBarberSkeleton();
                            },
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      return SizedBox(
                        height: 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final data =
                                snapshot.data!.docs[index].data()
                                    as Map<String, dynamic>;
                            return _buildFeaturedBarberCard(data);
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Services Categories
            Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Services',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    children: [
                      _buildServiceCategory('Haircut', Icons.cut),
                      _buildServiceCategory('Beard', Icons.face),
                      _buildServiceCategory('Shave', Icons.radar),
                      _buildServiceCategory('Color', Icons.palette),
                    ],
                  ),
                ],
              ),
            ),

            // Nearby Barbers with Queue Status
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Near You',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        child: Text('See all'),
                        onPressed: () {
                          push_next_page(context, BarberShopsPage());
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection('barber')
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Column(
                          children: List.generate(
                            3,
                            (index) => _buildBarberShopSkeleton(),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final data =
                              snapshot.data!.docs[index].data()
                                  as Map<String, dynamic>;
                          return _buildBarberShopCard(
                            barberShopData: data,
                            withQueueStatus: true,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            // Loyalty Program
            Padding(
              padding: EdgeInsets.all(15),
              child: Card(
                color: Colors.blue[800],
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.card_giftcard, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Loyalty Program',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        '5 visits = 1 free haircut!',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                      SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: 0.6,
                        backgroundColor: Colors.blue[200],
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '3/5 visits completed',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildFeaturedBarberCard(Map<String, dynamic> data) {
    final name = data['shopName'] as String? ?? 'No Name';
    final rating = (data['rating'] as num?)?.toDouble() ?? 0.0;
    final reviewCount = data['reviewCount'] as int? ?? 0;
    final imageUrl = data['imageUrl'] as String? ?? 'assets/background.jpg';

    return Container(
      width: 150,
      margin: EdgeInsets.only(right: 10),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            debugPrint('Tapped on $name');
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.network(
                  imageUrl,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/background.jpg',
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(
                          rating.toStringAsFixed(1),
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        Text(
                          ' ($reviewCount)',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedBarberSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 150,
        margin: EdgeInsets.only(right: 10),
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 100,
                width: double.infinity,
                color: Colors.white,
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 100, height: 16, color: Colors.white),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Container(width: 16, height: 16, color: Colors.white),
                        SizedBox(width: 5),
                        Container(width: 40, height: 12, color: Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCategory(String name, IconData icon) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.blue[100],
          child: Icon(icon, color: Colors.blue[800]),
        ),
        SizedBox(height: 5),
        Text(name, style: GoogleFonts.poppins(fontSize: 12)),
      ],
    );
  }

  Widget _buildBarberShopCard({
    required Map<String, dynamic> barberShopData,
    bool withQueueStatus = false,
  }) {
    final name = barberShopData['shopName'] as String? ?? 'No Name';
    final rating = (barberShopData['rating'] as num?)?.toDouble() ?? 0.0;
    final reviewCount = barberShopData['reviewCount'] as int? ?? 0;
    final imageUrl =
        barberShopData['imageUrl'] as String? ?? 'assets/background.jpg';
    final distance = (barberShopData['distance'] as num?)?.toDouble() ?? 0.0;
    final queueLength = barberShopData['queueLength'] as int?;
    final estimatedWaitTime = barberShopData['estimatedWaitTime'] as String?;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          debugPrint('Tapped on $name');
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/background.jpg',
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(
                          rating.toStringAsFixed(1),
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        Text(
                          ' ($reviewCount)',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey,
                        ),
                        Text(
                          '${distance.toStringAsFixed(1)} km away',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    if (withQueueStatus &&
                        queueLength != null &&
                        estimatedWaitTime != null) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.people,
                            size: 16,
                            color: Colors.grey,
                          ),
                          Text(
                            'Queue: $queueLength people ($estimatedWaitTime)',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  // Implement favorite functionality
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarberShopSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Container(width: 70, height: 70, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 150, height: 16, color: Colors.white),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Container(width: 16, height: 16, color: Colors.white),
                        const SizedBox(width: 5),
                        Container(width: 60, height: 12, color: Colors.white),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Container(width: 16, height: 16, color: Colors.white),
                        const SizedBox(width: 5),
                        Container(width: 80, height: 12, color: Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
              Container(width: 40, height: 40, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
