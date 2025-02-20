import 'package:flutter/material.dart';
import 'services/database_service.dart';

class SpecialtiesPage extends StatefulWidget {
  @override
  _SpecialtiesPageState createState() => _SpecialtiesPageState();
}

class _SpecialtiesPageState extends State<SpecialtiesPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController workAllowedController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController availabilityController = TextEditingController();
  final TextEditingController resumeController = TextEditingController();

  Future<void> _submitSpecialties() async {
    Map<String, dynamic> specialties = {
      "name": nameController.text,
      "work_allowed": workAllowedController.text,
      "experience": experienceController.text,
      "availability": availabilityController.text,
      "resume": resumeController.text,
    };

    await DatabaseService.insertSpecialties(specialties);
    Navigator.pop(context); // Redirect back
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Volunteer Specialties')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("We need your help. Please fill out the application below.", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Your Full Name')),
            TextField(controller: workAllowedController, decoration: InputDecoration(labelText: 'Are you allowed to perform the required work?')),
            TextField(controller: experienceController, decoration: InputDecoration(labelText: 'Relevant Experience')),
            TextField(controller: availabilityController, decoration: InputDecoration(labelText: 'Availability (Next 3 Months)')),
            TextField(controller: resumeController, decoration: InputDecoration(labelText: 'Resume or LinkedIn Profile')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitSpecialties,
              child: Text('Submit Application'),
            ),
          ],
        ),
      ),
    );
  }
}
