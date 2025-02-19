import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'constants.dart' as constants;

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
          Intro(),
          SponsorWidget(),
          LeaderboardWidget(),
          // Add more widgets here
        ],
      ),
    );
  }
}

class Intro extends StatelessWidget {
  const Intro({super.key});

  @override
  Widget build(BuildContext context) {
    // Task: Padding for the items inside the image
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/intro.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            constants.introText,
            style: TextStyle(
                fontSize: constants.fontSize, fontWeight: FontWeight.bold),
          ),
          MilestoneProgress(),
        ],
      ),
    );
  }
}

int fetchCollected(){
  // Task: Fetch the number of books collected from the server
  return 40;
}

class MilestoneProgress extends StatelessWidget {
  late int collected;
  static const int target = constants.target_milestone;

  MilestoneProgress({super.key}){
    collected = fetchCollected();
    // Flag: Async Await?!
  }

  @override
  Widget build(BuildContext context) {
    final double progress = collected / target;
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Text(
            'Books collected: ${(progress * 100).toStringAsFixed(0)}%',
            style: const TextStyle(fontSize: 16.0),
          ),
          LinearProgressIndicator(
            value: progress,
          ),
          Text(
            "$collected out of $target books",
            style: const TextStyle(fontSize: 14.0),
          ),
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
            style: TextStyle(
                fontSize: constants.fontSize, fontWeight: FontWeight.bold),
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
