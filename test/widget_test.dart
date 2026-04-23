import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders BloomList title widget', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('BloomList')),
        ),
      ),
    );

    expect(find.text('BloomList'), findsOneWidget);
  });
}
