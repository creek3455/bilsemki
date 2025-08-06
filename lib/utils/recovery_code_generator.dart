import 'package:bilsemki/models/user_progress.dart';

class RecoveryCodeGenerator {
  // Kullanılacak karakter seti
  static const String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  static String generate(UserProgress progress) {
    // Verileri birleştir
    final data = "${progress.categoryId}:${progress.level}:${progress.xp}:${progress.completedQuestions.join(',')}";

    // Basit bir şifreleme: her karakteri belirli bir kaydırma değeriyle değiştir
    String encoded = '';
    for (int i = 0; i < data.length; i++) {
      final charCode = data.codeUnitAt(i);
      // Her karakter için farklı bir kaydırma değeri kullan
      final shift = (i * 3) % 10;
      final newCharCode = charCode + shift;
      encoded += String.fromCharCode(newCharCode);
    }

    // Şifrelenmiş veriyi base64'e çevir
    final bytes = encoded.codeUnits;
    String base64 = _bytesToBase64(bytes);

    // Özel karakterleri temizle ve büyük harfe çevir
    base64 = base64
        .replaceAll('+', '-')
        .replaceAll('/', '_')
        .replaceAll('=', '')
        .toUpperCase();

    // Tam 12 karakter olacak şekilde kısalt veya doldur
    if (base64.length > 12) {
      base64 = base64.substring(0, 12);
    } else {
      base64 = base64.padRight(12, 'A');
    }

    return base64;
  }

  static UserProgress? parse(String code) {
    try {
      // Kodu küçük harfe çevir
      String base64 = code.toLowerCase();

      // Base64'ten bytes'a çevir
      final bytes = _base64ToBytes(base64);

      // Bytes'tan string'e çevir
      String encoded = String.fromCharCodes(bytes);

      // Şifreyi çöz: her karakteri kaydırma değeriyle geri değiştir
      String decoded = '';
      for (int i = 0; i < encoded.length; i++) {
        final charCode = encoded.codeUnitAt(i);
        // Her karakter için farklı bir kaydırma değeri kullan
        final shift = (i * 3) % 10;
        final originalCharCode = charCode - shift;
        decoded += String.fromCharCode(originalCharCode);
      }

      // Verileri ayrıştır
      final parts = decoded.split(':');
      if (parts.length != 4) return null;

      final categoryId = int.parse(parts[0]);
      final level = int.parse(parts[1]);
      final xp = int.parse(parts[2]);
      final completedQuestions = parts[3].split(',').map((e) => int.tryParse(e) ?? 0).toList();

      return UserProgress(
        categoryId: categoryId,
        level: level,
        xp: xp,
        completedQuestions: completedQuestions,
        lastPlayed: DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      print('DEBUG: Kurtarma kodu ayrıştırma hatası: $e');
      return null;
    }
  }

  // Basit base64 encoder
  static String _bytesToBase64(List<int> bytes) {
    const String base64Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    StringBuffer buffer = StringBuffer();

    for (int i = 0; i < bytes.length; i += 3) {
      int value = bytes[i] << 16;
      if (i + 1 < bytes.length) value |= bytes[i + 1] << 8;
      if (i + 2 < bytes.length) value |= bytes[i + 2];

      buffer.write(base64Chars[(value >> 18) & 0x3F]);
      buffer.write(base64Chars[(value >> 12) & 0x3F]);
      if (i + 1 < bytes.length) {
        buffer.write(base64Chars[(value >> 6) & 0x3F]);
      } else {
        buffer.write('=');
      }
      if (i + 2 < bytes.length) {
        buffer.write(base64Chars[value & 0x3F]);
      } else {
        buffer.write('=');
      }
    }

    return buffer.toString();
  }

  // Basit base64 decoder
  static List<int> _base64ToBytes(String base64) {
    const String base64Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    List<int> bytes = [];

    for (int i = 0; i < base64.length; i += 4) {
      int value = 0;

      // 4 karakteri 3 byte'a çevir
      for (int j = 0; j < 4; j++) {
        if (i + j < base64.length) {
          final char = base64[i + j];
          final index = base64Chars.indexOf(char);
          if (index != -1) {
            value |= index << (18 - j * 6);
          }
        }
      }

      bytes.add((value >> 16) & 0xFF);
      if (base64[i + 2] != '=') {
        bytes.add((value >> 8) & 0xFF);
      }
      if (base64[i + 3] != '=') {
        bytes.add(value & 0xFF);
      }
    }

    return bytes;
  }
}