import 'package:flutter/material.dart';
import 'package:bilsemki/models/category.dart';
import 'package:bilsemki/services/database_service.dart';
import 'package:bilsemki/services/api_service.dart';
import 'package:bilsemki/screens/profile_screen.dart';
import 'package:bilsemki/screens/category_detail_screen.dart';
import 'package:bilsemki/widgets/update_dialog.dart';
import 'package:bilsemki/config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Category>> _categories;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _categories = DatabaseService().getCategories();
    _checkForUpdatesOnStartup();
  }

  // Uygulama açılışında güncelleme kontrolü
  void _checkForUpdatesOnStartup() async {
    final newVersion = await ApiService.checkForUpdates();

    if (newVersion > 0) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => UpdateDialog(
            title: 'Güncelleme Mevcut',
            message: 'Yeni sorular mevcut (v$newVersion). Şimdi indirmek ister misiniz?',
            onUpdate: () => ApiService.downloadQuestions(newVersion, context),
            onSuccess: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sorular başarıyla güncellendi!')),
              );
              setState(() {
                _categories = DatabaseService().getCategories();
              });
            },
            onError: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Güncelleme başarısız')),
              );
            },
          ),
        );
      }
    }
  }

  // Manuel güncelleme kontrolü
  Future<void> _checkForUpdates() async {
    setState(() {
      _isUpdating = true;
    });

    final newVersion = await ApiService.checkForUpdates();

    if (newVersion > 0) {
      showDialog(
        context: context,
        builder: (context) => UpdateDialog(
          title: 'Güncelleme Mevcut',
          message: 'Yeni sorular mevcut (v$newVersion). Şimdi indirmek ister misiniz?',
          onUpdate: () => ApiService.downloadQuestions(newVersion, context),
          onSuccess: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sorular başarıyla güncellendi!')),
            );
            setState(() {
              _categories = DatabaseService().getCategories();
            });
          },
          onError: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Güncelleme başarısız')),
            );
          },
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Güncelleme mevcut değil')),
      );
    }

    setState(() {
      _isUpdating = false;
    });
  }

  // Test verisi indir
  Future<void> _downloadTestData() async {
    showDialog(
      context: context,
      builder: (context) => UpdateDialog(
        title: 'Test Verileri',
        message: 'Test verilerini indirmek istiyor musunuz?',
        onUpdate: () => ApiService.downloadTestData(context),
        onSuccess: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Test verileri başarıyla yüklendi!')),
          );
          setState(() {
            _categories = DatabaseService().getCategories();
          });
        },
        onError: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Test verileri yüklenemedi')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sınav Uygulaması'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Güncelleme butonları
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isUpdating ? null : _checkForUpdates,
                    icon: _isUpdating
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.update),
                    label: const Text('Soruları Güncelle'),
                  ),
                ),
                
                // Test Verisi düğmesi sadece demo modunda görünür
                if (Config.isDemoMode) ...[  
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isUpdating ? null : _downloadTestData,
                      icon: _isUpdating
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Icon(Icons.download),
                      label: const Text('Test Verisi'),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Kategori listesi
          Expanded(
            child: FutureBuilder<List<Category>>(
              future: _categories,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Kategori bulunamadı'));
                }

                final categories = snapshot.data!;
                return ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return CategoryCard(category: category);
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

class CategoryCard extends StatelessWidget {
  final Category category;

  const CategoryCard({required this.category, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Image.asset(category.icon, width: 48),
        title: Text(category.name),
        subtitle: Text(category.description),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryDetailScreen(category: category),
            ),
          );
        },
      ),
    );
  }
}