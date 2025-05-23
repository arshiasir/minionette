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
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 150,
        child: ElevatedButton(
          onPressed: () {
            controller.resetForm();
            Get.to(() => const AccountFormView());
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [Text("Add Account"), Icon(Icons.add)],
          ),
        ),
      ),
      body: GetX<SettingsController>(
        builder: (controller) {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
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
                          subtitle: Text(account.endpoint),
                          leading: GetX<MinioService>(
                            builder: (minioService) {
                              return Icon(
                                minioService.isConnected.value
                                    ? Icons.cloud_done
                                    : Icons.cloud_off,
                                color: minioService.isConnected.value
                                    ? Colors.green
                                    : Colors.red,
                              );
                            },
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isCurrent)
                                const Icon(Icons.check_circle,
                                    color: Colors.green),
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
