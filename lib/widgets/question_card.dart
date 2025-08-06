import 'dart:math';
import 'package:flutter/material.dart';
import 'package:bilsemki/models/question.dart';
import 'package:flutter/services.dart';

class QuestionCard extends StatefulWidget {
  final Question question;
  final Function(int) onAnswer;

  const QuestionCard({
    required this.question,
    required this.onAnswer,
    super.key,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  int? _selectedOption;
  bool _showResult = false;
  bool _isCorrect = false;

  void _handleAnswer(int option) async {
    if (_showResult) return;

    setState(() {
      _selectedOption = option;
      _showResult = true;
      _isCorrect = option == widget.question.correctOption;
    });

    // Geri bildirim efekti
    _showFeedback(_isCorrect);

    // 1.5 saniye sonra sonraki soruya geç
    await Future.delayed(const Duration(milliseconds: 1500));
    widget.onAnswer(option);
  }

  void _showFeedback(bool isCorrect) {
    HapticFeedback.heavyImpact();

    if (isCorrect) {
      // Doğru cevap animasyonu
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const _CorrectAnswerDialog(),
      ).then((_) {
        // Dialog kapandığında yapılacak işlemler
      });
      
      // 1 saniye sonra dialog'u otomatik kapat
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
    } else {
      // Yanlış cevap animasyonu
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const _WrongAnswerDialog(),
      ).then((_) {
        // Dialog kapandığında yapılacak işlemler
      });
      
      // 1 saniye sonra dialog'u otomatik kapat
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Soru metni
            Text(
              widget.question.question,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32),

            // Seçenekler
            ...widget.question.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final optionNumber = index + 1;
              final isSelected = _selectedOption == optionNumber;
              final isCorrect = optionNumber == widget.question.correctOption;

              Color buttonColor = Theme.of(context).primaryColor;
              Color textColor = Colors.white;

              // Sonuç gösteriliyorsa renkleri ayarla
              if (_showResult) {
                if (isSelected) {
                  buttonColor = isCorrect ? Colors.green : Colors.red;
                } else if (isCorrect) {
                  buttonColor = Colors.green;
                }
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: _showResult ? null : () => _handleAnswer(optionNumber),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: textColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(option),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class _CorrectAnswerDialog extends StatelessWidget {
  const _CorrectAnswerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Doğru! ✅',
            style: TextStyle(
              color: Colors.green,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _WrongAnswerDialog extends StatelessWidget {
  const _WrongAnswerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Yanlış! ❌',
            style: TextStyle(
              color: Colors.red,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}