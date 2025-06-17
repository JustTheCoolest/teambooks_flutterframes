import 'package:flutter/material.dart';
import 'actual_home_screen.dart';
import 'access_denied_screen.dart';
import 'services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For User type

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiate FirebaseService here. As this is a StatelessWidget,
    // if FirebaseService had significant internal state or was expensive to create,
    // it would ideally be provided through a DI mechanism or passed via constructor.
    // For this case, creating it locally in build is done to avoid class variables.
    final FirebaseService firebaseService = FirebaseService();
    final User? currentUser = firebaseService.currentUser;

    return FutureBuilder<bool>(
      // WARNING: Calling firebaseService.validateCurrentVolunteer() directly here
      // means it will be executed every time this build method runs.
      // If HomeScreen rebuilds frequently, this will result in multiple API calls.
      // This is a consequence of the constraints (StatelessWidget, no initState, logic in build).
      future: firebaseService.validateCurrentVolunteer(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Displaying the error directly from the snapshot.
                    // Assumes FirebaseService.validateCurrentVolunteer throws an error
                    // that is suitable for display.
                    Text(
                      snapshot.error.toString(),
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // In a StatelessWidget, this button cannot directly re-trigger
                        // the FutureBuilder with a new future by calling setState.
                        // If this HomeScreen widget is rebuilt by its parent,
                        // the future will be re-fetched. This button is a UX hint.
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          final bool isValidVolunteer = snapshot.data!;
          if (isValidVolunteer) {
            return const ActualHomeScreen();
          } else {
            // If data is false, volunteer is not valid (or not logged in,
            // as handled by validateCurrentVolunteer).
            // Pass the current user's UID to AccessDeniedScreen.
            return AccessDeniedScreen(
              uid: currentUser?.uid,
            );
          }
        }

        // Fallback for any other state, though typically covered by .waiting or .hasError/.hasData.
        return const Scaffold(
          body: Center(child: Text("Initializing...\nTry refreshing if it takes too long")), // Placeholder
        );
      },
    );
  }
}