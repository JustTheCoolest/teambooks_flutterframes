import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'volunteer_application.dart';
import 'book_pickup.dart';
import 'personal_details.dart';
import 'specialties.dart';
import 'search_page.dart';
import 'recommendation_engine.dart';
import 'donations_page.dart';
import 'scan_book_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart' as constants;

void main() {
  runApp(TeamBooksApp());
}

Future<double> fetchCurrentBooks() async {
  final response = await http.get(Uri.parse('${constants.backend_url}/books/'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['current_books'].toDouble();
  } else {
    throw Exception('Failed to load current books');
  }
}

Future<List<Map<String, dynamic>>> fetchDonationCategories() async {
  // TODO: Replace with actual backend call
  await Future.delayed(const Duration(milliseconds: 500));
  return [
    {"value": 5000, "title": "Science Fiction", "color": 0xFFFF0000},
    {"value": 2500, "title": "Self-help", "color": 0xFF0000FF},
    {"value": 1500, "title": "Engineering", "color": 0xFF00FF00},
    {"value": 7000, "title": "Medical", "color": 0xFF800080},
    {"value": 3000, "title": "Children’s books", "color": 0xFFFFA500},
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
      initialRoute: '/',
      routes: {
        '/': (context) => TeamBooksHomePage(),
        '/donations': (context) => DonationsPage(),
        '/volunteer_application': (context) => VolunteerApplicationPage(),
        '/bookPickup': (context) => BookPickupPage(),
        '/personal_details': (context) => PersonalDetailsPage(),
        '/specialties': (context) => SpecialtiesPage(),
        '/search': (context) => SearchPage(),
        '/recommendation_engine': (context) => RecommendationEnginePage(),
        '/scan_book': (context) => const ScanBookPage(),
        '/volunteer_application': (context) => const VolunteerApplicationPage(),
      },
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
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/volunteer_application'),
              child: const Text('Apply as Volunteer'),
            ),
            _headerSection(context),
            _howItWorksSection(),
            _donationChartsSection(),
            _sponsorsSection(),
            _testimonialsSection(),
            _volunteerOpportunitiesSection(context),
          ],
        ),
      ),
    );
  }
  
  Widget _progressBar() {
    return FutureBuilder<double>(
      future: fetchCurrentBooks(),
      builder: (context, snapshot) {
        double currentBooks;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        currentBooks = snapshot.data!;
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

  Widget _headerSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage(
            'header_image.jpg',
          ), // Replace with your image
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5),
            BlendMode.darken,
          ),
        ),
      ),
      child: Column(
        children: [
          // Task: Proper message
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

  // Widget _booksBarChart() {
  //   return SizedBox(
  //     height: 200,
  //     child: BarChart(
  //       BarChartData(
  //         barGroups: [
  //           BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 60, color: Colors.blue)]),
  //           BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 50, color: Colors.green)]),
  //         ],
  //         titlesData: const FlTitlesData(
  //           leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _howItWorksSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            "How It Works",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Column(
            children: constants.howItWorksLines.map((line) => Text(line)).toList(),
          )
        ],
      ),
    );
  }

  Widget _donationChartsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            "Category-Wise Donations",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text("(in number of books)"),
          const SizedBox(height: 42),
          _categoryPieChartWithLegend(),
        ],
      ),
    );
  }

  bool useWhiteText(Color background) {
    // Calculate luminance to decide text color
    return background.computeLuminance() < 0.5;
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
              color: useWhiteText(color) ? Colors.white : Colors.black,
              shadows: [
                Shadow(
                  blurRadius: 2,
                  color: Colors.black26,
                  offset: Offset(1, 1),
                )
              ],
            ),
            titlePositionPercentageOffset: 0.6, // Puts the number inside the section
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

  Widget _sponsorsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            "Our Sponsors",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          _donationLeaderboard(),
        ],
      ),
    );
  }

  Widget _donationLeaderboard() {
    List<Map<String, dynamic>> leaderboard = [
      {"name": "Anonymous", "amount": "\$20,000"},
      {"name": "Sally", "amount": "\$10,000"},
      {"name": "Sam", "amount": "\$5,000"},
      {"name": "Jenny", "amount": "\$2,000"},
      {"name": "Tom", "amount": "\$1,000"},
    ];

    return Column(
      children:
          leaderboard.map((entry) {
            return ListTile(
              title: Text(entry["name"]),
              trailing: Text(entry["amount"]),
            );
          }).toList(),
    );
  }

  Widget _testimonialsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            "What people say about us",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          _testimonialCard(
            "Bella",
            "Wonderful Initiative! I hope there were more of these around the world.",
          ),
          _testimonialCard(
            "Gloria Ochoa",
            "I can't wait to see the library open for our community.",
          ),
          _testimonialCard(
            "Luis Mejia",
            "This is a great initiative. Our community will benefit a lot.",
          ),
        ],
      ),
    );
  }

  Widget _testimonialCard(String name, String review) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(review),
      ),
    );
  }

  Widget _volunteerOpportunitiesSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            "Volunteer Opportunities",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          _volunteerCategory(context, "Web Development"),
          _volunteerCategory(context, "Marketing"),
          _volunteerCategory(context, "Finance"),
          _volunteerCategory(context, "Legal"),
          _volunteerCategory(context, "Physical Collection"),
        ],
      ),
    );
  }

  Widget _volunteerCategory(BuildContext context, String title) {
    return ListTile(
      title: Text(title),
      trailing: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/personal_details');
        },
        child: const Text("Apply"),
      ),
    );
  }
}
