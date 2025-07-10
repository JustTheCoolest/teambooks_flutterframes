import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:form_builder_phone_field/form_builder_phone_field.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'constants.dart' as constants;

final firebase_instance = FirebaseFunctions.instanceFor(region: 'asia-south1');

Future<bool> isOffline() async {
  return await InternetConnectionChecker.instance.hasConnection;
}

class BookEntry {
  final String? isbn;
  final Map<String, dynamic>? bookDetails; // manual entry
  final bool wasOfflineBookDetails;

  BookEntry({this.isbn, this.bookDetails, this.wasOfflineBookDetails = false});
}

class DonorDetails {
  final String? phoneNumber;
  final String? name;
  final String? companyOrApartment;
  final String? email;

  DonorDetails({
    this.phoneNumber,
    this.name,
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
  bool _wasOfflineDonorDetails = false;
  bool _isFetchingBookDetails = false;

  final _isbnController = TextEditingController();
  final List<BookEntry> _books = [];
  String? _errorMessage;

  // --- Placeholder Functions for backend interaction ---

  /// Simulates submitting the registration to the backend.
  Future<void> _addBookDonation(
    DonorDetails donorDetails,
    List<String?> isbns,
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
        _wasOfflineDonorDetails = false;
        _currentStep = RegistrationStep.donorDetails;
      });
      return;
    }

    setState(() {
      _isCheckingPhone = true;
      _errorMessage = null;
    });

    try {
      final response = await firebase_instance
          .httpsCallable('check_phone_number_exists')
          .call({'phoneNumber': phoneNumber})
          .then((result) => result.data as Map<String, dynamic>?);
      if (!mounted) return;

      setState(() {
        _wasOfflineDonorDetails = false;
        _isExistingDonor = response!['exists'] as bool;
        if (_isExistingDonor) {
          _formKey.currentState?.patchValue({
            'name': response['name'],
            'email': response['email'],
            'companyOrApartment': response['group'],
          });
          _donorDetailsLocked = true;
        } else {
          _donorDetailsLocked = false;
        }
        _currentStep = RegistrationStep.donorDetails;
      });
    } catch (e) {
      // Only check connectivity if the Firebase call fails
      _wasOfflineDonorDetails = await isOffline();

      if (_wasOfflineDonorDetails == true) {
        // Act as if phone number does not exist
        if (!mounted) return;
        setState(() {
          _isExistingDonor = false;
          _donorDetailsLocked = false;
          _currentStep = RegistrationStep.donorDetails;
        });
      } else {
        if (mounted) {
          setState(
            () => _errorMessage = "Error checking phone: ${e.toString()}",
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isCheckingPhone = false);
    }
  }

  Future<void> _addBook() async {
    if (_isFetchingBookDetails) return;
    if (_books.any((b) => b.bookDetails?['editing'] == true)) return;

    final isbn = _isbnController.text.trim();
    if (isbn.isEmpty || _books.any((b) => b.isbn == isbn)) {
      _isbnController.clear();
      return;
    }

    setState(() {
      _errorMessage = null;
      _isFetchingBookDetails = true;
    });

    try {
      final result = await firebase_instance
          .httpsCallable('get_book_details_by_isbn')
          .call({'isbn': isbn});
      final data = result.data as Map<String, dynamic>?;

      if (data != null && data['found'] == true) {
        setState(() {
          _books.add(BookEntry(
            isbn: isbn,
            bookDetails: {
              'name': data['name'],
              'author': data['author'],
              'genre': data['genre'],
              'editing': false,
              'message': null,
            },
            wasOfflineBookDetails: false,
          ));
          _isbnController.clear();
        });
      } else {
        setState(() {
          _books.add(BookEntry(
            isbn: isbn,
            bookDetails: {
              'name': '',
              'author': '',
              'genre': '',
              'editing': true,
              'message': 'No book with that ISBN found',
            },
            wasOfflineBookDetails: false,
          ));
          _isbnController.clear();
        });
      }
    } catch (e) {
      final offline = await isOffline();
      setState(() {
        _books.add(BookEntry(
          isbn: isbn,
          bookDetails: {
            'name': '',
            'author': '',
            'genre': '',
            'editing': true,
            'message': offline ? 'No internet' : 'Error: ${e.toString()}',
          },
          wasOfflineBookDetails: offline,
        ));
        _isbnController.clear();
      });
    } finally {
      setState(() {
        _isFetchingBookDetails = false;
      });
    }
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
      name: formValue['name'] as String?,
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
        if (formState.fields['name']!.validate() &&
            formState.fields['email']!.validate() &&
            formState.fields['companyOrApartment']!.validate()) {
          setState(() {
            _errorMessage = null;
            _currentStep = RegistrationStep.bookEntry;
          });
        } else {
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
          if (_errorMessage != null &&
              _currentStep == RegistrationStep.donorDetails)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          FormBuilderTextField(
            name: 'companyOrApartment',
            decoration: InputDecoration(
              labelText: 'Apartment (or Company)',
              filled: _donorDetailsLocked,
              fillColor: _donorDetailsLocked ? Colors.grey.shade300 : null,
            ),
            readOnly: _donorDetailsLocked,
            style: TextStyle(
              color: _donorDetailsLocked ? constants.uneditableTextColor : null,
            ),
          ),
          FormBuilderTextField(
            name: 'email',
            decoration: InputDecoration(
              labelText: 'Email (for receipt)',
              filled: _donorDetailsLocked,
              fillColor: _donorDetailsLocked ? Colors.grey.shade300 : null,
            ),
            keyboardType: TextInputType.emailAddress,
            readOnly: _donorDetailsLocked,
            style: TextStyle(
              color: _donorDetailsLocked ? constants.uneditableTextColor : null,
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.email(
                errorText: 'Please enter a valid email address',
                checkNullOrEmpty: false,
              ),
            ]),
          ),
          FormBuilderTextField(
            name: 'name',
            decoration: InputDecoration(
              labelText: 'Name',
              filled: _donorDetailsLocked,
              fillColor: _donorDetailsLocked ? Colors.grey.shade300 : null,
            ),
            readOnly: _donorDetailsLocked,
            style: TextStyle(
              color: _donorDetailsLocked ? constants.uneditableTextColor : null,
            ),
          ),
        ],
      ),
    );
  }

  Step _buildBookEntryStep() {
    bool isEditingAny = _books.any((b) => b.bookDetails?['editing'] == true);
    bool isbnFieldEnabled = !_isFetchingBookDetails && !isEditingAny;

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
                onPressed: isbnFieldEnabled ? _addBook : null,
              ),
            ),
            onFieldSubmitted: (_) => isbnFieldEnabled ? _addBook() : null,
            enabled: isbnFieldEnabled,
          ),
          if (_isFetchingBookDetails)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 8),
                  const Text('Fetching book details...'),
                ],
              ),
            ),
          const SizedBox(height: 10),
          if (_books.isEmpty)
            const Center(
              child: Text(
                'No books added yet.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            Column(
              children: [
                ...List.generate(_books.length, (i) => _books.length - 1 - i)
                    .map((index) {
                  final book = _books[index];
                  final details = book.bookDetails ?? {};

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: details['editing'] == true
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (details['message'] != null)
                                  Text(
                                    details['message'],
                                    style: TextStyle(
                                      color: details['message'] == 'No internet'
                                          ? constants.noInternetColor
                                          : Colors.red,
                                    ),
                                  ),
                                FormBuilderTextField(
                                  name: 'book_name_$index',
                                  initialValue: details['name'],
                                  onChanged: (val) => setState(() => details['name'] = val),
                                  decoration: InputDecoration(labelText: 'Book Name *'),
                                  validator: FormBuilderValidators.required(),
                                ),
                                FormBuilderTextField(
                                  name: 'author_$index',
                                  initialValue: details['author'],
                                  onChanged: (val) => setState(() => details['author'] = val),
                                  decoration: InputDecoration(labelText: 'Author *'),
                                  validator: FormBuilderValidators.required(),
                                ),
                                FormBuilderTextField(
                                  name: 'genre_$index',
                                  initialValue: details['genre'],
                                  onChanged: (val) => setState(() => details['genre'] = val),
                                  decoration: InputDecoration(labelText: 'Genre *'),
                                  validator: FormBuilderValidators.required(),
                                ),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() => details['editing'] = false);
                                      },
                                      child: Text('Verify'),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                      onPressed: () => setState(() => _books.removeAt(index)),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('ISBN: ${book.isbn}'),
                                    Text('Name: ${details['name']}'),
                                    Text('Author: ${details['author']}'),
                                    Text('Genre: ${details['genre']}'),
                                    if (book.wasOfflineBookDetails)
                                      Text('Added while offline', style: TextStyle(color: Colors.orange)),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () {
                                        setState(() => details['editing'] = true);
                                      },
                                      icon: const Icon(Icons.edit, size: 16),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                      onPressed: () => setState(() => _books.removeAt(index)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ),
                  );
                }).toList(),
              ],
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

// Next Steps:
// - no need to show isOffline
// - number of books should be verified when submitting
// - only one book should be in verification/editing mode at a time
// - disable add button, with a message when maximum number of books is reached
// - isbn validator
// - INTERNET CHECKER NOT WORKING??????