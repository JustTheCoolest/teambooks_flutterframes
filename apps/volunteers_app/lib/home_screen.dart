import 'package:flutter/material.dart';
import 'actual_home_screen.dart';
import 'access_denied_screen.dart';
import 'services/firebase_service.dart'; // Updated to use FirebaseService directly
import 'package:firebase_auth/firebase_auth.dart'; // For User type

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  Future<bool>? _validationFuture;
  String? _errorMessage;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _firebaseService.currentUser; // Get current user at init
    _validateVolunteer();
  }

  void _validateVolunteer() {
    setState(() {
      _errorMessage = null; // Clear previous errors
      _validationFuture = _firebaseService.validateCurrentVolunteer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _validationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          // Capture the error message from the snapshot
          // The exception is re-thrown from FirebaseService
          _errorMessage = snapshot.error.toString();
          return _buildErrorUI(); // Show error UI with retry
        }

        if (snapshot.hasData) {
          final isValidVolunteer = snapshot.data!;
          if (isValidVolunteer) {
            return const ActualHomeScreen();
          } else {
            // If not valid, but no specific error from function (e.g., user doc not found)
            // or if user is null initially.
            _errorMessage =
                _currentUser == null
                    ? "You are not logged in. Please log in and try again."
                    : "You are not authorized as a volunteer.";
            return AccessDeniedScreen(
              uid: _currentUser?.uid,
              customMessage: _errorMessage,
            );
          }
        }

        // Fallback / initial state before future completes or if no data/error yet
        // This case should ideally be covered by ConnectionState.waiting
        return _buildErrorUI(); // Or a generic loading/error screen
      },
    );
  }

  Widget _buildErrorUI() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage ?? 'Error validating volunteer status.',
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _validateVolunteer, // Retry validation
                child: const Text('Retry Validation'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
