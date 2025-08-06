import 'dart:convert';

class UserProgress {
  final int? id;
  final int categoryId;
  final int level;
  final int xp;
  final List<int> completedQuestions; // List<int> olarak değiştirdik
  final int lastPlayed;

  UserProgress({
    this.id,
    required this.categoryId,
    required this.level,
    required this.xp,
    required this.completedQuestions,
    required this.lastPlayed,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'level': level,
      'xp': xp,
      'completed_questions': jsonEncode(completedQuestions), // Listeyi JSON string'e dönüştür
      'last_played': lastPlayed,
    };
  }

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    try {
      List<int> completedQuestions = [];
      if (map['completed_questions'] != null && map['completed_questions'].toString().isNotEmpty) {
        completedQuestions = List<int>.from(jsonDecode(map['completed_questions']));
      }

      return UserProgress(
        id: map['id'],
        categoryId: map['category_id'],
        level: map['level'],
        xp: map['xp'],
        completedQuestions: completedQuestions,
        lastPlayed: map['last_played'],
      );
    } catch (e) {
      print('DEBUG: UserProgress.fromMap hatası: $e');
      rethrow;
    }
  }
}