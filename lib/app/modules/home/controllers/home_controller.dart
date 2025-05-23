import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/widgets.dart';
import '../../../services/minio_service.dart';

class HomeController extends GetxController {
  final MinioService _minioService = Get.find<MinioService>();
  final _storage = GetStorage();
  
  final RxList<String> files = <String>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMinioSettings();
    });
  }

  Future<void> _loadMinioSettings() async {
    try {
      final endpoint = _storage.read('minio_endpoint');
      final accessKey = _storage.read('minio_access_key');
      final secretKey = _storage.read('minio_secret_key');
      final bucket = _storage.read('minio_bucket');
      final useSSL = _storage.read('minio_use_ssl') ?? true;

      if (endpoint != null && accessKey != null && secretKey != null && bucket != null) {
        await _minioService.configureMinio(
          endpoint: endpoint,
          accessKey: accessKey,
          secretKey: secretKey,
          bucket: bucket,
          useSSL: useSSL,
        );
        await loadFiles();
      } else {
        Get.snackbar(
          'Configuration Required',
          'Please configure MinIO settings first',
          snackPosition: SnackPosition.BOTTOM,
        );
        await Future.delayed(const Duration(milliseconds: 500));
        Get.toNamed('/settings');
      }
    } catch (e) {
      errorMessage.value = 'Failed to load MinIO settings: ${e.toString()}';
    }
  }

  Future<void> loadFiles() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      files.value = await _minioService.listFiles();
    } catch (e) {
      errorMessage.value = 'Failed to load files: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickAndUploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null) {
        isLoading.value = true;
        errorMessage.value = '';
        final fileName = await _minioService.uploadFile(result.files.first);
        Get.snackbar(
          'Success',
          'File uploaded successfully: $fileName',
          snackPosition: SnackPosition.BOTTOM,
        );
        await loadFiles();
      }
    } catch (e) {
      errorMessage.value = 'Failed to upload file: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> downloadFile(String fileName) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final filePath = await _minioService.downloadFile(fileName);
      Get.snackbar(
        'Success',
        'File downloaded to: $filePath',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = 'Failed to download file: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getDownloadUrl(String fileName) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final url = await _minioService.getDownloadUrl(fileName);
      Get.snackbar(
        'Download URL',
        url,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 10),
      );
    } catch (e) {
      errorMessage.value = 'Failed to get download URL: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteFile(String fileName) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _minioService.deleteFile(fileName);
      Get.snackbar(
        'Success',
        'File deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      await loadFiles();
    } catch (e) {
      errorMessage.value = 'Failed to delete file: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }
} 