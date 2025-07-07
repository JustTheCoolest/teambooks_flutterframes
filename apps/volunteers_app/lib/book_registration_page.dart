import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:form_builder_phone_field/form_builder_phone_field.dart';

// Data models, previously in firebase_service.dart
class BookEntry {
  final String isbn;
  BookEntry({required this.isbn});
}

class DonorDetails {
  final String? phoneNumber;
  final String name;
  final String? companyOrApartment;
  final String? email;

  DonorDetails({
    this.phoneNumber,
    required this.name,
    this.companyOrApartment,
    this.email,
  });
}

class BookRegistrationPage extends StatelessWidget {
  const BookRegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Book Donation')),
      body: const BookRegistrationForm(),
    );
  }
}

class BookRegistrationForm extends StatefulWidget {
  const BookRegistrationForm({super.key});

  @override
  State<BookRegistrationForm> createState() => _BookRegistrationFormState();
}

enum RegistrationStep { donorType, donorDetails, bookEntry }

class _BookRegistrationFormState extends State<BookRegistrationForm> {
  final _formKey = GlobalKey<FormBuilderState>();

  RegistrationStep _currentStep = RegistrationStep.donorType;
  bool _isAnonymous = false;
  bool _isCheckingPhone = false;
  bool _isSubmitting = false;
  bool _isExistingDonor = false;
  bool _donorDetailsLocked = false;

  final _isbnController = TextEditingController();
  final List<BookEntry> _books = [];
  String? _errorMessage;

  // --- Placeholder Functions for backend interaction ---

  /// Simulates checking if a phone number exists in the backend.
  Future<Map<String, dynamic>?> _checkPhoneNumberExists(
    String phoneNumber,
  ) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    if (phoneNumber == '+911234567890') {
      return {
        'exists': true,
        'donorId': 'donor123',
        'name': 'Balu',
        'email': 'balu@test.com',
        'group': 'Test Apt',
        'phoneNumber': '+911234567890',
      };
    }
    return {'exists': false};
  }

  /// Simulates submitting the registration to the backend.
  Future<void> _addBookDonation(
    DonorDetails donorDetails,
    List<String> isbns,
  ) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    debugPrint(
      'Registering donor: ${donorDetails.name} with ${isbns.length} books.',
    );
    // Simulate success, no return value needed for Future<void>
  }

  @override
  void dispose() {
    _isbnController.dispose();
    super.dispose();
  }

  Future<void> _checkPhoneNumber() async {
    final phoneField = _formKey.currentState!.fields['phone']!;
    if (!phoneField.validate()) return;
    phoneField.save();
    final phoneNumber =
        (phoneField as FormBuilderPhoneFieldState).fullNumber.trim();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(phoneNumber)));

    if (phoneNumber.isEmpty) {
      setState(() {
        _isExistingDonor = false;
        _donorDetailsLocked = false;
        // _formKey.currentState?.patchValue({
        //   'name': '',
        //   'email': '',
        //   'companyOrApartment': '',
        // });
        _currentStep = RegistrationStep.donorDetails;
      });
      return;
    }

    setState(() {
      _isCheckingPhone = true;
      _errorMessage = null;
    });

    try {
      final response = await _checkPhoneNumberExists(phoneNumber);
      if (!mounted) return;

      setState(() {
        _isExistingDonor = response!['exists'] as bool;
        if (_isExistingDonor) {
          _formKey.currentState?.patchValue({
            'name': response['name'],
            'email': response['email'],
            'companyOrApartment': response['group'],
          });
          _donorDetailsLocked = true;
        } else {
          // _formKey.currentState?.patchValue({
          //   'name': '',
          //   'email': '',
          //   'companyOrApartment': '',
          // });
          _donorDetailsLocked = false;
        }
        _currentStep = RegistrationStep.donorDetails;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = "Error checking phone: ${e.toString()}");
      }
    } finally {
      if (mounted) setState(() => _isCheckingPhone = false);
    }
  }

  Future<void> _addBook() async {
    final isbn = _isbnController.text.trim();
    if (isbn.isEmpty || _books.any((b) => b.isbn == isbn)) {
      _isbnController.clear();
      return;
    }
    setState(() {
      _books.add(BookEntry(isbn: isbn));
      _isbnController.clear();
    });
  }

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.saveAndValidate() ?? false)) {
      setState(
        () => _errorMessage = 'Please correct the errors before submitting.',
      );
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

    final formValue = _formKey.currentState!.value;
    final donorDetails = DonorDetails(
      phoneNumber: _isAnonymous ? null : formValue['phone'] as String?,
      name: formValue['name'] as String,
      email: formValue['email'] as String?,
      companyOrApartment: formValue['companyOrApartment'] as String?,
    );
    final isbns = _books.map((b) => b.isbn).toList();

    try {
      await _addBookDonation(donorDetails, isbns);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donation submitted successfully!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = "Submission failed: ${e.toString()}");
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _formKey,
      child: Stepper(
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
                          onPressed:
                              _isCheckingPhone ? null : details.onStepContinue,
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
      ),
    );
  }

  void _onStepContinue() {
    final formState = _formKey.currentState!;
    switch (_currentStep) {
      case RegistrationStep.donorType:
        if (_isAnonymous) {
          setState(() => _currentStep = RegistrationStep.bookEntry);
        } else {
          _checkPhoneNumber();
        }
        break;
      case RegistrationStep.donorDetails:
        if (formState.fields['name']!.validate()) {
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
      if (_isAnonymous) {
        setState(() => _currentStep = RegistrationStep.donorType);
      } else {
        setState(() => _currentStep = RegistrationStep.donorDetails);
      }
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
              child: FormBuilderPhoneField(
                name: 'phone',
                decoration: InputDecoration(
                  labelText: 'Phone Number (Optional)',
                  hintText: 'Enter phone to find existing donor',
                  suffixIcon:
                      _isCheckingPhone
                          ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          )
                          : null,
                ),
                defaultSelectedCountryIsoCode: 'IN',
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.integer(),
                ]),
              ),
            ),
          if (_errorMessage != null &&
              _currentStep == RegistrationStep.donorType)
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
          FormBuilderTextField(
            name: 'name',
            decoration: const InputDecoration(labelText: 'Name*'),
            readOnly: _donorDetailsLocked,
            validator: FormBuilderValidators.required(
              errorText: 'Name is required',
            ),
          ),
          FormBuilderTextField(
            name: 'email',
            decoration: const InputDecoration(labelText: 'Email (for receipt)'),
            keyboardType: TextInputType.emailAddress,
            readOnly: _donorDetailsLocked,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.email(
                errorText: 'Please enter a valid email address',
              ),
            ]),
          ),
          FormBuilderTextField(
            name: 'companyOrApartment',
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
                  title: Text(book.isbn),
                  subtitle: const Text(
                    'Details will be fetched upon submission',
                  ),
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
