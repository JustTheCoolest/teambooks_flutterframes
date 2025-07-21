import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:volunteers_app/book_registration_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:volunteers_app/firebase_options.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_phone_field/form_builder_phone_field.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  testWidgets('Book registration form test for new donor', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: BookRegistrationPage())),
    );
    await tester.pumpAndSettle();

    // Step 1: Donor Type
    // Ensure "Anonymous" is off. It's off by default.
    // Find the phone field and enter the phone number.
    await tester.enterText(find.byType(FormBuilderPhoneField), '1234567890');
    await tester.pumpAndSettle();

    // Tap 'Continue' to move to the next step.
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle(
      const Duration(seconds: 5),
    ); // Wait for network call

    // Step 2: Donor Details
    // Expect "Existing donor found" message and "Edit" button with icon.
    expect(find.text('Existing donor found.'), findsOneWidget);
    expect(find.widgetWithIcon(TextButton, Icons.edit), findsOneWidget);

    // Expect prefilled, read-only donor details.
    expect(
      find.descendant(
        of: find.widgetWithText(FormBuilderTextField, 'Company or Apartment'),
        matching: find.text('VITC'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.widgetWithText(FormBuilderTextField, 'Email'),
        matching: find.text('hitmonlee@teambooks.org'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.widgetWithText(FormBuilderTextField, 'Name'),
        matching: find.text('Hitmonlee'),
      ),
      findsOneWidget,
    );

    // Optionally, check that the fields are read-only.
    final companyField = tester.widget<FormBuilderTextField>(
      find.widgetWithText(FormBuilderTextField, 'Company or Apartment'),
    );
    expect(companyField.readOnly, isTrue);

    final emailField = tester.widget<FormBuilderTextField>(
      find.widgetWithText(FormBuilderTextField, 'Email'),
    );
    expect(emailField.readOnly, isTrue);

    final nameField = tester.widget<FormBuilderTextField>(
      find.widgetWithText(FormBuilderTextField, 'Name'),
    );
    expect(nameField.readOnly, isTrue);

    await tester.pumpAndSettle();

    // Tap 'Continue'
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Step 3: Add Books
    // Add a book without an ISBN
    await tester.tap(find.text('Add Book without ISBN'));
    await tester.pumpAndSettle();

    // Verify the book is added to the list. We can't check by ISBN, so we'll check for the fields.
    expect(find.widgetWithText(FormBuilderTextField, 'Title'), findsOneWidget);
    expect(find.widgetWithText(FormBuilderTextField, 'Author'), findsOneWidget);

    // Fill in the details for the new book
    await tester.enterText(
      find.widgetWithText(FormBuilderTextField, 'Title'),
      'Test Book Title',
    );
    await tester.enterText(
      find.widgetWithText(FormBuilderTextField, 'Author'),
      'Test Author',
    );
    await tester.enterText(
      find.widgetWithText(FormBuilderTextField, 'Genre'),
      'Fiction',
    );
    await tester.pumpAndSettle();

    // "Verify" the book details to make the fields read-only
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();

    // Tap 'Submit'
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle(
      const Duration(seconds: 5),
    ); // Wait for submission

    // // After submission, a success message should be shown.
    // expect(find.text('Donation submitted successfully!'), findsOneWidget);
  });
}
