import 'package:flutter/material.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/models/task_set.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _addTask() {
    if (_titleController.text.trim().isEmpty) return;

    final task = Task(
      id_: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    setState(() {
      TASK_SET.appendTask(task);
    });

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
  }

  void _deleteTask(Task task) {
    setState(() {
      TASK_SET.removeTask(task);
    });
  }

  void _showAddTaskDialog() {
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
      body: tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_alt, size: 80, color: Colors.grey[400]),
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
                    style: TextStyle(fontSize: 16, color: Colors.grey[500]),
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
                          icon: const Icon(Icons.open_in_new),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/task_page/${task.id_}',
                            );
                          },
                          tooltip: 'Open Task',
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red[400]),
                          onPressed: () => _deleteTask(task),
                          tooltip: 'Delete Task',
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/task_page/${task.id_}');
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskDialog,
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }
}
