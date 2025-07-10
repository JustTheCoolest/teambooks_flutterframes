// Reference: 
// 1. https://firebase.google.com/codelabs/firebase-auth-in-flutter-apps

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';

final firebase_instance = FirebaseFunctions.instanceFor(region: 'asia-south1');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  firebase_instance.useFunctionsEmulator('127.0.0.1', 5001);
  runApp(const MyApp());
}
