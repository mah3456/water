import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../presentation/views/home/home_screen.dart';
import 'controller.dart';

class FingerprintAuthView extends StatelessWidget {

   FingerprintAuthView({super.key});

  final FingerprintController controller = Get.put(FingerprintController());


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // أيقونة البصمة
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade100, width: 2),
                ),
                child: const Icon(
                  Icons.fingerprint,
                  size: 70,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(height: 40),

              // النص التوجيهي
              Text(
                'المصادقة مطلوبة',
                style: TextStyle(fontFamily: 'cairo' , color: Colors.grey),
              ),

              const SizedBox(height: 15),

              Text(
                'استخدم بصمة إصبعك لفتح التطبيق',
                style: TextStyle(fontFamily: 'cairo' , color: Colors.grey),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // زر المصادقة
              Obx(() => controller.isLoading.value
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: () async {
                        final success = await controller.authenticate();
                        if (success) {
                          Get.to(HomeScreen()); // الانتقال للشاشة الرئيسية
                        }

                        if(controller.errorMessage.value == 'LocalAuthException(code noCredentialsSet, null, null)'){
                          Get.snackbar(
                             ' خطا!',
                              'جهازك غير محمي بقفل',
                              backgroundColor: Colors.red,
                              colorText: Colors.white
                          );
                        }
                      },
                      icon: const Icon(Icons.fingerprint , color: Colors.grey),
                      label: const Text('مسح البصمة' ,style: TextStyle(color: Colors.grey, fontFamily: 'cairo'),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    )),

              const SizedBox(height: 20),

            ],
          ),
        ),
      ),
    );
  }
}