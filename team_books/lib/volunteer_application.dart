import 'package:flutter/material.dart';
import 'services/database_service.dart';

class VolunteerApplicationPage extends StatelessWidget {
  final List<String> categories = [
    'Web Development', 'Sponsorships', 'Finance', 'Legal', 'Physical Collection',
    'Data Analysts and Computer Vision', 'Certificates and HR', 'Customer Support', 'Marketing'
  ];

  Future<void> _submitApplication(BuildContext context, String category) async {
    Map<String, dynamic> applicationData = {
      "category": category,
      "applied_at": DateTime.now().toString(),
    };

    await DatabaseService.insertVolunteerApplication(applicationData);
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false); // Redirect to Home Page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Volunteer Application')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Please check all the categories you're interested in volunteering for."),
            ...categories.map((category) => ListTile(
              title: Text(category),
              trailing: ElevatedButton(
                onPressed: () => _submitApplication(context, category),
                child: Text('Select'),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
