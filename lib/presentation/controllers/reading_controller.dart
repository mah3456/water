// import 'package:get/get.dart';
// import 'package:sqflite/sqflite.dart';
//
// import '../../data/models/reading_model.dart';
// import '../../data/repositories/client_repository.dart';
// import '../../data/repositories/reading_repository.dart';
//
// class ReadingController extends GetxController {
//   final ReadingRepository _readingRepository = ReadingRepository();
//   final ClientRepository _clientRepository = ClientRepository();
//
//   var readings = <ReadingModel>[].obs;
//   var isLoading = false.obs;
//   final ratePerUnit = 1200.0.obs;
//
//   Future<bool> addReading({
//     required int clientId,
//     required int currentReading,
//     required int previousReading,
//     required DateTime readingDate,
//     required double totalAmount,
//     required String reader,
//
//   }) async {
//     try {
//       final consumption = currentReading - previousReading;
//
//
//       final reading = ReadingModel(
//         clientId: clientId,
//         reader: reader,
//         currentReading: currentReading,
//         previousReading: previousReading,
//         consumption: consumption,
//         readingDate: readingDate,
//         ratePerUnit: ratePerUnit.value,
//         totalAmount: totalAmount,
//         createdAt: DateTime.now(),
//       );
//
//       var readingRes = await _readingRepository.insertReading(reading);
//
//       var Deptres = await _clientRepository.updateClientDebt(clientId, totalAmount);
//
//       await _clientRepository.updateClientCurrent(clientId: clientId, amount: totalAmount);
//
//       if(readingRes > 0 && Deptres > 0){
//         return true;
//       } else{
//         return false;
//       }
//
//     } on DatabaseException catch (e) {
//       Get.snackbar('خطأ', e.toString());
//       return false;
//     }
//   }
//
//
//
//   Future<void> loadClientReadings(int clientId) async {
//     try {
//       isLoading.value = true;
//       final clientReadings = await _readingRepository.getReadingsByClientId(clientId);
//       readings.assignAll(clientReadings);
//       isLoading.value = false;
//     } catch (e) {
//       isLoading.value = false;
//       Get.snackbar('خطأ', 'فشل في تحميل القراءات');
//     }
//   }
//
//   Future<ReadingModel?> getLastReading(int clientId) async {
//     return await _readingRepository.getLastReading(clientId);
//   }
//
//   Future<void> markReadingAsPaid(int readingId) async {
//     try {
//       await _readingRepository.markAsPaid(readingId: readingId);
//       Get.snackbar('نجاح', 'تم تحديث حالة الدفع');
//     } catch (e) {
//       Get.snackbar('خطأ', 'فشل في تحديث حالة الدفع');
//     }
//   }
//
//   double calculateTotalDebt(List<ReadingModel> readings) {
//     return readings
//         .where((reading) => !reading.isPaid)
//         .fold(0.0, (sum, reading) => sum + reading.totalAmount!);
//   }
//
//
//
//  Future<bool> delete({required int Readinid}) async {
//     var response =  await _readingRepository.deleteReading(id: Readinid);
//     if(response > 0){
//       return true;
//     } else{
//       return false;
//     }
//  }
//
//  Future<bool> payAmount({required int readingId , required double amount}) async {
//     var response = await _readingRepository.payAmount(readingId: readingId, amount: amount);
//     if(response > 0){
//       return true;
//     } else{
//       return false;
//     }
// }
//
//
//
//   Future<List<ReadingModel>> getReadingsByClientId(int clientId) async {
//     return await _readingRepository.getReadingsByClientId(clientId);
//   }
//
//
//   Future<List<ReadingModel>> getUnpaidInvoices(int clientId) async {
//     return await _readingRepository.getUnpaidInvoices(clientId);
//   }
//
//
//
//
//
//
//
//
//
//
//
// }