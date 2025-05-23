import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import 'bucket_management_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MinIO File Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder),
            onPressed: () => Get.to(() => const BucketManagementView()),
            tooltip: 'Manage Buckets',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.toNamed('/settings'),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.loadFiles,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.files.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'No files found',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: controller.pickAndUploadFile,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload File'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.files.length,
          itemBuilder: (context, index) {
            final fileName = controller.files[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.insert_drive_file),
                title: Text(fileName),
                subtitle: Obx(() {
                  final hasError = controller.errorMessage.value.contains(fileName);
                  return hasError
                      ? const Text(
                          'Error processing file',
                          style: TextStyle(color: Colors.red),
                        )
                      : const SizedBox.shrink();
                }),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.download),
                      onPressed: () => controller.downloadFile(fileName),
                      tooltip: 'Download',
                    ),
                    IconButton(
                      icon: const Icon(Icons.link),
                      onPressed: () => controller.getDownloadUrl(fileName),
                      tooltip: 'Get Download URL',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => controller.deleteFile(fileName),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.pickAndUploadFile,
        child: const Icon(Icons.add),
      ),
    );
  }
} 