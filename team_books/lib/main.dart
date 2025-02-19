import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'volunteer_application.dart';
import 'book_pickup.dart';
import 'personal_details.dart';
import 'specialties.dart';
import 'search_page.dart';
import 'recommendation_engine.dart';

void main() {
  runApp(TeamBooksApp());
}

class TeamBooksApp extends StatelessWidget {
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
      },
    );
  }
}

class TeamBooksHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Team Books')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _headerSection(context),
            _progressSection(),
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
      padding: const EdgeInsets.all(16),
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
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/volunteer_application');
            },
            child: const Text("I want to help"),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/donations');
            },
            child: const Text("Donate"),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
            child: const Text("Search"),
          ),
        ],
      ),
    );
  }

  Widget _progressSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text("Books Collected: 4,800 out of 8,000 (60%)",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _booksBarChart(),
        ],
      ),
    );
  }

  Widget _booksBarChart() {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barGroups: [
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 60, color: Colors.blue)]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 50, color: Colors.green)]),
          ],
          titlesData: const FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          ),
        ),
      ),
    );
  }

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
