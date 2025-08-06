import 'dart:ui';

class Config {
  // API Ayarları
  static const String apiBaseUrl = 'https://kemalercan.com/bilsemki';
  static const String apiVersion = 'v1';

  // API Endpoint'leri
  static const String versionEndpoint = '$apiBaseUrl/version.php';
  static const String questionsEndpoint = '$apiBaseUrl/get_questions.php';

  // Uygulama Ayarları
  static const String appName = 'Bilsemki Sınav Uygulaması';
  static const String appVersion = '1.0.0';

  // Veritabanı Ayarları
  static const String databaseName = 'bilsemki_app.db';
  static const int databaseVersion = 1;

  // Kurtarma Kodu Ayarları
  static const int recoveryCodeLength = 16;

  // UI Ayarları
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 8.0;

  // Soru Ayarları
  static const int questionsPerLevel = 5;
  static const int xpPerCorrectAnswer = 10;
  static const int xpPerWrongAnswer = 5;
  static const int xpForLevelUp = 30;

  // Tema Renkleri
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color secondaryColor = Color(0xFF2196F3);
  static const Color accentColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFB00020);

  // Animasyon Süreleri
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);

  // Diğer Sabitler
  static const int maxCategories = 10;
  static const int maxLevels = 20;
  static const int maxQuestionsPerCategory = 50;
}

