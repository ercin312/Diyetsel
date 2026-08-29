import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/diyetsel_assets.dart';
import '../../../../core/widgets/cartoon_asset_icon.dart';
import '../../../../core/widgets/cartoon_glyph.dart';
import '../../domain/home_feed_models.dart';

class SoftTap extends StatefulWidget {
  const SoftTap({super.key, required this.child, this.onTap, this.borderRadius});

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  @override
  State<SoftTap> createState() => _SoftTapState();
}

class _SoftTapState extends State<SoftTap> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    Widget child = AnimatedScale(
      scale: _down ? 0.97 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: widget.child,
    );
    if (widget.borderRadius != null) {
      child = ClipRRect(borderRadius: widget.borderRadius!, child: child);
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: widget.onTap == null ? null : (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: widget.onTap == null ? null : (_) => setState(() => _down = false),
      child: child,
    );
  }
}

class DiyetselLogoMark extends StatelessWidget {
  const DiyetselLogoMark({super.key, this.height = 36, this.rounded = true});

  final double height;
  final bool rounded;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      DiyetselAssets.logo,
      height: height,
      width: height,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, _, _) => Text(
        'e-Diyet',
        style: TextStyle(
          fontSize: height * 0.72,
          fontWeight: FontWeight.w900,
          color: AppColors.kawaiiLeaf,
          letterSpacing: -0.6,
          height: 1,
        ),
      ),
    );
    if (!rounded) return image;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height * 0.22),
      child: image,
    );
  }
}

class ProfileAvatarBubble extends StatelessWidget {
  const ProfileAvatarBubble({super.key, this.size = 44, this.asset = DiyetselAssets.characterBoy});

  final double size;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: () => context.push('/app/settings'),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.kawaiiSurfaceCream,
          border: Border.all(color: AppColors.kawaiiLeaf.withValues(alpha: 0.45), width: 2),
          boxShadow: AppSpacing.soft,
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(asset, fit: BoxFit.cover, errorBuilder: (_, _, _) => Icon(Icons.person, color: AppColors.kawaiiLeaf)),
      ),
    );
  }
}

class PremiumSearchBar extends StatelessWidget {
  const PremiumSearchBar({super.key, required this.hint, this.onTap});

  final String hint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSearch),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSearch),
          border: Border.all(color: AppColors.kawaiiOutline),
          boxShadow: AppSpacing.soft,
        ),
        child: Row(
          children: [
            CartoonAssetIcon(
              DiyetselAssets.iconSearch,
              size: 22,
              fallback: Icons.search_rounded,
              fallbackColor: AppColors.kawaiiMuted.withValues(alpha: 0.85),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.kawaiiMuted.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            CartoonAssetIcon(
              DiyetselAssets.iconSet,
              size: 22,
              fallback: Icons.tune_rounded,
              fallbackColor: AppColors.kawaiiMuted.withValues(alpha: 0.75),
            ),
          ],
        ),
      ),
    );
  }
}

class ShortcutRail extends StatelessWidget {
  const ShortcutRail({super.key, required this.items});

  final List<HomeShortcutModel> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 98,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final item = items[i];
          return SoftTap(
            onTap: () => context.push(item.route),
            child: SizedBox(
              width: 72,
              child: Column(
                children: [
                  CartoonGlyph(
                    asset: item.iconAsset,
                    icon: item.icon,
                    accent: item.accent,
                    size: 56,
                    radius: 18,
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
                      color: AppColors.kawaiiInk,
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

class HeroPlanCard extends StatelessWidget {
  const HeroPlanCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.ctaRoute,
    this.imageAsset = DiyetselAssets.foodSaladBowl,
  });

  final String title;
  final String subtitle;
  final String ctaLabel;
  final String ctaRoute;
  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: () => context.push(ctaRoute),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 8, 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.kawaiiMint, AppColors.kawaiiSurfaceCream],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
          border: Border.all(color: AppColors.kawaiiOutline.withValues(alpha: 0.8)),
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
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.kawaiiInk,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.kawaiiMuted,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.kawaiiLeaf,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      boxShadow: const [
                        BoxShadow(color: AppColors.kawaiiGlow, blurRadius: 12, offset: Offset(0, 4)),
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
              child: Image.asset(
                imageAsset,
                width: 118,
                height: 118,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const SizedBox(width: 100, height: 100),
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

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({super.key, required this.items});

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
                  border: Border.all(color: AppColors.kawaiiOutline),
                  boxShadow: AppSpacing.soft,
                ),
                child: Column(
                  children: [
                    CartoonGlyph(
                      asset: items[i].iconAsset,
                      icon: items[i].icon,
                      accent: items[i].accent,
                      size: 44,
                      radius: 14,
                      iconSize: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      items[i].title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: AppColors.kawaiiInk,
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

class FeaturedRecipeCard extends StatelessWidget {
  const FeaturedRecipeCard({super.key, required this.recipe});

  final HomeRecipeModel recipe;

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: () => context.push(recipe.route),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 10, 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF0E0), AppColors.kawaiiSurfaceCream],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
          border: Border.all(color: AppColors.kawaiiOutline),
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
                  color: AppColors.kawaiiCoral.withValues(alpha: 0.9),
                ),
              ),
            const SizedBox(height: 4),
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
                          color: AppColors.kawaiiInk,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        recipe.subtitle,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.kawaiiMuted,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _meta('🔥', '${recipe.kcal} kcal'),
                          _meta('🕒', '${recipe.minutes} dk'),
                          _meta('🌿', '${recipe.proteinG} g'),
                        ],
                      ),
                      if (recipe.badge.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.kawaiiCoral,
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
                  width: 110,
                  height: 110,
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
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$emoji $text',
        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.kawaiiInk),
      ),
    );
  }
}

class LessonCard extends StatelessWidget {
  const LessonCard({super.key, required this.lesson});

  final HomeLessonModel lesson;

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: () => context.push(lesson.route),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.kawaiiLilac.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(color: AppColors.kawaiiOutline),
          boxShadow: AppSpacing.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lesson.title, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.kawaiiPurple)),
            const SizedBox(height: 4),
            Text(lesson.headline, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.kawaiiInk, height: 1.2)),
            const SizedBox(height: 2),
            Text(lesson.subtitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.kawaiiMuted)),
            const Spacer(),
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(color: AppColors.kawaiiPurple, shape: BoxShape.circle),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                ),
                const Spacer(),
                Image.asset(lesson.imageAsset, width: 56, height: 56, fit: BoxFit.contain, errorBuilder: (_, _, _) => const SizedBox()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StreakCard extends StatelessWidget {
  const StreakCard({super.key, required this.streak});

  final HomeStreakModel streak;

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: () => context.push(streak.route),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.kawaiiSky.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(color: AppColors.kawaiiOutline),
          boxShadow: AppSpacing.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(streak.title, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.kawaiiSkyBlue)),
            const SizedBox(height: 4),
            Text(streak.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.kawaiiInk, height: 1.2)),
            const Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: streak.ratio),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.65),
                  color: AppColors.kawaiiSkyBlue,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('${streak.progress}/${streak.total}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.kawaiiInk)),
                const Spacer(),
                Image.asset(streak.imageAsset, width: 52, height: 52, fit: BoxFit.contain, errorBuilder: (_, _, _) => const SizedBox()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProgressChipRow extends StatelessWidget {
  const ProgressChipRow({super.key, required this.items});

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
                    CartoonAssetIcon(
                      items[i].iconAsset,
                      size: 28,
                      fallback: items[i].icon,
                      fallbackColor: items[i].accent,
                    ),
                    const SizedBox(height: 4),
                    Text(items[i].value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.kawaiiInk)),
                    Text(items[i].label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: AppColors.kawaiiMuted)),
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

class SectionHeaderRow extends StatelessWidget {
  const SectionHeaderRow({super.key, required this.title, required this.onSeeAll});

  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.kawaiiInk),
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.kawaiiLeafDeep,
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

class CampaignCard extends StatelessWidget {
  const CampaignCard({super.key, required this.campaign});

  final HomeCampaignModel campaign;

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: () => context.push(campaign.route),
      child: Container(
        width: 210,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: campaign.bgColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(color: AppColors.kawaiiOutline),
          boxShadow: AppSpacing.soft,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(campaign.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.kawaiiInk, height: 1.2)),
                  const SizedBox(height: 4),
                  Text(campaign.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.kawaiiMuted)),
                  const Spacer(),
                  if (campaign.price.isNotEmpty)
                    Text(campaign.price, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.kawaiiLeafDeep, fontSize: 13)),
                ],
              ),
            ),
            Image.asset(campaign.imageAsset, width: 64, height: 64, fit: BoxFit.contain, errorBuilder: (_, _, _) => const SizedBox()),
          ],
        ),
      ),
    );
  }
}

class RecipeThumbCard extends StatelessWidget {
  const RecipeThumbCard({super.key, required this.recipe});

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
          border: Border.all(color: AppColors.kawaiiOutline),
          boxShadow: AppSpacing.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Image.asset(recipe.imageAsset, fit: BoxFit.contain, errorBuilder: (_, _, _) => const SizedBox()),
              ),
            ),
            const SizedBox(height: 8),
            Text(recipe.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.kawaiiInk, height: 1.2)),
            const SizedBox(height: 4),
            Text(
              '${recipe.kcal} kcal · ${recipe.minutes} dk',
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.kawaiiMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class ArticleCard extends StatelessWidget {
  const ArticleCard({super.key, required this.article});

  final HomeArticleModel article;

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: () => context.push(article.route),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(color: AppColors.kawaiiOutline),
          boxShadow: AppSpacing.soft,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (article.tag.isNotEmpty)
                    Text(article.tag, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.kawaiiLeafDeep)),
                  Text(article.title, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.kawaiiInk, height: 1.25)),
                  const Spacer(),
                  Text(article.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, color: AppColors.kawaiiMuted, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            if (article.imageAsset.isNotEmpty) ...[
              const SizedBox(width: 6),
              Image.asset(article.imageAsset, width: 52, height: 52, fit: BoxFit.contain, errorBuilder: (_, _, _) => const SizedBox()),
            ],
          ],
        ),
      ),
    );
  }
}
