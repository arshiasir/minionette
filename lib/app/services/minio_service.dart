import 'package:get/get.dart';
import 'package:minio/minio.dart';
import 'package:minio/src/minio.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';

class MinioService extends GetxService {
  late Minio _minio;
  final RxBool isConnected = false.obs;
  final RxString currentBucket = ''.obs;
  final RxList<String> errorFiles = <String>[].obs;
  final RxList<String> buckets = <String>[].obs;

  Future<MinioService> init() async {
    return this;
  }

  Future<void> configureMinio({
    required String endpoint,
    required String accessKey,
    required String secretKey,
    bool useSSL = false,
  }) async {
    try {
      _minio = Minio(
        endPoint: endpoint,
        accessKey: accessKey,
        secretKey: secretKey,
        useSSL: useSSL,
      );
      isConnected.value = true;
    } catch (e) {
      isConnected.value = false;
      rethrow;
    }
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