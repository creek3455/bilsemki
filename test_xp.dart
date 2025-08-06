import 'dart:math' as math;

void main() {
  int baseXp = 30;
  double factor = 1.5;
  
  print('Seviye Atlama için Gereken XP Miktarları:');
  
  for (int i = 1; i <= 10; i++) {
    int xp = (baseXp * math.pow(factor, i - 1)).round();
    print('Seviye $i -> ${i+1}: $xp XP');
  }
}