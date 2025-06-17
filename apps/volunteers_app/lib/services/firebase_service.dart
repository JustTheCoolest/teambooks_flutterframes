import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Models to represent the data structures
class DonorDetails {
  String? phoneNumber; // Can be null for anonymous
  String name;
  String? companyOrApartment; // Dynamic list with create option - handled by UI
  String? email; // For receipt

  DonorDetails({
    this.phoneNumber,
    required this.name,
    this.companyOrApartment,
    this.email,
  });

  Map<String, dynamic> toJson() => {
    if (phoneNumber != null && phoneNumber!.isNotEmpty)
      'phoneNumber': phoneNumber,
    'name': name,
    if (companyOrApartment != null && companyOrApartment!.isNotEmpty)
      'companyOrApartment': companyOrApartment,
    if (email != null && email!.isNotEmpty) 'email': email,
  };
}

class BookEntry {
  String isbn;
  // Details like title, author will be fetched by cloud function
  // and included in the receipt, not necessarily stored directly here from UI

  BookEntry({required this.isbn});
}

class FirebaseService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<bool> validateCurrentVolunteer() async {
    final user = _auth.currentUser;
    if (user == null) {
      // Or throw an exception that the UI can catch
      return false; // Not logged in, so cannot be a valid volunteer
    }
    // The 'validateVolunteer' cloud function doesn't need parameters if it uses auth context
    final callable = _functions.httpsCallable('validateVolunteer');
    try {
      final result = await callable.call();
      return result.data['exists'] as bool? ?? false;
    } on FirebaseFunctionsException catch (e) {
      // Log or handle specific Firebase Functions errors
      print("Error calling validateVolunteer: ${e.code} - ${e.message}");
      throw Exception(
        "Error validating volunteer status: ${e.message}",
      ); // Re-throw for UI to catch
    } catch (e) {
      // Handle other errors
      print("Generic error calling validateVolunteer: $e");
      throw Exception(
        "An unexpected error occurred during validation.",
      ); // Re-throw for UI to catch
    }
  }

  Future<Map<String, dynamic>> checkPhoneNumberExists(
    String phoneNumber,
  ) async {
    final callable = _functions.httpsCallable('checkPhoneNumberExists');
    final response = await callable.call(<String, dynamic>{
      'phoneNumber': phoneNumber,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getBookDetails(String isbn) async {
    final callable = _functions.httpsCallable('getBookDetails');
    final response = await callable.call(<String, dynamic>{'isbn': isbn});
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> addBookToCatalog(
    DonorDetails donorDetails,
    List<String> isbns,
  ) async {
    if (currentUser == null) {
      throw Exception("User not logged in. Cannot add book to catalog.");
    }
    final callable = _functions.httpsCallable('addBookToCatalog');
    final response = await callable.call(<String, dynamic>{
      'donorDetails': donorDetails.toJson(),
      'isbns': isbns,
      // Volunteer UID is automatically picked up by the Cloud Function from the auth context
    });
    return response.data as Map<String, dynamic>;
  }
}
