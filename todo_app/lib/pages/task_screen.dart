import 'package:flutter/material.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/models/task_set.dart';
import 'package:todo_app/main.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key, required this.taskName});
  final String taskName;

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late Task? _task;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadTask() {
    AppConfig.log('Loading task with ID: ${widget.taskName}');
    AppConfig.log('Available tasks: ${TASK_SET.tasks.length}');

    setState(() {
      _task = TASK_SET.get_task(widget.taskName);
      if (_task != null) {
        _titleController.text = _task!.title;
        _descriptionController.text = _task!.description;
        AppConfig.log('Task found: ${_task!.title}');
      } else {
        AppConfig.log('Task not found for ID: ${widget.taskName}');
      }
    });
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing && _task != null) {
        _saveTask();
      }
    });
  }

  void _saveTask() {
    if (_task == null || _titleController.text.trim().isEmpty) return;

    final updatedTask = Task(
      id_: _task!.id_,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      isCompleted: _task!.isCompleted,
      createdAt: _task!.createdAt,
      appointedAt: _task!.appointedAt,
    );

    final index = TASK_SET.tasks.indexWhere((t) => t.id_ == _task!.id_);
    if (index != -1) {
      setState(() {
        TASK_SET.tasks[index] = updatedTask;
        _task = updatedTask;
      });
    }
  }

  void _toggleComplete() {
    if (_task == null) return;

    final updatedTask = Task(
      id_: _task!.id_,
      title: _task!.title,
      description: _task!.description,
      isCompleted: !_task!.isCompleted,
      createdAt: _task!.createdAt,
      appointedAt: _task!.appointedAt,
    );

    final index = TASK_SET.tasks.indexWhere((t) => t.id_ == _task!.id_);
    if (index != -1) {
      setState(() {
        TASK_SET.tasks[index] = updatedTask;
        _task = updatedTask;
      });
    }
  }

  void _deleteTask() {
    if (_task == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${_task!.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              TASK_SET.removeTask(_task!);
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_task == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Task Not Found'),
          backgroundColor: Colors.red[600],
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Task not found',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'The task you are looking for does not exist.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'Task Details'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _toggleEdit,
            tooltip: _isEditing ? 'Save' : 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteTask,
            tooltip: 'Delete',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      _task?.isCompleted == true
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: _task?.isCompleted == true
                          ? Colors.green
                          : Colors.grey,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _task?.isCompleted == true ? 'Completed' : 'Pending',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: _task?.isCompleted == true
                            ? Colors.green
                            : Colors.grey[700],
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _toggleComplete,
                      icon: Icon(
                        _task?.isCompleted == true ? Icons.undo : Icons.check,
                      ),
                      label: Text(
                        _task?.isCompleted == true
                            ? 'Mark Incomplete'
                            : 'Mark Complete',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _task?.isCompleted == true
                            ? Colors.orange
                            : Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title Field
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Title',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      enabled: _isEditing,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter task title',
                      ),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description Field
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      enabled: _isEditing,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter task description',
                      ),
                      maxLines: 5,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Metadata
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Task Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Task ID:', _task?.id_ ?? 'Unknown'),
                    _buildInfoRow(
                      'Created:',
                      _formatDate(_task?.createdAt ?? DateTime.now()),
                    ),
                    if (_task?.appointedAt != null)
                      _buildInfoRow(
                        'Appointed:',
                        _formatDate(_task!.appointedAt!),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
