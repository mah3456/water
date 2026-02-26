import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:water/presentation/views/auth/login_screen.dart';
import '../../../core/utils/helpers.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profilecontroller.dart';
import 'EditProfileView.dart';

class ProfileView extends StatelessWidget {
  ProfileView({super.key});

  final ProfileController controller = Get.put(ProfileController());
  final
  AuthController _authController = Get.find<AuthController>();

  Future<void> _checkInitialConnection() async {
    final hasConnection = await _authController.checkInternetConnection();
    if (!hasConnection) {
      Helpers.showErrorSnackBar('لا يوجد اتصال بالإنترنت. يرجى التحقق من اتصالك');
      return;
    }
  }


  @override
  Widget build(BuildContext context) {



    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'الملف الشخصي',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.userProfile.value.isEmpty) {
          return _buildLoadingState(theme);
        }

        if (!controller.isLoggedIn) {
          return _buildNotLoggedInState(theme);
        }

        return RefreshIndicator(
          onRefresh: () async {
            if (controller.currentUser.value != null) {
              await controller.getUserProfile(userId: controller.currentUser.value!.id);
            }
          },
          color: theme.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // قسم الصورة والاسم
                _buildProfileHeader(context, theme),

                const SizedBox(height: 20),

                // البطاقات المعلوماتية
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildInfoCard(
                        theme: theme,
                        title: 'المعلومات الشخصية',
                        icon: Iconsax.profile_circle,
                        children: [
                          _buildInfoItem(
                            icon: Iconsax.sms,
                            label: 'البريد الإلكتروني',
                            value: controller.email,
                            color: Colors.blue,
                            onEdit: () {
                              Helpers.customSnackBar(
                                title: 'قريباً',
                                message: 'خدمة تغيير البريد ستتوفر قريباً',
                                background: CupertinoColors.systemBlue,
                              );
                            },
                          ),
                          _buildInfoItem(
                            icon: Iconsax.call,
                            label: 'رقم الهاتف',
                            value: controller.phone,
                            color: Colors.green,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      _buildInfoCard(
                        theme: theme,
                        title: 'معلومات الحساب',
                        icon: Iconsax.security_card,
                        children: [
                          _buildInfoItem(
                            icon: Iconsax.calendar,
                            label: 'تاريخ التسجيل',
                            value: controller.createdAt,
                            color: Colors.orange,
                          ),
                          _buildInfoItem(
                            icon: Iconsax.tick_circle,
                            label: 'حالة الحساب',
                            value: 'مفعل',
                            color: Colors.green,
                            isStatus: true,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // أزرار التحكم
                      _buildActionButtons(theme),

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

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: CircularProgressIndicator(
              color: theme.primaryColor,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'جاري تحميل البيانات...',
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotLoggedInState(ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.profile_delete,
                size: 80,
                color: theme.primaryColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'لم تقم بتسجيل الدخول',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'يرجى تسجيل الدخول للوصول إلى ملفك الشخصي',
              style: TextStyle(
                fontSize: 14,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Get.to(() => LoginScreen()),
              icon: const Icon(Iconsax.login),
              label: const Text('تسجيل الدخول'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ThemeData theme) {

    return Container(
      width: double.infinity,
      height: 260,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // صورة المستخدم
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Obx(() => Text(
                  controller.fullName.isNotEmpty
                      ? controller.fullName[0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                )),
              ),
            ),

            const SizedBox(height: 16),

            // الاسم
            Obx(() => Text(
              controller.fullName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )),

            const SizedBox(height: 8),

            // البريد الإلكتروني
            Obx(() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Iconsax.sms, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    controller.email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )),

            const SizedBox(height: 20),

            // زر التعديل
            ElevatedButton.icon(
              onPressed: () {
                _checkInitialConnection();
               _authController.isConnected.value ? Get.to(() => EditProfileView()):null;
               },
              icon: const Icon(Iconsax.edit, size: 18),
              label: const Text('تعديل الملف الشخصي'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: theme.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required ThemeData theme,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(width: 1 , color: Color(0x0ff3c56c)),

      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: theme.colorScheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    VoidCallback? onEdit,
    bool isStatus = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // الأيقونة
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),

          const SizedBox(width: 12),

          // المحتوى
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isStatus ? Colors.green : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isStatus)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'نشط',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // زر التعديل إذا وجد
          if (onEdit != null)
            IconButton(
              onPressed: onEdit,
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Iconsax.edit, color: Colors.blue, size: 16),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      children: [
        // زر تسجيل الخروج
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.withOpacity(0.2)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showLogoutDialog,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.logout, color: Colors.red.shade400),
                    const SizedBox(width: 12),
                    Text(
                      'تسجيل الخروج',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // معلومات الإصدار
        Center(
          child: Text(
            'الإصدار 1.0.0',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade400,
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
            ),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await controller.signOut();
              Get.offAll(() => LoginScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}