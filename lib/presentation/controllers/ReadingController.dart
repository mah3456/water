import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase/supabase_client_helper.dart';
import '../../data/models/reading_model.dart';
import '../../data/repositories/ReadingRepository.dart';
import 'ClientsController.dart';

class ReadingsController extends GetxController {
  final ReadingsRepository _readingRepository = ReadingsRepository();
  final ClientsController _clientRepository = ClientsController();

  var readings = <ReadingModel>[].obs;
  var isLoading = false.obs;
  final ratePerUnit = 1200.0.obs;

  Future<bool> addReading({
    required int clientId,
    required int currentReading,
    required int previousReading,
    required DateTime readingDate,
    required double totalAmount,
    required String reader,
  }) async {

    isLoading.value = true;

    try {
      final consumption = currentReading - previousReading;

      isLoading.value = true;

      final reading = ReadingModel(
        clientId: clientId,
        reader: reader,
        currentReading: currentReading,
        previousReading: previousReading,
        readingDate: readingDate,
        ratePerUnit: ratePerUnit.value,
        remainingAmount: totalAmount,
        totalAmount: totalAmount,
        createdAt: DateTime.now(),
      );

      // إدراج القراءة في Supabase
      var readingRes = await _readingRepository.insertReading(reading);

      // تحديث ديون العميل في Supabase
      var debtRes = await _clientRepository.updateClientDebt(amount: totalAmount , clientId: clientId);

      // تحديث القيمة الحالية للعميل في Supabase
      var clientCur = await _clientRepository.updateClientCurrent(clientId: clientId, amount: totalAmount);

      loadClientReadings(clientId: clientId);

      // التأكد من نجاح العمليات
      if (readingRes > 0 && debtRes > 0 && clientCur > 0) {
        isLoading.value = false;
        return true;
      } else {
        isLoading.value = false;
        return false;
      }
    } on PostgrestException catch (e) {
      isLoading.value = false;
      Get.snackbar('خطأ في قاعدة البيانات', e.message);
      print(e.message);
      return false;
    } catch (e) {
      Get.snackbar('خطأ غير متوقع', e.toString());
      return false;
    }
  }

  Future<void> loadClientReadings({required int clientId}) async {
    try {
      isLoading.value = true;
      final clientReadings = await _readingRepository.getReadingsByClientId(clientId: clientId);
      readings.assignAll(clientReadings);
    } on PostgrestException catch (e) {
      Get.snackbar('خطأ في قاعدة البيانات', e.message);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحميل القراءات');
    } finally {
      isLoading.value = false;
    }
  }

  Future<ReadingModel?> getLastReading(int clientId) async {
    try {
      var res =  await _readingRepository.getLastReading(clientId: clientId);
      return res;
    } on PostgrestException catch (e) {
      print('خطأ في قاعدة البيانات ${e.message}');
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> markReadingAsPaid(int readingId) async {
    try {
      await _readingRepository.markAsPaid(readingId: readingId);
      
      // إعادة تحميل القراءات إذا كان هناك قائمة نشطة
      if (readings.isNotEmpty) {
        final clientId = readings.first.clientId;
        await loadClientReadings(clientId: clientId);
      }
      
      Get.snackbar('نجاح', 'تم تحديث حالة الدفع');
    } on PostgrestException catch (e) {
      Get.snackbar('خطأ في قاعدة البيانات', e.message);
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحديث حالة الدفع');
    }
  }

  double calculateTotalDebt(List<ReadingModel> readings) {
    return readings
        .where((reading) => !reading.isPaid)
        .fold(0.0, (sum, reading) => sum + reading.totalAmount!);
  }

  Future<bool> delete({required int readingId}) async {
    try {
      var response = await _readingRepository.deleteReading(id: readingId);
      
      if (response > 0) {
        if (readings.isNotEmpty) {
          final clientId = readings.first.clientId;
          await loadClientReadings(clientId: clientId);
        }
        
        return true;
      } else {
        return false;
      }
    } on PostgrestException catch (e) {
      Get.snackbar('خطأ في قاعدة البيانات', e.message);
      return false;
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في حذف القراءة');
      return false;
    }
  }

  Future<bool> payAmount({required int readingId, required double amount}) async {
    try {
      var response = await _readingRepository.payAmount(readingId: readingId, amount: amount);
      
      if (response > 0) {
        // إعادة تحميل القراءات إذا كان هناك قائمة نشطة
        if (readings.isNotEmpty) {
          final clientId = readings.first.clientId;
          await loadClientReadings(clientId: clientId);
        }
        
        Get.snackbar('نجاح', 'تم تحديث المبلغ المدفوع');
        return true;
      } else {
        Get.snackbar('خطأ', 'فشل في تحديث المبلغ');
        return false;
      }
    } on PostgrestException catch (e) {
      Get.snackbar('خطأ في قاعدة البيانات', e.message);
      return false;
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحديث المبلغ');
      return false;
    }
  }

  Future<List<ReadingModel>> getReadingsByClientId({required int clientId}) async {
    try {
      return await _readingRepository.getReadingsByClientId(clientId: clientId);
    } on PostgrestException catch (e) {
      Get.snackbar('خطأ في قاعدة البيانات', e.message);
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<ReadingModel>> getUnpaidInvoices(int clientId) async {
    try {
      return await _readingRepository.getUnpaidInvoices(clientId);
    } on PostgrestException catch (e) {
      Get.snackbar('خطأ في قاعدة البيانات', e.message);
      return [];
    } catch (e) {
      return [];
    }
  }

  // // دالة إضافية للاشتراك في التحديثات الحية (Real-time)
  // Stream<List<ReadingModel>> streamClientReadings(int clientId) {
  //   return _readingRepository.streamReadingsByClientId(clientId);
  // }
  //

// دالة للبحث في القراءات
  Future<List<ReadingModel>> searchReadings(String query) async {
    try {
      final allReadings = await _readingRepository.getAllReadings();

      return allReadings.where((reading) {
        return reading.reader!.toLowerCase().contains(query.toLowerCase()) ||
            reading.consumption.toString().contains(query) ||
            reading.totalAmount.toString().contains(query);
      }).toList();
    } catch (e) {
      return [];
    }
  }

// دالة للحصول على الإحصائيات
  Future<Map<String, dynamic>> getReadingStats(int clientId) async {
    final clientReadings = await getReadingsByClientId(clientId: clientId);

    final totalConsumption = clientReadings
        .fold(0, (sum, reading) => sum + reading.consumption!);

    final totalAmount = calculateTotalDebt(clientReadings);

    final paidCount = clientReadings
        .where((reading) => reading.isPaid)
        .length;

    final unpaidCount = clientReadings.length - paidCount;

    return {
      'totalReadings': clientReadings.length,
      'totalConsumption': totalConsumption,
      'totalDebt': totalAmount,
      'paidCount': paidCount,
      'unpaidCount': unpaidCount,
      'averageConsumption': clientReadings.isNotEmpty
          ? totalConsumption / clientReadings.length
          : 0,
    };
  }


}