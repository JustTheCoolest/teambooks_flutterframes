import 'package:flutter/material.dart';
import 'services/database_service.dart';

class PersonalDetailsPage extends StatefulWidget {
  @override
  _PersonalDetailsPageState createState() => _PersonalDetailsPageState();
}

class _PersonalDetailsPageState extends State<PersonalDetailsPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController introductionController = TextEditingController();
  final TextEditingController motivationController = TextEditingController();

  Future<void> _submitPersonalDetails() async {
    Map<String, dynamic> personalDetails = {
      "first_name": firstNameController.text,
      "last_name": lastNameController.text,
      "email": emailController.text,
      "phone": phoneController.text,
      "introduction": introductionController.text,
      "motivation": motivationController.text,
    };

    await DatabaseService.insertPersonalDetails(personalDetails);
    Navigator.pushNamed(context, '/specialties'); // Redirect to Specialties Page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Personal Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: firstNameController, decoration: InputDecoration(labelText: 'First Name')),
            TextField(controller: lastNameController, decoration: InputDecoration(labelText: 'Last Name')),
            TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: phoneController, decoration: InputDecoration(labelText: 'Phone')),
            TextField(controller: introductionController, decoration: InputDecoration(labelText: 'Introduction')),
            TextField(controller: motivationController, decoration: InputDecoration(labelText: 'Motivation')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitPersonalDetails,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
