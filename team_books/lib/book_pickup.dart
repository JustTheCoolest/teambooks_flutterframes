import 'package:flutter/material.dart';

class BookPickupPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Book Pickup")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("We'll pick up your books. Pack your books and tell us where they are."),
            TextField(decoration: InputDecoration(labelText: 'Apt, Suite, etc (Optional)')),
            TextField(decoration: InputDecoration(labelText: 'City')),
            TextField(decoration: InputDecoration(labelText: 'State')),
            TextField(decoration: InputDecoration(labelText: 'ZIP Code')),
            TextField(decoration: InputDecoration(labelText: 'Contact Email')),
            TextField(decoration: InputDecoration(labelText: 'Phone Number')),
            TextField(decoration: InputDecoration(labelText: 'Preferred Pickup Date')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}
