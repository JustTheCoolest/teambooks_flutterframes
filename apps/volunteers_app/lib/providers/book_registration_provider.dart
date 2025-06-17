import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class BookRegistrationProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  // Donor Details
  String? _phoneNumber;
  String _name = '';
  String? _companyOrApartment;
  String? _email;
  bool _donorExists = false;
  Map<String, dynamic>? _existingDonorDetails;

  // Book Entries
  final List<BookEntry> _books = [];
  final Map<String, Map<String, dynamic>> _bookDetailsCache =
      {}; // ISBN -> Details

  // UI State
  bool _isLoading = false;
  bool _isVerifyingPhoneNumber = false;
  bool _isVerifyingIsbn = false;
  String? _errorMessage;
  String? _successMessage;
  Map<String, dynamic>? _receiptData;

  // Getters
  String? get phoneNumber => _phoneNumber;
  String get name => _name;
  String? get companyOrApartment => _companyOrApartment;
  String? get email => _email;
  bool get donorExists => _donorExists;
  Map<String, dynamic>? get existingDonorDetails => _existingDonorDetails;
  List<BookEntry> get books => List.unmodifiable(_books);
  Map<String, Map<String, dynamic>> get bookDetailsCache =>
      Map.unmodifiable(_bookDetailsCache);
  bool get isLoading => _isLoading;
  bool get isVerifyingPhoneNumber => _isVerifyingPhoneNumber;
  bool get isVerifyingIsbn => _isVerifyingIsbn;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  Map<String, dynamic>? get receiptData => _receiptData;

  // Setters & Methods
  void setPhoneNumber(String? value) {
    _phoneNumber = value;
    _donorExists = false; // Reset when phone number changes
    _existingDonorDetails = null;
    notifyListeners();
  }

  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  void setCompanyOrApartment(String? value) {
    _companyOrApartment = value;
    notifyListeners();
  }

  void setEmail(String? value) {
    _email = value;
    notifyListeners();
  }

  Future<void> checkPhoneNumber() async {
    if (_phoneNumber == null || _phoneNumber!.isEmpty) {
      _donorExists = false;
      _existingDonorDetails = null;
      _errorMessage = "Phone number cannot be empty to check.";
      notifyListeners();
      return;
    }
    _isVerifyingPhoneNumber = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await _firebaseService.checkPhoneNumberExists(
        _phoneNumber!,
      );
      _donorExists = result['exists'] as bool? ?? false;
      if (_donorExists) {
        // If donor exists, you might want to fetch and prefill more details.
        // For now, we just acknowledge existence. The cloud function returns donorId.
        // Let's assume the cloud function `checkPhoneNumberExists` could return basic details
        // or we make another call. For simplicity, let's say it returns some details.
        _existingDonorDetails =
            result['donorData']
                as Map<String, dynamic>?; // Assuming 'donorData'
        if (_existingDonorDetails != null) {
          _name = _existingDonorDetails!['name'] ?? _name;
          _email = _existingDonorDetails!['email'] ?? _email;
          _companyOrApartment =
              _existingDonorDetails!['companyOrApartment'] ??
              _companyOrApartment;
        }
        _successMessage = "Existing donor found.";
      } else {
        _existingDonorDetails = null;
        _successMessage = "New donor.";
      }
    } catch (e) {
      _donorExists = false;
      _existingDonorDetails = null;
      _errorMessage = "Error checking phone number: ${e.toString()}";
    }
    _isVerifyingPhoneNumber = false;
    notifyListeners();
  }

  void addBook(String isbn) {
    if (isbn.isNotEmpty && !_books.any((b) => b.isbn == isbn)) {
      _books.add(BookEntry(isbn: isbn));
      verifyIsbn(isbn); // Automatically verify when added
      notifyListeners();
    }
  }

  void removeBook(String isbn) {
    _books.removeWhere((b) => b.isbn == isbn);
    _bookDetailsCache.remove(isbn);
    notifyListeners();
  }

  Future<void> verifyIsbn(String isbn) async {
    if (_bookDetailsCache.containsKey(isbn)) return; // Already fetched

    _isVerifyingIsbn = true;
    notifyListeners();
    try {
      final details = await _firebaseService.getBookDetails(isbn);
      _bookDetailsCache[isbn] = details;
    } catch (e) {
      _bookDetailsCache[isbn] = {
        'error': e.toString(),
        'title': 'Error fetching details',
      };
    }
    _isVerifyingIsbn = false;
    notifyListeners();
  }

  Future<bool> submitRegistration() async {
    if (_name.isEmpty) {
      _errorMessage = "Donor name is required.";
      notifyListeners();
      return false;
    }
    if (_books.isEmpty) {
      _errorMessage = "At least one book (ISBN) is required.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    _receiptData = null;
    notifyListeners();

    final donorDetails = DonorDetails(
      phoneNumber: _phoneNumber,
      name: _name,
      companyOrApartment: _companyOrApartment,
      email: _email,
    );
    final isbns = _books.map((b) => b.isbn).toList();

    try {
      final result = await _firebaseService.addBookToCatalog(
        donorDetails,
        isbns,
      );
      _receiptData = result;
      _successMessage = "Books registered successfully!";
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Error registering books: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearForm() {
    _phoneNumber = null;
    _name = '';
    _companyOrApartment = null;
    _email = null;
    _donorExists = false;
    _existingDonorDetails = null;
    _books.clear();
    _bookDetailsCache.clear();
    _errorMessage = null;
    _successMessage = null;
    _receiptData = null;
    _isLoading = false;
    notifyListeners();
  }
}
