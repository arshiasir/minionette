import 'dart:io';
import 'package:aws_s3_api/aws_s3_api.dart';
import 'package:aws_common/aws_common.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import '../models/api_response.dart';
import '../models/file_model.dart';

class MinioService {
  final String endpoint;
  final String accessKey;
  final String secretKey;
  final String bucket;
  late final S3Api _s3Client;

  MinioService({
    required this.endpoint,
    required this.accessKey,
    required this.secretKey,
    required this.bucket,
  }) {
    final credentials = AwsClientCredentials(
      accessKey: accessKey,
      secretKey: secretKey,
    );

    final region = 'us-east-1'; // MinIO doesn't require a specific region
    final scope = AwsScope(region: region, service: 's3');

    _s3Client = S3Api(
      region: region,
      credentials: credentials,
      endpoint: endpoint,
      scope: scope,
    );
  }

  Future<ApiResponse<List<FileModel>>> listFiles(String prefix) async {
    try {
      final response = await _s3Client.listObjects(
        bucket: bucket,
        prefix: prefix.isEmpty ? null : prefix,
      );

      final files = response.contents?.map((object) {
        final isDirectory = object.key?.endsWith('/') ?? false;
        final name = path.basename(object.key ?? '');
        
        return FileModel(
          id: object.key ?? '',
          name: name,
          path: object.key ?? '',
          size: object.size?.toInt() ?? 0,
          type: _getFileType(name),
          lastModified: object.lastModified ?? DateTime.now(),
          isDirectory: isDirectory,
          url: _getFileUrl(object.key ?? ''),
          thumbnailUrl: _getThumbnailUrl(object.key ?? ''),
        );
      }).toList() ?? [];

      return ApiResponse.success(files);
    } catch (e) {
      return ApiResponse.error('Failed to list files: $e');
    }
  }

  Future<ApiResponse<FileModel>> uploadFile(File file, String destination) async {
    try {
      final fileName = path.basename(file.path);
      final key = destination.isEmpty ? fileName : '$destination/$fileName';
      final contentType = lookupMimeType(fileName) ?? 'application/octet-stream';

      final bytes = await file.readAsBytes();
      await _s3Client.putObject(
        bucket: bucket,
        key: key,
        body: bytes,
        contentType: contentType,
      );

      final uploadedFile = FileModel(
        id: key,
        name: fileName,
        path: key,
        size: bytes.length,
        type: _getFileType(fileName),
        lastModified: DateTime.now(),
        isDirectory: false,
        url: _getFileUrl(key),
        thumbnailUrl: _getThumbnailUrl(key),
      );

      return ApiResponse.success(uploadedFile);
    } catch (e) {
      return ApiResponse.error('Failed to upload file: $e');
    }
  }

  Future<ApiResponse<String>> downloadFile(String key, String savePath) async {
    try {
      final response = await _s3Client.getObject(
        bucket: bucket,
        key: key,
      );

      final file = File(savePath);
      await file.writeAsBytes(response.bodyBytes);
      return ApiResponse.success(savePath);
    } catch (e) {
      return ApiResponse.error('Failed to download file: $e');
    }
  }

  Future<ApiResponse<void>> deleteFile(String key) async {
    try {
      await _s3Client.deleteObject(
        bucket: bucket,
        key: key,
      );
      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error('Failed to delete file: $e');
    }
  }

  Future<ApiResponse<FileModel>> renameFile(String oldKey, String newName) async {
    try {
      final newKey = path.join(path.dirname(oldKey), newName);
      await _s3Client.copyObject(
        bucket: bucket,
        key: newKey,
        copySource: '$bucket/$oldKey',
      );
      await _s3Client.deleteObject(
        bucket: bucket,
        key: oldKey,
      );

      final renamedFile = FileModel(
        id: newKey,
        name: newName,
        path: newKey,
        size: 0, // Size will be updated when listing files
        type: _getFileType(newName),
        lastModified: DateTime.now(),
        isDirectory: false,
        url: _getFileUrl(newKey),
        thumbnailUrl: _getThumbnailUrl(newKey),
      );

      return ApiResponse.success(renamedFile);
    } catch (e) {
      return ApiResponse.error('Failed to rename file: $e');
    }
  }

  Future<ApiResponse<FileModel>> moveFile(String oldKey, String newPath) async {
    try {
      final fileName = path.basename(oldKey);
      final newKey = path.join(newPath, fileName);
      
      await _s3Client.copyObject(
        bucket: bucket,
        key: newKey,
        copySource: '$bucket/$oldKey',
      );
      await _s3Client.deleteObject(
        bucket: bucket,
        key: oldKey,
      );

      final movedFile = FileModel(
        id: newKey,
        name: fileName,
        path: newKey,
        size: 0, // Size will be updated when listing files
        type: _getFileType(fileName),
        lastModified: DateTime.now(),
        isDirectory: false,
        url: _getFileUrl(newKey),
        thumbnailUrl: _getThumbnailUrl(newKey),
      );

      return ApiResponse.success(movedFile);
    } catch (e) {
      return ApiResponse.error('Failed to move file: $e');
    }
  }

  String _getFileType(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
        return 'image';
      case '.mp4':
      case '.avi':
      case '.mov':
        return 'video';
      case '.mp3':
      case '.wav':
      case '.ogg':
        return 'audio';
      case '.txt':
      case '.md':
      case '.json':
        return 'text';
      case '.pdf':
        return 'pdf';
      default:
        return 'unknown';
    }
  }

  String _getFileUrl(String key) {
    return '$endpoint/$bucket/$key';
  }

  String? _getThumbnailUrl(String key) {
    final fileType = _getFileType(key);
    if (fileType == 'image') {
      return _getFileUrl(key);
    }
    return null;
  }
} 