import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:water/presentation/views/profile/settings.dart';
import '../../../main.dart';
import '../../controllers/ClientsController.dart';
import '../../controllers/profilecontroller.dart';
import '../../controllers/auth_controller.dart'; // إضافة import
import '../clients/add_client_screen.dart';
import '../clients/clients_screen.dart';
import '../profile/profile_screen.dart';
import '../readings/InvoicesScreen.dart';
import '../readings/add_reading_screen.dart';

class HomeScreen extends StatelessWidget {
  final ProfileController profile = Get.put(ProfileController());
  final ClientsController _clientController = Get.put(ClientsController());
  final AuthController _authController = Get.find<AuthController>(); // إضافة AuthController
  final first = shared.getBool('firstTime') ?? false;
  final RxBool _isCheckingConnection = false.obs;

  HomeScreen({super.key}) {
    // بدء مراقبة الاتصال عند بناء الشاشة
    _checkInitialConnection();
  }

  // دالة لبدء مراقبة الاتصال
  Future<void> _checkInitialConnection() async {
    _isCheckingConnection.value = _authController.isConnected.value;
    await _authController.checkInternetConnection();
    _isCheckingConnection.value =  _authController.isConnected.value;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        toolbarHeight: 90,
        title: Obx(() => Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.secondary,
                    theme.colorScheme.secondary.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.secondary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مرحباً بك',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    profile.fullName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        )),
        // إضافة أيقونة حالة الاتصال في الـ AppBar
        actions: [
          Obx(() => InkWell(
              onTap: () => _checkInitialConnection(),
              child: _buildConnectionStatusIcon(theme))),
          const SizedBox(width: 8),
        ],
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.primaryColor.withOpacity(0.05),
              Colors.transparent,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // شريط حالة الاتصال (يظهر فقط عند عدم الاتصال)
              Obx(() => _buildConnectionBanner(theme)),

              // رسالة الترحيب
              if (first) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.primaryColor.withOpacity(0.1),
                        theme.primaryColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.primaryColor.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Iconsax.emoji_happy,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Obx(() => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'مرحباً، ${profile.fullName} 👋',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.titleLarge?.color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'نرحب بك في نظام إدارة المياه',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                              ),
                            ),
                          ],
                        )),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ] else
                const SizedBox(height: 16),

              const SizedBox(height: 16),

              // شبكة البطاقات
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    _buildDashboardCard(
                      context,
                      icon: Iconsax.user_add,
                      title: 'إضافة عميل',
                      gradient: const [Color(0xFF4A90E2), Color(0xFF357ABD)],
                      onTap: () => _navigateToScreen(context, () => AddClientScreen()),
                    ),
                    _buildDashboardCard(
                      context,
                      icon: Iconsax.people,
                      title: 'قائمة العملاء',
                      gradient: const [Color(0xFF50C878), Color(0xFF3CB371)],
                      onTap: () => _navigateToScreen(context, () => ClientsScreen()),
                    ),
                    _buildDashboardCard(
                      context,
                      icon: Iconsax.speedometer,
                      title: 'إضافة قراءة',
                      gradient: const [Color(0xFFFF6B6B), Color(0xFFEE5253)],
                      onTap: () => _navigateToScreen(context, () => AddReadingScreen()),
                    ),
                    _buildDashboardCard(
                      context,
                      icon: Iconsax.receipt,
                      title: 'الفواتير',
                      gradient: const [Color(0xFFFFA07A), Color(0xFFFF8C69)],
                      onTap: () => _navigateToScreen(context, () => InvoicesScreen()),
                    ),
                    _buildDashboardCard(
                      context,
                      icon: Iconsax.profile_circle,
                      title: 'حسابي',
                      gradient: const [Color(0xFF9B59B6), Color(0xFF8E44AD)],
                      onTap: () => _navigateToScreen(context, () => ProfileView()),
                    ),
                    _buildDashboardCard(
                      context,
                      icon: Iconsax.setting_2,
                      title: 'الإعدادات',
                      gradient: const [Color(0xFF34495E), Color(0xFF2C3E50)],
                      onTap: () => _navigateToScreen(context, () => Settings()),
                    ),
                  ],
                ),
              ),

              // مؤشر التحميل
              Obx(() => _clientController.isLoading.value
                  ? Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: LinearProgressIndicator(
                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                ),
              )
                  : Container()),
            ],
          ),
        ),
      ),
    );
  }

  // أيقونة حالة الاتصال في الـ AppBar
  Widget _buildConnectionStatusIcon(ThemeData theme) {
    if (_authController.isConnected.value) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.wifi,
          color: Colors.green,
          size: 18,
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.wifi_off,
          color: Colors.red,
          size: 18,
        ),
      );
    }
  }

  // شريط حالة الاتصال (يظهر فقط عند عدم الاتصال)
  Widget _buildConnectionBanner(ThemeData theme) {
    if (!_authController.isConnected.value) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.orange.shade800, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'لا يوجد اتصال بالإنترنت',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'بعض الخدمات قد لا تعمل بشكل صحيح',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => _authController.checkInternetConnection(),
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: Colors.orange.shade200,
              ),
              child: Text(
                'إعادة محاولة',
                style: TextStyle(
                  color: Colors.orange.shade800,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  // دالة للتنقل بين الشاشات مع التحقق من الاتصال
  void _navigateToScreen(BuildContext context, Widget Function() screen) {
    if (!_authController.isConnected.value) {
      // إذا كان غير متصل، اعرض رسالة تحذير
      _showNoConnectionDialog(context);
    } else {
      // إذا كان متصل، انتقل إلى الشاشة المطلوبة
      Get.to(screen());
    }
  }

  // عرض حوار عند عدم وجود اتصال
  void _showNoConnectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('لا يوجد اتصال بالإنترنت'),
          content: const Text('هذه الخدمة تتطلب اتصالاً بالإنترنت. يرجى التحقق من اتصالك والمحاولة مرة أخرى.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                // محاولة إعادة التحقق من الاتصال
                final hasConnection = await _authController.checkInternetConnection();
                if (hasConnection) {
                  // إذا تم استعادة الاتصال، حاول التنقل مرة أخرى
                  _navigateToScreen(context, () => AddClientScreen()); // مثال
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDashboardCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required List<Color> gradient,
        required VoidCallback onTap,
      }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isDark
              ? [theme.cardColor, theme.cardColor.withOpacity(0.8)]
              : gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(width: 1 , color: const Color(0x0ff3c56c)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.transparent
                : gradient.first.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: theme.primaryColor.withOpacity(0.1),
          highlightColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // أيقونة مع خلفية
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? theme.primaryColor.withOpacity(0.2)
                        : Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                // عنوان
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? theme.textTheme.bodyLarge?.color : Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}