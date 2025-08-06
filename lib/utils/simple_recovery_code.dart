import 'dart:convert';
import 'package:bilsemki/models/user_progress.dart';
import 'package:bilsemki/services/database_service.dart';
import 'package:bilsemki/models/category.dart';


class SimpleRecoveryCode {
  static Future<String> generate() async {
    final dbService = DatabaseService();
    final categories = await dbService.getCategories();

    String code = '';
    for (var category in categories) {
      final progress = await dbService.getUserProgress(category.id);
      if (progress != null) {
        // Her kategori için 4 karakterlik kod oluştur
        code += progress.level.toString().padLeft(2, '0');
        code += (progress.xp % 100).toString().padLeft(2, '0');
      }
    }

    // 16 karaktere tamamla
    if (code.length > 16) {
      code = code.substring(0, 16);
    } else {
      code = code.padRight(16, '0');
    }

    return code;
  }

  static Future<bool> restore(String code) async {
    try {
      final dbService = DatabaseService();
      final categories = await dbService.getCategories();

      int index = 0;
      for (var category in categories) {
        if (index + 4 <= code.length) {
          final levelStr = code.substring(index, index + 2);
          final xpStr = code.substring(index + 2, index + 4);

          final level = int.tryParse(levelStr) ?? 1;
          final xp = int.tryParse(xpStr) ?? 0;

          final existing = await dbService.getUserProgress(category.id);
          if (existing != null) {
            await dbService.updateUserProgress(
              UserProgress(
                id: existing.id,
                categoryId: category.id,
                level: level,
                xp: xp,
                completedQuestions: existing.completedQuestions,
                lastPlayed: DateTime.now().millisecondsSinceEpoch,
              ),
            );
          } else {
            await dbService.insertUserProgress(
              UserProgress(
                categoryId: category.id,
                level: level,
                xp: xp,
                completedQuestions: [],
                lastPlayed: DateTime.now().millisecondsSinceEpoch,
              ),
            );
          }

          index += 4;
        }
      }

      return true;
    } catch (e) {
      print('DEBUG: Kurtarma kodu hatası: $e');
      return false;
    }
  }
}