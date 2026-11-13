import 'package:dio/dio.dart';
import '../models/task_model.dart';

class TaskService {
  static const String _baseUrl = 'https://6af5ba65f6270fa08d688641.mockapi.io/tasks';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }
    )
  );

  // Mengambil daftar tugas
  Future<List<TaskModel>> fetchTasks() async {
    try {
      final response = await _dio.get('/tasks');
      final List<dynamic> data = response.data;
      return data.map((json) => TaskModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // Menambahkan tugas baru
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      final response = await _dio.post('/tasks', data: task.toJson());
      return TaskModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // Memperbarui tugas berdasarkan ID
  Future<TaskModel> updateTask(TaskModel task) async {
    if (task.id == null) {
      throw Exception('ID tugas tidak ditemukan');
    }
    try {
      final response = await _dio.put('/tasks/${task.id}', data: task.toJson());
      return TaskModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  // Menghapus tugas berdasarkan ID
  Future<void> deleteTask(String id) async {
    try {
      await _dio.delete ('/tasks/$id');
    } on DioException catch (e) {
      throw Exception(_handleDioError(e));
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi timeout. Silakan periksa koneksi internet Anda.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Pastikan koneksi internet Anda stabil.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        return 'Terjadi kesalahan pada server. Kode status: $statusCode';
      default:
        return 'Terjadi kesalahan yang tidak diketahui.';
    }
  }
}