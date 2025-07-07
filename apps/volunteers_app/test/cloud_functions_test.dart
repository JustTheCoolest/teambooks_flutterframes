import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:volunteers_app/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'credentials.dart';

final firebase_instance = FirebaseFunctions.instanceFor(region: 'asia-south1');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  firebase_instance.useFunctionsEmulator('192.168.1.13', 5001);
  await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: firebase_instance.httpsCallable('check_phone_number_exists').call({
          'phoneNumber': "1234567890"
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // Handle the error case
            return Text('Error: ${snapshot.error}');
          } else {
            print('Snapshot data: ${snapshot.data!.data}');
            return Text('Result: ${snapshot.data!.data}');
          }
        },
      ),
    );
  }
}
