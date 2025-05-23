import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:minionette/app/controllers/theme_controller.dart';
import '../../../services/minio_service.dart';
import '../../../models/minio_account.dart';

class SettingsController extends GetxController {
  late MinioService _minioService;
  final ThemeController themeController = Get.find<ThemeController>();
  final _storage = GetStorage();

  final RxList<MinioAccount> accounts = <MinioAccount>[].obs;
  final Rx<MinioAccount?> currentAccount = Rx<MinioAccount?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  RxBool isDarkMode = false.obs;

  // Form fields for new/edit account
  final RxString accountName = ''.obs;
  final RxString endpoint = ''.obs;
  final RxString accessKey = ''.obs;
  final RxString secretKey = ''.obs;
  final RxBool useSSL = true.obs;

  static const String _accountsKey = 'minio_accounts';
  static const String _currentAccountKey = 'current_minio_account';

  @override
  void onInit() {
    super.onInit();
    try {
      _minioService = Get.find<MinioService>();
    } catch (e) {
      _minioService = Get.put(MinioService());
    }
    loadSettings();
  }

  void loadSettings() {
    final accountsJson = _storage.read(_accountsKey) as List<dynamic>? ?? [];
    accounts.value = accountsJson
        .map((json) => MinioAccount.fromJson(json as Map<String, dynamic>))
        .toList();

    final currentAccountJson = _storage.read(_currentAccountKey);
    if (currentAccountJson != null) {
      currentAccount.value = MinioAccount.fromJson(currentAccountJson);
    } else if (accounts.isNotEmpty) {
      currentAccount.value = accounts.first;
    }

    isDarkMode.value = themeController.isDarkMode;
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    themeController.toggleTheme();
  }

  void setCurrentAccount(MinioAccount account) {
    try {
      currentAccount.value = account;
      _storage.write(_currentAccountKey, account.toJson());
      _configureMinio(account);
      Get.forceAppUpdate();
    } catch (e) {
      errorMessage.value = 'Failed to set current account: ${e.toString()}';
    }
  }

  Future<void> _configureMinio(MinioAccount account) async {
    try {
      await _minioService.configureMinio(
        accountName: account.name,
        endpoint: account.endpoint,
        accessKey: account.accessKey,
        secretKey: account.secretKey,
        useSSL: account.useSSL,
      );
    } catch (e) {
      errorMessage.value = 'Failed to configure MinIO: ${e.toString()}';
      rethrow;
    }
  }

  Future<void> saveAccount() async {
    if (accountName.value.isEmpty ||
        endpoint.value.isEmpty ||
        accessKey.value.isEmpty ||
        secretKey.value.isEmpty) {
      errorMessage.value = 'All fields are required';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final newAccount = MinioAccount(
        name: accountName.value,
        endpoint: endpoint.value,
        accessKey: accessKey.value,
        secretKey: secretKey.value,
        useSSL: useSSL.value,
      );

      // Test the configuration
      await _minioService.configureMinio(
        accountName: newAccount.name,
        endpoint: newAccount.endpoint,
        accessKey: newAccount.accessKey,
        secretKey: newAccount.secretKey,
        useSSL: newAccount.useSSL,
      );

      // Add to accounts list
      accounts.add(newAccount);
      await _storage.write(
          _accountsKey, accounts.map((a) => a.toJson()).toList());

      // If this is the first account, set it as current
      if (currentAccount.value == null) {
        setCurrentAccount(newAccount);
      }

      Get.back();
      Get.snackbar(
        'Success',
        'Account saved successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = 'Failed to save account: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAccount(MinioAccount account) async {
    try {
      accounts.remove(account);
      await _storage.write(
          _accountsKey, accounts.map((a) => a.toJson()).toList());

      if (currentAccount.value == account) {
        currentAccount.value = accounts.isNotEmpty ? accounts.first : null;
        if (currentAccount.value != null) {
          await _storage.write(
              _currentAccountKey, currentAccount.value!.toJson());
          await _configureMinio(currentAccount.value!);
        } else {
          await _storage.remove(_currentAccountKey);
        }
      }

      Get.snackbar(
        'Success',
        'Account deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = 'Failed to delete account: ${e.toString()}';
    }
  }

  void toggleSSL() {
    useSSL.value = !useSSL.value;
  }

  void resetForm() {
    accountName.value = '';
    endpoint.value = '';
    accessKey.value = '';
    secretKey.value = '';
    useSSL.value = true;
    errorMessage.value = '';
  }
}
