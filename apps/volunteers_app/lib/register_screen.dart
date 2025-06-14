import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Uncomment if you use Firestore in checkInvitationId
import 'package:url_launcher/url_launcher.dart'; // For launching URLs
import 'package:go_router/go_router.dart';

// --- Placeholder Functions ---
// TODO: Replace these with your actual backend logic (e.g., Firestore checks)

/// Placeholder: Checks if the invitation ID is valid.
/// This is now ASYNCHRONOUS.
// Future<bool> checkInvitationId(String invitationId) async {
//   // print("Checking invitation ID (async): $invitationId");
//   // // Example: Simulate network delay
//   // await Future.delayed(const Duration(seconds: 1));

//   // In a real app: query Firestore or your database
//   try {
//     final doc = await FirebaseFirestore.instance.collection('accepted_volunteers').doc(invitationId).get();
//     return doc.exists; // And potentially check if it's not already used, etc.
//   } catch (e) {
//     print("Error checking invitation ID: $e");
//     return false;
//   }
//   // return invitationId.isNotEmpty && invitationId != "invalid"; // Replace with actual async logic
// }

/// Placeholder: Checks if the registered email matches the one associated with the invitation ID.
Future<bool> checkEmailWithInvitationId(String? email, String invitationId) async {
  // print("Checking email with invitation ID (async): $email, $invitationId");
  // // Example: Simulate network delay
  // await Future.delayed(const Duration(seconds: 1));

  // In a real app: query Firestore or your database
  if (email == null || email.isEmpty) {
    return false; // Invalid email
  }

  try {
    final doc = await FirebaseFirestore.instance.collection('accepted_volunteers').doc(invitationId).get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      return data['email'] == email; // Assuming the document has an 'email' field
    }
    return false; // Document doesn't exist or no email match
  } catch (e) {
    print("Error checking email with invitation ID: $e");
    return false;
  }
}

Future<void> markInvitationAsUsed(String invitationId, String userId) async {
  // print("Marking invitation as used: $invitationId");
  // // Example: Simulate network delay
  // await Future.delayed(const Duration(seconds: 1));

  // In a real app: update Firestore or your database
  try {
    await FirebaseFirestore.instance.collection('accepted_volunteers').doc(invitationId).update({'used': true});
    print("Invitation $invitationId marked as used.");
    // await FirebaseFirestore.instance.collection('users').doc(userId).update({'roles.volunteer': true});
  } catch (e) {
    print("Error marking invitation as used: $e");
  }
}

// --- End Placeholder Functions ---

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.invitationId});
  final String? invitationId;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _invitationCheck = false;

  @override
  void initState() {
    super.initState();
    if (widget.invitationId != null && widget.invitationId!.isNotEmpty) {
      // _invitationCheckFuture = checkInvitationId(widget.invitationId!);
      _invitationCheck = true; // Assume invitation check is true for now
    } else {
      // Handle null or empty invitationId immediately without a future
      _invitationCheck = false;
    }
  }

  Widget _buildInvalidInvitationUI(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 16),
              const Text(
                'Invalid or Missing Invitation',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'You can only register using a valid invitation link.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'If you wish to become a volunteer, please apply at:',
                textAlign: TextAlign.center,
              ),
              SelectableText(
                'https://volunteers.example.com/apply',
                style: TextStyle(color: Theme.of(context).primaryColor, decoration: TextDecoration.underline),
                textAlign: TextAlign.center,
                onTap: () {
                  print('Navigate to apply link');
                  // TODO: Implement opening the URL (e.g., using url_launcher)
                  launchUrl(Uri.parse('https://volunteers.example.com/apply'));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.invitationId == null || widget.invitationId!.isEmpty) {
      return _buildInvalidInvitationUI(context);
    }

    // return FutureBuilder<bool>(
    //   future: _invitationCheckFuture,
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return Scaffold(
    //         appBar: AppBar(title: const Text('Verifying Invitation...')),
    //         body: const Center(child: CircularProgressIndicator()),
    //       );
    //     }

    //     if (snapshot.hasError) {
    //       print("Error checking invitation: ${snapshot.error}");
    //       return Scaffold(
    //         appBar: AppBar(title: const Text('Error')),
    //         body: Center(child: Text('Error verifying invitation: ${snapshot.error}')),
    //       );
    //     }

    //     final bool isInvitationValid = snapshot.data ?? false;

    //     if (isInvitationValid) {
    //       return RegistrationFlow(invitationId: widget.invitationId!);
    //     } else {
    //       return _buildInvalidInvitationUI(context);
    //     }
    //   },
    // );
    if (!_invitationCheck) {
      return _buildInvalidInvitationUI(context);
    }

    return RegistrationFlow(
      invitationId: widget.invitationId!,
    );
  }
}

class RegistrationFlow extends StatelessWidget {
  /// Constructs a [RegistrationFlow]
  const RegistrationFlow({super.key, required this.invitationId});

  /// The invitation ID for the registration
  final String invitationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Your Registration')),
      body: Padding( 
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView( 
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Important: Please register using the same email address that you provided in your volunteer application form.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                SignInScreen( 
                  providers: [
                    EmailAuthProvider(),
                  ],
                  actions: [
                    AuthStateChangeAction<SignedIn>((context, state) async { 
                      final userEmail = state.user?.email;
                      bool isEmailValid = await checkEmailWithInvitationId(userEmail, invitationId);

                      if (isEmailValid) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Registration successful! Welcome!')),
                        );
                        print("Registration successful for $userEmail");
                        // TODO: Navigate to the main part of the volunteer app
                        context.go('/'); // Adjust the route as needed
                        // TODO: Mark invitationId as used
                        markInvitationAsUsed(invitationId, state.user!.uid);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Registration Error: The email "$userEmail" is not the one associated with this invitation. Please use the correct email or contact support.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        await FirebaseAuth.instance.signOut();
                        print("Incorrect email $userEmail for invitation $invitationId. User signed out.");
                      }
                    }),
                     AuthStateChangeAction<AuthFailed>((context, state) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Authentication failed: ${state.exception.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        print("AuthFailed: ${state.exception}");
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}