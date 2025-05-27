import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class BucketStatusService extends GetxService {
  final _storage = GetStorage();
  static const String _bucketStatusKey = 'bucket_public_status';

  Future<BucketStatusService> init() async {
    return this;
  }

  // Save bucket public status to storage
  Future<void> saveBucketStatus(String bucketName, bool isPublic) async {
    final Map<String, dynamic> statusMap = _storage.read(_bucketStatusKey) ?? {};
    statusMap[bucketName] = isPublic;
    await _storage.write(_bucketStatusKey, statusMap);
  }

  // Get bucket public status from storage
  bool getBucketStatus(String bucketName) {
    final Map<String, dynamic> statusMap = _storage.read(_bucketStatusKey) ?? {};
    return statusMap[bucketName] ?? false;
  }

  // Get all bucket statuses from storage
  Map<String, bool> getAllBucketStatuses() {
    final Map<String, dynamic> statusMap = _storage.read(_bucketStatusKey) ?? {};
    return Map<String, bool>.from(statusMap);
  }

  // Remove bucket status from storage
  Future<void> removeBucketStatus(String bucketName) async {
    final Map<String, dynamic> statusMap = _storage.read(_bucketStatusKey) ?? {};
    statusMap.remove(bucketName);
    await _storage.write(_bucketStatusKey, statusMap);
  }

  // Clear all bucket statuses
  Future<void> clearAllStatuses() async {
    await _storage.remove(_bucketStatusKey);
  }
} 