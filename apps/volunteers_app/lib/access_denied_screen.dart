import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'constants.dart';

class AccessDeniedScreen extends StatelessWidget {
  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  AccessDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Denied'),
        backgroundColor: Colors.redAccent,
        automaticallyImplyLeading: false, // No back button needed
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.lock_outline,
                size: 80,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 20),
              const Text(
                'Access Denied',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              const Text(
                'You do not have permission to use this application. '
                'To request access, please fill out the volunteer registration form.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              if (uid != null)
                Container(
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.only(top: 25.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Copy your User ID below and paste it into the access request form:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SelectableText(
                            uid!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.blueGrey,
                              fontFamily: 'monospace',
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 18),
                            tooltip: 'Copy UID',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: uid!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('User ID copied to clipboard'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.description_outlined),
                label: const Text('Open Access Form'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  final Uri formUrl = Uri.parse(VOLUNTEER_REGISTRATION_FORM_URL);
                  launchUrl(formUrl);
                },
              ),
              const SizedBox(height: 20),
              TextButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  // The AuthGate will handle navigation back to the sign-in screen.
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
