import '../constants.dart';
import 'package:flutter/material.dart';

void submitVolunteerApplication({
  required String name,
  required String email,
  required String phone,
  required String category,
}) {
  // FirebaseFirestore.instance.collection(firestoreVolunteerApplications).add({
  //   'name': name,
  //   'email': email,
  //   'phone': phone,
  //   'category': category,
  //   'status': 'pending',
  //   'submittedAt': FieldValue.serverTimestamp(),
  // });
  return;
}

class VolunteerApplicationPage extends StatefulWidget {
  const VolunteerApplicationPage({super.key});
  @override
  State<VolunteerApplicationPage> createState() =>
      _VolunteerApplicationPageState();
}

class _VolunteerApplicationPageState extends State<VolunteerApplicationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _category = 'Sorting';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Volunteer Application')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              DropdownButtonFormField<String>(
                value: _category,
                items: const [
                  DropdownMenuItem(value: 'Sorting', child: Text('Sorting')),
                  DropdownMenuItem(value: 'Pickup', child: Text('Pickup')),
                  DropdownMenuItem(
                    value: 'Cataloguing',
                    child: Text('Cataloguing'),
                  ),
                ],
                onChanged: (value) => setState(() => _category = value!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    submitVolunteerApplication(
                      name: _nameController.text,
                      email: _emailController.text,
                      phone: _phoneController.text,
                      category: _category,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Application submitted')),
                    );
                  }
                },
                child: const Text('Submit'),
              ),
              const SizedBox(height: 40),
              const Text(
                'Volunteer Roles:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text(
                '• Sorting: Help organize books by genre or condition',
              ),
              const Text('• Pickup: Collect books from donors'),
              const Text('• Cataloguing: Add book metadata to system'),
            ],
          ),
        ),
      ),
    );
  }
}
