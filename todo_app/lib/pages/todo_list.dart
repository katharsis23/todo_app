import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/models/task_set.dart';
import 'package:todo_app/main.dart';

class CustomTestException implements Exception {
  final String message;
  CustomTestException(this.message);

  @override
  String toString() => 'CustomTestException: $message';
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<bool> _isAddTaskFeatureEnabled() async {
    if (AppConfig.forceAddTaskFeature) {
      return true;
    }

    // For web localhost, always enable add task feature
    if (kIsWeb) {
      return true;
    }

    if (!AppConfig.posthogEnabled || AppConfig.posthogApiKey.isEmpty) {
      return false;
    }

    return await Posthog().isFeatureEnabled('add-task-feature');
  }

  Future<void> _doHeavyOperation() async {
    final transaction = Sentry.startTransaction('heavy_operation', 'task');

    final span = transaction.startChild('ui_blocking');
    await Future.delayed(const Duration(milliseconds: 50)); // тестова затримка
    span.finish();

    await transaction.finish();
  }

  Future<void> _onAddTaskPressed() async {
    final enabled = await _isAddTaskFeatureEnabled();
    if (!mounted) return;

    if (enabled) {
      _showAddTaskDialog();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Task feature is disabled')),
    );
  }

  void _addTask() {
    if (_titleController.text.trim().isEmpty) return;

    final task = Task(
      id_: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    AppConfig.log('Creating task with ID: ${task.id_}');
    AppConfig.log('Task title: ${task.title}');
    AppConfig.log('Current TASK_SET size before: ${TASK_SET.tasks.length}');

    setState(() {
      TASK_SET.appendTask(task);
    });

    if (AppConfig.posthogEnabled && AppConfig.posthogApiKey.isNotEmpty) {
      Posthog().capture(
        eventName: 'task created',
        properties: {
          'task_id': task.id_,
          'has_description': task.description.trim().isNotEmpty,
        },
      );
    }

    AppConfig.log('Current TASK_SET size after: ${TASK_SET.tasks.length}');
    AppConfig.log('All task IDs: ${TASK_SET.tasks.map((t) => t.id_).toList()}');

    _titleController.clear();
    _descriptionController.clear();
    Navigator.of(context).pop();
  }

  void _toggleTask(Task task) {
    setState(() {
      final index = TASK_SET.tasks.indexWhere((t) => t.id_ == task.id_);
      if (index != -1) {
        final updatedTask = Task(
          id_: task.id_,
          title: task.title,
          description: task.description,
          isCompleted: !task.isCompleted,
          createdAt: task.createdAt,
          appointedAt: task.appointedAt,
        );
        TASK_SET.tasks[index] = updatedTask;
      }
    });

    if (AppConfig.posthogEnabled && AppConfig.posthogApiKey.isNotEmpty) {
      Posthog().capture(
        eventName: 'task completion toggled',
        properties: {
          'task_id': task.id_,
          'to_completed': !task.isCompleted,
          'source': 'list',
        },
      );
    }
  }

  void _deleteTask(Task task) {
    setState(() {
      TASK_SET.removeTask(task);
    });

    if (AppConfig.posthogEnabled && AppConfig.posthogApiKey.isNotEmpty) {
      Posthog().capture(
        eventName: 'task deleted',
        properties: {'task_id': task.id_, 'source': 'list'},
      );
    }
  }

  void _showAddTaskDialog() {
    if (AppConfig.posthogEnabled && AppConfig.posthogApiKey.isNotEmpty) {
      Posthog().capture(eventName: 'task create dialog opened');
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(onPressed: _addTask, child: const Text('Add')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = TASK_SET.tasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Tasks',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    print('Verify Sentry Setup button pressed');
                    final exception = StateError('This is test exception');
                    try {
                      await Sentry.captureException(
                        exception,
                        stackTrace: StackTrace.current,
                      );
                      print('[DEBUG] Sentry.captureException completed');
                    } catch (e) {
                      print('[DEBUG] Sentry.captureException failed: $e');
                    }
                    throw exception;
                  },
                  child: const Text('Verify Sentry Setup'),
                ),
                OutlinedButton(
                  onPressed: () async {
                    final exception = StateError(
                      'Sentry Test Error: Something went wrong! (non-crashing test)',
                    );
                    try {
                      await Sentry.captureException(
                        exception,
                        stackTrace: StackTrace.current,
                      );
                      if (AppConfig.debugMode) {
                        print(
                          '[DEBUG] Sentry.captureException (non-crashing) completed',
                        );
                      }
                    } catch (e) {
                      if (AppConfig.debugMode) {
                        print(
                          '[DEBUG] Sentry.captureException (non-crashing) failed: $e',
                        );
                      }
                    }
                  },
                  child: const Text('Send to Sentry (no crash)'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Sentry.configureScope((scope) {
                      scope.setUser(
                        SentryUser(id: '12345', email: 'student@example.com'),
                      );
                      scope.setTag('segment', 'premium_user');
                    });

                    throw Exception('Test with user ${DateTime.now()}');
                  },
                  child: const Text('Test User Error'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Sentry.configureScope((scope) {
                      scope.setUser(
                        SentryUser(
                          id: '12345',
                          email: 'student@example.com',
                          username: 'premium_user',
                        ),
                      );
                      scope.setTag('segment', 'premium_user');
                    });
                    if (AppConfig.debugMode) {
                      print(
                        '[DEBUG] Sentry user set: 12345 (student@example.com)',
                      );
                    }
                  },
                  child: const Text('Fake Login'),
                ),
                OutlinedButton(
                  onPressed: () {
                    Sentry.configureScope((scope) {
                      scope.setUser(null);
                      scope.removeTag('segment');
                    });
                    if (AppConfig.debugMode) {
                      print('[DEBUG] Sentry user cleared');
                    }
                  },
                  child: const Text('Fake Logout'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (AppConfig.debugMode) {
                      print('[DEBUG] Starting slow operation...');
                    }
                    await Future.delayed(const Duration(seconds: 3));
                    if (AppConfig.debugMode) {
                      print('[DEBUG] Slow operation completed');
                    }
                  },
                  child: const Text('Slow Operation (3s)'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (AppConfig.debugMode) {
                      print(
                        '[DEBUG] Starting heavy operation with transaction...',
                      );
                    }
                    await _doHeavyOperation();
                    if (AppConfig.debugMode) {
                      print(
                        '[DEBUG] Heavy operation with transaction completed',
                      );
                    }
                  },
                  child: const Text('Heavy Operation (Transaction)'),
                ),
                OutlinedButton(
                  onPressed: () async {
                    print('Custom Exception button pressed');
                    final exception = CustomTestException(
                      'This is a custom test exception',
                    );
                    try {
                      await Sentry.captureException(
                        exception,
                        stackTrace: StackTrace.current,
                      );
                      print('[DEBUG] Custom Sentry.captureException completed');
                    } catch (e) {
                      print(
                        '[DEBUG] Custom Sentry.captureException failed: $e',
                      );
                    }
                    throw exception;
                  },
                  child: const Text('Custom Exception'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: tasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.task_alt,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tasks yet',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first task to get started!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Checkbox(
                              value: task.isCompleted,
                              onChanged: (value) => _toggleTask(task),
                              activeColor: Colors.green[600],
                            ),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                color: task.isCompleted
                                    ? Colors.grey[500]
                                    : Colors.black87,
                              ),
                            ),
                            subtitle: task.description.isNotEmpty
                                ? Text(
                                    task.description,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: task.isCompleted
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                  )
                                : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.open_in_new,
                                    color: Colors.blue[400],
                                  ),
                                  onPressed: () {
                                    AppConfig.log(
                                      'Navigating to task: ${task.id_}',
                                    );
                                    if (AppConfig.posthogEnabled &&
                                        AppConfig.posthogApiKey.isNotEmpty) {
                                      Posthog().capture(
                                        eventName: 'task opened',
                                        properties: {
                                          'task_id': task.id_,
                                          'source': 'list_icon',
                                        },
                                      );
                                    }
                                    Navigator.pushNamed(
                                      context,
                                      '/task_page/${task.id_}',
                                    ).then((_) {
                                      if (!mounted) return;
                                      setState(() {});
                                    });
                                  },
                                  tooltip: 'Open Task',
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red[400],
                                  ),
                                  onPressed: () => _deleteTask(task),
                                  tooltip: 'Delete Task',
                                ),
                              ],
                            ),
                            onTap: () {
                              AppConfig.log('Tapped on task: ${task.id_}');
                              if (AppConfig.posthogEnabled &&
                                  AppConfig.posthogApiKey.isNotEmpty) {
                                Posthog().capture(
                                  eventName: 'task opened',
                                  properties: {
                                    'task_id': task.id_,
                                    'source': 'list_row',
                                  },
                                );
                              }
                              Navigator.pushNamed(
                                context,
                                '/task_page/${task.id_}',
                              ).then((_) {
                                if (!mounted) return;
                                setState(() {});
                              });
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAddTaskPressed,
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }
}
