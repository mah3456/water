// lib/data/models/invoice_model.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'reading_model.dart';
import 'client_model.dart';

class InvoiceModel {
  final ReadingModel reading;
  final ClientModel client;
  
  InvoiceModel({
    required this.reading,
    required this.client,
  });
  
  // حساب المبلغ المتبقي (إذا كان هناك نظام دفعات)

  double? get remainingAmount => reading.remainingAmount;


  // حالة الفاتورة
  String get status {
    if (reading.isPaid) return 'مدفوع';
    if (reading.totalAmount != null && reading.totalAmount! > 0) return 'مدفوع جزئياً';
    return 'غير مدفوع';
  }
  
  // لون حالة الفاتورة
  Color get statusColor {
    if (reading.isPaid) return Colors.green;
    if (reading.totalAmount != null && reading.totalAmount! > 0) return Colors.orange;
    return Colors.red;
  }
  
  // تنسيق التاريخ
  String get formattedDate {
    return DateFormat('yyyy/MM/dd').format(reading.readingDate);
  }
  
  // تنسيق المبلغ
  String get formattedAmount {
    final formatter = NumberFormat('#,##0.00', 'ar');
    return '${formatter.format(reading.totalAmount! + 300.0)} ر.ي';
  }

  String get formattedPaid {
    final formatter = NumberFormat('#,##0.00', 'ar');
    return '${formatter.format(reading.totalAmount! + 300 - reading.remainingAmount!)} ر.ي';
  }


  // تنسيق المبلغ المتبقي
  String get formattedRemaining {
    final formatter = NumberFormat('#,##0.00', 'ar');
    return '${formatter.format(remainingAmount)} ر.ي';
  }


}