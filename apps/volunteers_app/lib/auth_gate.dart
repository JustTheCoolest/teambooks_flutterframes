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
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
            ],
          );
        }
        // User is signed in, now check admin status
        return AdminCheckPage(user: snapshot.data!);
      },
    );
  }
}

class AdminCheckPage extends StatefulWidget {
  final User user;
  const AdminCheckPage({super.key, required this.user});

  @override
  State<AdminCheckPage> createState() => _AdminCheckPageState();
}

class _AdminCheckPageState extends State<AdminCheckPage> {
  Future<bool>? _isAdminFuture;

  @override
  void initState() {
    super.initState();
    _isAdminFuture = _checkIfAdmin();
  }

  Future<bool> _checkIfAdmin() async {
    try {
      // First, ensure the user's email is verified if that's a requirement
      // For this example, we'll assume email verification is handled elsewhere or not strictly required before this check.
      // if (!widget.user.emailVerified) {
      //   print("User email not verified.");
      //   // Optionally, navigate to an email verification screen or show a message.
      //   return false; // Or handle as needed
      // }

      final userDoc = await db.collection("users").doc(widget.user.uid).get();
      if (userDoc.exists && userDoc.data() != null && userDoc.data()!['roles']['admin'] == true) {
        return true; // User is an admin
      }
      return false; // User is not an admin or document doesn't exist
    } catch (error) {
      print("Error fetching user admin status: $error");
      return false; // Default to not admin on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isAdminFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          print("Error in FutureBuilder for admin check: ${snapshot.error}");
          return const AccessDeniedScreen(); // Or a generic error screen
        }

        final bool isAdmin = snapshot.data!;
        if (isAdmin) {
          return const HomeScreen();
        } else {
          return const AccessDeniedScreen();
        }
      },
    );
  }
}


class AccessDeniedScreen extends StatelessWidget {
  const AccessDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Denied'),
        automaticallyImplyLeading: false, // No back button
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 20),
              const Text(
                'Access Denied',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'You do not have the necessary permissions to access this application. Please contact support if you believe this is an error.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              const SignOutButton(), // FirebaseUI's SignOutButton
            ],
          ),
        ),
      ),
    );
  }
}