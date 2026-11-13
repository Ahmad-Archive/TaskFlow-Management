import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';

class TaskFormScreen extends StatefulWidget {
  final TaskModel? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;

  late String _status;
  late String _priority;
  late DateTime _dueDate;

  bool get _isEditMode => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController =
        TextEditingController(text: widget.task?.description ?? '');
    _status = widget.task?.status ?? 'todo';
    _priority = widget.task?.priority ?? 'medium';
    _dueDate = widget.task?.dueDate ?? DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<TaskProvider>();
    final taskData = TaskModel(
      id: widget.task?.id,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      status: _status,
      priority: _priority,
      dueDate: _dueDate,
    );

    final bool success = _isEditMode
        ? await provider.editTask(taskData)
        : await provider.addTask(taskData);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode
                ? 'Tugas berhasil diperbarui'
                : 'Tugas baru berhasil ditambahkan',
          ),
        ),
      );
      Navigator.pop(context, taskData);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(provider.errorMessage ?? 'Gagal menyimpan tugas'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<TaskProvider>().isLoading;
    final formattedDate = DateFormat('dd MMMM yyyy').format(_dueDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Tugas' : 'Tambah Tugas Baru'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul Tugas *',
                hintText: 'Contoh: Selesaikan laporan praktikum',
              ),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Judul tugas wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                hintText: 'Catatan detail atau langkah pengerjaan...',
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status Pengerjaan'),
              items: const [
                DropdownMenuItem(value: 'todo', child: Text('To-Do')),
                DropdownMenuItem(
                    value: 'in_progress', child: Text('In Progress')),
                DropdownMenuItem(value: 'done', child: Text('Done')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _status = val);
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _priority,
              decoration: const InputDecoration(labelText: 'Prioritas'),
              items: const [
                DropdownMenuItem(value: 'low', child: Text('Low')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'high', child: Text('High')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _priority = val);
              },
            ),
            const SizedBox(height: 16),

            // Pemilih Tanggal Deadline
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _pickDueDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Tenggat Waktu (Deadline)',
                  suffixIcon: Icon(Icons.calendar_month),
                ),
                child: Text(formattedDate),
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: isLoading ? null : _submitForm,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  isLoading
                      ? 'Menyimpan...'
                      : (_isEditMode ? 'Simpan Perubahan' : 'Simpan Tugas'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}