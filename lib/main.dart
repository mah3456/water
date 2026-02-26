import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:water/core/themes/theme.dart';
import 'package:water/presentation/controllers/ClientsController.dart';
import 'package:water/presentation/controllers/ReadingController.dart';
import 'package:water/presentation/controllers/auth_controller.dart';
import 'package:water/presentation/controllers/profilecontroller.dart';
import 'package:water/presentation/views/auth/login_screen.dart';
import 'package:water/presentation/views/auth/register_screen.dart';
import 'package:water/presentation/views/clients/add_client_screen.dart';
import 'package:water/presentation/views/clients/client_details_screen.dart';
import 'package:water/presentation/views/clients/clients_screen.dart';
import 'package:water/presentation/views/clients/pay_bill_screen.dart';
import 'package:water/presentation/views/home/home_screen.dart';
import 'package:water/presentation/views/readings/add_reading_screen.dart';
import 'core/themes/theme_data.dart';


late  SharedPreferences shared;
var first = shared.getBool('firstTime');
var isdark = shared.getBool('isDarkMode')?? true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  shared = await SharedPreferences.getInstance();

  await Supabase.initialize(
    url: 'https://ipuvnoakcenentjnfcqk.supabase.co',
    anonKey: 'sb_publishable_--XEVfojBNSRD7ok1nqI8w_ewxx0QBd',
  );

  try {
    runApp(const MyApp());
  } catch (e) {
    runApp(const ErrorApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'نظام إدارة المياه',
      locale: Locale('ar','YE'),

      // themeMode: ThemeMode.system, // سيتم التحكم به عبر الـ controller

      theme: ThemeData(
        fontFamily: 'cairo',
        useMaterial3: true,
        colorScheme: AppColors.lightScheme,
        scaffoldBackgroundColor: AppColors.lightScheme.surface,
      ),
      darkTheme: ThemeData(
        fontFamily: 'cairo',
        useMaterial3: true,
        colorScheme: AppColors.darkScheme,
        scaffoldBackgroundColor: AppColors.darkScheme.surface,
      ),
      defaultTransition: Transition.noTransition,


      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/register', page: () => RegisterScreen()),
        GetPage(name: '/home', page: () => HomeScreen()),
        GetPage(name: '/clients', page: () => ClientsScreen()),
        GetPage(name: '/add-client', page: () => AddClientScreen()),
        GetPage(name: '/client-details', page: () => ClientDetailsScreen(client: 0)),
        GetPage(name: '/pay-bill', page: () => PayBillScreen()),
        GetPage(name: '/add-reading', page: () => AddReadingScreen()),
        // GetPage(name: '/readings-history', page: () => ReadingsHistoryScreen()),
      ],
      initialBinding: BindingsBuilder(() {
        Get.put(themecont());
        Get.put(AuthController());
        Get.put(ClientsController());
        Get.put(ReadingsController());
        Get.put(ProfileController());

      }),
      debugShowCheckedModeBanner: false,

      onInit: () async{

        shared.setBool('firstTime', false);
        if(first != null && first == false){
          shared.setBool('isDarkMode', true);
        }
      },

    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        fontFamily: 'cairo'
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('خطأ'),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 20),
                Text(
                  'حدث خطأ في تهيئة التطبيق',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'يرجى إعادة تشغيل التطبيق أو الاتصال بالدعم الفني',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  'تفاصيل الخطأ: مشكلة في قاعدة البيانات',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}