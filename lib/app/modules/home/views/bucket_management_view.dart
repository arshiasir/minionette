import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class BucketManagementView extends GetView<HomeController> {
  const BucketManagementView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bucket Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadBuckets(),
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
                  onPressed: () => controller.loadBuckets(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'New Bucket Name',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          controller.createNewBucket(value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      final textController = TextEditingController();
                      Get.dialog(
                        AlertDialog(
                          title: const Text('Create New Bucket'),
                          content: TextField(
                            controller: textController,
                            decoration: const InputDecoration(
                              labelText: 'Bucket Name',
                              hintText: 'Enter bucket name',
                            ),
                            autofocus: true,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (textController.text.isNotEmpty) {
                                  controller.createNewBucket(textController.text);
                                  Get.back();
                                }
                              },
                              child: const Text('Create'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Bucket'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: controller.buckets.length,
                itemBuilder: (context, index) {
                  final bucket = controller.buckets[index];
                  final isCurrentBucket = bucket == controller.currentBucket.value;
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Icon(
                        Icons.folder,
                        color: isCurrentBucket ? Get.theme.primaryColor : null,
                      ),
                      title: Text(
                        bucket,
                        style: TextStyle(
                          fontWeight: isCurrentBucket ? FontWeight.bold : null,
                          color: isCurrentBucket ? Get.theme.primaryColor : null,
                        ),
                      ),
                      subtitle: isCurrentBucket
                          ? const Text('Current Bucket')
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isCurrentBucket)
                            IconButton(
                              icon: const Icon(Icons.swap_horiz),
                              onPressed: () => controller.switchBucket(bucket),
                              tooltip: 'Switch to this bucket',
                            ),
                          Obx(() {
                            final isPublic = controller.bucketPublicStatus[bucket] ?? false;
                            return IconButton(
                              icon: Icon(
                                Icons.public,
                                color: isPublic ? Colors.green : null,
                              ),
                              onPressed: () {
                                Get.dialog(
                                  AlertDialog(
                                    title: Text(isPublic ? 'Disable Public Access' : 'Enable Public Access'),
                                    content: Text(
                                      isPublic
                                          ? 'This will prevent public access to files in bucket "$bucket". '
                                              'Are you sure you want to disable public access?'
                                          : 'This will allow anyone with the URL to access files in bucket "$bucket". '
                                              'Are you sure you want to enable public access?'
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Get.back(),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          if (isPublic) {
                                            controller.disablePublicAccess(bucket);
                                          } else {
                                            controller.enablePublicAccess(bucket);
                                          }
                                          Get.back();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isPublic ? Colors.red : null,
                                        ),
                                        child: Text(isPublic ? 'Disable Public Access' : 'Enable Public Access'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              tooltip: isPublic ? 'Public access enabled - Click to disable' : 'Public access disabled - Click to enable',
                            );
                          }),
                          if (!isCurrentBucket)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                Get.dialog(
                                  AlertDialog(
                                    title: const Text('Delete Bucket'),
                                    content: Text('Are you sure you want to delete bucket "$bucket"?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Get.back(),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          controller.deleteBucket(bucket);
                                          Get.back();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              tooltip: 'Delete bucket',
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
} 