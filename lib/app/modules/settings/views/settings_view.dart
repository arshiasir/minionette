import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minionette/app/modules/settings/views/account_add.dart';
import '../controllers/settings_controller.dart';
import '../../../models/minio_account.dart';
import '../../../services/minio_service.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MinIO Settings'),
        actions: [
          GestureDetector(
            onTap: () {
              controller.resetForm();
              Get.to(() => const AccountFormView());
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [Text("Add Account"), Icon(Icons.add_link_outlined)],
              ),
            ),
          ),
        ],
      ),
      body: GetX<SettingsController>(
        builder: (controller) {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Global Error Display
              GetX<MinioService>(
                builder: (minioService) {
                  if (minioService.globalError.isNotEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              minioService.globalError.value,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => minioService.clearErrors(),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              // Theme Toggle
              Obx(() => SwitchListTile(
                    title: const Text('Dark Mode'),
                    value: controller.isDarkMode.value,
                    onChanged: (value) => controller.toggleTheme(),
                  )),
              const Divider(),
              // Accounts List
              Expanded(
                child: Obx(() => ListView.builder(
                      itemCount: controller.accounts.length,
                      itemBuilder: (context, index) {
                        final account = controller.accounts[index];
                        final isCurrent =
                            account == controller.currentAccount.value;
                        return ListTile(
                          title: Text(account.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(account.endpoint),
                              GetX<MinioService>(
                                builder: (minioService) {
                                  final error = minioService.getAccountError(account.name);
                                  if (error.isNotEmpty) {
                                    return Text(
                                      'Error: $error',
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ],
                          ),
                          leading: GetX<MinioService>(
                            builder: (minioService) {
                              return Icon(
                                minioService.isAccountConnected(account.name)
                                    ? Icons.cloud_done
                                    : Icons.cloud_off,
                                color: minioService.isAccountConnected(account.name)
                                    ? Colors.green
                                    : Colors.red,
                              );
                            },
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isCurrent) ...[
                                IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: () async {
                                    final minioService = Get.find<MinioService>();
                                    await minioService.testConnection(account.name);
                                  },
                                  tooltip: 'Test Connection',
                                ),
                                const Icon(Icons.check_circle,
                                    color: Colors.green),
                              ],
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () =>
                                    _showDeleteConfirmation(account),
                              ),
                            ],
                          ),
                          onTap: () => controller.setCurrentAccount(account),
                        );
                      },
                    )),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(MinioAccount account) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Account'),
        content: Text('Are you sure you want to delete ${account.name}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteAccount(account);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
