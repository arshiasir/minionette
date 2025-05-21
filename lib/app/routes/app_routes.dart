part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const CODE_WRITER = _Paths.CODE_WRITER;
  static const FILE_EXPLORER = _Paths.FILE_EXPLORER;
  static const SETTINGS = _Paths.SETTINGS;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const CODE_WRITER = '/code-writer';
  static const FILE_EXPLORER = '/file-explorer';
  static const SETTINGS = '/settings';
} 