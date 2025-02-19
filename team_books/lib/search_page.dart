import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  final List<String> genres = ['Engineering', 'Medical', 'Business', 'Art', 'Science', 'Biographies', 'Technology'];
  final List<String> recommendations = [
    'How to Avoid a Climate Disaster',
    'The Art of Doing Science and Engineering',
    'The Lean Startup',
    'Bad Blood: Secrets and Lies in a Silicon Valley Startup',
    'The Innovators'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Books')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(decoration: InputDecoration(labelText: 'Search for books, authors, or genres')),
            SizedBox(height: 10),
            Text("Browse by Genre", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 10,
              children: genres.map((genre) => Chip(label: Text(genre))).toList(),
            ),
            SizedBox(height: 20),
            Text("Recommended for You", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...recommendations.map((book) => ListTile(title: Text(book))),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/recommendation_engine');
              },
              child: Text('Go to Recommendation Engine'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
