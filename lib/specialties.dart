import 'package:flutter/material.dart';

class SpecialtiesPage extends StatelessWidget {
  const SpecialtiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Volunteer Specialties')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("We need your help. Please fill out the application below.", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(decoration: InputDecoration(labelText: 'Your Full Name')),
            TextField(decoration: InputDecoration(labelText: 'Are you allowed to perform the required work?')),
            TextField(decoration: InputDecoration(labelText: 'Relevant Experience')),
            TextField(decoration: InputDecoration(labelText: 'Availability (Next 3 Months)')),
            TextField(decoration: InputDecoration(labelText: 'Resume or LinkedIn Profile')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Submit Application'),
            ),
          ],
        ),
      ),
    );
  }
}
