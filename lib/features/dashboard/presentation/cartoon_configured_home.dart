import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/diyetsel_assets.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/home_theme_config.dart';
import '../../../core/utils/desktop.dart';
import '../../../core/widgets/cartoon_asset_icon.dart';
import '../domain/home_feed_models.dart';
import 'widgets/premium_home_widgets.dart';

/// Premium Cartoon Wellness home — real widgets + brand assets.
class CartoonConfiguredHome extends ConsumerWidget {
  const CartoonConfiguredHome({
    super.key,
    required this.userName,
    this.avatarUrl,
  });

  final String userName;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final hPad = width < 360 ? 14.0 : AppSpacing.pageH;
    final name = userName.isEmpty ? 'Dostum' : userName;
    final config = ref.watch(homeThemeProvider).valueOrNull ?? HomeThemeConfig.defaults();

    final featured = HomeRecipeModel(
      id: 'lentil',
      title: 'Mercimek çorbası',
      subtitle: 'Bugün ~110 g protein eksik — akşam için ideal',
      imageAsset: DiyetselAssets.foodLentilSoup,
      route: '/app/recipes',
      kcal: 310,
      minutes: 35,
      proteinG: 18,
      badge: '+18 g protein',
      sectionLabel: 'Bugün akşam bunu dene',
    );

    final lesson = const HomeLessonModel(
      title: 'Mini ders · Gün 1',
      headline: 'İlk bakış: İçindekiler',
      subtitle: 'Etiket Okuma',
      imageAsset: DiyetselAssets.characterWoman,
      route: '/app/learn',
    );

    final streak = const HomeStreakModel(
      title: 'Ateş serisi',
      subtitle: '3/7 · 7 günlük aktivite serisi',
      progress: 3,
      total: 7,
      imageAsset: DiyetselAssets.characterActiveBoy,
      route: '/app/story',
    );

    final chips = const [
      HomeProgressChipModel(
        id: 'streak',
        value: '3 gün',
        label: 'Seri',
        accent: AppColors.kawaiiCoral,
        iconAsset: DiyetselAssets.iconStreak,
        icon: Icons.local_fire_department_rounded,
        route: '/app/story',
      ),
      HomeProgressChipModel(
        id: 'water',
        value: '%30',
        label: 'Su',
        accent: AppColors.kawaiiSkyBlue,
        iconAsset: DiyetselAssets.iconWaterDrop,
        icon: Icons.water_drop_rounded,
        route: '/app/track',
      ),
      HomeProgressChipModel(
        id: 'meal',
        value: 'Tamam',
        label: 'Öğün',
        accent: AppColors.kawaiiLeaf,
        iconAsset: DiyetselAssets.iconCheck,
        icon: Icons.check_circle_rounded,
        route: '/app/diet',
      ),
    ];

    final campaigns = const [
      HomeCampaignModel(
        id: 'clinic',
        title: 'Yüz Yüze Klinik Seansı',
        subtitle: 'Diyetisyenle birebir görüşme',
        imageAsset: DiyetselAssets.characterWoman,
        route: '/app/services',
        price: '₺1.200',
        bgColor: AppColors.kawaiiLilac,
      ),
      HomeCampaignModel(
        id: 'detox',
        title: 'Detoks Programı',
        subtitle: '7 günlük taze başlangıç',
        imageAsset: DiyetselAssets.foodGreenSmoothie,
        route: '/app/services',
        price: '₺890',
        bgColor: AppColors.kawaiiMint,
      ),
    ];

    final recipes = const [
      HomeRecipeModel(
        id: 'bowl',
        title: 'Akdeniz protein kasesi',
        subtitle: '',
        imageAsset: DiyetselAssets.foodSaladBowl,
        route: '/app/recipes',
        kcal: 420,
        minutes: 25,
        proteinG: 32,
      ),
      HomeRecipeModel(
        id: 'soup2',
        title: 'Mercimek çorbası',
        subtitle: '',
        imageAsset: DiyetselAssets.foodLentilSoup,
        route: '/app/recipes',
        kcal: 310,
        minutes: 35,
        proteinG: 18,
      ),
    ];

    final articles = const [
      HomeArticleModel(
        id: 'if',
        title: 'Aralıklı oruç: 16:8 gerçekten size uygun mu?',
        subtitle: 'Başlangıç rehberi',
        route: '/app/blog',
        imageAsset: DiyetselAssets.mascotCarrot,
        tag: 'Blog',
      ),
      HomeArticleModel(
        id: 'keto',
        title: "Keto'ya yumuşak geçiş",
        subtitle: 'Sağlıklı yağlar',
        route: '/app/blog',
        imageAsset: DiyetselAssets.mascotAvocado,
        tag: 'Beslenme',
      ),
    ];

    return ColoredBox(
      color: AppColors.kawaiiCream,
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -30,
            child: IgnorePointer(
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.kawaiiMint.withValues(alpha: 0.55),
                ),
              ),
            ),
          ),
          Positioned(
            top: 120,
            left: -50,
            child: IgnorePointer(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.kawaiiLemon.withValues(alpha: 0.35),
                ),
              ),
            ),
          ),
          ListView(
            padding: EdgeInsets.fromLTRB(
              hPad,
              context.isDesktopLayout ? 20 : 8,
              hPad,
              28,
            ),
            children: [
              if (config.isHomeBlockVisible('greeting')) ...[
                _GreetingHeader(userName: name)
                    .animate()
                    .fadeIn(duration: 280.ms)
                    .slideY(begin: -0.04, curve: Curves.easeOut),
                const SizedBox(height: 16),
              ],
              if (config.isHomeBlockVisible('search')) ...[
                PremiumSearchBar(
                  hint: 'Tarif, yazı veya hizmet ara...',
                  onTap: () => context.push('/app/recipes'),
                ),
                const SizedBox(height: 18),
              ],
              if (config.isHomeBlockVisible('shortcuts')) ...[
                ShortcutRail(items: HomeFeedData.shortcuts()),
                const SizedBox(height: 16),
              ],
              if (config.isHomeBlockVisible('hero')) ...[
                const HeroPlanCard(
                  title: 'Bugünkü plan tamam 🎉',
                  subtitle: 'Kampanyalar ve tarifler aşağıda, günün tek kartta.',
                  ctaLabel: 'Diyetim',
                  ctaRoute: '/app/diet',
                ),
                const SizedBox(height: 16),
              ],
              if (config.isHomeBlockVisible('quickActions')) ...[
                QuickActionGrid(items: HomeFeedData.quickActions()),
                const SizedBox(height: 18),
              ],
              if (config.isHomeBlockVisible('featuredRecipe')) ...[
                FeaturedRecipeCard(recipe: featured),
                const SizedBox(height: 14),
              ],
              if (config.isHomeBlockVisible('lessonStreak')) ...[
                SizedBox(
                  height: 168,
                  child: Row(
                    children: [
                      Expanded(child: LessonCard(lesson: lesson)),
                      const SizedBox(width: 10),
                      Expanded(child: StreakCard(streak: streak)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (config.isHomeBlockVisible('progressChips')) ...[
                ProgressChipRow(items: chips),
                const SizedBox(height: 22),
              ],
              if (config.isHomeBlockVisible('campaigns')) ...[
                SectionHeaderRow(title: 'Kampanyalar', onSeeAll: () => context.push('/app/services')),
                const SizedBox(height: 10),
                SizedBox(
                  height: 128,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: campaigns.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => CampaignCard(campaign: campaigns[i]),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              if (config.isHomeBlockVisible('recipes')) ...[
                SectionHeaderRow(title: 'Sana özel tarifler', onSeeAll: () => context.push('/app/recipes')),
                const SizedBox(height: 10),
                SizedBox(
                  height: 188,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: recipes.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => RecipeThumbCard(recipe: recipes[i]),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              if (config.isHomeBlockVisible('articles')) ...[
                SectionHeaderRow(title: 'Öne çıkan yazılar', onSeeAll: () => context.push('/app/blog')),
                const SizedBox(height: 10),
                SizedBox(
                  height: 128,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: articles.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => ArticleCard(article: articles[i]),
                  ),
                ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        ],
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({required this.userName});

  final String userName;

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
                'Merhaba, $userName! 👋',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.kawaiiInk,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Planın, tariflerin ve kampanyaların tek yerde.',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.kawaiiMuted,
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
            backgroundColor: AppColors.kawaiiCoral,
            child: CartoonAssetIcon(
              DiyetselAssets.iconBell,
              size: 26,
              fallback: Icons.notifications_none_rounded,
              fallbackColor: AppColors.kawaiiInk.withValues(alpha: 0.7),
            ),
          ),
        ),
        const SizedBox(width: 2),
        const ProfileAvatarBubble(),
      ],
    );
  }
}
