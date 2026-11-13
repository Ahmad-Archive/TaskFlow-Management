import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import 'task_form_screen.dart';
import 'task_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List _statusFilters = const [
    {'value': 'all', 'label': 'Semua'},
    {'value': 'todo', 'label': 'To-Do'},
    {'value': 'in_progress', 'label': 'In Progress'},
    {'value': 'done', 'label': 'Done'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskFlow Management', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Muat Ulang',
            icon: const Icon(Icons.refresh),
            onPressed: provider.isLoading ? null : () => provider.loadTasks(),
          )
        ]
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari judul atau deskripsi tugas',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: provider.searchQuery.isNotEmpty ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    provider.setSearchQuery('');
                  },
                )
                : null,
              ),
              onChanged: provider.setSearchQuery,
            ),
          ),

          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _statusFilters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8,),
              itemBuilder: (context, index) {
                final filter = _statusFilters[index];
                final isSelected = provider.selectedStatus == filter['value'];
                return ChoiceChip(
                  label: Text(filter['label']!),
                  selected: isSelected,
                  onSelected: (_) => provider.setStatusFilter(filter['value']!),
                );
              },
            ),
          ),
          const SizedBox(height: 8,),
          
          Expanded(
            child: _buildBody(provider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openTaskForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Tugas baru'),
      ),
    );
  }

  Widget _buildBody(TaskProvider provider) {
    if (provider.isLoading && provider.tasks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.tasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 56, color: Colors.redAccent),
              const SizedBox(height: 12,),
              Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 16,),
              FilledButton.icon(
                onPressed: () => provider.loadTasks(),
                icon: const Icon(Icons.refresh),
                label: const Text('Coba lagi'),
              ),
            ],
          )
        )
      );
    }

    final tasks = provider.tasks;
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.task_alt, size: 64, color: Colors.grey.shade600,),
            const SizedBox(height: 12,),
            Text(
              'Belum ada tugas ditemukan',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadTasks(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
        itemCount: tasks.length,
        separatorBuilder: (_, _) => SizedBox(height: 10,),
        itemBuilder: (context, index) {
          final task = tasks[index];
          return _buildTaskCard(context, task, provider);
        },
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    TaskModel task,
    TaskProvider provider,
  ) {
    final isDone = task.status == 'done';
    final formattedDate = DateFormat('DD MM YYYY').format(task.dueDate);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)));
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildStatusBadge(task.status),
                  const SizedBox(width: 8),
                  _buildPriorityBadge(task.priority),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Hapus tugas',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _confirmDelete(context, task, provider),
                  )
                ],
              ),
              const SizedBox(height: 6),
              Text(
                task.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  color: isDone ? Colors.grey : null,
                ),
              ),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    'Deadline: $formattedDate',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  )
                ],
              )
            ],
          )
        )
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
          fontSize: 11,
          fontWeight: FontWeight.w600,
        )
      )
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color color;
    String label;
    switch (priority){
      case 'high':
        color =  Colors.red;
        label = 'High';
        break;
      case 'low':
        color = Colors.teal;
        label = 'Low';
        break;
      default:
        color = Colors.indigo;
        label = 'Medium';
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
          fontSize: 11,
          fontWeight: FontWeight.w500,
        )
      )
    );
  }

  void _openTaskForm(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskFormScreen()),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    TaskModel task,
    TaskProvider provider,
  ) async {
    if (task.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Tugas?'),
        content: Text('Tugas "${task.title}" akan dihapus permanen'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus')
          ),
        ],
      )
    );

    if (confirmed == true && context.mounted) {
      final success = await provider.removeTask(task.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Tugas berhasil dihapus' : provider.errorMessage ?? 'Gagal menghapus tugas',
            ),
          )
        );
      }
    }
  }
}