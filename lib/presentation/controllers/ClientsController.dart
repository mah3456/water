import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water/data/models/client_model.dart';
import 'package:water/presentation/controllers/auth_controller.dart';
import 'package:water/core/utils/helpers.dart';

import '../../core/supabase/supabase_client_helper.dart';

class ClientsController extends GetxController {
  final ClientRepository _repository = ClientRepository();


  // Observables
  var clients = <ClientModel>[].obs;
  var userClients = <ClientModel>[].obs;
  var isLoading = false.obs;
  var selectedClient = Rxn<ClientModel>();
  var userDebtStats = <String, dynamic>{}.obs;
  late ClientModel client;

  // Subscriptions
  // RealtimeChannel? _realtimeChannel;

  @override
  void onInit() {
    super.onInit();
    loadClients();
    // _subscribeToRealtimeUpdates();
  }

  @override
  void onClose() {
    // _realtimeChannel?.unsubscribe();
    super.onClose();
  }

  // جلب جميع العملاء
  Future<void> loadClients() async {
    try {
      isLoading.value = true;
      
      final loadedClients = await _repository.getAllClients();
      clients.assignAll(loadedClients);

    } catch (e) {
      print('Error loading clients: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // جلب عميل محدد
  Future<void> loadClient({required int clientId}) async {
    try {
      isLoading.value = true;
      
      final loadedClient = await _repository.getClientById(clientId: clientId);
      if (loadedClient != null) {
        client = loadedClient;
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحميل العميل');
      print('Error loading client: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // إضافة عميل جديد
  Future<bool> addClient({required ClientModel client}) async {
    try {
      isLoading.value = true;
      
      final response = await _repository.addClient(client: client);
      
      if (response.isNotEmpty) {
        await loadClients();
        return true;
      }
      return false;
    } catch (e) {
      Helpers.customSnackBar(
        title: 'خطا!', 
        message: 'فشل اضافة عميل', 
        background: Colors.red
      );
      print('Error adding client: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // تحديث دين العميل
  Future<int> updateClientDebt({
    required int clientId, 
    required double amount
  }) async {
    try {
      final client = await _repository.getClientById(clientId: clientId);
      if (client == null) {
        throw Exception('العميل غير موجود');
      }

      return await _repository.updateClientDebt(
        clientId: clientId,
        amount: amount,
        currentDebt: client.totalDebt,
      );
    } catch (e) {
      print('Error updating client debt: $e');
      rethrow;
    }
  }

  // تحديث الفاتورة الحالية
  Future<int> updateClientCurrent({
    required int clientId, 
    required double amount
  }) async {
    try {
      return await _repository.updateClientCurrent(
        clientId: clientId,
        amount: amount,
      );
    } catch (e) {
      print('Error updating client current: $e');
      return 0;
    }
  }

  // تحديث بيانات العميل
  Future<bool> updateClient({required ClientModel client}) async {
    try {
      final success = await _repository.updateClient(client: client);
      
      if (success) {
        await loadClients();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // حذف عميل
  Future<int> deleteClient({required int id}) async {
    try {
      await _repository.deleteClient(id: id);
      await loadClients();
      return 1;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في حذف العميل',
        backgroundColor: Colors.red
      );
      print('Error deleting client: $e');
      rethrow;
    }
  }

  // دفع فاتورة
  Future<bool> payBill({
    required int clientId, 
    required double amount
  }) async {
    try {
      isLoading.value = true;

      final success = await _repository.payBill(
        clientId: clientId,
        amount: amount,
        currentDebt: client.totalDebt,
      );

      if (success) {
        await loadClients();
      }
      
      return success;
    } catch (e) {
      Get.snackbar('خطأ', e.toString());
      print('Error paying bill: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // دفع فاتورة محددة
  Future<bool> paySpecificInvoice({
    required int clientId,
    required int invoiceId,
    required double paidAmount,
    required double price,
    required String paybay,
    String? notes,
  }) async {
    try {
      final remaining = price - paidAmount;
      
      // تحديث حالة الفاتورة
      await _repository.updateInvoiceStatus(
        invoiceId: invoiceId,
        remaining: remaining,
        payBy: paybay,
      );

      // تسديد المبلغ من دين العميل
      await payBill(clientId: clientId, amount: paidAmount);

      return true;
    } catch (e) {
      print('Error paying specific invoice: $e');
      return false;
    }
  }

  // جلب عملاء المستخدم
  Future<void> loadUserClients(int userId) async {
    try {
      isLoading.value = true;
      
      final loadedClients = await _repository.getUserClients(userId);
      userClients.assignAll(loadedClients);
      
      await loadUserDebtStats(userId);
    } catch (e) {
      print('Error loading user clients: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // جلب إحصائيات ديون المستخدم
  Future<void> loadUserDebtStats(int userId) async {
    try {
      final stats = await _repository.getUserDebtStats(userId);
      userDebtStats.value = stats;
    } catch (e) {
      print('Error loading user debt stats: $e');
    }
  }

  // الاشتراك في التحديثات المباشرة
  // void _subscribeToRealtimeUpdates() {
  //   _realtimeChannel = _repository.subscribeToClientsChanges(() {
  //     loadClients();
  //   });
  // }

  // دوال المساعدة
  void selectClient(ClientModel client) {
    selectedClient.value = client;
  }

  List<ClientModel> searchClients(String query) {
    return clients.where((client) {
      return client.name.toLowerCase().contains(query.toLowerCase()) ||
          client.phone.contains(query) ||
          client.meterNumber.contains(query);
    }).toList();
  }

  List<ClientModel> searchUserClients(String query, int userId) {
    return userClients.where((client) {
      return client.name.toLowerCase().contains(query.toLowerCase()) ||
          client.phone.contains(query) ||
          client.meterNumber.contains(query);
    }).toList();
  }

  List<ClientModel> getUserClientsWithDebt(int userId) {
    return userClients.where((client) => client.totalDebt > 0).toList();
  }

  Future<ClientModel?> getClientById({required int clientId}) async {
    return await _repository.getClientById(clientId: clientId);
  }

  Future<List<ClientModel>> getAllClients() async {
    return await _repository.getAllClients();
  }
}