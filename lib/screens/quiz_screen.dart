import 'dart:math';
import 'package:flutter/material.dart';
import 'package:bilsemki/models/question.dart';
import 'package:bilsemki/models/user_progress.dart';
import 'package:bilsemki/services/database_service.dart';
import 'package:bilsemki/screens/quiz_result_screen.dart';
import 'package:bilsemki/config.dart';
import 'package:bilsemki/widgets/question_card.dart';

class QuizScreen extends StatefulWidget {
  final int categoryId;
  final int level;

  const QuizScreen({
    required this.categoryId,
    required this.level,
    super.key,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  late Future<List<Question>> _questions;
  int currentQuestionIndex = 0;
  int score = 0;
  List<int> answeredQuestions = [];
  List<Question>? _questionsList;

  // Animasyon controller'lar
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadQuestions();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _loadQuestions() async {
    _questions = DatabaseService().getRandomQuestions(widget.categoryId, Config.questionsPerLevel);
    _questionsList = await _questions;

    // Sorular yüklendiğinde animasyonu başlat
    if (mounted) {
      _slideController.forward();
      _fadeController.forward();
    }
  }

  void _answerQuestion(int selectedOption) {
    if (_questionsList == null || currentQuestionIndex >= _questionsList!.length) return;

    final currentQuestion = _questionsList![currentQuestionIndex];
    final isCorrect = selectedOption == currentQuestion.correctOption;

    setState(() {
      if (isCorrect) {
        score += Config.xpPerCorrectAnswer;
      }
      answeredQuestions.add(currentQuestion.id);
    });

    // Sonraki soruya geç animasyonu
    if (currentQuestionIndex < _questionsList!.length - 1) {
      _fadeController.reverse().then((_) {
        setState(() {
          currentQuestionIndex++;
        });
        _slideController.forward();
        _fadeController.forward();
      });
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() async {
    final dbService = DatabaseService();
    final progress = await dbService.getUserProgress(widget.categoryId);

    if (progress != null) {
      final completed = List<int>.from(progress.completedQuestions);
      completed.addAll(answeredQuestions);
      
      // Mevcut seviye için gereken XP miktarını hesapla
      final requiredXp = Config.getXpRequiredForLevel(progress.level);
      final newXp = progress.xp + score;
      
      // Yeni XP, gereken XP'den fazla ise seviye atla
      final levelUp = newXp >= requiredXp;
      final newLevel = levelUp ? progress.level + 1 : progress.level;
      
      // Seviye atlandığında XP sıfırlanır, atlanmadığında mevcut XP korunur
      final updatedXp = levelUp ? 0 : newXp;

      await dbService.updateUserProgress(
        UserProgress(
          id: progress.id,
          categoryId: widget.categoryId,
          level: newLevel,
          xp: updatedXp,
          completedQuestions: completed,
          lastPlayed: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } else {
      // Mevcut seviye için gereken XP miktarını hesapla
      final requiredXp = Config.getXpRequiredForLevel(widget.level);
      final newXp = score;
      
      // Yeni XP, gereken XP'den fazla ise seviye atla
      final levelUp = newXp >= requiredXp;
      final newLevel = levelUp ? widget.level + 1 : widget.level;
      
      // Seviye atlandığında XP sıfırlanır, atlanmadığında mevcut XP korunur
      final updatedXp = levelUp ? 0 : newXp;

      await dbService.insertUserProgress(
        UserProgress(
          categoryId: widget.categoryId,
          level: newLevel,
          xp: updatedXp,
          completedQuestions: answeredQuestions,
          lastPlayed: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }

    // Mevcut seviye için gereken XP miktarını hesapla
    final requiredXp = Config.getXpRequiredForLevel(widget.level);
    final levelUp = score >= requiredXp;
    
    // QuizResultScreen'e geçiş öncesi değerleri yazdır
    print('DEBUG: QuizResultScreen\'e gönderilen değerler:');
    print('  score: $score');
    print('  totalQuestions: ${Config.questionsPerLevel}');
    print('  levelUp: $levelUp');
    print('  newLevel: ${levelUp ? widget.level + 1 : widget.level}');
    print('  requiredXp: $requiredXp');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultScreen(
          score: score,
          totalQuestions: Config.questionsPerLevel,
          levelUp: levelUp,
          newLevel: levelUp ? widget.level + 1 : widget.level,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seviye ${widget.level}'),
      ),
      body: FutureBuilder<List<Question>>(
        future: _questions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Soru bulunamadı'));
          }

          if (_questionsList == null) {
            _questionsList = snapshot.data!;
          }

          final questions = _questionsList!;
          final currentQuestion = questions[currentQuestionIndex];

          return Column(
            children: [
              // İlerleme çubuğu
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Soru ${currentQuestionIndex + 1} / ${questions.length}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          'Puan: $score',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (currentQuestionIndex + 1) / questions.length,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                    ),
                  ],
                ),
              ),

              // Soru kartı
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: QuestionCard(
                    key: ValueKey(currentQuestionIndex),
                    question: currentQuestion,
                    onAnswer: _answerQuestion,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}