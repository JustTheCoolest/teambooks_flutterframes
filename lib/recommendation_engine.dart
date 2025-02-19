import 'package:flutter/material.dart';

class RecommendationEnginePage extends StatelessWidget {
  final List<String> userRecommendations = [
    'The Hunger Games',
    'Kid’s Stories 101',
    'The Da Vinci Code',
  ];

  final List<String> frequentlyViewedGenres = ['Engineering', 'Medical', 'Drama', 'Self-Help', 'Business'];
  final List<String> searchHistory = ['Cinderella', 'Snow White', 'Becoming', 'Investing', 'Harry Potter'];

  const RecommendationEnginePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recommendation Engine')),
      body: SingleChildScrollView(  // ✅ Fix Overflow by enabling scrolling
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("User Recommendations", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...userRecommendations.map((book) => ListTile(title: Text(book))),
              SizedBox(height: 20),
              Text("Frequently Viewed Genres", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 10,
                children: frequentlyViewedGenres.map((genre) => Chip(label: Text(genre))).toList(),
              ),
              SizedBox(height: 20),
              Text("Search History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...searchHistory.map((book) => ListTile(title: Text(book))),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Back to Search'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/'),
                    child: Text('Back to Home'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
