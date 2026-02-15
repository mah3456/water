// lib/controllers/invoice_controller.dart
import 'package:get/get.dart';

import '../../data/models/InvoiceModel.dart';
import '../../data/repositories/InvoiceRepository.dart';
import 'ReadingController.dart';

class InvoiceController extends GetxController {
  final InvoiceRepository _repository = InvoiceRepository();

  // قوائم الفواتير
  final RxList<InvoiceModel> allInvoices = <InvoiceModel>[].obs;
  final RxList<InvoiceModel> filteredInvoices = <InvoiceModel>[].obs;

  // حالة التحميل
  final RxBool isLoading = false.obs;
  
  // البحث
  final RxString searchQuery = ''.obs;
  final RxString filterType = 'all'.obs; // all, paid, unpaid
  
  @override
  void onInit() {
    super.onInit();
    fetchAllInvoices();
  }
  
  // جلب جميع الفواتير
  Future<void> fetchAllInvoices() async {
    try {
      isLoading.value = true;
      allInvoices.value = await _repository.getAllInvoices();
      applyFilter();
    } catch (e) {
      print('Error fetching invoices: $e');
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> searchInvoice(String query) async{
    final result =  await allInvoices.where((invoice) {
      return invoice.client.name.toLowerCase().contains(query.toLowerCase()) ||
          invoice.client.phone.contains(query) ||
          invoice.client.meterNumber.contains(query) ||
          invoice.client.meterNumber.contains(query);
    }).toList();

    filteredInvoices.value = result;
  }
  
  // تطبيق الفلتر
  void applyFilter() {
    switch (filterType.value) {
      case 'paid':
        filteredInvoices.value = allInvoices
            .where((invoice) => invoice.reading.isPaid)
            .toList();
        break;
      case 'unpaid':
        filteredInvoices.value = allInvoices
            .where((invoice) => !invoice.reading.isPaid)
            .toList();
        break;
      default:
        filteredInvoices.value = List.from(allInvoices);
    }
    
    // تطبيق البحث على الفلتر
    if (searchQuery.isNotEmpty) {
      filteredInvoices.value = filteredInvoices
          .where((invoice) =>
              invoice.client.name.contains(searchQuery.value) ||
              invoice.client.phone.contains(searchQuery.value) ||
              invoice.client.meterNumber.contains(searchQuery.value))
          .toList();
    }
  }
  
  // تغيير نوع الفلتر
  void setFilter(String filter) {
    filterType.value = filter;
    applyFilter();
  }
  
  // تحديث حالة الفاتورة
  Future<void> markAsPaid(int readingId) async {
    // سيتم إضافة دالة التحديث هنا
  }


  // حساب إجمالي الفواتير
  double get totalAmount {
    return filteredInvoices.fold(0, (sum, invoice) => sum + invoice.reading.totalAmount!);
  }
  
  // عدد الفواتير غير المدفوعة
  int get unpaidCount {
    return allInvoices.where((invoice) => !invoice.reading.isPaid).length;
  }
  
  // عدد الفواتير المدفوعة
  int get paidCount {
    return allInvoices.where((invoice) => invoice.reading.isPaid).length;
  }
}