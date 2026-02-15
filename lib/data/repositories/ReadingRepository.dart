import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/database/database_constants.dart';
import '../models/reading_model.dart';

class ReadingsRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<int> insertReading(ReadingModel reading) async {
    final response = await _supabase
        .from('readings')
        .insert(reading.toMap())
        .select('reading_id')
        .single();


    print('insert | ${response}');

    if(response.isNotEmpty){
      return 1;
    } else{
      return 0;
    }

  }


  Future<List<ReadingModel>> getReadingsByClientId({required int clientId}) async {
    final response = await _supabase
        .from('readings')
        .select()
        .eq(DatabaseConstants.clientId, clientId)
        .order('reading_date', ascending: false);
    
    return (response as List)
        .map((reading) => ReadingModel.fromMap(reading))
        .toList();
  }



  Future<ReadingModel?> getLastReading({required int clientId}) async {
    final response = await _supabase
        .from('readings')
        .select()
        .eq('client_id', clientId)
        .limit(1)
        .single();
    
    if (response != null) {
      return ReadingModel.fromMap(response);
    }
    return null;
  }


  Future<List<ReadingModel>> getAllReadings() async {
    final response = await _supabase
        .from('readings')
        .select()
        .order('reading_date', ascending: false);
    
    return (response as List)
        .map((reading) => ReadingModel.fromMap(reading))
        .toList();
  }

  Future<int> markAsPaid({required int readingId}) async {
    final response = await _supabase
        .from('readings')
        .update({
          'is_paid': true,
          'created_at': DateTime.now().toIso8601String(),
        })
        .eq('id', readingId)
        .select('id')
        .single();
    
    return 1; // عدد السجلات المتأثرة
  }

  Future<List<ReadingModel>> getUnpaidInvoices(int clientId) async {
    final response = await _supabase
        .from('readings')
        .select()
        .eq('client_id', clientId)
        .eq('is_paid', false)
        .order('reading_date', ascending: false);
    
    return (response as List)
        .map((reading) => ReadingModel.fromMap(reading))
        .toList();
  }

  Future<int> deleteReading({required int id}) async {
    final response = await _supabase
        .from('readings')
        .delete()
        .eq(DatabaseConstants.readingId, id)
        .select(DatabaseConstants.readingId)
        .single();

    if(response.isNotEmpty){
      return 1;
    } else{
      return 0;
    }

  }

  Future<int> payAmount({required int readingId, required double amount}) async {
    final response = await _supabase
        .from('readings')
        .update({
          'total_amount': amount,
          'created_at': DateTime.now().toIso8601String(),
        })
        .eq('id', readingId)
        .select('id')
        .single();
    
    return 1; // عدد السجلات المتأثرة
  }

  // دالة إضافية مفيدة لـ Supabase: الاشتراك في التحديثات الحية
  Stream<List<ReadingModel>> streamReadingsByClientId(int clientId) {
    return _supabase
        .from('readings')
        .stream(primaryKey: ['id'])
        .eq('client_id', clientId)
        .order('reading_date', ascending: false)
        .map((event) => event
            .map((reading) => ReadingModel.fromMap(reading))
            .toList());
  }





}