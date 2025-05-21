import 'dart:io';
import 'package:get/get.dart';
import '../../../data/models/api_response.dart';
import '../../../data/models/file_model.dart';
import '../../../data/repositories/file_repository.dart';

class FileExplorerController extends GetxController {
  final FileRepository _fileRepository;
  
  // Observable variables
  final RxList<FileModel> files = <FileModel>[].obs;
  final RxString currentPath = '/'.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  FileExplorerController(this._fileRepository);

  @override
  void onInit() {
    super.onInit();
    loadFiles(currentPath.value);
  }

  Future<void> loadFiles(String directory) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _fileRepository.getFiles(directory);
      
      if (response.success) {
        files.value = response.data ?? [];
        currentPath.value = directory;
      } else {
        errorMessage.value = response.message ?? 'Failed to load files';
      }
    } catch (e) {
      errorMessage.value = 'Failed to load files: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> uploadFile(File file) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _fileRepository.uploadFile(file, currentPath.value);
      
      if (response.success) {
        await loadFiles(currentPath.value);
      } else {
        errorMessage.value = response.message ?? 'Failed to upload file';
      }
    } catch (e) {
      errorMessage.value = 'Failed to upload file: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> downloadFile(FileModel file) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final savePath = '${Directory.systemTemp.path}/${file.name}';
      final response = await _fileRepository.downloadFile(file.id, savePath);
      
      if (!response.success) {
        errorMessage.value = response.message ?? 'Failed to download file';
      }
    } catch (e) {
      errorMessage.value = 'Failed to download file: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteFile(FileModel file) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _fileRepository.deleteFile(file.id);
      
      if (response.success) {
        await loadFiles(currentPath.value);
      } else {
        errorMessage.value = response.message ?? 'Failed to delete file';
      }
    } catch (e) {
      errorMessage.value = 'Failed to delete file: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> renameFile(FileModel file, String newName) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _fileRepository.renameFile(file.id, newName);
      
      if (response.success) {
        await loadFiles(currentPath.value);
      } else {
        errorMessage.value = response.message ?? 'Failed to rename file';
      }
    } catch (e) {
      errorMessage.value = 'Failed to rename file: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> moveFile(FileModel file, String newPath) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final response = await _fileRepository.moveFile(file.id, newPath);
      
      if (response.success) {
        await loadFiles(currentPath.value);
      } else {
        errorMessage.value = response.message ?? 'Failed to move file';
      }
    } catch (e) {
      errorMessage.value = 'Failed to move file: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToDirectory(String path) {
    loadFiles(path);
  }

  void navigateUp() {
    final parentPath = currentPath.value.split('/');
    if (parentPath.length > 1) {
      parentPath.removeLast();
      loadFiles(parentPath.join('/'));
    }
  }
} 