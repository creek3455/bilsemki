import 'package:flutter/material.dart';
import 'package:bilsemki/screens/home_screen.dart';
import 'package:bilsemki/services/data_initializer.dart';

import 'app_theme.dart';
import 'config.dart';

/*

flutter clean yaptım
emülatörü wipe data yapıp ve cold boot yaptım
 await deleteDatabase(path); satırı mevcut


 */



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataInitializer.initialize(); // Başlangıç verilerini yükle
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Config.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Sistem temasını takip et
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}