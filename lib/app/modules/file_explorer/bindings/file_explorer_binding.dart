import 'package:get/get.dart';
import '../controllers/file_explorer_controller.dart';
import '../../../data/repositories/file_repository.dart';
import '../../../data/services/file_service.dart';

class FileExplorerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FileService>(() => FileService(baseUrl: 'http://localhost:8080'));
    Get.lazyPut<FileRepository>(() => FileRepository(Get.find<FileService>()));
    Get.lazyPut<FileExplorerController>(
      () => FileExplorerController(Get.find<FileRepository>()),
    );
  }
} 