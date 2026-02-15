class AppConstants {
  // App Info
  static const String appName = 'نظام إدارة المياه';
  static const String appVersion = '1.0.0';

  // Database
  static const String databaseName = 'water_management.db';
  static const int databaseVersion = 1;

  // Rates
  static const double defaultWaterRate = 2.0; // دينار لكل متر مكعب

  // Validation
  static const int minPasswordLength = 6;
  static const int phoneNumberLength = 10;

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';

  // Routes
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String clientsRoute = '/clients';
  static const String addClientRoute = '/add-client';
  static const String clientDetailsRoute = '/client-details';
  static const String addReadingRoute = '/add-reading';
  static const String payBillRoute = '/pay-bill';
  static const String readingsHistoryRoute = '/readings-history';
}

class StorageKeys {
  static const String userToken = 'user_token';
  static const String userId = 'user_id';
  static const String userData = 'user_data';
  static const String isLoggedIn = 'is_logged_in';
  static const String appTheme = 'app_theme';
  static const String language = 'language';
}