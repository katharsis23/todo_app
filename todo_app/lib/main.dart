import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
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

  static const String posthogApiKey = String.fromEnvironment('POSTHOG_API_KEY');
  static const String posthogHost = String.fromEnvironment(
    'POSTHOG_HOST',
    defaultValue: 'https://us.i.posthog.com',
  );
  static const bool posthogEnabled = bool.fromEnvironment(
    'POSTHOG_ENABLED',
    defaultValue: true,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb &&
      AppConfig.posthogEnabled &&
      AppConfig.posthogApiKey.isNotEmpty) {
    final config = PostHogConfig(AppConfig.posthogApiKey);
    config.debug = AppConfig.debugMode;
    config.captureApplicationLifecycleEvents = true;
    config.host = AppConfig.posthogHost;
    await Posthog().setup(config);
  }
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      navigatorObservers: [PosthogObserver()],
      onGenerateRoute: (settings) {
        AppConfig.log('Navigation to: ${settings.name}');

        switch (settings.name) {
          case '/':
            AppConfig.log('Routing to HomePage');
            return MaterialPageRoute(
              settings: const RouteSettings(name: 'Todo List'),
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
                settings: RouteSettings(name: 'Task/$taskName'),
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
