import 'dart:convert';

class Question {
  final int id;
  final int categoryId;
  final String question;
  final List<String> options;
  final int correctOption;
  final int difficulty;

  Question({
    required this.id,
    required this.categoryId,
    required this.question,
    required this.options,
    required this.correctOption,
    required this.difficulty,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      categoryId: json['category_id'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctOption: json['correct_option'],
      difficulty: json['difficulty'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'question': question,
      'options': jsonEncode(options), // Listeyi JSON string'e dönüştür
      'correct_option': correctOption,
      'difficulty': difficulty,
    };
  }

  // Veritabanından okurken kullanılacak factory constructor
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      categoryId: map['category_id'],
      question: map['question'],
      options: List<String>.from(jsonDecode(map['options'])), // JSON string'i listeye dönüştür
      correctOption: map['correct_option'],
      difficulty: map['difficulty'],
    );
  }
}