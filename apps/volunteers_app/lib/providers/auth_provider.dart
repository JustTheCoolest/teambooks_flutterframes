import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VolunteerAuthProvider extends ChangeNotifier {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool? _isValidVolunteer;
  bool _isLoading = false;
  String? _errorMessage;
  User? _user;

  bool? get isValidVolunteer => _isValidVolunteer;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get user => _user;

  VolunteerAuthProvider() {
    _user = _auth.currentUser;
    // Removed authStateChanges listener to prevent automatic re-validation or state reset on auth change.
    // Validation will now primarily be triggered by explicit calls to validateVolunteer().
    // Consider the implications if the auth state changes elsewhere in the app
    // and this provider is not re-initialized or validateVolunteer() isn't re-called.
  }

  Future<void> validateVolunteer() async {
    // It's good to refresh the user state at the beginning of an explicit validation call,
    // in case it changed since the provider was initialized.
    _user = _auth.currentUser;

    if (_user == null) {
      _errorMessage = "User not logged in.";
      _isValidVolunteer = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final HttpsCallable callable = _functions.httpsCallable(
        'validateVolunteer',
      );
      final result = await callable.call();
      _isValidVolunteer = result.data['exists'] as bool? ?? false;
    } on FirebaseFunctionsException catch (e) {
      _errorMessage =
          "Error validating volunteer: ${e.message} (Code: ${e.code})";
      _isValidVolunteer = false;
    } catch (e) {
      _errorMessage = "An unexpected error occurred: ${e.toString()}";
      _isValidVolunteer = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  void reset() {
    _isValidVolunteer = null;
    _isLoading = false;
    _errorMessage = null;
    // _user is managed by FirebaseAuth listener
    notifyListeners();
  }
}
