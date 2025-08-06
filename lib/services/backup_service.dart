import 'dart:convert';
import 'dart:math';
import 'package:bilsemki/models/user_progress.dart';
import 'package:bilsemki/services/database_service.dart';
import 'package:bilsemki/models/category.dart';

class BackupService {
  static const String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  static final Random _rnd = Random();

  // Tüm ilerleme verilerini JSON olarak dışa aktar
  static Future<String> createBackup() async {
    final dbService = DatabaseService();
    final categories = await dbService.getCategories();

    List<Map<String, dynamic>> backupData = [];

    for (var category in categories) {
      final progress = await dbService.getUserProgress(category.id);
      if (progress != null) {
        backupData.add({
          'category_id': progress.categoryId,
          'level': progress.level,
          'xp': progress.xp,
          'completed_questions': progress.completedQuestions,
        });
      }
    }

    // JSON oluştur
    final jsonStr = jsonEncode(backupData);

    // Base64'e çevir
    final bytes = utf8.encode(jsonStr);
    String base64 = base64Encode(bytes);

    // Özel karakterleri temizle
    base64 = base64.replaceAll(RegExp(r'[/+=]'), '');

    // Rastgele 4 karakter ekle (benzersizlik için)
    final randomPart = List.generate(4, (_) => _chars[_rnd.nextInt(_chars.length)]).join();
    base64 = '$base64$randomPart';

    // İlk 12 karakteri al
    if (base64.length > 12) {
      base64 = base64.substring(0, 12);
    }

    return base64.toUpperCase();
  }

  // Yedekten verileri geri yükle
  static Future<bool> restoreFromBackup(String code) async {
    try {
      final dbService = DatabaseService();

      // Rastgele karakterleri kaldır (son 4 karakter)
      String base64 = code;
      if (code.length > 8) {
        base64 = code.substring(0, code.length - 4);
      }

      // Base64'ten JSON'a çevir
      final bytes = base64Decode(base64);
      final jsonStr = utf8.decode(bytes);

      // JSON'u parse et
      final List<dynamic> backupData = jsonDecode(jsonStr);

      // Veritabanını güncelle
      for (var item in backupData) {
        final progress = UserProgress(
          categoryId: item['category_id'],
          level: item['level'],
          xp: item['xp'],
          completedQuestions: List<int>.from(item['completed_questions']),
          lastPlayed: DateTime.now().millisecondsSinceEpoch,
        );

        // Önce mevcut kaydı kontrol et
        final existing = await dbService.getUserProgress(progress.categoryId);
        if (existing != null) {
          // Mevcut kaydı güncelle
          await dbService.updateUserProgress(
            UserProgress(
              id: existing.id,
              categoryId: progress.categoryId,
              level: progress.level,
              xp: progress.xp,
              completedQuestions: progress.completedQuestions,
              lastPlayed: progress.lastPlayed,
            ),
          );
        } else {
          // Yeni kayıt ekle
          await dbService.insertUserProgress(progress);
        }
      }

      return true;
    } catch (e) {
      print('DEBUG: Yedek geri yükleme hatası: $e');
      return false;
    }
  }
}