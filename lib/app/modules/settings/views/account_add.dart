





import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minionette/app/modules/settings/controllers/settings_controller.dart';

class AccountFormView extends GetView<SettingsController> {
  const AccountFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Account'),
      ),
      body: GetX<SettingsController>(
        builder: (controller) {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (controller.errorMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      controller.errorMessage.value,
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Account Name',
                    hintText: 'e.g., Production Server',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => controller.accountName.value = value,
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Endpoint',
                    hintText: 'e.g., play.min.io',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => controller.endpoint.value = value,
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Access Key',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => controller.accessKey.value = value,
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Secret Key',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  onChanged: (value) => controller.secretKey.value = value,
                ),
                const SizedBox(height: 16),
                GetX<SettingsController>(
                  builder: (ctrl) => SwitchListTile(
                    title: const Text('Use SSL'),
                    value: ctrl.useSSL.value,
                    onChanged: (value) => ctrl.toggleSSL(),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: controller.saveAccount,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Save Account'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
