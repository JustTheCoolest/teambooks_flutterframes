import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:volunteers_app/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.useFirestoreEmulator('192.168.1.13', 8088);
  await FirebaseFirestore.instance
      .collection('volunteers')
      .doc('TestCollection')
      .set({
        'items': [1, 2, 3],
      });
}
