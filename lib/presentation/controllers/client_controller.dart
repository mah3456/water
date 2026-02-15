// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:sqflite/sqlite_api.dart';
// import '../../core/supabase/supabase_client_helper.dart';
// import '../../data/models/client_model.dart';
// import '../../data/repositories/client_repository.dart';
// import '../../data/repositories/reading_repository.dart';
// import 'auth_controller.dart';
//
// class ClientController extends GetxController {
//   final ClientRepository clientRepository = ClientRepository();
//   final ReadingRepository readingRepository = ReadingRepository();
//   var clients = <ClientModel>[].obs;
//   var userClients = <ClientModel>[].obs;
//   var isLoading = false.obs;
//   var selectedClient = Rxn<ClientModel>();
//   var userDebtStats = <String, dynamic>{}.obs;
//   late ClientModel client;
//
//
//
//   @override
//   void onInit() {
//     super.onInit();
//     loadClients();
//   }
//
//   Future<void> loadClients() async {
//     try {
//       isLoading.value = true;
//       final loadedClients = await clientRepository.getAllClients();
//       clients.assignAll(loadedClients);
//       isLoading.value = false;
//       final authController = Get.find<AuthController>();
//       if (authController.currentUser.value != null) {
//         await loadUserClients(authController.currentUser.value!.id!);
//       }
//     } catch (e) {
//       isLoading.value = false;
//       Get.snackbar('خطأ', 'فشل في تحميل العملاء');
//     }
//   }
//
//
//   Future<List<ClientModel>> getAllClients() async {
//
//     List<Map<String,dynamic>> data = await clientRepository.queryAllClients();
//
//     return data.map((e) => ClientModel.fromMap(e)).toList();
//   }
//
//
//   Future<bool> addClient({required ClientModel client}) async {
//     try {
//       await loadClients();
//       var response=  await clientRepository.insertClient(client);
//       if(response >0){
//         return true;
//       } else{
//         return false;
//       }
//     } catch (e) {
//       Get.snackbar('!خطا', e.toString(), backgroundColor: Colors.red);
//       rethrow;
//     }
//   }
//
//   Future<bool> updateClient({required ClientModel client}) async {
//     try {
//       var response = await clientRepository.updateClient(client: client);
//
//       if(response > 0){
//         await loadClients();
//         return true;
//       }  else{
//         return false;
//       }
//     } catch (e) {
//       Get.snackbar('خطأ', 'فشل في تحديث البيانات');
//       return false;
//     }
//   }
//
//   Future<int> deleteClient({required int id}) async {
//     try {
//       return await clientRepository.deleteClient(id);
//     } on DatabaseException catch (e) {
//       Get.snackbar(
//           'خطأ',
//           'فشل في حذف العميل',
//           backgroundColor: Colors.red
//       );
//       rethrow;
//     }
//   }
//
//   Future<bool> payBill({required int clientId, required double amount}) async {
//     try {
//       var response = await clientRepository.payBill(clientId: clientId, amount: amount);
//       final authController = Get.find<AuthController>();
//       if (authController.currentUser.value != null) {
//         await loadUserDebtStats(authController.currentUser.value!.id!);
//       }
//       if(response!  > 0){
//         return true;
//
//       } else{
//         return false;
//       }
//     } on DatabaseException catch (e) {
//       Get.snackbar('خطأ', e.toString());
//       rethrow;
//     }
//   }
//
//   void selectClient(ClientModel client) {
//     selectedClient.value = client;
//   }
//
//   List<ClientModel> searchClients(String query) {
//     return clients.where((client) {
//       return client.name.toLowerCase().contains(query.toLowerCase()) ||
//           client.phone.contains(query) ||
//           client.meterNumber.contains(query);
//     }).toList();
//   }
//
//
//
//     Future<ClientModel?>? getClientById({required int clientId}) async {
//     return await clientRepository.getClientById(id: clientId);
//   }
//
//   // دالة جديدة لتسديد فاتورة محددة
//   Future<bool> paySpecificInvoice({
//     required int clientId,
//     required int invoiceId,
//     required double Paidamount,
//     required double price,
//     String? notes,
//   }) async {
//     try {
//
//
//       final remain = price - Paidamount;
//       // تسديد الفاتورة المحددة
//       final authController = Get.find<AuthController>();
//       if (authController.currentUser.value != null) {
//         await loadUserDebtStats(authController.currentUser.value!.id!);
//       }
//       if(remain == 0){
//          var res = await readingRepository.markAsPaid(readingId: invoiceId);
//          var res1 = await clientRepository.payBill(clientId: clientId, amount: Paidamount);
//
//          print("bill| ${res1}");
//          print('read ${res}');
//
//          if(res > 0 && res1 > 0){
//            await loadClients();
//            return true;
//          } else{
//            return false;
//          }
//       } else {
//         print('remain: ${remain}');
//
//         // تحديث دين العميل
//         var res = await clientRepository.payBill(clientId: clientId, amount: Paidamount);
//         var res1 = await readingRepository.payAmount(readingId: invoiceId, amount: remain);
//
//
//         print("pay| ${res1}");
//         print("bill| ${res}");
//
//
//         if (res > 0 && res1 >0) {
//           await loadClients();
//           return true;
//         } else {
//           return false;
//         }
//       }
//
//     } catch (e) {
//       print('Error paying specific invoice: $e');
//       return false;
//     }
//   }
//
//
//
//
//
//
//   // دالة جديدة لتحميل عملاء المستخدم الحالي
//   Future<void> loadUserClients(int userId) async {
//     try {
//       isLoading.value = true;
//       final loadedClients = await clientRepository.getClientsByUser(userId);
//       userClients.assignAll(loadedClients);
//       await loadUserDebtStats(userId);
//       isLoading.value = false;
//     } catch (e) {
//       isLoading.value = false;
//       print('Error loading user clients: $e');
//     }
//   }
//
//   // دالة جديدة لتحميل إحصائيات المديونيات للمستخدم
//   Future<void> loadUserDebtStats(int userId) async {
//     try {
//       final stats = await clientRepository.getUserDebtStatistics(userId);
//       userDebtStats.value = stats;
//     } catch (e) {
//       print('Error loading user debt stats: $e');
//     }
//   }
//
//   // دالة للحصول على عملاء المستخدم الحالي مع ديون
//   List<ClientModel> getUserClientsWithDebt(int userId) {
//     return userClients.where((client) => client.totalDebt > 0).toList();
//   }
//
//
//
//   List<ClientModel> searchUserClients(String query, int userId) {
//     return userClients.where((client) {
//       return client.name.toLowerCase().contains(query.toLowerCase()) ||
//           client.phone.contains(query) ||
//           client.meterNumber.contains(query);
//     }).toList();
//   }
//
//
//
// }
