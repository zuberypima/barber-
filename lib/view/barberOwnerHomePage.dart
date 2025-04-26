import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BarberOwnerHomePage extends StatelessWidget {
  const BarberOwnerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('My BarberShop', style: GoogleFonts.poppins()),
        actions: [
          IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Shop Overview Card
            Card(
              margin: EdgeInsets.all(15),
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(
                            'assets/images/shop_logo.jpg',
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Elite Barbers',
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
                                    '4.8 (124 reviews)',
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
                        _buildStatItem('Today', '12', Icons.calendar_today),
                        _buildStatItem('Queue', '4', Icons.people),
                        _buildStatItem('Earnings', '\$320', Icons.attach_money),
                      ],
                    ),
                  ],
                ),
              ),
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
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          _buildQueueItem(
                            'Michael Scott',
                            'Haircut & Beard',
                            'Now',
                          ),
                          Divider(),
                          _buildQueueItem('Jim Halpert', 'Haircut', 'Next'),
                          Divider(),
                          _buildQueueItem('Pam Beesly', 'Hair Color', '15 min'),
                          Divider(),
                          _buildQueueItem(
                            'Dwight Schrute',
                            'Traditional Shave',
                            '30 min',
                          ),
                        ],
                      ),
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
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          _buildReviewItem('Amazing fade!', 5, '2 hours ago'),
                          Divider(),
                          _buildReviewItem('Good service', 4, '1 day ago'),
                        ],
                      ),
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
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('This Week', style: GoogleFonts.poppins()),
                              Text(
                                '\$1,240',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          LinearProgressIndicator(
                            value: 0.7,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation(Colors.blue),
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '+12% from last week',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                '42 customers',
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
          name[0],
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
