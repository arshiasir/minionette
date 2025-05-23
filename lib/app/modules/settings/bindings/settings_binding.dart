import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../../../services/minio_service.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MinioService>(() => MinioService());
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
} 