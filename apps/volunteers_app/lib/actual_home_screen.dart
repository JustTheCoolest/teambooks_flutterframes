import 'package:flutter/material.dart';
import 'book_registration_page.dart';

class ActualHomeScreen extends StatelessWidget {
  const ActualHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TeamBooks Volunteer Portal'),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.logout),
        //     tooltip: 'Sign Out',
        //     onPressed: () {
        //       // TODO: Implement Sign Out Logic (e.g., context.read<AuthProvider>().signOut())
        //       // For now, just navigate to a placeholder or clear auth state
        //       // This might involve popping all routes and pushing a login screen.
        //     },
        //   ),
        // ],
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.book_online),
          label: const Text('Register Book Donation'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            textStyle: const TextStyle(fontSize: 18),
          ),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const BookRegistrationPage(),
              ),
            );
          },
        ),
      ),
    );
  }
}
