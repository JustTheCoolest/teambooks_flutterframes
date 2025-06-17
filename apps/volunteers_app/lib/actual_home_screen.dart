import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_registration_provider.dart';
import '../services/firebase_service.dart'; // For BookEntry model
import 'receipt_dialog.dart';

class ActualHomeScreen extends StatelessWidget {
  const ActualHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TeamBooks Volunteer Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () {
              // TODO: Implement Sign Out Logic (e.g., context.read<AuthProvider>().signOut())
              // For now, just navigate to a placeholder or clear auth state
              // This might involve popping all routes and pushing a login screen.
            },
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.book_online),
          label: const Text('Register Book Donation'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            textStyle: const TextStyle(fontSize: 18),
          ),
          onPressed: () {
            // Reset form state before showing dialog
            context.read<BookRegistrationProvider>().clearForm();
            showDialog(
              context: context,
              barrierDismissible: false, // User must explicitly close
              builder:
                  (_) => ChangeNotifierProvider.value(
                    value: context.read<BookRegistrationProvider>(),
                    child: const BookRegistrationDialog(),
                  ),
            );
          },
        ),
      ),
    );
  }
}

class BookRegistrationDialog extends StatefulWidget {
  const BookRegistrationDialog({super.key});

  @override
  State<BookRegistrationDialog> createState() => _BookRegistrationDialogState();
}

class _BookRegistrationDialogState extends State<BookRegistrationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _isbnController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with provider data if dialog is rebuilt (e.g. due to orientation change)
    // but typically clearForm() is called before dialog is shown.
    final provider = context.read<BookRegistrationProvider>();
    _phoneController.text = provider.phoneNumber ?? '';
    _nameController.text = provider.name;
    _companyController.text = provider.companyOrApartment ?? '';
    _emailController.text = provider.email ?? '';
  }

  @override
  void dispose() {
    _isbnController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _companyController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submitForm(BookRegistrationProvider provider) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Triggers onSaved for all fields
      final success = await provider.submitRegistration();
      if (success && mounted) {
        // Show receipt
        showDialog(
          context: context,
          builder:
              (receiptContext) => ReceiptDialog(
                receiptData: provider.receiptData!,
                donorEmail: provider.email,
              ),
        ).then((_) {
          // After receipt is closed, close the registration form as well
          Navigator.of(context).pop(); // Close BookRegistrationDialog
          provider.clearForm(); // Clear form for next time
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookRegistrationProvider>();

    // Update text controllers if provider data changes externally (e.g. after phone check)
    // This is a bit manual; more complex forms might use listeners on controllers or dedicated state objects.
    if (_nameController.text != provider.name) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _nameController.text = provider.name;
      });
    }
    if (_emailController.text != provider.email) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _emailController.text = provider.email ?? '';
      });
    }
    if (_companyController.text != provider.companyOrApartment) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _companyController.text = provider.companyOrApartment ?? '';
      });
    }

    return AlertDialog(
      title: const Text('Register New Book Donation'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Donor Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number (Optional)',
                  hintText: 'Check if donor exists',
                  suffixIcon:
                      provider.isVerifyingPhoneNumber
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : IconButton(
                            icon: const Icon(Icons.search),
                            tooltip: 'Check Phone Number',
                            onPressed:
                                _phoneController.text.isNotEmpty
                                    ? () {
                                      provider.setPhoneNumber(
                                        _phoneController.text,
                                      );
                                      provider.checkPhoneNumber();
                                    }
                                    : null,
                          ),
                ),
                keyboardType: TextInputType.phone,
                onChanged: (value) => provider.setPhoneNumber(value),
                // No validator, as it's optional for submission but required for check
              ),
              if (provider.donorExists)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    provider.existingDonorDetails?['name'] != null
                        ? 'Existing donor: ${provider.existingDonorDetails!['name']}'
                        : 'Existing donor found.',
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name*'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Donor name is required'
                            : null,
                onChanged: (value) => provider.setName(value),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (for receipt)',
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) => provider.setEmail(value),
                // Optional: add email validator
              ),
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: 'Company / Apartment (Optional)',
                ),
                onChanged: (value) => provider.setCompanyOrApartment(value),
              ),
              const SizedBox(height: 20),
              const Text(
                'Books (ISBNs)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _isbnController,
                      decoration: const InputDecoration(
                        labelText: 'Enter ISBN',
                      ),
                      keyboardType:
                          TextInputType
                              .text, // Can be number, but ISBNs can have 'X'
                      validator: (value) {
                        // Basic ISBN validation (length), more complex validation can be added
                        if (provider.books.isEmpty &&
                            (value == null || value.isEmpty)) {
                          return 'At least one ISBN is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: 'Add ISBN',
                    onPressed: () {
                      if (_isbnController.text.isNotEmpty) {
                        provider.addBook(_isbnController.text);
                        _isbnController.clear();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (provider.books.isEmpty)
                const Text(
                  'Please add at least one ISBN.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.books.length,
                itemBuilder: (context, index) {
                  final book = provider.books[index];
                  final details = provider.bookDetailsCache[book.isbn];
                  return ListTile(
                    leading:
                        provider.isVerifyingIsbn && details == null
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : (details?['error'] != null
                                ? const Icon(
                                  Icons.error_outline,
                                  color: Colors.orange,
                                )
                                : const Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green,
                                )),
                    title: Text(details?['title'] ?? book.isbn),
                    subtitle:
                        details?['error'] != null
                            ? Text(
                              details!['error'].toString(),
                              style: const TextStyle(color: Colors.red),
                            )
                            : Text(
                              "ISBN: ${book.isbn}${details?['authors'] != null ? ' - ${details!['authors'].join(', ')}' : ''}",
                            ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.redAccent,
                      ),
                      onPressed: () => provider.removeBook(book.isbn),
                    ),
                    dense: true,
                  );
                },
              ),
              if (provider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Text(
                    provider.errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (provider.successMessage != null &&
                  provider.receiptData ==
                      null) // Show general success if no receipt yet
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Text(
                    provider.successMessage!,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
            provider.clearForm();
          },
        ),
        ElevatedButton.icon(
          icon:
              provider.isLoading
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      color: Colors.white,
                    ),
                  )
                  : const Icon(Icons.send),
          label: const Text('Submit Donation'),
          onPressed: provider.isLoading ? null : () => _submitForm(provider),
        ),
      ],
    );
  }
}
