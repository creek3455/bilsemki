import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:bilsemki/models/category.dart';
import 'package:bilsemki/models/question.dart';
import 'package:bilsemki/services/database_service.dart';

class DataInitializer {
  static Future<void> initialize() async {
    final dbService = DatabaseService();

    // Kategorilerin zaten var olup olmadığını kontrol et
    final existingCategories = await dbService.getCategories();
    if (existingCategories.isNotEmpty) {
      return; // Veriler zaten var, tekrar ekleme
    }

    // JSON dosyasını oku
    final String response = await rootBundle.loadString('assets/data/initial_data.json');
    final data = await json.decode(response);

    // Kategorileri ekle
    for (var categoryJson in data['categories']) {
      final category = Category.fromJson(categoryJson);
      await dbService.insertCategory(category);
    }

    // Soruları ekle
    for (var questionJson in data['questions']) {
      final question = Question.fromJson(questionJson);
      await dbService.insertQuestion(question);
    }
  }
}