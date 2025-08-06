import 'dart:ui';
import 'dart:math' as math;

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
  
  // Seviye Atlama Ayarları
  static const int baseXpForLevelUp = 30; // 1. seviyeden 2. seviyeye geçmek için gereken temel XP
  static const double levelScalingFactor = 1.5; // Her seviye için XP artış çarpanı
  static const int levelCap = 50; // Maksimum seviye sınırı
  
  // Belirli bir seviyeden sonraki seviyeye geçmek için gereken XP miktarını hesaplar
  // Örnek: 1 -> 2 seviye: 30 XP, 2 -> 3 seviye: 45 XP, 3 -> 4 seviye: 68 XP
  static int getXpRequiredForLevel(int currentLevel) {
    if (currentLevel <= 0 || currentLevel >= levelCap) {
      return 0; // Geçersiz seviye veya maksimum seviyeye ulaşıldı
    }
    
    // World of Warcraft benzeri logaritmik artış formülü
    // Her seviye için gereken XP, önceki seviyeye göre levelScalingFactor kadar artar
    return (baseXpForLevelUp * math.pow(levelScalingFactor, currentLevel - 1)).round();
  }

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
  
  // Geliştirme Modu Ayarları
  static const bool isDemoMode = true; // Geliştirme sırasında test özelliklerini göstermek için
}

