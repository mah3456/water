class DatabaseConstants {
  // أسماء الجداول
  static const String usersTable = 'users';
  static const String clientsTable = 'clients';
  static const String readingsTable = 'readings';

  // أسماء الحقول
  // جدول المستخدمين
  static const String userId = 'user_id';
  static const String userName = 'name';
  static const String userEmail = 'email';
  static const String userPhone = 'phone';
  static const String userPassword = 'password';

  // جدول العملاء
  static const String clientId = 'client_id';
  static const String clientName = 'name';
  static const String clientPhone = 'phone';
  static const String clientAddress = 'address';
  static const String meterNumber = 'meter_number';
  static const String totalDebt = 'total_debt';
  static const String currentBill = 'current_bill';
  static const String notes = 'notes';

  // جدول القراءات
  static const String readingId = 'reading_id';
  static const String clientIdForeignKey = 'client_id';
  static const String currentReading = 'current_reading';
  static const String previousReading = 'previous_reading';
  static const String consumption = 'consumption';
  static const String readingDate = 'reading_date';
  static const String ratePerUnit = 'rate_per_unit';
  static const String totalAmount = 'total_amount';
  static const String remainingAmount = 'remaining_amount';
  static const String isPaid = 'is_paid';
  static const String reader = 'reader';
  static const String  payby= 'payby';

  // حقول مشتركة
  static const String createdAt = 'created_at';
  static const String createdBy = 'created_by';
}