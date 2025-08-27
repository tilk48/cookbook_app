import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cookbook_app/main.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CookbookApp());
    
    // Verify that our app builds without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}