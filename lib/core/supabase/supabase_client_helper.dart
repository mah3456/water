import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:water/core/database/database_constants.dart';
import 'package:water/data/models/client_model.dart';

class ClientRepository {
  final _supabase = Supabase.instance.client;

  // جلب جميع العملاء مع قراءاتهم
  Future<List<ClientModel>> getAllClients() async {
    try {
      final response = await _supabase
          .from('clients')
          .select('*, readings(*)')
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => ClientModel.fromMap(e))
          .toList();
    } catch (e) {
      print('Error in getAllClients: $e');
      rethrow;
    }
  }

  // جلب عميل محدد
  Future<ClientModel?> getClientById({required int clientId}) async {
    try {
      final response = await _supabase
          .from('clients')
          .select('*, readings(*)')
          .eq(DatabaseConstants.clientId, clientId)
          .single();

      return ClientModel.fromMap(response);
    } catch (e) {
      print('Error in getClientById: $e');
      return null;
    }
  }

  // إضافة عميل جديد
  Future<Map<String, dynamic>> addClient({required ClientModel client}) async {
    try {
      final response = await _supabase
          .from('clients')
          .insert({
        'name': client.name,
        'phone': client.phone,
        'meter_number': client.meterNumber,
        'address': client.address,
        'created_at': DateTime.now().toIso8601String(),
      })
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error in addClient: $e');
      rethrow;
    }
  }

  // تحديث دين العميل
  Future<int> updateClientDebt({
    required int clientId,
    required double amount,
    required double currentDebt
  }) async {
    try {
      final response = await _supabase
          .from('clients')
          .update({
        'total_debt': currentDebt + amount,
      })
          .eq(DatabaseConstants.clientId, clientId)
          .select(DatabaseConstants.clientId)
          .single();

      return response.isNotEmpty ? 1 : 0;
    } catch (e) {
      print('Error in updateClientDebt: $e');
      rethrow;
    }
  }

  // تحديث الفاتورة الحالية
  Future<int> updateClientCurrent({
    required int clientId,
    required double amount
  }) async {
    try {
      final response = await _supabase
          .from('clients')
          .update({
        'current_bill': amount,
      })
          .eq(DatabaseConstants.clientId, clientId)
          .select();

      return response.isNotEmpty ? 1 : 0;
    } on PostgrestException catch (e) {
      print('Postgrest Error in updateClientCurrent: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error in updateClientCurrent: $e');
      return 0;
    }
  }

  // تحديث بيانات العميل
  Future<bool> updateClient({required ClientModel client}) async {
    try {

      final response = await _supabase
          .from('clients')
          .update({
        DatabaseConstants.clientName: client.name,
        DatabaseConstants.clientPhone: client.phone,
        DatabaseConstants.meterNumber: client.meterNumber,
        DatabaseConstants.clientAddress: client.address,
        DatabaseConstants.totalDebt: client.totalDebt,
        DatabaseConstants.notes : client.notes

      }).eq(DatabaseConstants.clientId, client.id!)
          .select()
          .single();

      if(response.isNotEmpty){
        return true;
      } else{
        return false;
      }


    } catch (e) {
      rethrow;
    }
  }

  // حذف عميل
  Future<void> deleteClient({required int id}) async {
    try {
      // حذف القراءات المرتبطة أولاً
      // await _supabase
      //     .from('readings')
      //     .delete()
      //     .eq(DatabaseConstants.readingId, id);

      await _supabase
          .from('clients')
          .delete()
          .eq(DatabaseConstants.clientId, id);
    } catch (e) {
      print('Error in deleteClient: $e');
      rethrow;
    }
  }

  // دفع فاتورة
  Future<bool> payBill({
    required int clientId,
    required double amount,
    required double currentDebt
  }) async {
    try {
      final newBalance = (currentDebt) - amount;

      final response = await _supabase
          .from('clients')
          .update({
        'total_debt': newBalance < 0 ? 0.0 : newBalance,
      })
          .eq(DatabaseConstants.clientId, clientId);

      return response == null;
    } catch (e) {
      print('Error in payBill: $e');
      rethrow;
    }
  }

  // جلب عملاء مستخدم محدد
  Future<List<ClientModel>> getUserClients(int userId) async {
    try {
      final response = await _supabase
          .from('clients')
          .select('*, readings(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => ClientModel.fromMap(e))
          .toList();
    } catch (e) {
      print('Error in getUserClients: $e');
      rethrow;
    }
  }

  // حساب إحصائيات ديون المستخدم
  Future<Map<String, dynamic>> getUserDebtStats(int userId) async {
    try {
      final response = await _supabase
          .from('clients')
          .select('total_debt')
          .eq('user_id', userId);

      double totalDebt = 0;
      int clientsWithDebt = 0;

      if (!response.isNull && response is List) {
        for (var client in response) {
          final debt = client['total_debt'] ?? 0.0;
          totalDebt += debt;
          if (debt > 0) clientsWithDebt++;
        }
      }

      return {
        'total_debt': totalDebt,
        'clients_with_debt': clientsWithDebt,
        'total_clients': response?.length ?? 0,
      };
    } catch (e) {
      print('Error in getUserDebtStats: $e');
      rethrow;
    }
  }

  // تحديث حالة الفاتورة
  Future<void> updateInvoiceStatus({
    required int invoiceId,
    required double remaining,
    required String payBy,
  }) async {
    try {
      if (remaining == 0) {
        await _supabase.from('readings')
            .update({
          'is_paid': true,
          'remaining_amount': 0.0,
          DatabaseConstants.payby: payBy,
        }).eq(DatabaseConstants.readingId, invoiceId);

        print('remaining ${remaining}');

      } else {
        await _supabase.from('readings')
            .update({
          'remaining_amount': remaining,
          DatabaseConstants.payby: payBy,
        }).eq(DatabaseConstants.readingId, invoiceId);

        print('remain $remaining');

      }
    } catch (e) {
      print('Error in updateInvoiceStatus: $e');
      rethrow;
    }
  }

  // الاشتراك في التحديثات المباشرة
  RealtimeChannel subscribeToClientsChanges(Function callback) {
    return _supabase
        .channel('clients_channel')
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'clients',
      callback: (payload) => callback(),
    )
        .subscribe();
  }
}