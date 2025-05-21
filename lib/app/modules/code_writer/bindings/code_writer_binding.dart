import 'package:get/get.dart';
import '../controllers/code_writer_controller.dart';

class CodeWriterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CodeWriterController>(() => CodeWriterController());
  }
} 