import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import '../../../services/minio_service.dart';
import '../../../services/bucket_status_service.dart';

class HomeController extends GetxController {
  final MinioService _minioService = Get.find<MinioService>();
  final BucketStatusService _bucketStatusService = Get.find<BucketStatusService>();
  final _storage = GetStorage();
  
  final RxList<String> files = <String>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<String> buckets = <String>[].obs;
  final RxString currentBucket = ''.obs;
  final RxMap<String, bool> bucketPublicStatus = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    // Load buckets and their public status immediately
    loadBuckets();
    // Load MinIO settings and files after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMinioSettings();
    });
  }

  Future<void> _loadMinioSettings() async {
    try {
      final name = _storage.read('minio_name') ?? 'Default Account';
      final endpoint = _storage.read('minio_endpoint');
      final accessKey = _storage.read('minio_access_key');
      final secretKey = _storage.read('minio_secret_key');
      final bucket = _storage.read('minio_bucket');
      final useSSL = _storage.read('minio_use_ssl') ?? true;

      if (endpoint != null && accessKey != null && secretKey != null && bucket != null) {
        await _minioService.configureMinio(
          accountName: name,
          endpoint: endpoint,
          accessKey: accessKey,
          secretKey: secretKey,
          useSSL: useSSL,
        );
        // Reload buckets to ensure we have the latest public status
        await loadBuckets();
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

  Future<void> getDownloadUrl(String fileName, {int hours = 1}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final url = await _minioService.getDownloadUrl(
        fileName,
        expiry: Duration(hours: hours),
      );
      await Clipboard.setData(ClipboardData(text: url));
      Get.snackbar(
        'Temporary Download URL',
        'URL copied to clipboard (expires in $hours hours): $url',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 10),
      );
    } catch (e) {
      errorMessage.value = 'Failed to get download URL: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getPublicUrl(String fileName) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final url = await _minioService.getPublicUrl(fileName);
      await Clipboard.setData(ClipboardData(text: url));
      Get.snackbar(
        'Public Download URL',
        'URL copied to clipboard: $url',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 10),
      );
    } catch (e) {
      errorMessage.value = 'Failed to get public URL: ${e.toString()}';
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

  Future<void> loadBuckets() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // First get the list of buckets
      buckets.value = await _minioService.listBuckets();
      currentBucket.value = _minioService.currentBucket.value;
      
      // Load saved statuses from storage
      final savedStatuses = _bucketStatusService.getAllBucketStatuses();
      
      // Check public status for each bucket
      for (final bucket in buckets) {
        try {
          // Try to get the status from MinIO
          final isPublic = await _minioService.isBucketPublic(bucket);
          bucketPublicStatus[bucket] = isPublic;
          // Save the status to storage
          await _bucketStatusService.saveBucketStatus(bucket, isPublic);
        } catch (e) {
          // If we can't check the status, use the saved status if available
          bucketPublicStatus[bucket] = savedStatuses[bucket] ?? false;
        }
      }
      
      // Notify listeners that the status has been updated
      bucketPublicStatus.refresh();
    } catch (e) {
      errorMessage.value = 'Failed to load buckets: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }
  Rx<TextEditingController> bucketName = TextEditingController().obs;
  Future<void> createNewBucket() async {
    if (bucketName.value.text.isEmpty) {
      errorMessage.value = 'Bucket name cannot be empty';
      return;
    }

    if (bucketName.value.text.contains(' ')) {
      errorMessage.value = 'Bucket name cannot contain spaces';
      return;
    }

    if (bucketName.value.text.length < 3) {
      errorMessage.value = 'Bucket name must be at least 3 characters long';
      return;
    }
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _minioService.createBucket(bucketName.value.text);
      Get.snackbar(
        'Success',
        'Bucket created successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      bucketName.value.clear(); // Clear the input field after successful creation
      await loadBuckets();
    } catch (e) {
      String errorMsg = 'Failed to create bucket';
      if (e.toString().toLowerCase().contains('bucketalreadyexists')) {
        errorMsg = 'A bucket with this name already exists';
      } else if (e.toString().toLowerCase().contains('invalidbucketname')) {
        errorMsg = 'Invalid bucket name. Use only lowercase letters, numbers, dots, and hyphens';
      }
      errorMessage.value = errorMsg;
      Get.snackbar(
        'Error',
        errorMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteBucket(String bucketName) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _minioService.deleteBucket(bucketName);
      // Remove the bucket status from storage
      await _bucketStatusService.removeBucketStatus(bucketName);
      Get.snackbar(
        'Success',
        'Bucket deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      await loadBuckets();
    } catch (e) {
      errorMessage.value = 'Failed to delete bucket: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> switchBucket(String bucketName) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _minioService.switchBucket(bucketName);
      currentBucket.value = bucketName;
      await loadFiles(); // Reload files for the new bucket
      Get.snackbar(
        'Success',
        'Switched to bucket: $bucketName',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = 'Failed to switch bucket: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> enablePublicAccess(String bucketName) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _minioService.setBucketPublicAccess(bucketName);
      bucketPublicStatus[bucketName] = true;
      // Save the status to storage
      await _bucketStatusService.saveBucketStatus(bucketName, true);
      Get.snackbar(
        'Success',
        'Public access enabled for bucket: $bucketName',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = 'Failed to enable public access: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> disablePublicAccess(String bucketName) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _minioService.disablePublicAccess(bucketName);
      bucketPublicStatus[bucketName] = false;
      // Save the status to storage
      await _bucketStatusService.saveBucketStatus(bucketName, false);
      Get.snackbar(
        'Success',
        'Public access disabled for bucket: $bucketName',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = 'Failed to disable public access: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }
} 