import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shimmer/shimmer.dart';

class BarberOwnerHomePage extends StatelessWidget {
  const BarberOwnerHomePage({super.key});

  // Reference to the current user's shop document
  DocumentReference get _shopRef {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance.collection('shops').doc(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: _shopRef.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(width: 150, height: 20, color: Colors.white),
              );
            }
            final shopName = snapshot.data?['name'] ?? 'My BarberShop';
            return Text(shopName, style: GoogleFonts.poppins());
          },
        ),
        actions: [
          IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Shop Overview Card
            StreamBuilder<DocumentSnapshot>(
              stream: _shopRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return _buildShopOverviewSkeleton();
                }

                final shopData =
                    snapshot.data!.data() as Map<String, dynamic>? ?? {};
                final todayAppointments = shopData['todayAppointments'] ?? 0;
                final queueLength = shopData['queueLength'] ?? 0;
                final todayEarnings = shopData['todayEarnings'] ?? 0;
                final rating = shopData['rating'] ?? 0;
                final reviewCount = shopData['reviewCount'] ?? 0;

                return Card(
                  margin: EdgeInsets.all(15),
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage:
                                  shopData['logoUrl'] != null
                                      ? NetworkImage(shopData['logoUrl'])
                                      : AssetImage(
                                            'assets/images/shop_logo.jpg',
                                          )
                                          as ImageProvider,
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    shopData['name'] ?? 'Elite Barbers',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                      Text(
                                        '${rating.toStringAsFixed(1)} ($reviewCount reviews)',
                                        style: GoogleFonts.poppins(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                // Edit shop profile
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              'Today',
                              todayAppointments.toString(),
                              Icons.calendar_today,
                            ),
                            _buildStatItem(
                              'Queue',
                              queueLength.toString(),
                              Icons.people,
                            ),
                            _buildStatItem(
                              'Earnings',
                              '\$$todayEarnings',
                              Icons.attach_money,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Quick Actions
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildQuickAction('Manage Queue', Icons.queue),
                  _buildQuickAction('Add Service', Icons.add_circle),
                  _buildQuickAction('View Bookings', Icons.calendar_month),
                  _buildQuickAction('Loyalty Program', Icons.card_giftcard),
                ],
              ),
            ),

            // Current Queue
            Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Queue',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(child: Text('Manage'), onPressed: () {}),
                    ],
                  ),
                  SizedBox(height: 10),
                  Card(
                    child: StreamBuilder<QuerySnapshot>(
                      stream:
                          _shopRef
                              .collection('queue')
                              .orderBy('timestamp')
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return _buildQueueSkeleton();
                        }

                        final queueItems = snapshot.data!.docs;

                        if (queueItems.isEmpty) {
                          return Padding(
                            padding: EdgeInsets.all(15),
                            child: Text(
                              'No customers in queue',
                              style: GoogleFonts.poppins(),
                            ),
                          );
                        }

                        return Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              for (var i = 0; i < queueItems.length; i++) ...[
                                if (i > 0) Divider(),
                                _buildQueueItem(
                                  queueItems[i]['customerName'],
                                  queueItems[i]['service'],
                                  i == 0 ? 'Now' : '${i * 15} min',
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Recent Reviews
            Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Reviews',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(child: Text('See all'), onPressed: () {}),
                    ],
                  ),
                  SizedBox(height: 10),
                  Card(
                    child: StreamBuilder<QuerySnapshot>(
                      stream:
                          _shopRef
                              .collection('reviews')
                              .orderBy('timestamp', descending: true)
                              .limit(2)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return _buildReviewsSkeleton();
                        }

                        final reviews = snapshot.data!.docs;

                        if (reviews.isEmpty) {
                          return Padding(
                            padding: EdgeInsets.all(15),
                            child: Text(
                              'No reviews yet',
                              style: GoogleFonts.poppins(),
                            ),
                          );
                        }

                        return Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              for (var i = 0; i < reviews.length; i++) ...[
                                if (i > 0) Divider(),
                                _buildReviewItem(
                                  reviews[i]['comment'],
                                  reviews[i]['rating'],
                                  _formatTimeAgo(
                                    reviews[i]['timestamp']?.toDate(),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Business Insights
            Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Business Insights',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Card(
                    child: StreamBuilder<DocumentSnapshot>(
                      stream:
                          _shopRef
                              .collection('stats')
                              .doc('weekly')
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return _buildInsightsSkeleton();
                        }

                        final stats =
                            snapshot.data!.data() as Map<String, dynamic>? ??
                            {};
                        final currentWeek = stats['currentWeek'] ?? 0;
                        final lastWeek = stats['lastWeek'] ?? 0;
                        final customerCount = stats['customerCount'] ?? 0;

                        final percentageChange =
                            lastWeek > 0
                                ? ((currentWeek - lastWeek) / lastWeek * 100)
                                    .round()
                                : 100;

                        return Padding(
                          padding: EdgeInsets.all(15),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'This Week',
                                    style: GoogleFonts.poppins(),
                                  ),
                                  Text(
                                    '\$$currentWeek',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              LinearProgressIndicator(
                                value:
                                    currentWeek > 0
                                        ? (currentWeek / 2000).clamp(0.0, 1.0)
                                        : 0.0,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation(Colors.blue),
                              ),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${percentageChange >= 0 ? '+' : ''}$percentageChange% from last week',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color:
                                          percentageChange >= 0
                                              ? Colors.green
                                              : Colors.red,
                                    ),
                                  ),
                                  Text(
                                    '$customerCount customers',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.queue), label: 'Queue'),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: 'Insights',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  // Skeleton loading widgets
  Widget _buildShopOverviewSkeleton() {
    return Card(
      margin: EdgeInsets.all(15),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 150,
                          height: 20,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 100,
                          height: 15,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(width: 24, height: 24, color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(3, (index) => _buildStatSkeleton()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueSkeleton() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: List.generate(
          3,
          (index) => Column(
            children: [
              if (index > 0) Divider(),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.white),
                  title: Container(width: 100, height: 16, color: Colors.white),
                  subtitle: Container(
                    width: 150,
                    height: 12,
                    color: Colors.white,
                  ),
                  trailing: Container(
                    width: 50,
                    height: 24,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsSkeleton() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: List.generate(
          2,
          (index) => Column(
            children: [
              if (index > 0) Divider(),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.white),
                  title: Row(
                    children: List.generate(
                      5,
                      (starIndex) => Icon(Icons.star, color: Colors.white),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 200, height: 14, color: Colors.white),
                      SizedBox(height: 5),
                      Container(width: 80, height: 10, color: Colors.white),
                    ],
                  ),
                  trailing: Container(
                    width: 24,
                    height: 24,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightsSkeleton() {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(width: 80, height: 16, color: Colors.white),
              ),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(width: 60, height: 16, color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 10),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 8,
              width: double.infinity,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(width: 100, height: 12, color: Colors.white),
              ),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(width: 80, height: 12, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Container(width: 30, height: 18, color: Colors.white),
          SizedBox(height: 5),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 16, height: 16, color: Colors.white),
              SizedBox(width: 5),
              Container(width: 40, height: 12, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime? date) {
    if (date == null) return 'Just now';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';
    if (difference.inDays < 7) return '${difference.inDays} days ago';

    return '${(difference.inDays / 7).floor()} weeks ago';
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(height: 5),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.grey),
            SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAction(String title, IconData icon) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(title, style: GoogleFonts.poppins()),
      style: ElevatedButton.styleFrom(
        alignment: Alignment.centerLeft,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
      onPressed: () {},
    );
  }

  Widget _buildQueueItem(String name, String service, String time) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue[100],
        child: Text(
          name.isNotEmpty ? name[0] : '?',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
      ),
      title: Text(name, style: GoogleFonts.poppins()),
      subtitle: Text(
        service,
        style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
      ),
      trailing: Chip(
        label: Text(time),
        backgroundColor: time == 'Now' ? Colors.green[100] : Colors.grey[200],
        labelStyle: GoogleFonts.poppins(
          color: time == 'Now' ? Colors.green[800] : Colors.black,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildReviewItem(String comment, int rating, String time) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.amber[100],
        child: Icon(Icons.person, color: Colors.amber[800]),
      ),
      title: Row(
        children: List.generate(5, (index) {
          return Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 16,
          );
        }),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(comment, style: GoogleFonts.poppins()),
          SizedBox(height: 5),
          Text(
            time,
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(Icons.reply),
        onPressed: () {
          // Respond to review
        },
      ),
    );
  }
}
