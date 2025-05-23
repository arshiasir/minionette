import 'package:get/get.dart';
import '../controllers/file_details_controller.dart';

class FileDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FileDetailsController>(() => FileDetailsController());
  }
} 