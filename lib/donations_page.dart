import 'package:flutter/material.dart';

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
            const Text(
              "Give Hope, Change Lives – Your Donation Makes a Difference!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(labelText: "Full Name"),
            ),
            TextField(decoration: const InputDecoration(labelText: "Email")),
            TextField(
              decoration: const InputDecoration(labelText: "Phone Number"),
            ),
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
