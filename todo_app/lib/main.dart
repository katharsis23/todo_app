import 'package:flutter/material.dart';
import 'package:todo_app/pages/todo_list.dart';
import 'package:todo_app/pages/task_screen.dart';
import 'package:todo_app/models/task_set.dart';

// Global configuration
class AppConfig {
  /*
    debugMode: Controls whether debug logging is enabled
    authorized: Controls authentication state
  */
  static const bool debugMode = !bool.fromEnvironment('dart.vm.product');
  static bool authorized = false;

  static void log(String message) {
    if (debugMode) {
      print('[DEBUG] $message');
    }
  }
}

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      onGenerateRoute: (settings) {
        AppConfig.log('Navigation to: ${settings.name}');

        switch (settings.name) {
          case '/':
            AppConfig.log('Routing to HomePage');
            return MaterialPageRoute(
              builder: (context) => const TodoListScreen(),
            );
          default:
            // Handle dynamic routes like /task_page/task_name
            final uri = Uri.parse(settings.name ?? '');
            if (uri.pathSegments.length == 2 &&
                uri.pathSegments[0] == 'task_page') {
              final taskName = uri.pathSegments[1];
              AppConfig.log('Routing to TaskScreen with task: $taskName');
              AppConfig.log('Current TASK_SET size: ${TASK_SET.tasks.length}');
              AppConfig.log(
                'Available task IDs: ${TASK_SET.tasks.map((t) => t.id_).toList()}',
              );
              return MaterialPageRoute(
                builder: (context) => TaskScreen(taskName: taskName),
              );
            }
            AppConfig.log('Route not found: ${settings.name}');
            return MaterialPageRoute(builder: (context) => const ErrorPage());
        }
      },
    );
  }
}

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Page not found', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
