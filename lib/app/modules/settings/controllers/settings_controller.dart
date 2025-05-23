import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:minionette/app/controllers/theme_controller.dart';
import '../../../services/minio_service.dart';

class SettingsController extends GetxController {
  final MinioService _minioService = Get.find<MinioService>();
  final ThemeController themeController = Get.find<ThemeController>();
  final _storage = GetStorage();
  
  final RxString endpoint = ''.obs;
  final RxString accessKey = ''.obs;
  final RxString secretKey = ''.obs;
  final RxString bucket = ''.obs;
  final RxBool useSSL = true.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  static const String _endpointKey = 'minio_endpoint';
  static const String _accessKeyKey = 'minio_access_key';
  static const String _secretKeyKey = 'minio_secret_key';
  static const String _bucketKey = 'minio_bucket';
  static const String _useSSLKey = 'minio_use_ssl';
        


  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }
  void loadSettings() {
    endpoint.value = _storage.read(_endpointKey) ?? '';
    accessKey.value = _storage.read(_accessKeyKey) ?? '';
    secretKey.value = _storage.read(_secretKeyKey) ?? '';
    bucket.value = _storage.read(_bucketKey) ?? '';
    useSSL.value = _storage.read(_useSSLKey) ?? true;
  }

  Future<void> saveSettings() async {
    if (endpoint.value.isEmpty || accessKey.value.isEmpty || 
        secretKey.value.isEmpty || bucket.value.isEmpty) {
      errorMessage.value = 'All fields are required';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Save to storage
      await _storage.write(_endpointKey, endpoint.value);
      await _storage.write(_accessKeyKey, accessKey.value);
      await _storage.write(_secretKeyKey, secretKey.value);
      await _storage.write(_bucketKey, bucket.value);
      await _storage.write(_useSSLKey, useSSL.value);

      // Configure MinIO service
      await _minioService.configureMinio(
        endpoint: endpoint.value,
        accessKey: accessKey.value,
        secretKey: secretKey.value,
        bucket: bucket.value,
        useSSL: useSSL.value,
      );

      Get.back();
      Get.snackbar(
        'Success',
        'Settings saved successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = 'Failed to save settings: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  void toggleSSL() {
    useSSL.value = !useSSL.value;
  }
} 