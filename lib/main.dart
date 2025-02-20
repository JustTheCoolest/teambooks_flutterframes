import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'volunteer_application.dart';
import 'book_pickup.dart';
import 'personal_details.dart';
import 'specialties.dart';
import 'search_page.dart';
import 'recommendation_engine.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data'; // For web file upload

void main() {
  runApp(TeamBooksApp());
}

class ScanBookPage extends StatefulWidget {
  const ScanBookPage({super.key});

  @override
  State<ScanBookPage> createState() => _ScanBookPageState();
}

class _ScanBookPageState extends State<ScanBookPage> {
  final ApiService _apiService = ApiService();
  String? _result;
  bool _isLoading = false;

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() => _isLoading = true);
      try {
        final result = await _apiService.uploadImage(image);
        setState(() {
          _result = 'Extracted Text: ${result['extracted_text']}\n\n'
                   'Book Details: ${result['book_details']}';
        });
      } catch (e) {
        setState(() => _result = 'Error: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Book')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _pickAndUploadImage,
              child: Text(_isLoading ? 'Processing...' : 'Take Picture'),
            ),
            if (_isLoading)
              const CircularProgressIndicator(),
            if (_result != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(_result!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ApiService {
  static const String baseUrl = 'http://localhost:8000';

  Future<Map<String, dynamic>> uploadImage(XFile image) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload/'));

    if (kIsWeb) {
      // For web, read the file as bytes
      Uint8List bytes = await image.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: image.name));
    } else {
      // For mobile, use fromPath
      request.files.add(await http.MultipartFile.fromPath('file', image.path));
    }

    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    
    if (response.statusCode == 200) {
      return json.decode(responseData);
    } else {
      throw Exception('Failed to upload image');
    }
  }
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

  Widget _headerSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('header_image.jpg'), // Replace with your image
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
        ),
      ),
      child: Column(
        children: [
          const Text(
            "Join the team. Help us donate 1 million books.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Container(
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
                const Text(
                  "Books collected: 60%",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: 0.6,
                  backgroundColor: Colors.grey[300],
                  color: Colors.green,
                ),
                const SizedBox(height: 10),
                const Text(
                  "4,800 out of 8,000 books",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
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
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text("How It Works", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("We partner with local schools and libraries to provide free books."),
          Text("You can volunteer to collect books or make a donation."),
        ],
      ),
    );
  }

  Widget _donationChartsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text("Category-Wise Donations", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _categoryPieChart(),
        ],
      ),
    );
  }

  Widget _categoryPieChart() {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(value: 5000, title: "Science Fiction", color: Colors.red),
            PieChartSectionData(value: 2500, title: "Self-help", color: Colors.blue),
            PieChartSectionData(value: 1500, title: "Engineering", color: Colors.green),
            PieChartSectionData(value: 7000, title: "Medical", color: Colors.purple),
            PieChartSectionData(value: 3000, title: "Children’s books", color: Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _sponsorsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text("Our Sponsors", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
      children: leaderboard.map((entry) {
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
          const Text("What people say about us", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          _testimonialCard("Bella", "Wonderful Initiative! I hope there were more of these around the world."),
          _testimonialCard("Gloria Ochoa", "I can't wait to see the library open for our community."),
          _testimonialCard("Luis Mejia", "This is a great initiative. Our community will benefit a lot."),
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
          const Text("Volunteer Opportunities", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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

class DonationsPage extends StatelessWidget {
  const DonationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Donate Books")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Give Hope, Change Lives – Your Donation Makes a Difference!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(decoration: const InputDecoration(labelText: "Full Name")),
            TextField(decoration: const InputDecoration(labelText: "Email")),
            TextField(decoration: const InputDecoration(labelText: "Phone Number")),
            TextField(decoration: const InputDecoration(labelText: "Address")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/bookPickup');
              },
              child: const Text("Schedule Pickup"),
            ),
          ],
        ),
      ),
    );
  }
}