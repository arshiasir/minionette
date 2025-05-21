import 'package:get/get.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/code_writer/bindings/code_writer_binding.dart';
import '../modules/code_writer/views/code_writer_view.dart';
import '../modules/file_explorer/bindings/file_explorer_binding.dart';
import '../modules/file_explorer/views/file_explorer_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.CODE_WRITER,
      page: () => const CodeWriterView(),
      binding: CodeWriterBinding(),
    ),
    GetPage(
      name: _Paths.FILE_EXPLORER,
      page: () => const FileExplorerView(),
      binding: FileExplorerBinding(),
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
  ];
} 