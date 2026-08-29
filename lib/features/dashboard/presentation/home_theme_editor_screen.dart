import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/diyetsel_assets.dart';
import '../../../core/data/app_store.dart';
import '../../../core/models/home_theme_config.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/diyetsel_widgets.dart';
import 'widgets/premium_home_widgets.dart' show SoftTap;

/// Admin: modern home hero slider + cartoon home JSON.
class HomeThemeEditorScreen extends ConsumerStatefulWidget {
  const HomeThemeEditorScreen({super.key});

  @override
  ConsumerState<HomeThemeEditorScreen> createState() => _HomeThemeEditorScreenState();
}

class _HomeThemeEditorScreenState extends ConsumerState<HomeThemeEditorScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  late final TextEditingController _jsonController;
  late List<HomeHeroSlideConfig> _slides;
  String? _error;
  bool _saving = false;

  static const _imageKeys = [
    ('bowl', 'Salata kasesi'),
    ('soup', 'Mercimek çorbası'),
    ('smoothie', 'Yeşil smoothie'),
  ];

  static const _routes = [
    '/app/diet',
    '/app/track',
    '/app/recipes',
    '/app/check-in',
    '/app/services',
    '/app/blog',
    '/app/story',
    '/app/appointments',
    '/app/more',
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    final config = ref.read(appStoreProvider).homeThemeConfig();
    _jsonController = TextEditingController(text: config.toJson());
    _slides = List<HomeHeroSlideConfig>.from(
      config.heroSlides.isEmpty ? HomeHeroSlideConfig.defaults() : config.heroSlides,
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    _jsonController.dispose();
    super.dispose();
  }

  Future<void> _saveSlides() async {
    setState(() {
      _error = null;
      _saving = true;
    });
    try {
      final store = ref.read(appStoreProvider);
      final current = store.homeThemeConfig();
      final cleaned = _slides
          .where((s) => s.title.trim().isNotEmpty)
          .map(
            (s) => s.copyWith(
              title: s.title.trim(),
              description: s.description.trim(),
              buttonText: s.buttonText.trim().isEmpty ? 'Keşfet' : s.buttonText.trim(),
            ),
          )
          .toList();
      if (cleaned.isEmpty) {
        setState(() => _error = 'En az bir slayt gerekli.');
        return;
      }
      final next = current.copyWith(heroSlides: cleaned);
      await store.saveHomeThemeConfig(next);
      _jsonController.text = next.toJson();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Modern ana sayfa slider kaydedildi'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => _slides = cleaned);
    } catch (e) {
      setState(() => _error = 'Kayıt hatası: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveJson() async {
    setState(() {
      _error = null;
      _saving = true;
    });
    try {
      final config = HomeThemeConfig.fromJson(_jsonController.text);
      await ref.read(appStoreProvider).saveHomeThemeConfig(config);
      setState(() {
        _slides = List<HomeHeroSlideConfig>.from(
          config.heroSlides.isEmpty ? HomeHeroSlideConfig.defaults() : config.heroSlides,
        );
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ana sayfa teması kaydedildi'),
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
      _jsonController.text = defaults.toJson();
      _slides = List<HomeHeroSlideConfig>.from(defaults.heroSlides);
      _error = null;
    });
  }

  void _addSlide() {
    setState(() {
      _slides = [
        ..._slides,
        HomeHeroSlideConfig(
          id: 'slide_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Yeni slayt',
          description: 'Kısa bir açıklama yaz',
          buttonText: 'Keşfet',
          buttonRoute: '/app/diet',
          imageKey: 'bowl',
          bgColor: '#E8F5F0',
        ),
      ];
    });
  }

  String _previewAsset(HomeHeroSlideConfig slide) {
    final url = slide.imageUrl.trim();
    if (url.isNotEmpty) return url;
    return switch (slide.imageKey) {
      'soup' || 'lentil' => DiyetselAssets.foodLentilSoup,
      'smoothie' || 'drink' => DiyetselAssets.foodGreenSmoothie,
      _ => DiyetselAssets.foodSaladBowl,
    };
  }

  @override
  Widget build(BuildContext context) {
    final soft = context.isModern;
    return AppPage(
      title: soft ? 'Ana sayfa slider' : 'Ana sayfa teması',
      actions: [
        TextButton(onPressed: _saving ? null : _reset, child: const Text('Sıfırla')),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          final h = constraints.maxHeight.isFinite ? constraints.maxHeight : 640.0;
          return SizedBox(
            height: h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: soft ? Colors.white : null,
                    borderRadius: BorderRadius.circular(soft ? 16 : 12),
                    border: soft ? Border.all(color: AppColors.modernLine) : null,
                  ),
                  child: TabBar(
                    controller: _tabs,
                    labelColor: soft ? AppColors.primaryDeep : null,
                    unselectedLabelColor: soft ? AppColors.primary.withValues(alpha: 0.45) : null,
                    indicatorColor: soft ? AppColors.primary : null,
                    tabs: const [
                      Tab(text: 'Modern slider'),
                      Tab(text: 'Karikatür JSON'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (_error != null) ...[
                  Text(
                    _error!,
                    style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                ],
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      _buildSliderEditor(soft),
                      _buildJsonEditor(soft),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliderEditor(bool soft) {
    return ListView(
      children: [
        Text(
          'Modern ana sayfadaki hero slider. Başlık, metin, buton, rota ve görseli buradan yönet.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < _slides.length; i++) ...[
          _SlideEditorCard(
            key: ValueKey(_slides[i].id),
            index: i,
            slide: _slides[i],
            soft: soft,
            imageKeys: _imageKeys,
            routes: _routes,
            previewAsset: _previewAsset(_slides[i]),
            canRemove: _slides.length > 1,
            onChanged: (next) => setState(() => _slides[i] = next),
            onRemove: () => setState(() => _slides.removeAt(i)),
            onMoveUp: i == 0
                ? null
                : () => setState(() {
                      final item = _slides.removeAt(i);
                      _slides.insert(i - 1, item);
                    }),
            onMoveDown: i >= _slides.length - 1
                ? null
                : () => setState(() {
                      final item = _slides.removeAt(i);
                      _slides.insert(i + 1, item);
                    }),
          ),
          const SizedBox(height: 12),
        ],
        SoftTap(
          onTap: _addSlide,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: soft ? Colors.white : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: soft ? AppColors.modernLine : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, color: soft ? AppColors.primary : null),
                const SizedBox(width: 8),
                Text(
                  'Slayt ekle',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: soft ? AppColors.primaryDeep : null,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        DiyetselButton(
          label: _saving ? 'Kaydediliyor…' : 'Slider’ı kaydet',
          onPressed: _saving ? null : _saveSlides,
          icon: Icons.save_rounded,
        ),
        const SizedBox(height: 8),
        Text(
          'Kaydettikten sonra modern temadaki ana sayfada hemen görünür.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildJsonEditor(bool soft) {
    return ListView(
      children: [
        Text(
          'Tüm metinler, renkler (hex), görsel URL’leri, ikon anahtarları ve rotalar bu JSON’dan gelir. '
          'Danışan karikatür temasındayken ana sayfa bunu kullanır. heroSlides modern slider’ı da içerir.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 12),
        DiyetselCard(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _jsonController,
            maxLines: 24,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5, height: 1.35),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: '{ ... }',
            ),
          ),
        ),
        const SizedBox(height: 16),
        DiyetselButton(
          label: _saving ? 'Kaydediliyor…' : 'JSON kaydet',
          onPressed: _saving ? null : _saveJson,
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
    );
  }
}

class _SlideEditorCard extends StatelessWidget {
  const _SlideEditorCard({
    super.key,
    required this.index,
    required this.slide,
    required this.soft,
    required this.imageKeys,
    required this.routes,
    required this.previewAsset,
    required this.canRemove,
    required this.onChanged,
    required this.onRemove,
    this.onMoveUp,
    this.onMoveDown,
  });

  final int index;
  final HomeHeroSlideConfig slide;
  final bool soft;
  final List<(String, String)> imageKeys;
  final List<String> routes;
  final String previewAsset;
  final bool canRemove;
  final ValueChanged<HomeHeroSlideConfig> onChanged;
  final VoidCallback onRemove;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: soft ? Colors.white : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(soft ? 20 : 14),
        border: Border.all(
          color: soft ? AppColors.modernLine : Theme.of(context).colorScheme.outline.withValues(alpha: 0.25),
        ),
        boxShadow: soft ? AppSpacing.soft : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: soft ? const Color(0xFFE8F5F0) : Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: soft ? AppColors.primaryDeep : null,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Slayt ${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: soft ? AppColors.primaryDeep : null,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Yukarı',
                onPressed: onMoveUp,
                icon: const Icon(Icons.arrow_upward_rounded, size: 20),
              ),
              IconButton(
                tooltip: 'Aşağı',
                onPressed: onMoveDown,
                icon: const Icon(Icons.arrow_downward_rounded, size: 20),
              ),
              if (canRemove)
                IconButton(
                  tooltip: 'Sil',
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: previewAsset.startsWith('http')
                    ? Image.network(
                        previewAsset,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Image.asset(
                          DiyetselAssets.foodSaladBowl,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        previewAsset,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox(width: 64, height: 64),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: slide.title,
                      decoration: const InputDecoration(
                        labelText: 'Başlık',
                        isDense: true,
                      ),
                      onChanged: (v) => onChanged(slide.copyWith(title: v)),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: slide.description,
                      decoration: const InputDecoration(
                        labelText: 'Açıklama',
                        isDense: true,
                      ),
                      maxLines: 2,
                      onChanged: (v) => onChanged(slide.copyWith(description: v)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: slide.buttonText,
                  decoration: const InputDecoration(
                    labelText: 'Buton',
                    isDense: true,
                  ),
                  onChanged: (v) => onChanged(slide.copyWith(buttonText: v)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: routes.contains(slide.buttonRoute) ? slide.buttonRoute : routes.first,
                  decoration: const InputDecoration(
                    labelText: 'Rota',
                    isDense: true,
                  ),
                  items: [
                    for (final r in routes)
                      DropdownMenuItem(value: r, child: Text(r.replaceFirst('/app/', ''), overflow: TextOverflow.ellipsis)),
                  ],
                  onChanged: (v) {
                    if (v != null) onChanged(slide.copyWith(buttonRoute: v));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: imageKeys.any((e) => e.$1 == slide.imageKey) ? slide.imageKey : 'bowl',
            decoration: const InputDecoration(
              labelText: 'Görsel',
              isDense: true,
            ),
            items: [
              for (final e in imageKeys) DropdownMenuItem(value: e.$1, child: Text(e.$2)),
            ],
            onChanged: (v) {
              if (v != null) onChanged(slide.copyWith(imageKey: v));
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: slide.imageUrl,
            decoration: const InputDecoration(
              labelText: 'Görsel URL (opsiyonel — doluysa anahtar yerine kullanılır)',
              isDense: true,
            ),
            onChanged: (v) => onChanged(slide.copyWith(imageUrl: v)),
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: slide.bgColor,
            decoration: const InputDecoration(
              labelText: 'Arka plan rengi (hex)',
              isDense: true,
              hintText: '#E8F5F0',
            ),
            onChanged: (v) => onChanged(slide.copyWith(bgColor: v)),
          ),
        ],
      ),
    );
  }
}
