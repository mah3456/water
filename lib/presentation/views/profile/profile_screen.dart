import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water/presentation/views/auth/login_screen.dart';
import '../../controllers/profilecontroller.dart';
import 'EditProfileView.dart';
import 'UpdateEmailScreen.dart';

class ProfileView extends StatelessWidget {

  ProfileView({super.key});

  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الملف الشخصي',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        elevation: 1,

      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.userProfile.value.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.blue),
                SizedBox(height: 20),
                Text(
                  'جاري تحميل البيانات...',
                  style: TextStyle(color: Colors.blue),
                ),
              ],
            ),
          );
        }

        if (!controller.isLoggedIn) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.person_off,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 20),
                const Text(
                  'لم تقم بتسجيل الدخول',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Get.to(LoginScreen()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'تسجيل الدخول',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            if (controller.currentUser.value != null) {
              await controller.getUserProfile(userId: controller.currentUser.value!.id);
            }
          },
          color: Colors.blue,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // قسم الصورة والاسم
                _buildProfileHeader(),

                // البطاقات المعلوماتية
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildInfoCard(
                        title: 'المعلومات الشخصية',
                        icon: Icons.person_outline,
                        children: [
                          _buildInfoItem(
                            icon: Icons.email_outlined,
                            label: 'البريد الإلكتروني',
                            value: controller.email,
                            color: Colors.blue,
                            lefticon: InkWell(
                              onTap: () => Get.to(UpdateEmailScreen()),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.update),
                              ),
                            )
                          ),
                          _buildInfoItem(
                            icon: Icons.phone_outlined,
                            label: 'رقم الهاتف',
                            value: controller.phone,
                            color: Colors.green,
                            lefticon: SizedBox()
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      _buildInfoCard(
                        title: 'معلومات الحساب',
                        icon: Icons.account_circle_outlined,
                        children: [
                          _buildInfoItem(
                            icon: Icons.date_range_outlined,
                            label: 'تاريخ التسجيل',
                            value: controller.createdAt,
                            color: Colors.teal,
                            lefticon: SizedBox()
                          ),
                          _buildInfoItem(
                            icon: Icons.verified_outlined,
                            label: 'حالة الحساب',
                            value: 'مفعل',
                            color: Colors.green,
                            lefticon: SizedBox()
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // أزرار التحكم
                      _buildActionButtons(),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // بناء رأس الملف الشخصي
  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // الاسم
          Obx(() => Text(
            controller.fullName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          )),

          const SizedBox(height: 8),

          // البريد الإلكتروني
          Obx(() => Text(
            controller.email,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          )),

          const SizedBox(height: 20),

          // زر التعديل
          ElevatedButton.icon(
            onPressed: () => Get.to(() => EditProfileView()),
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('تعديل الملف الشخصي'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  // بناء بطاقة المعلومات
  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue, size: 22),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: Colors.grey),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  // بناء عنصر معلومات
  Widget _buildInfoItem({
    required IconData icon,
    required Widget lefticon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          lefticon
        ],
      ),
    );
  }

  // أزرار التحكم
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _showLogoutDialog,
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('تسجيل الخروج'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // تسجيل الخروج
  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء' , style: TextStyle(color: Colors.grey),),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await controller.signOut().then((value) => Get.off(LoginScreen()));
            },
            child: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

}