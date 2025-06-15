import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> approveVolunteer({required String uid, required String email}) async {
  // Task: Check if exceptions are notified to the user
  final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
  if (!doc.exists) {
    throw Exception('User does not exist');
  }
  final emailInCloud = doc.data()?['email'];
  if (emailInCloud != email) {
    throw Exception('Email does not match');
  }
  await FirebaseFirestore.instance.collection('users').doc(uid).update({
    'roles.volunteer': true,
  });
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<ProfileScreen>(
                  builder:
                      (context) => ProfileScreen(
                        appBar: AppBar(title: const Text('User Profile')),
                        actions: [
                          SignedOutAction((context) {
                            Navigator.of(context).pop();
                          }),
                        ],
                      ),
                ),
              );
            },
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          children: [
            Text('Welcome!', style: Theme.of(context).textTheme.displaySmall),
            VolunteerCreationForm(),
          ],
        ),
      ),
    );
  }
}

class VolunteerCreationForm extends StatelessWidget {
  const VolunteerCreationForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add a Volunteer',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // CreateNewAccountForm(),
                  // const SizedBox(height: 16),
                  ApproveExistingAccountForm(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ApproveExistingAccountForm extends StatefulWidget {
  const ApproveExistingAccountForm({super.key});

  @override
  State<ApproveExistingAccountForm> createState() =>
      _ApproveExistingAccountFormState();
}

class _ApproveExistingAccountFormState
    extends State<ApproveExistingAccountForm> {
  final _formKey = GlobalKey<FormState>();
  final _uidController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _uidController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showApprovalDialog(context);
      },
      child: const Text('Approve Existing Volunteer Account'),
    );
  }

  void showApprovalDialog(BuildContext context) {
    _uidController.clear();
    _emailController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Approve Volunteer'),
          content: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                TextFormField(
                  controller: _uidController,
                  decoration: const InputDecoration(
                    hintText: "UID of Volunteer's Account",
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter UID';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: "Email of Volunteer's Account",
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Handle the approval logic here
                if (_formKey.currentState!.validate()) {
                  try {
                    await approveVolunteer(
                      uid: _uidController.text,
                      email: _emailController.text,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Volunteer approved')),
                    );
                    Navigator.of(context).pop(); // Pop only on success
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString().replaceFirst("Exception: ", "")}')), // Display a cleaner error
                    );
                    // Optionally, don't pop the dialog on error, so the user can try again or see the error.
                    // Navigator.of(context).pop(); 
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please correct the errors')),
                  );
                }
              },
              child: const Text('Approve'),
            ),
          ],
        );
      },
    );
  }
}
