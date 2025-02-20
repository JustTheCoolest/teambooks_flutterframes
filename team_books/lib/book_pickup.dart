import 'package:flutter/material.dart';
import 'services/database_service.dart';

class BookPickupPage extends StatefulWidget {
  @override
  _BookPickupPageState createState() => _BookPickupPageState();
}

class _BookPickupPageState extends State<BookPickupPage> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController zipController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  Future<void> _confirmPickup() async {
    Map<String, dynamic> bookPickupData = {
      "address": addressController.text,
      "city": cityController.text,
      "state": stateController.text,
      "zip": zipController.text,
      "email": emailController.text,
      "phone": phoneController.text,
      "pickup_date": dateController.text,
    };

    await DatabaseService.insertBookPickup(bookPickupData);
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false); // Redirect to Home Page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Book Pickup")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("We'll pick up your books. Pack your books and tell us where they are."),
            TextField(controller: addressController, decoration: InputDecoration(labelText: 'Apt, Suite, etc (Optional)')),
            TextField(controller: cityController, decoration: InputDecoration(labelText: 'City')),
            TextField(controller: stateController, decoration: InputDecoration(labelText: 'State')),
            TextField(controller: zipController, decoration: InputDecoration(labelText: 'ZIP Code')),
            TextField(controller: emailController, decoration: InputDecoration(labelText: 'Contact Email')),
            TextField(controller: phoneController, decoration: InputDecoration(labelText: 'Phone Number')),
            TextField(controller: dateController, decoration: InputDecoration(labelText: 'Preferred Pickup Date')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _confirmPickup,
              child: Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}
