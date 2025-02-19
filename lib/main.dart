import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'constants.dart' as constants;

void main() {
  runApp(const MyApp());
}

// Task: Colour palette of app
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
          GenresPieChart(),
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

int fetchCollected() {
  // Task: Fetch the number of books collected from the server
  return 40;
}

class MilestoneProgress extends StatelessWidget {
  late int collected;
  static const int target = constants.target_milestone;

  MilestoneProgress({super.key}) {
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

// Assuming fetchGenres() is defined somewhere in your code
Map<String, int> fetchGenres() {
  // Fetch the genres data from the server or any other source
  return {
    'Fiction': 10,
    'Non-Fiction': 15,
    'Science': 5,
    'History': 8,
  };
}

Map<String, Color> assignColors(Map<String, int> genres) {
  // Task: Assign a color to each genre
  return {
    'Fiction': Colors.blue,
    'Non-Fiction': Colors.green,
    'Science': Colors.red,
    'History': Colors.orange,
  };
}

// Assuming Pie is a widget defined somewhere in your code
class Pie extends StatelessWidget {
  final Map<String, int> genres;

  const Pie(this.genres, {super.key});

  @override
  Widget build(BuildContext context) {
    // Build the pie chart using the genres data
    return Container(); // Replace with actual pie chart implementation
  }
}

class ColorCircle extends StatelessWidget {
  final Color color;

  const ColorCircle(this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16.0,
      height: 16.0,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

// Task: Colour Palette of pie chart
class GenresPieChart extends StatelessWidget {
  const GenresPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, int> genres = fetchGenres();
    final Map<String, Color> genreColors = assignColors(genres);
    return Row(
      children: [
        Pie(genres),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: genres.keys.map((genre) {
                return Row(
                  // Flag: This is very confusing in desktop site
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ColorCircle(genreColors[genre]!),
                        const SizedBox(width: 8.0), // Adds some horizontal spacing
                        Text(
                          genre,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Text(
                      genres[genre].toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ]
                );
              }).toList(),
            )
          )
        )
      ],
    );
  }
}
