import 'package:flutter/material.dart';

class UpdateDialog extends StatefulWidget {
  final String title;
  final String message;
  final Future<bool> Function() onUpdate;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;

  const UpdateDialog({
    required this.title,
    required this.message,
    required this.onUpdate,
    this.onSuccess,
    this.onError,
    super.key,
  });

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _isUpdating = false;
  double _progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Başlık
            Text(
              widget.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // Mesaj
            Text(
              widget.message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Yüklenme göstergesi
            if (_isUpdating) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              LinearProgressIndicator(value: _progress),
              const SizedBox(height: 8),
              Text(
                '%${(_progress * 100).round()}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 24),
            ] else ...[
              // Butonlar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('İptal'),
                  ),
                  ElevatedButton(
                    onPressed: _startUpdate,
                    child: const Text('Güncelle'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _startUpdate() async {
    setState(() {
      _isUpdating = true;
      _progress = 0.0;
    });

    try {
      // Simüle edilmiş ilerleme
      final progressStream = Stream.periodic(
        const Duration(milliseconds: 100),
            (count) => count / 10.0,
      ).take(10);

      await for (final progress in progressStream) {
        setState(() {
          _progress = progress.clamp(0.0, 1.0);
        });
      }

      // Gerçek güncelleme işlemini yap
      final success = await widget.onUpdate();

      if (success) {
        Navigator.pop(context);
        widget.onSuccess?.call();
      } else {
        Navigator.pop(context);
        widget.onError?.call();
      }
    } catch (e) {
      Navigator.pop(context);
      widget.onError?.call();
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }
}