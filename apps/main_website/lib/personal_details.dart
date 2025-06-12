import 'package:flutter/material.dart';

class PersonalDetailsPage extends StatelessWidget {
  const PersonalDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Personal Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(decoration: InputDecoration(labelText: 'First Name')),
            TextField(decoration: InputDecoration(labelText: 'Last Name')),
            TextField(decoration: InputDecoration(labelText: 'Email')),
            TextField(decoration: InputDecoration(labelText: 'Phone')),
            TextField(decoration: InputDecoration(labelText: 'Introduction')),
            TextField(decoration: InputDecoration(labelText: 'Motivation')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/specialties');
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
