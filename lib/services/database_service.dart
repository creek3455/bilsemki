import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bilsemki/models/category.dart';
import 'package:bilsemki/models/question.dart';
import 'package:bilsemki/models/user_progress.dart';

import 'package:bilsemki/config.dart'; // Config dosyasını içe aktar

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, Config.databaseName);

    // Bu satırı ekleyin (sadece test için)
    if (Config.isDemoMode){
      await deleteDatabase(path);
    }

    return await openDatabase(
      path,
      version: Config.databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT,
            icon TEXT,
            order_index INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE questions (
            id INTEGER PRIMARY KEY,
            category_id INTEGER,
            question TEXT NOT NULL,
            options TEXT NOT NULL,
            correct_option INTEGER NOT NULL,
            difficulty INTEGER,
            FOREIGN KEY (category_id) REFERENCES categories(id)
          )
        ''');
        await db.execute('''
          CREATE TABLE user_progress (
            id INTEGER PRIMARY KEY,
            category_id INTEGER,
            level INTEGER DEFAULT 1,
            xp INTEGER DEFAULT 0,
            completed_questions TEXT,
            last_played INTEGER,
            FOREIGN KEY (category_id) REFERENCES categories(id)
          )
        ''');
      },
    );
  }

  // Kategoriler için CRUD işlemleri
  Future<void> insertCategory(Category category) async {
    final db = await database;
    await db.insert('categories', category.toJson());
  }

  Future<List<Category>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) => Category.fromJson(maps[i]));
  }

// Kategorileri güncelle (mevcut olanları sil, yenilerini ekle)
  Future<void> updateCategories(List<Category> categories) async {
    final db = await database;
    final batch = db.batch();

    // Mevcut kategorileri sil
    await db.delete('categories');

    // Yeni kategorileri ekle
    for (var category in categories) {
      batch.insert('categories', category.toJson());
    }

    await batch.commit();
    print('DEBUG: Kategoriler güncellendi');
  }
  
  // Tüm kullanıcı ilerlemesini sıfırla (sadece demo modunda kullanılabilir)
  Future<void> resetAllProgress() async {
    final db = await database;
    await db.delete('user_progress');
    print('DEBUG: Tüm kullanıcı ilerlemesi sıfırlandı');
  }




  // Sorular için CRUD işlemleri
  Future<void> insertQuestion(Question question) async {
    final db = await database;
    await db.insert('questions', question.toJson());
  }

  Future<List<Question>> getQuestions(int categoryId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'questions',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    return List.generate(maps.length, (i) => Question.fromMap(maps[i]));
  }

  // Belirli bir kategoriden rastgele sorular getir
  Future<List<Question>> getRandomQuestions(int categoryId, int limit) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'questions',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'RANDOM()',
      limit: limit,
    );
    return List.generate(maps.length, (i) => Question.fromMap(maps[i]));
  }


  // Soruları güncelle (mevcut olanları sil, yenilerini ekle)
  Future<void> updateQuestions(List<Question> questions) async {
    final db = await database;
    final batch = db.batch();

    // Mevcut soruları sil
    await db.delete('questions');

    // Yeni soruları ekle
    for (var question in questions) {
      batch.insert('questions', question.toJson());
    }

    await batch.commit();
    print('DEBUG: Sorular güncellendi');
  }

  // Kullanıcı ilerlemesi için CRUD işlemleri
  Future<void> insertUserProgress(UserProgress progress) async {
    final db = await database;
    final id = await db.insert('user_progress', progress.toMap());

    print('DEBUG: insertUserProgress sonucu = $id (yeni kayıt ID)');
  }

  Future<UserProgress?> getUserProgress(int categoryId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_progress',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );

    print('DEBUG: getUserProgress için sorgu sonucu = $maps');

    if (maps.isNotEmpty) {
      final progress = UserProgress.fromMap(maps.first);
      print('DEBUG: Dönüştürülmüş ilerleme = $progress');
      return progress;
    }
    print('DEBUG: İlerleme bulunamadı');
    return null;
  }

  Future<void> updateUserProgress(UserProgress progress) async {
    final db = await database;
    final result = await db.update(
      'user_progress',
      progress.toMap(),
      where: 'id = ?',
      whereArgs: [progress.id],
    );

    print('DEBUG: updateUserProgress sonucu = $result (güncellenen satır sayısı)');
  }


}