import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import '../controllers/file_explorer_controller.dart';
import '../../../data/models/file_model.dart';

class FileExplorerView extends GetView<FileExplorerController> {
  const FileExplorerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.currentPath.value)),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () => _pickAndUploadFile(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPathBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        controller.errorMessage.value,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => controller.loadFiles(controller.currentPath.value),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (controller.files.isEmpty) {
                return const Center(
                  child: Text('No files found in this directory'),
                );
              }

              return ListView.builder(
                itemCount: controller.files.length,
                itemBuilder: (context, index) {
                  final file = controller.files[index];
                  return _buildFileItem(file);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPathBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_upward),
            onPressed: controller.navigateUp,
          ),
          Expanded(
            child: Obx(() {
              final pathParts = controller.currentPath.value.split('/');
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var i = 0; i < pathParts.length; i++)
                      if (pathParts[i].isNotEmpty) ...[
                        TextButton(
                          onPressed: () {
                            final path = pathParts.sublist(0, i + 1).join('/');
                            controller.navigateToDirectory(path);
                          },
                          child: Text(pathParts[i]),
                        ),
                        if (i < pathParts.length - 1)
                          const Text('/'),
                      ],
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFileItem(FileModel file) {
    return ListTile(
      leading: Icon(
        file.isDirectory ? Icons.folder : _getFileIcon(file.type),
        color: file.isDirectory ? Colors.amber : Colors.blue,
      ),
      title: Text(file.name),
      subtitle: Text(
        file.isDirectory
            ? 'Directory'
            : '${_formatFileSize(file.size)} • ${_formatDate(file.lastModified)}',
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => _handleFileAction(value, file),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'download',
            child: Text('Download'),
          ),
          const PopupMenuItem(
            value: 'rename',
            child: Text('Rename'),
          ),
          const PopupMenuItem(
            value: 'move',
            child: Text('Move'),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Text('Delete'),
          ),
        ],
      ),
      onTap: () {
        if (file.isDirectory) {
          controller.navigateToDirectory(file.path);
        }
      },
    );
  }

  IconData _getFileIcon(String? fileType) {
    if (fileType == null) return Icons.insert_drive_file;
    
    switch (fileType.toLowerCase()) {
      case 'image':
        return Icons.image;
      case 'video':
        return Icons.video_file;
      case 'audio':
        return Icons.audio_file;
      case 'text':
        return Icons.text_snippet;
      case 'pdf':
        return Icons.picture_as_pdf;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int size) {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _pickAndUploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null) {
        final file = File(result.files.single.path!);
        await controller.uploadFile(file);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick file: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _handleFileAction(String action, FileModel file) async {
    switch (action) {
      case 'download':
        await controller.downloadFile(file);
        break;
      case 'rename':
        _showRenameDialog(file);
        break;
      case 'move':
        _showMoveDialog(file);
        break;
      case 'delete':
        _showDeleteConfirmation(file);
        break;
    }
  }

  void _showRenameDialog(FileModel file) {
    final TextEditingController nameController = TextEditingController(text: file.name);
    Get.dialog(
      AlertDialog(
        title: const Text('Rename File'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'New Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.renameFile(file, nameController.text);
              Get.back();
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _showMoveDialog(FileModel file) {
    final TextEditingController pathController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('Move File'),
        content: TextField(
          controller: pathController,
          decoration: const InputDecoration(
            labelText: 'New Path',
            hintText: 'Enter the destination path',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.moveFile(file, pathController.text);
              Get.back();
            },
            child: const Text('Move'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(FileModel file) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete ${file.name}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteFile(file);
              Get.back();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 