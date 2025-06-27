class AppConstants {
  // API
  static const String baseUrl = 'https://api.example.com/v1';
  
  // Storage keys
  static const String themeKey = 'theme_mode';
  static const String localeKey = 'locale';
  static const String tokenKey = 'auth_token';
  
  // Pagination
  static const int defaultPageSize = 10;
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
  
  // Date formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String dateTimeFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'";
  static const String displayDateFormat = 'MMM d, yyyy';
  static const String displayDateTimeFormat = 'MMM d, yyyy HH:mm';
  
  // Other constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const double defaultElevation = 2.0;
}
