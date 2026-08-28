import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/data/app_store.dart';
import '../../../core/models/home_theme_config.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/diyetsel_widgets.dart';

/// Admin: edit cartoon home theme JSON (texts, colors, image URLs, routes).
class HomeThemeEditorScreen extends ConsumerStatefulWidget {
  const HomeThemeEditorScreen({super.key});

  @override
  ConsumerState<HomeThemeEditorScreen> createState() => _HomeThemeEditorScreenState();
}

class _HomeThemeEditorScreenState extends ConsumerState<HomeThemeEditorScreen> {
  late final TextEditingController _controller;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final config = ref.read(appStoreProvider).homeThemeConfig();
    _controller = TextEditingController(text: config.toJson());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _error = null;
      _saving = true;
    });
    try {
      final config = HomeThemeConfig.fromJson(_controller.text);
      await ref.read(appStoreProvider).saveHomeThemeConfig(config);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Karikatür ana sayfa teması kaydedildi'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.kawaiiLeaf,
        ),
      );
    } catch (e) {
      setState(() => _error = 'JSON geçersiz: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _reset() async {
    final defaults = HomeThemeConfig.defaults();
    await ref.read(appStoreProvider).saveHomeThemeConfig(defaults);
    setState(() {
      _controller.text = defaults.toJson();
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Karikatür ana sayfa JSON',
      actions: [
        TextButton(onPressed: _saving ? null : _reset, child: const Text('Sıfırla')),
      ],
      child: ListView(
        children: [
          Text(
            'Tüm metinler, renkler (hex), görsel URL’leri, ikon anahtarları ve rotalar bu JSON’dan gelir. '
            'Danışan karikatür temasındayken ana sayfa bunu kullanır.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          if (_error != null) ...[
            Text(_error!, style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
          ],
          DiyetselCard(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              maxLines: 28,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5, height: 1.35),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '{ ... }',
              ),
            ),
          ),
          const SizedBox(height: 16),
          DiyetselButton(
            label: _saving ? 'Kaydediliyor…' : 'Kaydet',
            onPressed: _saving ? null : _save,
            icon: Icons.save_rounded,
          ),
          if (context.isCartoon) ...[
            const SizedBox(height: 12),
            Text(
              'Önizleme için Ana Sayfa’ya dön.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}
