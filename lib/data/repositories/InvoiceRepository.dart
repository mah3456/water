// lib/data/repositories/invoice_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/InvoiceModel.dart';
import '../models/reading_model.dart';
import '../models/client_model.dart';

class InvoiceRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // الحصول على جميع الفواتير مع معلومات العملاء
  Future<List<InvoiceModel>> getAllInvoices() async {
    try {
      // جلب جميع القراءات مع معلومات العميل المرتبطة بها
      final response = await _supabase
          .from('readings')
          .select('''
            *,
            clients (*)
          ''')
          .order('reading_date', ascending: false);
      
      final List<InvoiceModel> invoices = [];
      
      for (var item in response) {
        final reading = ReadingModel.fromMap(item);
        final clientData = item['clients'];
        
        if (clientData != null) {
          final client = ClientModel.fromMap(clientData);
          invoices.add(InvoiceModel(reading: reading, client: client));
        }
      }
      
      return invoices;
    } catch (e) {
      print('Error getting invoices: $e');
      return [];
    }
  }
  

  // الحصول على الفواتير غير المدفوعة
  Future<List<InvoiceModel>> getUnpaidInvoices() async {
    try {
      final response = await _supabase
          .from('readings')
          .select('''
            *,
            clients (*)
          ''')
          .eq('is_paid', false)
          .order('reading_date', ascending: false);
      
      final List<InvoiceModel> invoices = [];
      
      for (var item in response) {
        final reading = ReadingModel.fromMap(item);
        final clientData = item['clients'];
        
        if (clientData != null) {
          final client = ClientModel.fromMap(clientData);
          invoices.add(InvoiceModel(reading: reading, client: client));
        }
      }
      
      return invoices;
    } catch (e) {
      print('Error getting unpaid invoices: $e');
      return [];
    }
  }




  // الحصول على الفواتير المدفوعة
  Future<List<InvoiceModel>> getPaidInvoices() async {
    try {
      final response = await _supabase
          .from('readings')
          .select('''
            *,
            clients (*)
          ''')
          .eq('is_paid', true)
          .order('reading_date', ascending: false);
      
      final List<InvoiceModel> invoices = [];
      
      for (var item in response) {
        final reading = ReadingModel.fromMap(item);
        final clientData = item['clients'];
        
        if (clientData != null) {
          final client = ClientModel.fromMap(clientData);
          invoices.add(InvoiceModel(reading: reading, client: client));
        }
      }
      
      return invoices;
    } catch (e) {
      print('Error getting paid invoices: $e');
      return [];
    }
  }
}