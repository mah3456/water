import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller.dart';

class FingerprintSettingsView extends StatelessWidget {
  final FingerprintController controller = Get.put(FingerprintController());
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات البصمة'),
        centerTitle: true,
      ),
      body: Obx(() => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات الجهاز
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.fingerprint,
                      size: 60,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'فتح التطبيق بالبصمة',
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'استخدم بصمة إصبعك لفتح التطبيق بسرعة وأمان',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // تفعيل/تعطيل البصمة
            SwitchListTile(
              title: const Text('تفعيل فتح التطبيق بالبصمة'),
              subtitle: const Text('ستحتاج للبصمة في كل مرة تفتح فيها التطبيق'),
              value: controller.isFingerprintEnabled.value,
              onChanged: (value) async {
                await controller.toggleFingerprint(value);
              },
              secondary: const Icon(Icons.security),
            ),
            
            const SizedBox(height: 20),
            
            // زر اختبار البصمة
            if (controller.isFingerprintEnabled.value)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await controller.authenticate();
                    if (result) {
                      Get.back();
                    }
                  },
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('اختبار البصمة'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            
            const SizedBox(height: 20),
            
            // رسالة الخطأ
            if (controller.errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        controller.errorMessage.value,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            
            // تحميل
            if (controller.isLoading.value)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      )),
    );
  }
}