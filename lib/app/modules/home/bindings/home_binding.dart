import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../services/minio_service.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MinioService>(() => MinioService());
    Get.lazyPut<HomeController>(() => HomeController());
  }
} 