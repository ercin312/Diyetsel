import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/diyetsel_assets.dart';
import '../../../../core/models/home_theme_config.dart';
import '../../domain/home_feed_models.dart';
import 'premium_home_widgets.dart' show SoftTap, DiyetselLogoMark;

/// Soft modern home widgets — cream / teal palette; modern_icon_* assets.
/// Does not alter cartoon [premium_home_widgets] defaults.

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
        color: fallbackColor ?? AppColors.primary,
      ),
    );
  }
}

class SoftSearchBar extends StatelessWidget {
  const SoftSearchBar({super.key, required this.hint, this.onTap});

  final String hint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSearch),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSearch),
          border: Border.all(color: AppColors.modernLine),
          boxShadow: AppSpacing.soft,
        ),
        child: Row(
          children: [
            SoftModernIcon(
              DiyetselAssets.modernIconSearch,
              size: 22,
              fallback: Icons.search_rounded,
              fallbackColor: AppColors.primary.withValues(alpha: 0.55),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.primary.withValues(alpha: 0.45),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            SoftModernIcon(
              DiyetselAssets.modernIconBell,
              size: 22,
              fallback: Icons.tune_rounded,
              fallbackColor: AppColors.primary.withValues(alpha: 0.45),
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
      height: 98,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final item = items[i];
          return SoftTap(
            onTap: () => context.push(item.route),
            child: SizedBox(
              width: 72,
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: item.accent,
                      boxShadow: AppSpacing.soft,
                    ),
                    alignment: Alignment.center,
                    child: SoftModernIcon(
                      item.iconAsset,
                      size: 30,
                      fallback: item.icon,
                      fallbackColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDeep,
                    ),
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
    final tint = bgColor ?? const Color(0xFFE8F5F0);
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
              Color.lerp(tint, const Color(0xFFFFF6E9), 0.65)!,
            ],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
          border: Border.all(color: AppColors.modernLine),
          boxShadow: AppSpacing.softLift,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDeep,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary.withValues(alpha: 0.7),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      ctaLabel,
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
                      color: AppColors.primary.withValues(alpha: 0.14),
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
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.22),
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
                  border: Border.all(color: AppColors.modernLine),
                  boxShadow: AppSpacing.soft,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                      alignment: Alignment.center,
                      child: SoftModernIcon(
                        items[i].iconAsset,
                        size: 28,
                        fallback: items[i].icon,
                        fallbackColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      items[i].title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: AppColors.primaryDeep,
                      ),
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

/// Dark teal featured recipe — mockup “Mercimek çorbası” card.
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
          color: AppColors.modernTealCard,
          borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
          boxShadow: AppSpacing.softLift,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recipe.sectionLabel.isNotEmpty)
              Text(
                recipe.sectionLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.72),
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
                      Text(
                        recipe.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        recipe.subtitle,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.78),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _meta('🔥', '${recipe.kcal} kcal'),
                          _meta('⏱', '${recipe.minutes} dk'),
                          _meta('💪', '${recipe.proteinG} g'),
                        ],
                      ),
                      if (recipe.badge.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            recipe.badge,
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

  Widget _meta(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$emoji $text',
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
            colors: [Color(0xFFF3EEFF), Color(0xFFFFFFFF)],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFD9CFF5)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7B6BB0).withValues(alpha: 0.14),
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
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7B6BB0).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      lesson.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF5B4E8C),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              lesson.headline,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDeep,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              lesson.subtitle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary.withValues(alpha: 0.55),
              ),
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
                  border: Border.all(color: const Color(0xFFE4DCF8), width: 2),
                  boxShadow: AppSpacing.soft,
                ),
                padding: const EdgeInsets.all(8),
                child: SoftModernIcon(
                  lesson.imageAsset,
                  size: 56,
                  fallback: Icons.menu_book_rounded,
                  fallbackColor: const Color(0xFF7B6BB0),
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
                  child: Text(
                    streak.title,
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
            Text(
              streak.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDeep,
                height: 1.2,
              ),
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
                            ? const Color(0xFFE07A5F)
                            : Colors.white.withValues(alpha: 0.85),
                        border: Border.all(
                          color: i < streak.progress
                              ? const Color(0xFFC45A3C)
                              : const Color(0xFFFFD5C8),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${streak.progress}/${streak.total} gün',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
                color: Color(0xFFC45A3C),
              ),
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
                  color: Color.lerp(items[i].accent, Colors.white, 0.78),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: items[i].accent.withValues(alpha: 0.28)),
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
                    Text(
                      items[i].value,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: AppColors.primaryDeep,
                      ),
                    ),
                    Text(
                      items[i].label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        color: AppColors.primary.withValues(alpha: 0.55),
                      ),
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
  const SoftSectionHeader({super.key, required this.title, required this.onSeeAll});

  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDeep,
            ),
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('Tümü →', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
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
    final accent = _isClinic ? const Color(0xFF7B6BB0) : AppColors.primary;

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
                  Text(
                    campaign.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: AppColors.primaryDeep,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    campaign.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary.withValues(alpha: 0.55),
                    ),
                  ),
                  const Spacer(),
                  if (campaign.price.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        campaign.price,
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(color: AppColors.modernLine),
          boxShadow: AppSpacing.soft,
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
            Text(
              recipe.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: AppColors.primaryDeep,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${recipe.kcal} kcal · ${recipe.minutes} dk',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.primary.withValues(alpha: 0.55),
              ),
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
            colors: [Color(0xFFFFFBF4), Colors.white],
          ),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppColors.modernLine),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: const Color(0xFFE8F5F0),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.15), width: 2),
              ),
              padding: const EdgeInsets.all(8),
              child: SoftModernIcon(
                article.imageAsset.isEmpty
                    ? DiyetselAssets.modernCardBlog
                    : article.imageAsset,
                size: 52,
                fallback: Icons.article_rounded,
                fallbackColor: AppColors.primary,
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
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        article.tag,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    article.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: AppColors.primaryDeep,
                      height: 1.25,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    article.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.primary.withValues(alpha: 0.55),
                      fontWeight: FontWeight.w600,
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

class SoftGreetingHeader extends StatelessWidget {
  const SoftGreetingHeader({super.key, required this.userName, this.avatarUrl});

  final String userName;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DiyetselLogoMark(height: 34),
              const SizedBox(height: 12),
              Text(
                'Merhaba, $userName',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDeep,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Planın, tariflerin ve kampanyaların tek yerde.',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary.withValues(alpha: 0.55),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => context.push('/app/badges'),
          tooltip: 'Bildirimler',
          visualDensity: VisualDensity.compact,
          icon: Badge(
            smallSize: 8,
            backgroundColor: const Color(0xFFE07A5F),
            child: SoftModernIcon(
              DiyetselAssets.modernIconBell,
              size: 26,
              fallback: Icons.notifications_none_rounded,
              fallbackColor: AppColors.primary.withValues(alpha: 0.7),
            ),
          ),
        ),
        SoftTap(
          onTap: () => context.push('/app/settings'),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
              boxShadow: AppSpacing.soft,
            ),
            clipBehavior: Clip.antiAlias,
            child: avatarUrl != null && avatarUrl!.trim().isNotEmpty
                ? Image.network(
                    avatarUrl!.trim(),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Image.asset(
                      DiyetselAssets.characterBoy,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.person, color: AppColors.primary),
                    ),
                  )
                : Image.asset(
                    DiyetselAssets.characterBoy,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const Icon(Icons.person, color: AppColors.primary),
                  ),
          ),
        ),
      ],
    );
  }
}
