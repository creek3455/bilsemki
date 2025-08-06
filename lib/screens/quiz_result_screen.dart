import 'dart:math';
import 'package:flutter/material.dart';
import 'package:bilsemki/config.dart';

class QuizResultScreen extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final bool levelUp;
  final int newLevel;

  const QuizResultScreen({
    required this.score,
    required this.totalQuestions,
    required this.levelUp,
    required this.newLevel,
    super.key,
  });

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Animation controller'ları başlat
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Animation tanımlamaları
    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    // Animasyonları başlat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.levelUp) {
        _confettiController.forward();
      }
      _scaleController.forward();
      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxPossibleScore = widget.totalQuestions * Config.xpPerCorrectAnswer;
    final percentage = maxPossibleScore > 0
        ? (widget.score / maxPossibleScore) * 100
        : 0;
    final correctAnswers = widget.score ~/ Config.xpPerCorrectAnswer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sınav Sonucu'),
      ),
      body: Stack(
        children: [
          // Konfeti animasyonu
          if (widget.levelUp)
            Positioned.fill(
              child: ConfettiAnimation(
                controller: _confettiController,
              ),
            ),

          // Ana içerik
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Seviye atlama animasyonu
                  if (widget.levelUp) ...[
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: child,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.emoji_events,
                              color: Colors.green,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'TEBRİKLER!',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Seviye ${widget.newLevel}\'e atladınız!',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Sonuç detayları animasyonu
                  AnimatedBuilder(
                    animation: _fadeAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: _slideAnimation.value,
                        child: child,
                      );
                    },
                    child: Column(
                      children: [
                        // Doğru sayısı
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$correctAnswers',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text(
                              ' / ${widget.totalQuestions} Doğru',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Puan
                        Text(
                          '${widget.score} Puan',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),

                        const SizedBox(height: 8),

                        // Yüzde
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              percentage >= 70 ? Colors.green :
                              percentage >= 40 ? Colors.yellow : Colors.red,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: percentage >= 70 ? Colors.green :
                            percentage >= 40 ? Colors.orange : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Ana sayfaya dön butonu
                  AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: child,
                      );
                    },
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: const Text('Ana Sayfaya Dön'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Konfeti animasyonu
class ConfettiAnimation extends StatelessWidget {
  final AnimationController controller;

  const ConfettiAnimation({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Stack(
          children: List.generate(50, (index) {
            final random = Random();
            final left = random.nextDouble() * MediaQuery.of(context).size.width;
            final top = -20.0 + (controller.value * 100) + (random.nextDouble() * 50);
            final color = [
              Colors.red,
              Colors.blue,
              Colors.green,
              Colors.yellow,
              Colors.purple,
            ][random.nextInt(5)];

            return Positioned(
              left: left,
              top: top,
              child: Transform.rotate(
                angle: controller.value * 2 * pi,
                child: Icon(
                  Icons.star,
                  color: color,
                  size: 16,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}