import 'package:get/get.dart';
import 'package:minio/minio.dart';
import 'package:minio/src/minio.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class MinioService extends GetxService {
  late Minio _minio;
  final RxMap<String, bool> accountConnections = <String, bool>{}.obs;
  final RxMap<String, String> accountErrors = <String, String>{}.obs;
  final RxString currentBucket = ''.obs;
  final RxList<String> errorFiles = <String>[].obs;
  final RxList<String> buckets = <String>[].obs;
  final RxString globalError = ''.obs;

  String _getDetailedErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    // Network related errors
    if (errorString.contains('socketexception')) {
      if (errorString.contains('connection refused')) {
        return 'Server is not running or not accessible. Please check if the MinIO server is running and the endpoint is correct.';
      } else if (errorString.contains('connection timed out')) {
        return 'Connection timed out. Please check your network connection and server availability.';
      } else if (errorString.contains('no address associated with hostname')) {
        return 'Invalid endpoint address. Please check if the server address is correct.';
      }
      return 'Network connection error. Please check your internet connection and server address.';
    }

    // Authentication errors
    if (errorString.contains('invalidaccesskeyid')) {
      return 'Invalid access key. Please check your access key credentials.';
    }
    if (errorString.contains('signaturedoesnotmatch')) {
      return 'Invalid secret key. Please check your secret key credentials.';
    }
    if (errorString.contains('accessdenied')) {
      return 'Access denied. Please check your credentials and permissions.';
    }

    // SSL/TLS errors
    if (errorString.contains('ssl') || errorString.contains('tls')) {
      if (errorString.contains('certificate')) {
        return 'SSL certificate error. Please check your SSL settings and certificate configuration.';
      }
      return 'SSL/TLS connection error. Please check your SSL settings.';
    }

    // Bucket related errors
    if (errorString.contains('nosuchbucket')) {
      return 'Bucket does not exist. Please check the bucket name.';
    }
    if (errorString.contains('bucketalreadyexists')) {
      return 'Bucket already exists. Please use a different bucket name.';
    }

    // Port related errors
    if (errorString.contains('port')) {
      return 'Invalid port number. Please check if the port is correct and accessible.';
    }

    // Default error message
    return 'An error occurred: ${error.toString()}';
  }

  Future<MinioService> init() async {
    try {
      globalError.value = '';
      return this;
    } catch (e) {
      globalError.value = 'Failed to initialize MinIO service: ${_getDetailedErrorMessage(e)}';
      rethrow;
    }
  }

  Future<bool> testConnection(String accountName) async {
    try {
      accountErrors[accountName] = '';
      globalError.value = '';
      
      if (_minio == null) {
        throw Exception('MinIO client not initialized. Please try reconnecting.');
      }

      // Try to list buckets as a connection test
      await _minio.listBuckets();
      accountConnections[accountName] = true;
      return true;
    } catch (e) {
      accountConnections[accountName] = false;
      final errorMessage = _getDetailedErrorMessage(e);
      accountErrors[accountName] = errorMessage;
      globalError.value = errorMessage;
      return false;
    }
  }

  Future<void> configureMinio({
    required String endpoint,
    required String accessKey,
    required String secretKey,
    required String accountName,
    bool useSSL = false,
  }) async {
    try {
      accountErrors[accountName] = '';
      globalError.value = '';

      // Validate inputs with specific messages
      if (endpoint.isEmpty) {
        throw Exception('Endpoint cannot be empty. Please provide a valid server address.');
      }
      if (accessKey.isEmpty) {
        throw Exception('Access key cannot be empty. Please provide your MinIO access key.');
      }
      if (secretKey.isEmpty) {
        throw Exception('Secret key cannot be empty. Please provide your MinIO secret key.');
      }

      // Validate endpoint format
      if (!endpoint.contains('.')) {
        throw Exception('Invalid endpoint format. Please provide a valid server address (e.g., play.min.io).');
      }

      _minio = Minio(
        endPoint: endpoint,
        accessKey: accessKey,
        secretKey: secretKey,
        useSSL: useSSL,
      );

      // Test the connection immediately after configuration
      await testConnection(accountName);
    } catch (e) {
      accountConnections[accountName] = false;
      final errorMessage = _getDetailedErrorMessage(e);
      accountErrors[accountName] = errorMessage;
      globalError.value = errorMessage;
      rethrow;
    }
  }

  bool isAccountConnected(String accountName) {
    return accountConnections[accountName] ?? false;
  }

  String getAccountError(String accountName) {
    return accountErrors[accountName] ?? '';
  }

  void clearErrors() {
    globalError.value = '';
    accountErrors.clear();
  }

  Future<String> uploadFile(PlatformFile file) async {
    try {
      final fileName = path.basename(file.path!);
      final fileBytes = await File(file.path!).readAsBytes();
      final stream = Stream.value(fileBytes);
      
      await _minio.putObject(
        currentBucket.value,
        fileName,
        stream,
      );
      return fileName;
    } catch (e) {
      errorFiles.add(file.name);
      rethrow;
    }
  }

  Future<String> downloadFile(String fileName) async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath = path.join(directory.path, fileName);
      
      final data = await _minio.getObject(currentBucket.value, fileName);
      final file = File(filePath);
      final bytes = await data.toList().then((chunks) => 
        chunks.expand((chunk) => chunk).toList());
      await file.writeAsBytes(bytes);
      
      return filePath;
    } catch (e) {
      errorFiles.add(fileName);
      rethrow;
    }
  }

  Future<String> getDownloadUrl(String fileName, {Duration? expiry}) async {
    try {
      final url = await _minio.presignedGetObject(
        currentBucket.value,
        fileName,
        expires: expiry?.inSeconds ?? 3600,
      );
      return url;
    } catch (e) {
      errorFiles.add(fileName);
      rethrow;
    }
  }

  Future<List<String>> listFiles() async {
  try {
    final objects = await _minio.listObjects(currentBucket.value);
    final List<String> fileNames = [];
    await for (final result in objects) {
      for (final object in result.objects) {
        fileNames.add(object.key!);
      }
    }
    return fileNames;
  } catch (e) {
    rethrow;
  }
}


  Future<void> deleteFile(String fileName) async {
    try {
      await _minio.removeObject(currentBucket.value, fileName);
      errorFiles.remove(fileName);
    } catch (e) {
      rethrow;
    }
  }

  void clearErrorFiles() {
    errorFiles.clear();
  }

  Future<List<String>> listBuckets() async {
    try {
      final bucketList = await _minio.listBuckets();
      buckets.value = bucketList.map((b) => b.name).toList();
      return buckets;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createBucket(String bucketName) async {
    try {
      final exists = await _minio.bucketExists(bucketName);
      if (!exists) {
        await _minio.makeBucket(bucketName);
        buckets.add(bucketName);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteBucket(String bucketName) async {
    try {
      if (bucketName == currentBucket.value) {
        throw Exception('Cannot delete currently selected bucket');
      }
      await _minio.removeBucket(bucketName);
      buckets.remove(bucketName);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> switchBucket(String bucketName) async {
    try {
      final exists = await _minio.bucketExists(bucketName);
      if (!exists) {
        throw Exception('Bucket does not exist');
      }
      currentBucket.value = bucketName;
    } catch (e) {
      rethrow;
    }
  }
} 