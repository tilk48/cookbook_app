import 'package:flutter/material.dart';
import 'api_test_harness.dart';

/// Simple test app to run the API test harness
void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mealie API Test Harness',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ApiTestPage(),
    );
  }
}

/// Instructions for using the test harness:
/// 
/// 1. Set your credentials in api_test_harness.dart:
///    - Update defaultUsername 
///    - Update defaultPassword
///    - Update defaultServerUrl if needed
/// 
/// 2. Run this test app:
///    flutter run lib/test/test_main.dart
/// 
/// 3. Use the buttons to test different API scenarios
/// 
/// 4. Check the console output for detailed API call information