import 'package:flutter/material.dart';
import 'package:bilsemki/models/category.dart';
import 'package:bilsemki/models/user_progress.dart';
import 'package:bilsemki/services/database_service.dart';
import 'package:bilsemki/screens/quiz_screen.dart';
import 'package:bilsemki/config.dart'; // Config dosyasını içe aktar

class CategoryDetailScreen extends StatefulWidget {
  final Category category;
  const CategoryDetailScreen({required this.category, super.key});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  late Future<UserProgress?> _userProgress;

  @override
  void initState() {
    super.initState();
    _userProgress = DatabaseService().getUserProgress(widget.category.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
      ),
      body: FutureBuilder<UserProgress?>(
        future: _userProgress,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          final progress = snapshot.data;
          final currentLevel = progress?.level ?? 1;
          final xp = progress?.xp ?? 0;

          return Column(
            children: [
              // Kategori bilgileri ve ilerleme
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Row(
                  children: [
                    Image.asset(widget.category.icon, width: 64),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.category.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(widget.category.description),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text('Seviye: $currentLevel'),
                              const SizedBox(width: 16),
                              Text('XP: $xp'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Seviyeler
              Expanded(child: ListView.builder(
                  itemCount: 10, // Toplam 10 seviye
                  itemBuilder: (context, index) {
                    final level = index + 1;
                    final isLocked = level > currentLevel;
                    return LevelCard(
                      level: level,
                      isLocked: isLocked,
                      currentXP: xp,
                      requiredXP: Config.getXpRequiredForLevel(level), // Dinamik XP hesaplama
                      currentLevel: currentLevel, // Mevcut seviye bilgisi
                      onTap: isLocked
                          ? null
                          : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizScreen(
                              categoryId: widget.category.id,
                              level: level,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class LevelCard extends StatelessWidget {
  final int level;
  final bool isLocked;
  final int currentXP;
  final int requiredXP;
  final int currentLevel;
  final VoidCallback? onTap;

  const LevelCard({
    required this.level,
    required this.isLocked,
    required this.currentXP,
    required this.requiredXP,
    required this.currentLevel,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: isLocked ? const Icon(Icons.lock) : Text('$level'),
        ),
        title: Text('Seviye $level'),
        subtitle: isLocked
            ? const Text('Kilitli')
            : level < currentLevel
                ? const Text('Tamamlandı') // Geçilmiş seviye için sadece "Tamamlandı" göster
                : Text('$currentXP / $requiredXP XP'), // Mevcut seviye için XP göster
        trailing: isLocked ? null : const Icon(Icons.play_arrow),
        onTap: onTap,
      ),
    );
  }
}