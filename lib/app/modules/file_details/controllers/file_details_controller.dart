import 'package:get/get.dart';
import '../../../services/minio_service.dart';

class FileDetailsController extends GetxController {
  final MinioService _minioService = Get.find<MinioService>();
  
  final RxString fileName = ''.obs;
  final RxString downloadUrl = ''.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is String) {
      fileName.value = args;
      generateDownloadUrl();
    }
  }

  Future<void> generateDownloadUrl() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      downloadUrl.value = await _minioService.getDownloadUrl(fileName.value);
    } catch (e) {
      errorMessage.value = 'Failed to generate download URL: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> downloadFile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final filePath = await _minioService.downloadFile(fileName.value);
      
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

  Future<void> deleteFile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      await _minioService.deleteFile(fileName.value);
      
      Get.back();
      Get.snackbar(
        'Success',
        'File deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = 'Failed to delete file: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }
} 