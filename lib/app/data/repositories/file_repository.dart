import 'dart:io';
import '../models/api_response.dart';
import '../models/file_model.dart';
import '../services/file_service.dart';

class FileRepository {
  final FileService _fileService;

  FileRepository(this._fileService);

  Future<ApiResponse<List<FileModel>>> getFiles(String directory) async {
    return await _fileService.listFiles(directory);
  }

  Future<ApiResponse<FileModel>> uploadFile(File file, String destination) async {
    return await _fileService.uploadFile(file, destination);
  }

  Future<ApiResponse<String>> downloadFile(String fileId, String savePath) async {
    return await _fileService.downloadFile(fileId, savePath);
  }

  Future<ApiResponse<void>> deleteFile(String fileId) async {
    return await _fileService.deleteFile(fileId);
  }

  Future<ApiResponse<FileModel>> renameFile(String fileId, String newName) async {
    return await _fileService.renameFile(fileId, newName);
  }

  Future<ApiResponse<FileModel>> moveFile(String fileId, String newPath) async {
    return await _fileService.moveFile(fileId, newPath);
  }
} 