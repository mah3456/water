import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../controllers/profilecontroller.dart';

class EditProfileView extends StatefulWidget {
  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final ProfileController controller = Get.put(ProfileController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController fullNameController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    final profile = controller.userProfile.value;

    fullNameController = TextEditingController(text: profile['name'] ?? '');
    phoneController = TextEditingController(text: profile['phone'] ?? '');
  }

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right),
          onPressed: () => Get.back(),
        ),
        title: const Text('تعديل البيانات'),
        centerTitle: true,
      ),
      body: controller.isLoading.value
          ?  Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary,))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),

              // الاسم الكامل
              TextFormField(
                controller: fullNameController,
                decoration: InputDecoration(
                  labelText: 'الاسم الكامل',
                  prefixIcon: const Icon(Icons.person, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال الاسم الكامل';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // رقم الهاتف
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف',
                  prefixIcon: const Icon(Icons.phone, color: Colors.green),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال رقم الهاتف';
                  }
                  return null;
                },
              ),


              const SizedBox(height: 40),

              // أزرار الحفظ والإلغاء
              Row(
                children: [

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _saveProfile(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side:BorderSide(color: Color(0x0ff3c56c)),



                        ),
                      ),
                      child: const Text(
                        'حفظ التغييرات',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }

  // حفظ البيانات
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      // بدء التحميل
      controller.isLoading.value = true;

      var result = await controller.updateProfile(
        name: fullNameController.text,
        phone: phoneController.text,
      );

      // إيقاف التحميل بعد الانتهاء
      controller.isLoading.value = false;

      if (result) {
        Get.snackbar(
          'نجاح',
          'تم تحديث بياناتك بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // العودة للشاشة السابقة بعد نجاح الحفظ
        Future.delayed(const Duration(milliseconds: 1500), () {
          Get.back();
        });
      } else {
        Get.snackbar(
          'خطأ',
          'فشل تحديث البيانات',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    }
  }
}