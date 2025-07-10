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
  State<ApproveExistingAccountForm> createState() => _ApproveExistingAccountFormState();
}

class _ApproveExistingAccountFormState extends State<ApproveExistingAccountForm> {
  final _formKey = GlobalKey<FormState>();
  final _uidController = TextEditingController();
  final _emailController = TextEditingController();

  bool _uidExists = false;
  bool _emailExists = false;
  bool _checkingUid = false;
  bool _checkingEmail = false;

  @override
  void dispose() {
    _uidController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> checkUidExists(String uid) async {
    setState(() {
      _checkingUid = true;
      _uidExists = false;
    });
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      _checkingUid = false;
      _uidExists = doc.exists;
    });
  }

  Future<void> checkEmailExists(String email) async {
    setState(() {
      _checkingEmail = true;
      _emailExists = false;
    });
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    setState(() {
      _checkingEmail = false;
      _emailExists = querySnapshot.docs.isNotEmpty;
    });
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
    _uidExists = false;
    _emailExists = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> checkUidExists(String uid) async {
              setState(() {
                _checkingUid = true;
                _uidExists = false;
              });
              final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
              setState(() {
                _checkingUid = false;
                _uidExists = doc.exists;
              });
            }

            Future<void> checkEmailExists(String email) async {
              setState(() {
                _checkingEmail = true;
                _emailExists = false;
              });
              final querySnapshot = await FirebaseFirestore.instance
                  .collection('users')
                  .where('email', isEqualTo: email)
                  .get();
              setState(() {
                _checkingEmail = false;
                _emailExists = querySnapshot.docs.isNotEmpty;
              });
            }

            return AlertDialog(
              title: const Text('Approve Volunteer'),
              content: Container(
                width: 300,
                constraints: const BoxConstraints(maxHeight: 300),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      TextFormField(
                        controller: _uidController,
                        decoration: InputDecoration(
                          hintText: "UID of Volunteer's Account",
                          suffixIcon: _checkingUid
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : (_uidExists
                                  ? const Icon(Icons.check, color: Colors.green)
                                  : null),
                        ),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter UID';
                          }
                          if (!_uidExists) {
                            return 'UID does not exist';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            checkUidExists(value);
                          } else {
                            setState(() {
                              _uidExists = false;
                            });
                          }
                        },
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: "Email of Volunteer's Account",
                          suffixIcon: _checkingEmail
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : (_emailExists
                                  ? const Icon(Icons.check, color: Colors.green)
                                  : null),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          if (!_emailExists) {
                            return 'Email does not exist';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            checkEmailExists(value);
                          } else {
                            setState(() {
                              _emailExists = false;
                            });
                          }
                        },
                      ),
                    ],
                  ),
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
                    if (_formKey.currentState!.validate()) {
                      try {
                        await approveVolunteer(
                          uid: _uidController.text,
                          email: _emailController.text,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Volunteer approved')),
                        );
                        Navigator.of(context).pop();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString().replaceFirst("Exception: ", "")}')),
                        );
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
      },
    );
  }
}