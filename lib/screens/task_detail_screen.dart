import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import 'task_form_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TaskModel _currentTask;

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
  }

  Future<void> _quickUpdateStatus(TaskModel task, String newStatus) async {
    final provider = context.read<TaskProvider>();
    final updated = task.copyWith(status: newStatus);

    final success = await provider.editTask(updated);
    if (!mounted) return;

    if (success) {
      setState(() => _currentTask = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status tugas diperbarui')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(provider.errorMessage ?? 'Gagal memperbarui status'),
        ),
      );
    }
  }

  Future<void> _openEditForm(TaskModel task) async {
    final updatedTask = await Navigator.push<TaskModel>(
      context,
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
    );

    if (updatedTask != null && mounted) {
      setState(() => _currentTask = updatedTask);
    }
  }

  Future<void> _confirmDelete(TaskModel task) async {
    if (task.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Tugas?'),
        content: Text('Tugas "${task.title}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<TaskProvider>();
      final success = await provider.removeTask(task.id!);
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tugas berhasil dihapus')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(provider.errorMessage ?? 'Gagal menghapus tugas'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final matchingTasks =
        provider.tasks.where((t) => t.id == _currentTask.id);
    final displayTask =
        matchingTasks.isNotEmpty ? matchingTasks.first : _currentTask;

    final isDone = displayTask.status == 'done';
    final formattedDate = DateFormat('dd MMMM yyyy').format(displayTask.dueDate);
    final isOverdue = !isDone &&
        displayTask.dueDate.isBefore(
          DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tugas'),
        actions: [
          IconButton(
            tooltip: 'Edit Tugas',
            icon: const Icon(Icons.edit_outlined),
            onPressed: provider.isLoading ? null : () => _openEditForm(displayTask),
          ),
          IconButton(
            tooltip: 'Hapus Tugas',
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: provider.isLoading ? null : () => _confirmDelete(displayTask),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Kartu Informasi Utama
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildStatusBadge(displayTask.status),
                      const SizedBox(width: 8),
                      _buildPriorityBadge(displayTask.priority),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    displayTask.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone ? Colors.grey : null,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: isOverdue ? Colors.red : Colors.grey.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Deadline: $formattedDate',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isOverdue ? FontWeight.w600 : FontWeight.normal,
                          color: isOverdue ? Colors.red : Colors.grey.shade800,
                        ),
                      ),
                      if (isOverdue) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Terlewat',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Ubah Status Cepat
          const Text(
            'Ubah Status Cepat',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'todo',
                label: Text('To-Do'),
                icon: Icon(Icons.radio_button_unchecked, size: 18),
              ),
              ButtonSegment(
                value: 'in_progress',
                label: Text('Progress'),
                icon: Icon(Icons.timelapse, size: 18),
              ),
              ButtonSegment(
                value: 'done',
                label: Text('Done'),
                icon: Icon(Icons.check_circle_outline, size: 18),
              ),
            ],
            selected: {displayTask.status},
            onSelectionChanged: provider.isLoading
                ? null
                : (newSelection) {
                    final selected = newSelection.first;
                    if (selected != displayTask.status) {
                      _quickUpdateStatus(displayTask, selected);
                    }
                  },
          ),
          const SizedBox(height: 20),

          // Bagian Deskripsi Tugas
          const Text(
            'Deskripsi Tugas',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                displayTask.description.isNotEmpty
                    ? displayTask.description
                    : 'Tidak ada deskripsi tambahan untuk tugas ini.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  fontStyle: displayTask.description.isEmpty
                      ? FontStyle.italic
                      : FontStyle.normal,
                  color: displayTask.description.isEmpty
                      ? Colors.grey.shade600
                      : Colors.grey.shade900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    switch (status) {
      case 'in_progress':
        color = Colors.orange;
        label = 'In Progress';
        break;
      case 'done':
        color = Colors.green;
        label = 'Done';
        break;
      default:
        color = Colors.blueGrey;
        label = 'To-Do';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color color;
    String label;
    switch (priority) {
      case 'high':
        color = Colors.red;
        label = 'High Priority';
        break;
      case 'low':
        color = Colors.teal;
        label = 'Low Priority';
        break;
      default:
        color = Colors.indigo;
        label = 'Medium Priority';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}