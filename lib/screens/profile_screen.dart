import 'package:flutter/material.dart';
import 'package:bilsemki/models/category.dart';
import 'package:bilsemki/models/user_progress.dart';
import 'package:bilsemki/services/database_service.dart';
import 'package:bilsemki/utils/simple_recovery_code.dart';
import 'package:bilsemki/config.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<List<Map<String, dynamic>>> _progressData;

  @override
  void initState() {
    super.initState();
    _progressData = _loadProgressData();
  }

  Future<List<Map<String, dynamic>>> _loadProgressData() async {
    final dbService = DatabaseService();
    final categories = await dbService.getCategories();
    List<Map<String, dynamic>> result = [];

    for (var category in categories) {
      final progress = await dbService.getUserProgress(category.id);
      if (progress != null) {
        result.add({
          'category': category,
          'progress': progress,
        });
      }
    }

    return result;
  }

  void _createCode() async {
    final code = await SimpleRecoveryCode.generate();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kurtarma Kodunuz'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectableText(
              code,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Bu kodu kaydedin. İlerlemenizi geri yüklemek için kullanabilirsiniz.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  // Test amaçlı tüm ilerlemeyi sıfırlama fonksiyonu
  void _resetAllProgress() async {
    final dbService = DatabaseService();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İlerlemeyi Sıfırla'),
        content: const Text('Tüm ilerlemeniz sıfırlanacak. Bu işlem geri alınamaz. Devam etmek istiyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              await dbService.resetAllProgress();
              Navigator.pop(context);
              setState(() {
                _progressData = _loadProgressData();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tüm ilerleme sıfırlandı')),
              );
            },
            child: const Text('Sıfırla'),
          ),
        ],
      ),
    );
  }

  void _loadCode() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kurtarma Kodu Girin'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '16 haneli kodu girin',
          ),
          maxLength: 16,
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              final code = controller.text.trim();
              if (code.length != 16) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kod 16 haneli olmalı')),
                );
                return;
              }

              final success = await SimpleRecoveryCode.restore(code);

              Navigator.pop(context);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('İlerleme yüklendi')),
                );

                setState(() {
                  _progressData = _loadProgressData();
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Geçersiz kod')),
                );
              }
            },
            child: const Text('Yükle'),
          ),
        ],
      ),
    );
  }

  void _addTestData() async {
    final testProgress = UserProgress(
      categoryId: 1,
      level: 2,
      xp: 50,
      completedQuestions: [1, 2, 3],
      lastPlayed: DateTime.now().millisecondsSinceEpoch,
    );

    final dbService = DatabaseService();
    await dbService.insertUserProgress(testProgress);

    setState(() {
      _progressData = _loadProgressData();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Test verisi eklendi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: Column(
        children: [
          // Test butonları (sadece demo modunda görünür)
          if (Config.isDemoMode) ...[  
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _addTestData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text('Test Verisi Ekle'),
                  ),
                  ElevatedButton(
                    onPressed: _resetAllProgress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('İlerlemeyi Sıfırla'),
                  ),
                ],
              ),
            ),
          ],

          // Kurtarma kodu butonları
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _createCode,
                    child: const Text('Kod Oluştur'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loadCode,
                    child: const Text('Kod Yükle'),
                  ),
                ),
              ],
            ),
          ),

          // İlerleme listesi
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _progressData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Henüz ilerleme kaydınız bulunmuyor'));
                }

                final progressData = snapshot.data!;

                return ListView.builder(
                  itemCount: progressData.length,
                  itemBuilder: (context, index) {
                    final item = progressData[index];
                    final category = item['category'] as Category;
                    final progress = item['progress'] as UserProgress;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: Image.asset(category.icon, width: 48),
                        title: Text(category.name),
                        subtitle: Text('Seviye: ${progress.level} | XP: ${progress.xp}'),
                        trailing: Text(
                          '${progress.completedQuestions.length} soru',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}