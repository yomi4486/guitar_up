import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guiter_up/main.dart';

void main() {
  testWidgets('App starts and shows navigation bar', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that navigation bar items are present
    expect(find.text('練習'), findsOneWidget);
    expect(find.text('記録'), findsOneWidget);
  });

  testWidgets('Can navigate between tabs', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(const MyApp());

    // Verify Practice tab is shown initially
    expect(find.text('GuiterUp - 練習'), findsOneWidget);

    // Tap on 記録 tab
    await tester.tap(find.text('記録'));
    await tester.pumpAndSettle();

    // Verify Records screen is shown
    expect(find.text('GuiterUp - 記録'), findsOneWidget);

    // Tap on 練習 tab
    await tester.tap(find.text('練習'));
    await tester.pumpAndSettle();

    // Verify Practice screen is shown again
    expect(find.text('GuiterUp - 練習'), findsOneWidget);
  });
}
