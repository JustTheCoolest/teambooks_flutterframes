import 'package:flutter/material.dart';

class VolunteerApplicationPage extends StatelessWidget {
  final List<String> categories = [
    'Web Development',
    'Sponsorships',
    'Finance',
    'Legal',
    'Physical Collection',
    'Data Analysts and Computer Vision',
    'Certificates and HR',
    'Customer Support',
    'Marketing'
  ];

  const VolunteerApplicationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Volunteer Application')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            //Image.asset('volunteer_image.jpg'),
            Text("Please check all the categories you're interested in volunteering for."),
            ...categories.map((category) => ListTile(
                  title: Text(category),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/personal_details');
                    },
                    child: Text('Select'),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
