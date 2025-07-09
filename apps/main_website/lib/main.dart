// main.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart' as constants;

void main() {
  runApp(TeamBooksApp());
}

// Placeholder async fetch functions

Future<double> fetchCurrentBooks() async {
  await Future.delayed(const Duration(milliseconds: 500));
  return 350.0;
}

Future<List<Map<String, dynamic>>> fetchDonationCategories() async {
  await Future.delayed(const Duration(milliseconds: 500));
  return [
    {"value": 5000, "title": "Science Fiction", "color": 0xFFFF0000},
    {"value": 2500, "title": "Self-help", "color": 0xFF0000FF},
    {"value": 1500, "title": "Engineering", "color": 0xFF00FF00},
    {"value": 7000, "title": "Medical", "color": 0xFF800080},
    {"value": 3000, "title": "Children’s books", "color": 0xFFFFA500},
  ];
}

Future<List<Map<String, dynamic>>> fetchCategories() async {
  await Future.delayed(const Duration(milliseconds: 300));
  return constants.categories;
}

Future<List<Map<String, dynamic>>> fetchLinks() async {
  await Future.delayed(const Duration(milliseconds: 200));
  return constants.links;
}
Future<List<Map<String, dynamic>>> fetchTimelineEvents() async {
  await Future.delayed(const Duration(milliseconds: 300));
  return constants.timelineEvents;
}

Future<List<Map<String, dynamic>>> fetchSponsors() async {
  await Future.delayed(const Duration(milliseconds: 300));
  return constants.sponsors;
}

Future<List<Map<String, dynamic>>> fetchTestimonials() async {
  await Future.delayed(const Duration(milliseconds: 400));
  return [
    {"author": "Bella", "role": "CEO at Pearson Shepherd", "text": "Wonderful Initiative, I hope there were more of these around the world"},
    {"author": "Gloria Ochoa", "date": "11/12/2021", "text": "I can’t wait to see the library open for our community. I’m so excited!"},
    {"author": "Luis Mejia", "date": "01/15/2029", "text": "Amazing project! Happy to contribute."},
  ];
}
Future<List<Map<String, dynamic>>> fetchDonationLeaderboard() async {
  await Future.delayed(const Duration(milliseconds: 400));
  return [
    {"name": "Anonymous", "amount": "\$20,000"},
    {"name": "Sally", "amount": "\$10,000"},
    {"name": "Sam", "amount": "\$5,000"},
    {"name": "Jenny", "amount": "\$2,000"},
    {"name": "Tom", "amount": "\$1,000"},
  ];
}

class TeamBooksApp extends StatelessWidget {
  const TeamBooksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Team Books',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const TeamBooksHomePage(),
    );
  }
}

class TeamBooksHomePage extends StatelessWidget {
  const TeamBooksHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Team Books')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _headerSection(context),
            SizedBox(height: 32), // Add space here (adjust as needed)
            _categoryPieChartWithLegend(),
            _howItWorksSection(),
            _readyToJoinSection(),
            // Inserted sections as requested
            _timelineSection(),
            _sponsorsSection(),
            _donationLeaderboardSection(),
            _testimonialsSection(),
            _categoriesSection(),
            _linksSection(),
          ],
        ),
      ),
    );
  }

  Widget _headerSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('header_image.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5),
            BlendMode.darken,
          ),
        ),
      ),
      child: Column(
        children: [
          const Text(
            constants.introText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          _progressBar(),
        ],
      ),
    );
  }

  Widget _progressBar() {
    return FutureBuilder<double>(
      future: fetchCurrentBooks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        double currentBooks = snapshot.data ?? 0;
        const totalBooks = constants.target_milestone;
        final double progress = currentBooks / totalBooks;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                "Books collected: ${(progress * 100).toStringAsFixed(0)}%",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                color: Colors.green,
              ),
              const SizedBox(height: 10),
              Text(
                "$currentBooks out of $totalBooks books",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _categoryPieChartWithLegend() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchDonationCategories(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;
        final sections = data.map((cat) {
          final color = Color(cat["color"]);
          final value = cat["value"] * 1.0;
          final title = cat["value"].toString();
          return PieChartSectionData(
            value: value,
            color: color,
            title: title,
            radius: 60,
            titleStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color.computeLuminance() < 0.5 ? Colors.white : Colors.black,
              shadows: [
                const Shadow(
                  blurRadius: 2,
                  color: Colors.black26,
                  offset: Offset(1, 1),
                )
              ],
            ),
            titlePositionPercentageOffset: 0.6,
          );
        }).toList();

        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 400;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: isSmallScreen ? 180 : 220,
              width: isSmallScreen ? 180 : 220,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  startDegreeOffset: 180,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 8,
              children: data
                  .map((cat) =>
                      _buildLegendItem(cat["title"], Color(cat["color"])))
                  .toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(title, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget _howItWorksSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            "How it works",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _infoCard(
                  icon: Icons.menu_book,
                  title: "Book Donation",
                  description:
                      "We partner with local schools and libraries to provide free books.",
                ),
                const SizedBox(width: 16),
                _infoCard(
                  icon: Icons.volunteer_activism,
                  title: "Volunteer Opportunities",
                  description:
                      "You can volunteer to collect books or make a donation.",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.orange),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _readyToJoinSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Text(
            "Ready to join the team?",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            onPressed: () {},
            child: const Text(
              "I want to help",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ----------- Inserted Sections ------------

  Widget _timelineSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchTimelineEvents(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final events = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "About this project",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(constants.introText),
              const SizedBox(height: 16),
              ...events.map((e) => ListTile(
                    leading: const Icon(Icons.circle, size: 16),
                    title: Text(e["month"]),
                    subtitle: Text(e["desc"]),
                  )),
            ],
          ),
        );
      },
    );
  }

Widget _sponsorsSection() {
  return FutureBuilder<List<Map<String, dynamic>>>(
    future: fetchSponsors(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final sponsors = snapshot.data!;
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Our Sponsors",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: sponsors.map((sponsor) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      Image.asset(
                        sponsor["logoUrl"],
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 4),
                      Text(sponsor["name"]),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
      );
    },
  );
}


  Widget _donationLeaderboardSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchDonationLeaderboard(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final leaderboard = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Donation Leaderboard",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...leaderboard.map((entry) => ListTile(
                    title: Text(entry["name"]),
                    trailing: Text(entry["amount"]),
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _testimonialsSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchTestimonials(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final testimonials = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "What people say about us",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...testimonials.map((t) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (t.containsKey("role"))
                            Text(t["author"], style: const TextStyle(fontWeight: FontWeight.bold)),
                          if (t.containsKey("role"))
                            Text(t["role"], style: const TextStyle(color: Colors.grey)),
                          if (t.containsKey("date"))
                            Text(t["author"], style: const TextStyle(fontWeight: FontWeight.bold)),
                          if (t.containsKey("date"))
                            Text(t["date"], style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 6),
                          Text(t["text"]),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

  // ----------- End Inserted Sections ------------

  Widget _categoriesSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchCategories(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final categories = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Categories",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...categories.map((cat) => ListTile(
                    title: Text(cat["name"]),
                    trailing: TextButton(
                      onPressed: () {},
                      child: const Text("Apply"),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _linksSection() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchLinks(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final links = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Links",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...links.map((link) => ListTile(
                    title: Text(link["name"]),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  )),
            ],
          ),
        );
      },
    );
  }
}

// Placeholders for fetch functions and constants.dart remain unchanged
