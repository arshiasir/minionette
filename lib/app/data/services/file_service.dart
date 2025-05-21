import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import '../models/api_response.dart';
import '../models/file_model.dart';

class FileService {
  final Dio _dio;
  final String baseUrl;

  FileService({
    required this.baseUrl,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  Future<ApiResponse<List<FileModel>>> listFiles(String directory) async {
    try {
      final response = await _dio.get('/files', queryParameters: {'path': directory});
      final List<dynamic> data = response.data['data'];
      final files = data.map((json) => FileModel.fromJson(json)).toList();
      return ApiResponse.success(files);
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to list files',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred');
    }
  }

  Future<ApiResponse<FileModel>> uploadFile(File file, String destination) async {
    try {
      final fileName = path.basename(file.path);
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        'destination': destination,
      });

      final response = await _dio.post('/files/upload', data: formData);
      final uploadedFile = FileModel.fromJson(response.data['data']);
      return ApiResponse.success(uploadedFile);
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to upload file',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred');
    }
  }

  Future<ApiResponse<String>> downloadFile(String fileId, String savePath) async {
    try {
      final response = await _dio.get(
        '/files/download/$fileId',
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
        ),
      );

      final file = File(savePath);
      await file.writeAsBytes(response.data);
      return ApiResponse.success(savePath);
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to download file',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred');
    }
  }

  Future<ApiResponse<void>> deleteFile(String fileId) async {
    try {
      await _dio.delete('/files/$fileId');
      return ApiResponse.success(null);
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to delete file',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred');
    }
  }

  Future<ApiResponse<FileModel>> renameFile(String fileId, String newName) async {
    try {
      final response = await _dio.patch(
        '/files/$fileId/rename',
        data: {'name': newName},
      );
      final renamedFile = FileModel.fromJson(response.data['data']);
      return ApiResponse.success(renamedFile);
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to rename file',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred');
    }
  }

  Future<ApiResponse<FileModel>> moveFile(String fileId, String newPath) async {
    try {
      final response = await _dio.patch(
        '/files/$fileId/move',
        data: {'path': newPath},
      );
      final movedFile = FileModel.fromJson(response.data['data']);
      return ApiResponse.success(movedFile);
    } on DioException catch (e) {
      return ApiResponse.error(
        e.response?.data['message'] ?? 'Failed to move file',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred');
    }
  }
} 