import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/themes/theme.dart';
import '../../../main.dart';
import '../../controllers/ClientsController.dart';
import '../../controllers/auth_controller.dart';
import '../clients/add_client_screen.dart';
import '../clients/clients_screen.dart';
import '../clients/pay_bill_screen.dart';
import '../profile/profile_screen.dart';
import '../readings/InvoicesScreen.dart';
import '../readings/add_reading_screen.dart';



class HomeScreen extends StatelessWidget {
  final AuthController _authController = Get.find<AuthController>();
  final ClientsController _clientController = Get.put(ClientsController());
  final themecont theme = Get.put(themecont());
  final first = shared.getBool('firstTime')??false;
  final user = Supabase.instance.client.auth.currentUser?.userMetadata;


  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Container(
        //   width: 150,
        //   height: 50,
        //   color: Colors.grey, child: Text(user!.values.first, style: TextStyle(color: Colors.red),)),
        centerTitle: true,
        actionsPadding: EdgeInsets.all(12),
        actions: [
          Obx(() => Switch(
              value: theme.isDarkMode,
              onChanged: (value) => theme.toggleTheme(),
              // activeThumbColor: Theme.of(context).colorScheme.secondary,
            ),
          ),

          // IconButton(
          //   onPressed: () {
          //     _authController.logout();
          //   },
          //   icon: const Icon(Icons.logout , color: Colors.red),
          // ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            first ? Obx(() => Text(
              'مرحباً، ${_authController.currentUser.value?.name ?? 'مستخدم'} 👋',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            )):Container(),



            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                scrollDirection: Axis.vertical,
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.3,
                children: [

                  _buildDashboardCard(
                    context,
                    icon: Icons.group_add,
                    title: 'إضافة عميل',
                    onTap: () => Get.to(() => AddClientScreen()),
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.people,
                    title: 'قائمة العملاء',
                    onTap: () => Get.to(() => ClientsScreen()),
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.speed,
                    title: 'إضافة قراءة',
                    onTap: () => Get.to(() => AddReadingScreen()),
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.payment,
                    title: 'تسديد فاتورة',
                    onTap: () => Get.to(() => InvoicesScreen()),
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.history,
                    title: 'سجل القراءات',

                    onTap: () {
                      Get.snackbar('قريباً', 'هذه الميزة قيد التطوير',
                          backgroundColor: Colors.orange);
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.receipt,
                    title: 'طباعة فاتورة',
                    onTap: () {
                      Get.snackbar('قريباً', 'هذه الميزة قيد التطوير',
                          backgroundColor: Colors.orange);
                    },
                  ),

                  _buildDashboardCard(
                    context,
                    icon: Icons.people,
                    title: 'قائمة العملاء',
                    onTap: () => Get.to(() => ClientsScreen()),
                  ),

                  _buildDashboardCard(
                    context,
                    icon: Icons.people,
                    title: 'قائمة العملاء',
                    onTap: () => Get.to(() => ClientsScreen()),
                  ),

                  _buildDashboardCard(
                    context,
                    icon: Icons.people,
                    title: 'حسابي',
                    onTap: () => Get.to(() => ProfileView()),
                  ),


                ],
              ),
            ),
            Obx(() => _clientController.isLoading.value
                ? const LinearProgressIndicator()
                : Container()),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                title,
                style: TextStyle(

                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}