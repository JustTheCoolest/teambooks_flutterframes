import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: ListView(
        children: const <Widget>[
          SponsorWidget(),
          LeaderboardWidget(),
          // Add more widgets here
        ],
      ),
    );
  }
}

class SponsorWidget extends StatelessWidget {
  const SponsorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          Text(
            'Sponsors',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          // Add more content here
        ],
      ),
    );
  }
}

class LeaderboardWidget extends StatelessWidget {
  const LeaderboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          Text(
            'Leaderboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          // Add more content here
        ],
      ),
    );
  }
}