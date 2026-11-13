import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  List<TaskModel> _allTasks = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedStatus = 'all';
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedStatus => _selectedStatus;
  String get searchQuery => _searchQuery;

  // Mengembalikan daftar tugas yang difilter berdasarkan status dan pencarian
  List<TaskModel> get tasks {
    return _allTasks.where((task) {
      final matchesStatus = _selectedStatus == 'all' || task.status == _selectedStatus;
      final query = _searchQuery.toLowerCase();
      final matchesSearch = task.title.toLowerCase().contains(query) || task.description.toLowerCase().contains(query);
      return matchesStatus && matchesSearch;
    }).toList();
  }

  // Mengambil data awal dari API
  Future<void> loadTasks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allTasks = await _taskService.fetchTasks();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Menambahkan tugas baru & langsung memperbarui state lokal
  Future<bool> addTask(TaskModel newTask) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final createdTask = await _taskService.createTask(newTask);
      _allTasks.insert(0, createdTask);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Edit task yang ada
  Future<bool> editTask(TaskModel updatedTask) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _taskService.updateTask(updatedTask);
      final index = _allTasks.indexWhere((t) => t.id == result.id);
      if (index != -1) {
        _allTasks[index] = result;
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Menghapus task berdasarkan ID
  Future<bool> removeTask(String id) async {
    try {
      await _taskService.deleteTask(id);
      _allTasks.removeWhere((task) => task.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void setStatusFilter(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}