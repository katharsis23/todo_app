import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/main.dart';

void main() {
  testWidgets('TodoApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TodoApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
