import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:todo_app/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('routing: list -> details, editing persists back to list', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TodoApp());
    await tester.pumpAndSettle();

    // Add a task
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Task A');
    await tester.enterText(
      find.widgetWithText(TextField, 'Description'),
      'Desc A',
    );
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Task A'), findsOneWidget);

    // Navigate to details
    await tester.tap(find.text('Task A'));
    await tester.pumpAndSettle();

    expect(find.text('Task Details'), findsOneWidget);

    // Edit title
    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();

    final titleField = find
        .byType(TextField)
        .first; // title field is first TextField on TaskScreen

    await tester.enterText(titleField, 'Task A (edited)');

    // Save
    await tester.tap(find.byTooltip('Save'));
    await tester.pumpAndSettle();

    // Back to list
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Task A (edited)'), findsOneWidget);
  });
}
