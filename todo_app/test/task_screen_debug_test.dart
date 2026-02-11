import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/models/task_set.dart';
import 'package:todo_app/pages/task_screen.dart';

void main() {
  group('TaskScreen Debug Tests', () {
    setUp(() {
      // Clear global TASK_SET before each test
      TASK_SET.tasks.clear();
    });

    tearDown(() {
      // Clean up after each test
      TASK_SET.tasks.clear();
    });

    testWidgets('TaskScreen should handle missing task gracefully', (
      WidgetTester tester,
    ) async {
      // Don't add any task to TASK_SET
      await tester.pumpWidget(
        const MaterialApp(home: TaskScreen(taskName: '1770750264331')),
      );

      await tester.pumpAndSettle();

      // Should show not found screen
      expect(find.text('Task not found'), findsOneWidget);
      expect(
        find.text('The task you are looking for does not exist.'),
        findsOneWidget,
      );
    });

    testWidgets('TaskScreen should display existing task', (
      WidgetTester tester,
    ) async {
      final testTask = Task(
        id_: '1770750264331',
        title: 'Test Task Title',
        description: 'Test Task Description',
        isCompleted: false,
        createdAt: DateTime.now(),
      );
      TASK_SET.appendTask(testTask);

      await tester.pumpWidget(
        const MaterialApp(home: TaskScreen(taskName: '1770750264331')),
      );

      await tester.pumpAndSettle();

      // Should show task details
      expect(find.text('Test Task Title'), findsOneWidget);
      expect(find.text('Test Task Description'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Task ID:'), findsOneWidget);
      expect(find.text('1770750264331'), findsOneWidget);
    });
  });
}
