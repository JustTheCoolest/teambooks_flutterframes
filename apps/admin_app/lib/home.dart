import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> approveVolunteer({required String uid, required String email}) async {
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
                  builder: (context) => ProfileScreen(
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

  String? _email;
  bool _uidExists = false;
  bool _checkingUid = false;

  @override
  void dispose() {
    _uidController.dispose();
    super.dispose();
  }

  Future<void> fetchEmailForUid(String uid) async {
    setState(() {
      _checkingUid = true;
      _uidExists = false;
      _email = null;
    });
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      _checkingUid = false;
      _uidExists = doc.exists;
      _email = doc.data()?['email'];
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
    _uidExists = false;
    _email = null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> fetchEmailForUid(String uid) async {
              setState(() {
                _checkingUid = true;
                _uidExists = false;
                _email = null;
              });
              final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
              setState(() {
                _checkingUid = false;
                _uidExists = doc.exists;
                _email = doc.data()?['email'];
              });
            }

            return AlertDialog(
              title: const Text('Approve Volunteer'),
              content: Container(
                width: 300,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                            fetchEmailForUid(value);
                          } else {
                            setState(() {
                              _uidExists = false;
                              _email = null;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      if (_email != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Email found:'),
                            SelectableText(_email!, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
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
                    if (_formKey.currentState!.validate() && _email != null) {
                      try {
                        await approveVolunteer(
                          uid: _uidController.text,
                          email: _email!,
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
