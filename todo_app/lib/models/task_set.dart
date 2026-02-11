import 'package:todo_app/models/task.dart';

class TaskSet {
  final List<Task> tasks;

  TaskSet({required this.tasks});

  TaskSet copyWith({List<Task>? tasks}) {
    return TaskSet(tasks: tasks ?? this.tasks);
  }

  void append_by_json(Map<String, dynamic> task) {
    final task_ = Task.fromJson(task);
    tasks.add(task_);
  }

  Map<String, dynamic> snapshotToJson() {
    return {'tasks': tasks.map((task) => task.toJson()).toList()};
  }

  void appendTask(Task task) {
    tasks.add(task);
  }

  void removeTask(Task task) {
    tasks.remove(task);
  }

  List<Task> get_tasks() {
    return tasks;
  }

  Task? get_task(String id_) {
    try {
      return tasks.firstWhere((task) => task.id_ == id_);
    } catch (e) {
      return null;
    }
  }
}

// Make TASK_SET persistent by using a singleton pattern
class TaskManager {
  static final TaskManager _instance = TaskManager._internal();
  factory TaskManager() => _instance;
  TaskManager._internal();

  final TaskSet _taskSet = TaskSet(tasks: []);

  TaskSet get taskSet => _taskSet;
}

final TaskManager taskManager = TaskManager();
final TaskSet TASK_SET = taskManager.taskSet;
