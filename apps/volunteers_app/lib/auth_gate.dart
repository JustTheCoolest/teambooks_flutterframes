import 'package:cloud_firestore/cloud_firestore.dart'; // Added for FirebaseFirestore
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'home.dart'; // Assuming home.dart contains HomeScreen
import 'home_screen.dart'; // Assuming home_screen.dart contains HomeScreen

// Define db instance
final db = FirebaseFirestore.instance; // Added

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ); // Show loading indicator while checking auth state
        }
        if (!snapshot.hasData) {
          return SignInScreen(providers: [EmailAuthProvider()]);
        }
        // User is signed in, now check admin status
        return HomeScreen();
      },
    );
  }
}
