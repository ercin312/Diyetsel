import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/diyetsel_assets.dart';
import '../../../../core/models/home_theme_config.dart';
import '../../domain/home_feed_models.dart';
import '../../../../core/widgets/user_avatar.dart';
import 'premium_home_widgets.dart' show SoftTap;
import 'soft_home_palette.dart';
import '../../../../core/l10n/ui_string.dart';

/// Soft modern home widgets — warm ember / orange-red wellness language.

class SoftModernIcon extends StatelessWidget {
  const SoftModernIcon(
    this.asset, {
    super.key,
    this.size = 28,
    this.fallback = Icons.circle,
    this.fallbackColor,
  });

  final String asset;
  final double size;
  final IconData fallback;
  final Color? fallbackColor;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, _, _) => Icon(
        fallback,
        size: size * 0.85,
        color: fallbackColor ?? SoftHomeColors.ember,
      ),
    );
  }
}

class SoftSearchBar extends StatelessWidget {
  const SoftSearchBar({super.key, required this.hint, this.onTap});

  final String hint;
  final VoidCallback? onTap;

  void _openQuickSearch(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final items = [
          (Icons.menu_book_rounded, 'Tarifler', '/app/recipes', SoftHomeColors.blushSoft),
          (Icons.article_outlined, 'Blog', '/app/blog', SoftHomeColors.amberSoft),
          (Icons.restaurant_rounded, 'Diyet planım', '/app/diet', SoftHomeColors.blush),
          (Icons.water_drop_rounded, 'Su takibi', '/app/track', SoftHomeColors.waterSoft),
          (Icons.storefront_outlined, 'Hizmetler', '/app/services', SoftHomeColors.blushSoft),
          (Icons.school_outlined, 'Mini dersler', '/app/learn', SoftHomeColors.amberSoft),
          (Icons.shopping_cart_outlined, 'Alışveriş', '/app/shopping', SoftHomeColors.blush),
          (Icons.insights_rounded, 'Raporlar', '/app/reports', SoftHomeColors.waterSoft),
        ];
        return Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          decoration: BoxDecoration(
            color: SoftHomeColors.cream,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: SoftHomeColors.line),
            boxShadow: SoftHomeColors.liftShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: SoftHomeColors.line,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(('Hızlı keşfet').ui, style: SoftHomeColors.display(size: 20)),
              const SizedBox(height: 4),
              Text(('Nereye gitmek istiyorsun?').ui, style: SoftHomeColors.body()),
              const SizedBox(height: 14),
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SoftTap(
                    onTap: () {
                      Navigator.pop(ctx);
                      context.push(item.$3);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: item.$4,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: SoftHomeColors.line.withValues(alpha: 0.7)),
                      ),
                      child: Row(
                        children: [
                          Icon(item.$1, color: SoftHomeColors.emberDeep, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text((item.$2).ui, style: SoftHomeColors.title(size: 14.5)),
                          ),
                          Icon(Icons.chevron_right_rounded, color: SoftHomeColors.muted),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: onTap ?? () => _openQuickSearch(context),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: SoftHomeColors.cream,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: SoftHomeColors.line),
          boxShadow: SoftHomeColors.softShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SoftHomeColors.blush,
              ),
              alignment: Alignment.center,
              child: SoftModernIcon(
                DiyetselAssets.modernIconSearch,
                size: 18,
                fallback: Icons.search_rounded,
                fallbackColor: SoftHomeColors.emberDeep,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text((hint).ui,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SoftHomeColors.body(color: SoftHomeColors.muted.withValues(alpha: 0.85)),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: SoftHomeColors.emberGradient,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(('Keşfet').ui,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SoftShortcutRail extends StatelessWidget {
  const SoftShortcutRail({super.key, required this.items});

  final List<HomeShortcutModel> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final item = items[i];
          return SoftTap(
            onTap: () => context.push(item.route),
            child: SizedBox(
              width: 76,
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          item.accent,
                          Color.lerp(item.accent, SoftHomeColors.blush, 0.35)!,
                        ],
                      ),
                      border: Border.all(color: SoftHomeColors.line.withValues(alpha: 0.8)),
                      boxShadow: SoftHomeColors.softShadow,
                    ),
                    alignment: Alignment.center,
                    child: SoftModernIcon(
                      item.iconAsset,
                      size: 30,
                      fallback: item.icon,
                      fallbackColor: SoftHomeColors.emberDeep,
                    ),
                  )
                      .animate(onPlay: (c) => c.forward())
                      .scale(
                        begin: const Offset(0.9, 0.9),
                        delay: (45 * i).ms,
                        duration: 400.ms,
                        curve: Curves.easeOutBack,
                      ),
                  const SizedBox(height: 8),
                  Text((item.title).ui,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: SoftHomeColors.label(size: 12, color: SoftHomeColors.ink),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class SoftHeroPlanCard extends StatelessWidget {
  const SoftHeroPlanCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.ctaRoute,
    this.imageAsset = DiyetselAssets.foodSaladBowl,
    this.bgColor,
  });

  final String title;
  final String subtitle;
  final String ctaLabel;
  final String ctaRoute;
  final String imageAsset;
  final Color? bgColor;

  @override
  Widget build(BuildContext context) {
    final tint = bgColor ?? SoftHomeColors.blushSoft;
    return SoftTap(
      onTap: () => context.push(ctaRoute),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 8, 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              tint,
              Color.lerp(tint, SoftHomeColors.parchment, 0.55)!,
            ],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
          border: Border.all(color: SoftHomeColors.line),
          boxShadow: SoftHomeColors.softShadow,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text((title).ui, maxLines: 2, overflow: TextOverflow.ellipsis, style: SoftHomeColors.title(size: 18)),
                  const SizedBox(height: 8),
                  Text((subtitle).ui, maxLines: 2, overflow: TextOverflow.ellipsis, style: SoftHomeColors.body()),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: SoftHomeColors.emberGradient,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                      boxShadow: SoftHomeColors.softShadow,
                    ),
                    child: Text((ctaLabel).ui,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(6, 0),
              child: Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: SoftHomeColors.ember.withValues(alpha: 0.16),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: imageAsset.startsWith('http')
                    ? ClipOval(
                        child: Image.network(
                          imageAsset,
                          width: 108,
                          height: 108,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Image.asset(
                            DiyetselAssets.foodSaladBowl,
                            width: 108,
                            height: 108,
                            fit: BoxFit.contain,
                          ),
                        ),
                      )
                    : Image.asset(
                        imageAsset,
                        width: 108,
                        height: 108,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const SizedBox(width: 100, height: 100),
                      ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .moveY(begin: 0, end: -4, duration: 2200.ms, curve: Curves.easeInOut),
            ),
          ],
        ),
      ),
    );
  }
}

/// Soft premium hero carousel — admin-driven slides with food visuals.
class SoftHeroSlider extends StatefulWidget {
  const SoftHeroSlider({
    super.key,
    required this.slides,
    this.height = 192,
  });

  final List<HomeHeroSlideConfig> slides;
  final double height;

  @override
  State<SoftHeroSlider> createState() => _SoftHeroSliderState();
}

class _SoftHeroSliderState extends State<SoftHeroSlider> {
  late final PageController _controller;
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _restartTimer();
  }

  @override
  void didUpdateWidget(covariant SoftHeroSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slides.length != widget.slides.length) {
      _index = _index.clamp(0, (widget.slides.length - 1).clamp(0, 999));
      _restartTimer();
    }
  }

  void _restartTimer() {
    _timer?.cancel();
    if (widget.slides.length < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_index + 1) % widget.slides.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  static String resolveImage(HomeHeroSlideConfig slide) {
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
    final slides = widget.slides.isEmpty ? HomeHeroSlideConfig.defaults() : widget.slides;

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _controller,
            itemCount: slides.length,
            onPageChanged: (i) {
              setState(() => _index = i);
              _restartTimer();
            },
            itemBuilder: (context, i) {
              final slide = slides[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: SoftHeroPlanCard(
                  title: slide.title,
                  subtitle: slide.description,
                  ctaLabel: slide.buttonText,
                  ctaRoute: slide.buttonRoute,
                  imageAsset: resolveImage(slide),
                  bgColor: slide.background,
                ),
              );
            },
          ),
        ),
        if (slides.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < slides.length; i++)
                GestureDetector(
                  onTap: () {
                    _controller.animateToPage(
                      i,
                      duration: const Duration(milliseconds: 360),
                      curve: Curves.easeOutCubic,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _index ? 20 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i == _index
                          ? SoftHomeColors.ember
                          : SoftHomeColors.ember.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class SoftQuickActionGrid extends StatelessWidget {
  const SoftQuickActionGrid({super.key, required this.items});

  final List<HomeQuickActionModel> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: SoftTap(
              onTap: () => context.push(items[i].route),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                  border: Border.all(color: SoftHomeColors.line),
                  boxShadow: SoftHomeColors.softShadow,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: SoftHomeColors.blush,
                      ),
                      alignment: Alignment.center,
                      child: SoftModernIcon(
                        items[i].iconAsset,
                        size: 28,
                        fallback: items[i].icon,
                        fallbackColor: SoftHomeColors.emberDeep,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text((items[i].title).ui,
                      style: SoftHomeColors.label(size: 12, color: SoftHomeColors.ink),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Dark ember featured recipe card.
class SoftFeaturedRecipeCard extends StatelessWidget {
  const SoftFeaturedRecipeCard({super.key, required this.recipe});

  final HomeRecipeModel recipe;

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: () => context.push(recipe.route),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 10, 14),
        decoration: BoxDecoration(
          gradient: SoftHomeColors.emberGradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: SoftHomeColors.liftShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recipe.sectionLabel.isNotEmpty)
              Text((recipe.sectionLabel).ui,
                style: SoftHomeColors.label(
                  size: 12,
                  color: Colors.white.withValues(alpha: 0.78),
                ),
              ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text((recipe.title).ui,
                        style: SoftHomeColors.display(size: 20, color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text((recipe.subtitle).ui,
                        style: SoftHomeColors.body(
                          size: 12.5,
                          color: Colors.white.withValues(alpha: 0.82),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _meta('${recipe.kcal} kcal'),
                          _meta('${recipe.minutes} dk'),
                          _meta('${recipe.proteinG} g protein'),
                        ],
                      ),
                      if (recipe.badge.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text((recipe.badge).ui,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Image.asset(
                  recipe.imageAsset,
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const SizedBox(width: 90, height: 90),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _meta(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text((text).ui,
        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white),
      ),
    );
  }
}

class SoftLessonCard extends StatelessWidget {
  const SoftLessonCard({super.key, required this.lesson});

  final HomeLessonModel lesson;

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: () => context.push(lesson.route),
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 12, 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [SoftHomeColors.blushSoft, SoftHomeColors.cream],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: SoftHomeColors.line),
          boxShadow: SoftHomeColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: SoftHomeColors.ember.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text((lesson.title).ui,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SoftHomeColors.label(size: 11, color: SoftHomeColors.emberDeep),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SoftHomeColors.emberGradient,
                    boxShadow: SoftHomeColors.softShadow,
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text((lesson.headline).ui,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: SoftHomeColors.title(size: 14.5),
            ),
            const SizedBox(height: 2),
            Text((lesson.subtitle).ui,
              style: SoftHomeColors.body(size: 12),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: SoftHomeColors.line, width: 2),
                  boxShadow: SoftHomeColors.softShadow,
                ),
                padding: const EdgeInsets.all(8),
                child: SoftModernIcon(
                  lesson.imageAsset,
                  size: 56,
                  fallback: Icons.menu_book_rounded,
                  fallbackColor: SoftHomeColors.ember,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SoftStreakCard extends StatelessWidget {
  const SoftStreakCard({super.key, required this.streak});

  final HomeStreakModel streak;

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: () => context.push(streak.route),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(22),
        topRight: Radius.circular(34),
        bottomLeft: Radius.circular(34),
        bottomRight: Radius.circular(22),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 12, 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFE8DF), Color(0xFFFFF8F3)],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(22),
            topRight: Radius.circular(34),
            bottomLeft: Radius.circular(34),
            bottomRight: Radius.circular(22),
          ),
          border: Border.all(color: const Color(0xFFFFCDBD)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE07A5F).withValues(alpha: 0.16),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text((streak.title).ui,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFC45A3C),
                    ),
                  ),
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFFFD5C8), width: 2),
                    boxShadow: AppSpacing.soft,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: SoftModernIcon(
                    streak.imageAsset,
                    size: 44,
                    fallback: Icons.local_fire_department_rounded,
                    fallbackColor: const Color(0xFFE07A5F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text((streak.subtitle).ui,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: SoftHomeColors.title(size: 13),
            ),
            const Spacer(),
            Row(
              children: [
                for (var i = 0; i < streak.total; i++) ...[
                  if (i > 0) const SizedBox(width: 4),
                  Expanded(
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 280 + i * 40),
                      height: 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: i < streak.progress
                            ? SoftHomeColors.ember
                            : Colors.white.withValues(alpha: 0.85),
                        border: Border.all(
                          color: i < streak.progress
                              ? SoftHomeColors.emberDeep
                              : SoftHomeColors.blush,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(('${streak.progress}/${streak.total} gün').ui,
              style: SoftHomeColors.label(size: 12.5, color: SoftHomeColors.emberDeep),
            ),
          ],
        ),
      ),
    );
  }
}

class SoftProgressChipRow extends StatelessWidget {
  const SoftProgressChipRow({super.key, required this.items});

  final List<HomeProgressChipModel> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: SoftTap(
              onTap: () => context.push(items[i].route),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: SoftHomeColors.cream,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: items[i].accent.withValues(alpha: 0.28)),
                  boxShadow: SoftHomeColors.softShadow,
                ),
                child: Column(
                  children: [
                    SoftModernIcon(
                      items[i].iconAsset,
                      size: 26,
                      fallback: items[i].icon,
                      fallbackColor: items[i].accent,
                    ),
                    const SizedBox(height: 4),
                    Text((items[i].value).ui,
                      style: SoftHomeColors.title(size: 13),
                    ),
                    Text((items[i].label).ui,
                      style: SoftHomeColors.body(size: 11),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class SoftSectionHeader extends StatelessWidget {
  const SoftSectionHeader({
    super.key,
    required this.title,
    required this.onSeeAll,
    this.subtitle,
  });

  final String title;
  final VoidCallback onSeeAll;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 4,
          height: subtitle == null ? 22 : 36,
          margin: const EdgeInsets.only(right: 10, bottom: 2),
          decoration: BoxDecoration(
            gradient: SoftHomeColors.emberGradient,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text((title).ui, style: SoftHomeColors.title(size: 17.5)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text((subtitle!).ui, style: SoftHomeColors.body(size: 12)),
              ],
            ],
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          style: TextButton.styleFrom(
            foregroundColor: SoftHomeColors.ember,
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(('Tümü →').ui, style: SoftHomeColors.label(size: 13, color: SoftHomeColors.ember)),
        ),
      ],
    );
  }
}

class SoftCampaignCard extends StatelessWidget {
  const SoftCampaignCard({super.key, required this.campaign});

  final HomeCampaignModel campaign;

  bool get _isClinic => campaign.id == 'clinic';

  @override
  Widget build(BuildContext context) {
    final radius = _isClinic
        ? const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(28),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(30),
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(18),
          );
    final accent = _isClinic ? SoftHomeColors.wine : SoftHomeColors.ember;

    return SoftTap(
      onTap: () => context.push(campaign.route),
      borderRadius: radius,
      child: Container(
        width: 236,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              campaign.bgColor,
              Colors.white,
            ],
          ),
          borderRadius: radius,
          border: Border.all(color: accent.withValues(alpha: 0.22)),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.14),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: accent.withValues(alpha: 0.2), width: 2.5),
                boxShadow: AppSpacing.soft,
              ),
              padding: const EdgeInsets.all(8),
              child: SoftModernIcon(
                campaign.imageAsset,
                size: 62,
                fallback: _isClinic ? Icons.medical_services_rounded : Icons.local_drink_rounded,
                fallbackColor: accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text((campaign.title).ui,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: SoftHomeColors.title(size: 14),
                  ),
                  const SizedBox(height: 4),
                  Text((campaign.subtitle).ui,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: SoftHomeColors.body(size: 11.5),
                  ),
                  const Spacer(),
                  if (campaign.price.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text((campaign.price).ui,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SoftRecipeThumbCard extends StatelessWidget {
  const SoftRecipeThumbCard({super.key, required this.recipe});

  final HomeRecipeModel recipe;

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: () => context.push(recipe.route),
      child: Container(
        width: 168,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: SoftHomeColors.cream,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(color: SoftHomeColors.line),
          boxShadow: SoftHomeColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Image.asset(
                  recipe.imageAsset,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const SizedBox(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text((recipe.title).ui,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: SoftHomeColors.title(size: 13),
            ),
            const SizedBox(height: 4),
            Text(('${recipe.kcal} kcal · ${recipe.minutes} dk').ui,
              style: SoftHomeColors.body(size: 11.5),
            ),
          ],
        ),
      ),
    );
  }
}

class SoftArticleCard extends StatelessWidget {
  const SoftArticleCard({super.key, required this.article});

  final HomeArticleModel article;

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: () => context.push(article.route),
      borderRadius: BorderRadius.circular(26),
      child: Container(
        width: 248,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [SoftHomeColors.cream, SoftHomeColors.blushSoft],
          ),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: SoftHomeColors.line),
          boxShadow: SoftHomeColors.softShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: SoftHomeColors.blushSoft,
                border: Border.all(color: SoftHomeColors.ember.withValues(alpha: 0.2), width: 2),
              ),
              padding: const EdgeInsets.all(8),
              child: SoftModernIcon(
                article.imageAsset.isEmpty
                    ? DiyetselAssets.modernCardBlog
                    : article.imageAsset,
                size: 52,
                fallback: Icons.article_rounded,
                fallbackColor: SoftHomeColors.ember,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (article.tag.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: SoftHomeColors.ember.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text((article.tag).ui,
                        style: SoftHomeColors.label(size: 10.5, color: SoftHomeColors.emberDeep),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text((article.title).ui,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: SoftHomeColors.title(size: 13),
                  ),
                  const Spacer(),
                  Text((article.subtitle).ui,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SoftHomeColors.body(size: 11.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SoftGreetingHeader extends StatelessWidget {
  const SoftGreetingHeader({super.key, required this.userName, this.avatarUrl, this.onAvatarTap});

  final String userName;
  final String? avatarUrl;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greet = hour < 6
        ? 'İyi geceler'
        : hour < 12
            ? 'Günaydın'
            : hour < 17
                ? 'İyi günler'
                : hour < 21
                    ? 'İyi akşamlar'
                    : 'İyi geceler';
    final vibe = hour < 12
        ? 'Bugün ateşini yak — küçük bir adım yeter.'
        : hour < 17
            ? 'Öğün ve su ritminle enerjini koru.'
            : 'Akşamı tamamla, seriyi bozma.';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
      decoration: BoxDecoration(
        gradient: SoftHomeColors.emberGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: SoftHomeColors.liftShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(('e-Diyet').ui,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 11.5,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const Spacer(),
                    SoftTap(
                      onTap: () => context.push('/app/badges'),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.16),
                        ),
                        alignment: Alignment.center,
                        child: Badge(
                          smallSize: 8,
                          backgroundColor: SoftHomeColors.amberSoft,
                          child: Icon(
                            Icons.notifications_none_rounded,
                            color: Colors.white.withValues(alpha: 0.95),
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(('$greet,').ui,
                  style: SoftHomeColors.body(
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.82),
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text((userName).ui,
                  style: SoftHomeColors.display(size: 28, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text((vibe).ui,
                  style: SoftHomeColors.body(
                    size: 13,
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          UserAvatar(
            photoUrl: avatarUrl,
            size: 56,
            onTap: onAvatarTap,
            borderColor: Colors.white.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }
}

/// Bold ember “Bugünün özeti” for home only.
class SoftHomeFocusBanner extends StatelessWidget {
  const SoftHomeFocusBanner({
    super.key,
    required this.waterProgress,
    required this.mealsDone,
    required this.mealsTotal,
    required this.streakDays,
    this.onWater,
    this.onDiet,
    this.onStory,
  });

  final double waterProgress;
  final int mealsDone;
  final int mealsTotal;
  final int streakDays;
  final VoidCallback? onWater;
  final VoidCallback? onDiet;
  final VoidCallback? onStory;

  @override
  Widget build(BuildContext context) {
    final mealP = mealsTotal == 0 ? 0.0 : mealsDone / mealsTotal;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: SoftHomeColors.cream,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: SoftHomeColors.line),
        boxShadow: SoftHomeColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(('Bugünün ateşi').ui, style: SoftHomeColors.title(size: 16)),
                    const SizedBox(height: 2),
                    Text(('Su · öğün · seri — tek bakışta').ui, style: SoftHomeColors.body(size: 12)),
                  ],
                ),
              ),
              SoftTap(
                onTap: onStory,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: SoftHomeColors.emberGradient,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department_rounded, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(('$streakDays gün').ui,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SoftTap(
                  onTap: onWater,
                  child: _FocusRing(
                    progress: waterProgress,
                    color: SoftHomeColors.water,
                    label: 'Su',
                    value: '%${(waterProgress * 100).round()}',
                  ),
                ),
              ),
              Expanded(
                child: SoftTap(
                  onTap: onDiet,
                  child: _FocusRing(
                    progress: mealP,
                    color: SoftHomeColors.ember,
                    label: 'Öğün',
                    value: '$mealsDone/$mealsTotal',
                  ),
                ),
              ),
              Expanded(
                child: SoftTap(
                  onTap: onStory,
                  child: _FocusRing(
                    progress: (streakDays / 7).clamp(0.0, 1.0),
                    color: SoftHomeColors.wine,
                    label: 'Seri',
                    value: streakDays > 0 ? '$streakDays' : '0',
                    icon: Icons.bolt_rounded,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FocusRing extends StatelessWidget {
  const _FocusRing({
    required this.progress,
    required this.color,
    required this.label,
    required this.value,
    this.icon,
  });

  final double progress;
  final Color color;
  final String label;
  final String value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 72,
          height: 72,
          child: CustomPaint(
            painter: _HomeRingPainter(progress: progress.clamp(0.0, 1.0), color: color),
            child: Center(
              child: icon != null
                  ? Icon(icon, color: color, size: 22)
                  : Text((value).ui, style: SoftHomeColors.title(size: 13)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text((label).ui, style: SoftHomeColors.label(size: 12, color: SoftHomeColors.muted)),
      ],
    );
  }
}

class _HomeRingPainter extends CustomPainter {
  _HomeRingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const stroke = 7.0;
    final radius = (math.min(size.width, size.height) - stroke) / 2;
    final bg = Paint()
      ..color = color.withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bg);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _HomeRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class SoftHomeTipStrip extends StatelessWidget {
  const SoftHomeTipStrip({super.key, this.onTap});

  final VoidCallback? onTap;

  static const _tips = [
    (title: 'Su ritmi', body: 'Her öğünden önce bir bardak — tokluk ve odak artar.'),
    (title: 'Protein önce', body: 'Tabağında önce proteini bitir; enerji daha dengeli kalır.'),
    (title: 'Yavaş ye', body: 'Her lokmayı iyi çiğne — doyma sinyali geç gelir.'),
    (title: 'Ateş serisi', body: 'Bugün küçük bir check-in bile seriyi canlı tutar.'),
  ];

  @override
  Widget build(BuildContext context) {
    final tip = _tips[DateTime.now().difference(DateTime(DateTime.now().year)).inDays % _tips.length];
    return SoftTap(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [SoftHomeColors.blushSoft, SoftHomeColors.amberSoft],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: SoftHomeColors.line),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SoftHomeColors.emberGradient,
              ),
              child: const Icon(Icons.lightbulb_outline_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(('Günün ipucu · ${tip.title}').ui, style: SoftHomeColors.title(size: 13.5)),
                  const SizedBox(height: 3),
                  Text((tip.body).ui, style: SoftHomeColors.body(size: 12.5)),
                  if (onTap != null) ...[
                    const SizedBox(height: 6),
                    Text(('Daha fazla öğren →').ui,
                      style: SoftHomeColors.label(size: 12, color: SoftHomeColors.emberDeep),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
