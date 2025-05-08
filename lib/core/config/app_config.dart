class AppConfig {
  static const String appName = 'Tilarán en Línea';
  static const String appVersion = '1.0.0';

  // API Endpoints
  static const String supabaseUrl = 'https://cqhnpdfjurscptttscjk.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNxaG5wZGZqdXJzY3B0dHRzY2prIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU2OTk0ODgsImV4cCI6MjA2MTI3NTQ4OH0.ODCznjYbigoCCFqoSVQ4w5J7sU_d1-sEUR-2gVcE0G0';

  // Cache Configuration
  static const Duration cacheValidDuration = Duration(days: 7);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB

  // Pagination
  static const int defaultPageSize = 20;

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Feature Flags
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashlytics = true;
}
