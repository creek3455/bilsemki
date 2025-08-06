import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bilsemki/services/database_service.dart';
import 'package:bilsemki/models/question.dart';
import 'package:bilsemki/models/category.dart';
import 'package:bilsemki/config.dart';
import 'package:bilsemki/widgets/loading_overlay.dart';

class ApiService {
  // Mevcut versiyonu kontrol et
  static Future<int> checkForUpdates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localVersion = prefs.getInt('questions_version') ?? 1;

      final response = await http.get(Uri.parse(Config.versionEndpoint));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final serverVersion = data['version'];

        print('DEBUG: Local version: $localVersion, Server version: $serverVersion');
        return serverVersion > localVersion ? serverVersion : -1;
      }
      return -1;
    } catch (e) {
      print('Güncelleme kontrolü hatası: $e');
      return -1;
    }
  }

  // Soruları indir ve veritabanını güncelle
  static Future<bool> downloadQuestions(int version, BuildContext context) async {
    LoadingOverlay.show(context, message: 'Sorular indiriliyor...');

    try {
      final response = await http.get(Uri.parse('${Config.questionsEndpoint}?v=$version'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('DEBUG: İndirilen veri: $data');

        final dbService = DatabaseService();

        // Kategorileri güncelle
        if (data['categories'] != null) {
          final categories = List<Category>.from(
              data['categories'].map((x) => Category.fromJson(x))
          );
          await dbService.updateCategories(categories);
        }

        // Soruları güncelle
        if (data['questions'] != null) {
          final questions = List<Question>.from(
              data['questions'].map((x) => Question.fromJson(x))
          );
          await dbService.updateQuestions(questions);
        }

        // Versiyonu güncelle
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('questions_version', version);

        LoadingOverlay.hide(context);
        return true;
      }

      LoadingOverlay.hide(context);
      return false;
    } catch (e) {
      LoadingOverlay.hide(context);
      print('İndirme hatası: $e');
      return false;
    }
  }

  // Test için örnek veri oluştur
  static Future<bool> downloadTestData(BuildContext context) async {
    LoadingOverlay.show(context, message: 'Test verileri indiriliyor...');

    try {
      // Test verileri
      final categories = [
        Category(
          id: 1,
          name: 'Matematik',
          description: 'Temel matematik işlemleri',
          icon: 'assets/icons/math.png',
          orderIndex: 1,
        ),
        Category(
          id: 2,
          name: 'Fen Bilgisi',
          description: 'Doğa bilimleri',
          icon: 'assets/icons/science.png',
          orderIndex: 2,
        ),
        Category(
          id: 3,
          name: 'Tarih',
          description: 'Genel tarih bilgisi',
          icon: 'assets/icons/history.png',
          orderIndex: 3,
        ),
      ];

      final questions = [
        Question(
          id: 1,
          categoryId: 1,
          question: '5 x 6 = ?',
          options: ['25', '30', '35', '40'],
          correctOption: 2,
          difficulty: 1,
        ),
        // Diğer sorular...
      ];

      // Veritabanını güncelle
      final dbService = DatabaseService();
      await dbService.updateCategories(categories);
      await dbService.updateQuestions(questions);

      // Versiyonu güncelle
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('questions_version', 2);

      LoadingOverlay.hide(context);
      return true;
    } catch (e) {
      LoadingOverlay.hide(context);
      print('Test verisi indirme hatası: $e');
      return false;
    }
  }
}