import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:team_books/main.dart';

void main() {
  testWidgets('Home page loads properly', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(TeamBooksApp());

    // Verify that the home screen contains expected text
    expect(find.text('Team Books'), findsOneWidget);
    expect(find.text('Join the team. Help us donate 1 million books.'), findsOneWidget);

    // Check if the donate button is present
    expect(find.widgetWithText(ElevatedButton, 'Donate'), findsOneWidget);

    // Check if the "I want to help" button is present
    expect(find.widgetWithText(ElevatedButton, 'I want to help'), findsOneWidget);
  });
}
