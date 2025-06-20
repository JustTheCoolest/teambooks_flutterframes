import 'package:flutter/material.dart';
import 'dart:async';

// Placeholder models based on pseudocode
class DonorDetails {
  String? phoneNumber;
  String name;
  String? email;
  String? companyOrApartment;

  DonorDetails({
    this.phoneNumber,
    required this.name,
    this.email,
    this.companyOrApartment,
  });
}

class BookDetails {
  String isbn;
  String? title;
  String? author;
  // Genre was in pseudocode, but not used in UI logic, keeping it simple.
  // String? genre;

  BookDetails({required this.isbn, this.title, this.author});
}

class BookRegistrationPage extends StatelessWidget {
  const BookRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Book Donation')),
      // Using a separate widget for the form improves readability and state management.
      body: const BookRegistrationForm(),
    );
  }
}

class BookRegistrationForm extends StatefulWidget {
  const BookRegistrationForm({super.key});

  @override
  State<BookRegistrationForm> createState() => _BookRegistrationFormState();
}

// Enum to manage the current step in the registration process.
enum RegistrationStep { donorType, donorDetails, bookEntry }

class _BookRegistrationFormState extends State<BookRegistrationForm> {
  // State management for the stepper and form logic
  RegistrationStep _currentStep = RegistrationStep.donorType;
  bool _isAnonymous = false;
  bool _isCheckingPhone = false;
  bool _isSubmitting = false;
  bool _isExistingDonor = false;
  bool _donorDetailsLocked = false;

  // Form controllers
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _companyController = TextEditingController();
  final _isbnController = TextEditingController();

  // Data storage
  final List<BookDetails> _books = [];
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    _isbnController.dispose();
    super.dispose();
  }

  // --- Placeholder Functions for Business Logic ---

  /// Placeholder to check if a phone number belongs to an existing donor.
  Future<void> _checkPhoneNumber() async {
    if (_phoneController.text.trim().isEmpty) {
      // If phone is empty, treat as a new, non-anonymous donor.
      setState(() {
        _isExistingDonor = false;
        _donorDetailsLocked = false;
        _nameController.clear();
        _emailController.clear();
        _companyController.clear();
        _currentStep = RegistrationStep.donorDetails;
      });
      return;
    }

    setState(() {
      _isCheckingPhone = true;
      _errorMessage = null;
    });

    // Simulate a network call to a backend service.
    await Future.delayed(const Duration(seconds: 1));

    // --- MOCK BACKEND RESPONSE ---
    // In a real app, this would be an API call, e.g.:
    // final response = await FirebaseService().checkPhoneNumberExists(_phoneController.text.trim());
    final isExisting = _phoneController.text.trim() == '1234567890';
    final mockDonorData = {
      'name': 'Jane Doe (Existing)',
      'email': 'jane.doe@example.com',
      'companyOrApartment': 'Flutter Corp',
    };
    // --- END MOCK ---

    if (!mounted) return;

    setState(() {
      _isExistingDonor = isExisting;
      if (_isExistingDonor) {
        _nameController.text = mockDonorData['name']!;
        _emailController.text = mockDonorData['email']!;
        _companyController.text = mockDonorData['companyOrApartment']!;
        _donorDetailsLocked = true;
      } else {
        // Clear fields for new donor entry.
        _nameController.clear();
        _emailController.clear();
        _companyController.clear();
        _donorDetailsLocked = false;
      }
      _isCheckingPhone = false;
      _currentStep = RegistrationStep.donorDetails;
    });
  }

  /// Placeholder to fetch book details from an ISBN.
  Future<void> _addBook() async {
    final isbn = _isbnController.text.trim();
    if (isbn.isEmpty || _books.any((b) => b.isbn == isbn)) {
      _isbnController.clear();
      return;
    }

    // --- MOCK BACKEND RESPONSE ---
    // In a real app, this would be an API call, e.g.:
    // final details = await FirebaseService().getBookDetails(isbn);
    final mockBookDetails = BookDetails(
      isbn: isbn,
      title: 'The Art of Flutter',
      author: 'Dr. Widget',
    );
    // --- END MOCK ---

    setState(() {
      _books.add(mockBookDetails);
      _isbnController.clear();
    });
  }

  /// Placeholder to submit the final donation registration.
  Future<void> _submitForm() async {
    // Basic validation
    if (_nameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Donor name is required.');
      return;
    }
    if (_books.isEmpty) {
      setState(() => _errorMessage = 'At least one book must be added.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final donorDetails = DonorDetails(
      phoneNumber: _isAnonymous ? null : _phoneController.text.trim(),
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      companyOrApartment: _companyController.text.trim(),
    );

    // --- MOCK BACKEND SUBMISSION ---
    // In a real app, this would be an API call, e.g.:
    // final receipt = await FirebaseService().addBookDonation(donorDetails, _books);
    print(
      'Submitting donation for ${donorDetails.name} with ${_books.length} books.',
    );
    await Future.delayed(const Duration(seconds: 2));
    // --- END MOCK ---

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    // On success, show a confirmation and pop the page.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Donation submitted successfully!')),
    );
    Navigator.of(context).pop();
  }

  // --- UI Builder Methods ---

  @override
  Widget build(BuildContext context) {
    // Using a Stepper to guide the user through the registration process.
    return Stepper(
      type: StepperType.vertical,
      currentStep: _currentStep.index,
      onStepContinue: _onStepContinue,
      onStepCancel: _onStepCancel,
      steps: [
        _buildDonorTypeStep(),
        _buildDonorDetailsStep(),
        _buildBookEntryStep(),
      ],
      controlsBuilder: (context, details) {
        return Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child:
              _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                    children: [
                      ElevatedButton(
                        onPressed: details.onStepContinue,
                        child: Text(
                          _currentStep == RegistrationStep.bookEntry
                              ? 'Submit'
                              : 'Next',
                        ),
                      ),
                      if (_currentStep != RegistrationStep.donorType)
                        TextButton(
                          onPressed: details.onStepCancel,
                          child: const Text('Back'),
                        ),
                    ],
                  ),
        );
      },
    );
  }

  void _onStepContinue() {
    switch (_currentStep) {
      case RegistrationStep.donorType:
        if (_isAnonymous) {
          setState(() => _currentStep = RegistrationStep.donorDetails);
        } else {
          _checkPhoneNumber();
        }
        break;
      case RegistrationStep.donorDetails:
        if (_nameController.text.trim().isNotEmpty) {
          setState(() {
            _errorMessage = null;
            _currentStep = RegistrationStep.bookEntry;
          });
        } else {
          setState(() => _errorMessage = 'Donor name is required to proceed.');
        }
        break;
      case RegistrationStep.bookEntry:
        _submitForm();
        break;
    }
  }

  void _onStepCancel() {
    if (_currentStep == RegistrationStep.donorDetails) {
      setState(() => _currentStep = RegistrationStep.donorType);
    } else if (_currentStep == RegistrationStep.bookEntry) {
      setState(() => _currentStep = RegistrationStep.donorDetails);
    }
  }

  Step _buildDonorTypeStep() {
    return Step(
      title: const Text('Step 1: Donor Information'),
      subtitle: const Text('Anonymous or existing donor?'),
      isActive: _currentStep == RegistrationStep.donorType,
      state: _currentStep.index > 0 ? StepState.complete : StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: const Text('Donate anonymously'),
            value: _isAnonymous,
            onChanged: (value) => setState(() => _isAnonymous = value),
          ),
          if (!_isAnonymous)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter phone to find existing donor',
                  suffixIcon:
                      _isCheckingPhone
                          ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          )
                          : null,
                ),
                keyboardType: TextInputType.phone,
                onFieldSubmitted: (_) => _checkPhoneNumber(),
              ),
            ),
        ],
      ),
    );
  }

  Step _buildDonorDetailsStep() {
    return Step(
      title: const Text('Step 2: Donor Details'),
      isActive: _currentStep == RegistrationStep.donorDetails,
      state: _currentStep.index > 1 ? StepState.complete : StepState.indexed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isExistingDonor)
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('Existing donor found.')),
                  if (_donorDetailsLocked)
                    TextButton.icon(
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                      onPressed:
                          () => setState(() => _donorDetailsLocked = false),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name*'),
            readOnly: _donorDetailsLocked,
            validator: (v) => v!.isEmpty ? 'Name is required' : null,
          ),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email (for receipt)'),
            keyboardType: TextInputType.emailAddress,
            readOnly: _donorDetailsLocked,
          ),
          TextFormField(
            controller: _companyController,
            decoration: const InputDecoration(labelText: 'Company / Apartment'),
            readOnly: _donorDetailsLocked,
          ),
          if (_errorMessage != null &&
              _currentStep == RegistrationStep.donorDetails)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  Step _buildBookEntryStep() {
    return Step(
      title: const Text('Step 3: Add Books'),
      isActive: _currentStep == RegistrationStep.bookEntry,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _isbnController,
            decoration: InputDecoration(
              labelText: 'Enter ISBN',
              suffixIcon: IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Add Book',
                onPressed: _addBook,
              ),
            ),
            onFieldSubmitted: (_) => _addBook(),
          ),
          const SizedBox(height: 10),
          if (_books.isEmpty)
            const Center(
              child: Text(
                'No books added yet.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _books.length,
            itemBuilder: (context, index) {
              final book = _books[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.book_outlined),
                  title: Text(book.title ?? 'Title Not Found'),
                  subtitle: Text('ISBN: ${book.isbn}'),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.redAccent,
                    ),
                    onPressed: () => setState(() => _books.removeAt(index)),
                  ),
                ),
              );
            },
          ),
          if (_errorMessage != null &&
              _currentStep == RegistrationStep.bookEntry)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}
