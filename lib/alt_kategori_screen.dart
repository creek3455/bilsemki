import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AltKategoriScreen extends StatefulWidget {
  final int kategoriId;
  final String kategoriAdi;

  const AltKategoriScreen({
    Key? key,
    required this.kategoriId,
    required this.kategoriAdi,
  }) : super(key: key);

  @override
  State<AltKategoriScreen> createState() => _AltKategoriScreenState();
}

class _AltKategoriScreenState extends State<AltKategoriScreen> {
  List<dynamic> _altKategoriler = [];

  @override
  void initState() {
    super.initState();
    _altKategorileriGetir();
  }

  Future<void> _altKategorileriGetir() async {
    try {
      final response = await http.post(
        Uri.parse('https://kemalercan.com/bilsemki/alt_kategoriler.php'),
        body: {'kategori_id': widget.kategoriId.toString()},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _altKategoriler = data;
        });
      } else {
        throw Exception('Sunucu hatası');
      }
    } catch (e) {
      print('Hata: $e');
    }
  }

  void _tumAltKategorilerleSorularaGit() {
    // Burada tüm alt kategoriler için rastgele soruya yönlendirme yapılabilir.
    Navigator.pushNamed(context, '/sorular', arguments: {
      'kategori_id': widget.kategoriId,
      'tum': true,
    });
  }

  void _altKategoriyeGit(Map<String, dynamic> altKategori) {
    Navigator.pushNamed(context, '/sorular', arguments: {
      'alt_kategori_id': altKategori['id'],
      'alt_kategori_adi': altKategori['ad'],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.kategoriAdi} Alt Kategorileri'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.shuffle),
            title: const Text('Tümü (karışık sorular)'),
            onTap: _tumAltKategorilerleSorularaGit,
          ),
          const Divider(),
          ..._altKategoriler.map((altKategori) {
            return ListTile(
              title: Text(altKategori['ad']),
              onTap: () => _altKategoriyeGit(altKategori),
            );
          }).toList(),
        ],
      ),
    );
  }
}
