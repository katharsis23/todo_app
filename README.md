# Todo App

A Flutter-based task management application with a clean, intuitive interface for organizing and tracking daily tasks.

## Features

- **Task Management**: Create, view, and manage tasks with titles and descriptions
- **Task Status Tracking**: Mark tasks as completed or pending
- **Task Scheduling**: Set appointment dates for tasks (optional)
- **Dynamic Routing**: Navigate between task list and individual task details
- **Debug Mode**: Built-in debugging capabilities for development
- **JSON Serialization**: Full support for data persistence through JSON

## Architecture

The app follows a clean architecture pattern with the following key components:

### Models
- **Task**: Core task entity with properties like id, title, description, completion status, and timestamps
- **TaskSet**: Collection manager for tasks with CRUD operations
- **TaskManager**: Singleton pattern for persistent task management across the app

### Pages
- **TodoListScreen**: Main screen displaying all tasks
- **TaskScreen**: Detailed view for individual tasks
- **ErrorPage**: Fallback for invalid routes

### Core Features
- Global configuration through `AppConfig` class
- Dynamic route handling for task navigation
- Comprehensive logging in debug mode
- Material Design UI components

## Getting Started

### Prerequisites
- Flutter SDK (version 3.9.2 or higher)
- Dart SDK
- An IDE or editor with Flutter support (VS Code, Android Studio, etc.)

### Installation

1. Clone this repository:
```bash
git clone <repository-url>
cd todo_app
```

2. Navigate to the Flutter app directory:
```bash
cd todo_app
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

## Project Structure

```
todo_app/
├── lib/
│   ├── main.dart              # App entry point and routing configuration
│   ├── models/
│   │   ├── task.dart          # Task model with JSON serialization
│   │   ├── task_set.dart      # Task collection manager
│   │   └── user.dart          # User model (if implemented)
│   └── pages/
│       ├── login_page.dart    # User authentication (if implemented)
│       ├── task_screen.dart   # Individual task details
│       └── todo_list.dart     # Main task list view
├── test/                      # Unit and widget tests
└── pubspec.yaml              # Dependencies and project configuration
```

## Usage

1. **View Tasks**: Launch the app to see the main task list
2. **Add Tasks**: Navigate to create new tasks (implementation dependent)
3. **Task Details**: Click on any task to view and edit details
4. **Mark Complete**: Toggle task completion status
5. **Schedule Tasks**: Set appointment dates for time-sensitive tasks

## Development

### Debug Mode
The app includes built-in debug mode that can be controlled through the `AppConfig` class. Debug logging is automatically disabled in release builds.

### Testing
Run the test suite:
```bash
flutter test
```

### Building
Build for production:
```bash
# Android
flutter build apk

# iOS
flutter build ios

# Web
flutter build web
```

## Dependencies

- `flutter`: Core Flutter framework
- `cupertino_icons`: iOS-style icons
- `flutter_test`: Testing framework
- `flutter_lints`: Code quality and style guidelines

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the terms specified in the LICENSE file.

## Future Enhancements

- User authentication system
- Cloud synchronization
- Task categories and labels
- Push notifications for task reminders
- Collaborative task management
- Data export/import functionality
