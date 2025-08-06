import 'dart:convert';
import 'package:bilsemki/models/user_progress.dart';
import 'package:bilsemki/services/database_service.dart';
import 'package:bilsemki/models/category.dart';

class QRBackupService {
  // Yedek verisini oluştur
  static Future<Map<String, dynamic>> createBackupData() async {
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

    return {
      'version': 1,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'data': backupData,
    };
  }

  // QR kodundan verileri geri yükle
  static Future<bool> restoreFromQRCode(String qrData) async {
    try {
      final backupData = jsonDecode(qrData);

      // Veritabanını güncelle
      final dbService = DatabaseService();

      for (var item in backupData['data']) {
        final progress = UserProgress(
          categoryId: item['category_id'],
          level: item['level'],
          xp: item['xp'],
          completedQuestions: List<int>.from(item['completed_questions']),
          lastPlayed: DateTime.now().millisecondsSinceEpoch,
        );

        final existing = await dbService.getUserProgress(progress.categoryId);
        if (existing != null) {
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
          await dbService.insertUserProgress(progress);
        }
      }

      return true;
    } catch (e) {
      print('QR kod geri yükleme hatası: $e');
      return false;
    }
  }
}