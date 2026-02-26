import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class Helpers {
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  static String formatCurrency(double amount) {
    return NumberFormat.currency(
      symbol: 'ر.ي ',
      decimalDigits: 0,
    ).format(amount);
  }

  static void showErrorSnackBar(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Helpers.customSnackBar(
        title: 'خطأ',
        message: message,
        background: Colors.red,
      );
    });
  }

  static bool isValidPhone(String phone) {
    return phone.length >= 10;
  }

  static bool isValidMeterNumber(String meterNumber) {
    return meterNumber.isNotEmpty;
  }

  // دالة إضافية لعرض snackbar مخصص
  static void customSnackBar({
    required String title,
    required String message,
    required Color background,
    Color textColor = Colors.white,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title,
      message,
      backgroundColor: background,
      colorText: textColor,
      duration: duration,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(10),
      borderRadius: 8,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }




     static void showDeleteDialog({
      required BuildContext context,
      required Widget content,
      required Function delete
    }) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 10),
              Text('تأكيد الحذف'),
            ],
          ),
          content: content,
          actions: [
            TextButton(
              style: ButtonStyle(
                  elevation: WidgetStatePropertyAll(0),
                  foregroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.surface),
                  overlayColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.surface)
              
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),

            TextButton(
              onPressed: () => delete(),
              style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  overlayColor: Theme.of(context).colorScheme.surface,
              ),
              child: const Text('حذف', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }







}