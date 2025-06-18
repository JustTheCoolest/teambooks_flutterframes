import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:volunteers_app/firebase_options.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:http/http.dart' as http;

// final firebase_instance = FirebaseFunctions.instanceFor(region: 'asia-south1');
final firebase_instance = FirebaseFunctions.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  firebase_instance.useFunctionsEmulator('192.168.1.13', 5001);
  // await FirebaseAuth.instance.signInWithEmailAndPassword(
  //   email: '---',
  //   password: '---',
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: firebase_instance.httpsCallable('helloworld').call(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else {
            print('Snapshot data: ${snapshot.data}');
            return Text('Result: ${snapshot.data as bool}');
          }
        },
      ),
    );
  }
}
