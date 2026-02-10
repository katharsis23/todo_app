import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/models/task_set.dart';

void main() {
  group('TaskSet Tests', () {
    late TaskSet taskSet;
    late Task testTask1;
    late Task testTask2;

    setUp(() {
      taskSet = TaskSet(tasks: []);
      testTask1 = Task(
        id_: '1',
        title: 'Test Task 1',
        description: 'Description 1',
        isCompleted: false,
        createdAt: DateTime.now(),
      );
      testTask2 = Task(
        id_: '2',
        title: 'Test Task 2',
        description: 'Description 2',
        isCompleted: true,
        createdAt: DateTime.now(),
      );
    });

    test('TaskSet should initialize with empty tasks list', () {
      expect(taskSet.tasks.isEmpty, true);
    });

    test('copyWith should create new TaskSet with updated tasks', () {
      final newTasks = [testTask1];
      final newTaskSet = taskSet.copyWith(tasks: newTasks);

      expect(newTaskSet.tasks, equals(newTasks));
      expect(identical(newTaskSet, taskSet), false);
    });

    test('appendTask should add task to tasks list', () {
      taskSet.appendTask(testTask1);

      expect(taskSet.tasks.length, 1);
      expect(taskSet.tasks.first, equals(testTask1));
    });

    test('append_by_json should add task from JSON', () {
      final taskJson = {
        'id_': '3',
        'title': 'JSON Task',
        'description': 'JSON Description',
        'isCompleted': false,
        'createdAt': DateTime.now().toIso8601String(),
      };

      taskSet.append_by_json(taskJson);

      expect(taskSet.tasks.length, 1);
      expect(taskSet.tasks.first.id_, equals('3'));
      expect(taskSet.tasks.first.title, equals('JSON Task'));
    });

    test('removeTask should remove task from tasks list', () {
      taskSet.appendTask(testTask1);
      taskSet.appendTask(testTask2);

      expect(taskSet.tasks.length, 2);

      taskSet.removeTask(testTask1);

      expect(taskSet.tasks.length, 1);
      expect(taskSet.tasks.first, equals(testTask2));
    });

    test('get_tasks should return all tasks', () {
      taskSet.appendTask(testTask1);
      taskSet.appendTask(testTask2);

      final allTasks = taskSet.get_tasks();

      expect(allTasks.length, 2);
      expect(allTasks, contains(testTask1));
      expect(allTasks, contains(testTask2));
    });

    test('get_task should return task by id', () {
      taskSet.appendTask(testTask1);
      taskSet.appendTask(testTask2);

      final foundTask = taskSet.get_task('1');

      expect(foundTask, equals(testTask1));
    });

    test('get_task should return null for non-existent id', () {
      taskSet.appendTask(testTask1);

      final foundTask = taskSet.get_task('999');

      expect(foundTask, isNull);
    });

    test('snapshotToJson should convert tasks to JSON', () {
      taskSet.appendTask(testTask1);
      taskSet.appendTask(testTask2);

      final json = taskSet.snapshotToJson();

      expect(json.containsKey('tasks'), true);
      expect(json['tasks'], isA<List>());
      expect(json['tasks'].length, 2);

      final task1Json = json['tasks'].firstWhere((task) => task['id_'] == '1');
      expect(task1Json['title'], equals('Test Task 1'));
      expect(task1Json['description'], equals('Description 1'));
      expect(task1Json['isCompleted'], equals(false));
    });

    test('Task JSON serialization should work correctly', () {
      final originalTask = Task(
        id_: 'test-id',
        title: 'Test Title',
        description: 'Test Description',
        isCompleted: true,
        createdAt: DateTime(2023, 1, 1),
        appointedAt: DateTime(2023, 1, 2),
      );

      final json = originalTask.toJson();
      final deserializedTask = Task.fromJson(json);

      expect(deserializedTask.id_, equals(originalTask.id_));
      expect(deserializedTask.title, equals(originalTask.title));
      expect(deserializedTask.description, equals(originalTask.description));
      expect(deserializedTask.isCompleted, equals(originalTask.isCompleted));
      expect(deserializedTask.createdAt, equals(originalTask.createdAt));
      expect(deserializedTask.appointedAt, equals(originalTask.appointedAt));
    });

    test('Task JSON serialization should handle null appointedAt', () {
      final originalTask = Task(
        id_: 'test-id',
        title: 'Test Title',
        description: 'Test Description',
        isCompleted: false,
        createdAt: DateTime(2023, 1, 1),
        appointedAt: null,
      );

      final json = originalTask.toJson();
      final deserializedTask = Task.fromJson(json);

      expect(deserializedTask.appointedAt, isNull);
    });

    test('Global TASK_SET should be accessible', () {
      expect(TASK_SET, isA<TaskSet>());
      expect(TASK_SET.tasks, isA<List<Task>>());
    });
  });
}
