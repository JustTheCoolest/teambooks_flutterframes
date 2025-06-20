import 'package:flutter/material.dart';
import 'actual_home_screen.dart';
import 'access_denied_screen.dart';
import 'package:cloud_functions/cloud_functions.dart';

final firebase_instance = FirebaseFunctions.instanceFor(region: 'asia-south1');
// Flag: Instance is duplicated

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      // WARNING: Calling firebaseService.validateCurrentVolunteer() directly here
      // means it will be executed every time this build method runs.
      // If HomeScreen rebuilds frequently, this will result in multiple API calls.
      // This is a consequence of the constraints (StatelessWidget, no initState, logic in build).
      future: firebase_instance.httpsCallable('validate_volunteer').call(),
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
                    Text(
                      snapshot.error.toString(),
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    // const SizedBox(height: 20),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     // In a StatelessWidget, this button cannot directly re-trigger
                    //     // the FutureBuilder with a new future by calling setState.
                    //     // If this HomeScreen widget is rebuilt by its parent,
                    //     // the future will be re-fetched. This button is a UX hint.
                    //   },
                    //   child: const Text('Retry'),
                    // ),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          final bool isValidVolunteer = snapshot.data!.data;
          if (isValidVolunteer) {
            return const ActualHomeScreen();
          } else {
            return AccessDeniedScreen();
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