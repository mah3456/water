

import '../../core/database/database_constants.dart';
import '../../core/utils/helpers.dart';

class ReadingModel {
  int? id;
  int clientId;
  int currentReading;
  int previousReading;
  int? consumption;
  DateTime readingDate;
  double ratePerUnit;
  double? totalAmount;
  double? remainingAmount;
  String? reader;
  bool isPaid;
  String? payby;
  DateTime createdAt;


  ReadingModel({
    this.id,
    this.reader,
    this.payby,
    required this.clientId,
    required this.currentReading,
    required this.previousReading,
    this.consumption,
    required this.readingDate,
    required this.ratePerUnit,
     this.totalAmount,
    this.remainingAmount,
    this.isPaid = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      DatabaseConstants.clientId: clientId,
      DatabaseConstants.reader: reader,
      DatabaseConstants.currentReading: currentReading,
      DatabaseConstants.previousReading: previousReading,
      DatabaseConstants.readingDate: readingDate.toIso8601String(),
      DatabaseConstants.ratePerUnit: ratePerUnit,
      DatabaseConstants.remainingAmount: remainingAmount,
      DatabaseConstants.isPaid: isPaid ? 1 : 0,
      DatabaseConstants.createdAt: createdAt.toIso8601String(),
    };
  }

  factory ReadingModel.fromMap(Map<String, dynamic> map) {
    return ReadingModel(
      id: map[DatabaseConstants.readingId],
      clientId: map[DatabaseConstants.clientId],
      reader: map[DatabaseConstants.reader],
      currentReading: map[DatabaseConstants.currentReading],
      previousReading: map[DatabaseConstants.previousReading],
      consumption: map[DatabaseConstants.consumption],
      payby: map[DatabaseConstants.payby] ?? 'لا يوجد',
      readingDate: DateTime.parse(map[DatabaseConstants.readingDate]),
      ratePerUnit: map[DatabaseConstants.ratePerUnit]?.toDouble() ?? 2.0,
      totalAmount: map[DatabaseConstants.totalAmount]?.toDouble() ?? 0.0,
      remainingAmount: map[DatabaseConstants.remainingAmount]?.toDouble() ??0,
      isPaid: map[DatabaseConstants.isPaid],
      createdAt: DateTime.parse(map[DatabaseConstants.createdAt]),
    );
  }



  String get invoiceDetails {
          return '''
      فاتورة رقم: $id
      التاريخ: ${Helpers.formatDate(readingDate)}
      القراءة السابقة: $previousReading وحده
      القراءة الحالية: $currentReading وحده
      الاستهلاك: $consumption وحده
      سعر  الوحده: ${ratePerUnit.toStringAsFixed(2)} ر.ي
      المبلغ الإجمالي: ${Helpers.formatCurrency(totalAmount!)}
      الحالة: ${isPaid ? 'مدفوعة' : 'غير مدفوعة'}
          ''';
  }




}