class Validator {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال الاسم';
    }
    if (value.length < 2) {
      return 'الاسم يجب أن يكون على الأقل حرفين';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال رقم الهاتف';
    }
    if (!RegExp(r'^[0-9]{10,}$').hasMatch(value)) {
      return 'رقم الهاتف غير صحيح';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
  }

  static String? validateMeterNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال رقم العداد';
    }
    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال العنوان';
    }
    return null;
  }

  static String? validateReading(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال القراءة';
    }
    if (int.tryParse(value) == null) {
      return 'يرجى إدخال رقم صحيح';
    }
    return null;
  }

  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال المبلغ';
    }
    if (double.tryParse(value) == null) {
      return 'يرجى إدخال رقم صحيح';
    }
    if (double.parse(value) <= 0) {
      return 'المبلغ يجب أن يكون أكبر من صفر';
    }
    return null;
  }
}