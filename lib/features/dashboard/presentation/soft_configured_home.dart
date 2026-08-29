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
import '../domain/home_feed_models.dart';
import 'widgets/soft_home_widgets.dart';

/// Soft premium modern home — mockup layout + modern_icon_* assets.
/// Cartoon theme uses [CartoonConfiguredHome] instead; do not share that path.
class SoftConfiguredHome extends ConsumerWidget {
  const SoftConfiguredHome({
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
    final themeAsync = ref.watch(homeThemeProvider);
    final heroSlides = themeAsync.valueOrNull?.heroSlides ?? HomeHeroSlideConfig.defaults();


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

    const lesson = HomeLessonModel(
      title: 'Mini ders · Gün 1',
      headline: 'İlk bakış: İçindekiler',
      subtitle: 'Etiket Okuma',
      imageAsset: DiyetselAssets.modernCardLesson,
      route: '/app/learn',
    );

    const streak = HomeStreakModel(
      title: 'Ateş serisi',
      subtitle: '3/7 · 7 günlük aktivite serisi',
      progress: 3,
      total: 7,
      imageAsset: DiyetselAssets.modernCardStreak,
      route: '/app/story',
    );

    const chips = [
      HomeProgressChipModel(
        id: 'streak',
        value: '3 gün',
        label: 'Seri',
        accent: Color(0xFFE07A5F),
        iconAsset: DiyetselAssets.modernIconStreak,
        icon: Icons.local_fire_department_rounded,
        route: '/app/story',
      ),
      HomeProgressChipModel(
        id: 'water',
        value: '%30',
        label: 'Su',
        accent: Color(0xFF5BA3C9),
        iconAsset: DiyetselAssets.modernIconWaterDrop,
        icon: Icons.water_drop_rounded,
        route: '/app/track',
      ),
      HomeProgressChipModel(
        id: 'meal',
        value: 'Tamam',
        label: 'Öğün',
        accent: AppColors.primary,
        iconAsset: DiyetselAssets.modernIconCheck,
        icon: Icons.check_circle_rounded,
        route: '/app/diet',
      ),
    ];

    const campaigns = [
      HomeCampaignModel(
        id: 'clinic',
        title: 'Yüz Yüze Klinik Seansı',
        subtitle: 'Diyetisyenle birebir görüşme',
        imageAsset: DiyetselAssets.modernCardClinic,
        route: '/app/services',
        price: '₺1.200',
        bgColor: Color(0xFFEDE8F8),
      ),
      HomeCampaignModel(
        id: 'detox',
        title: 'Detoks Programı',
        subtitle: '7 günlük taze başlangıç',
        imageAsset: DiyetselAssets.modernCardDetox,
        route: '/app/services',
        price: '₺890',
        bgColor: Color(0xFFD8F0E4),
      ),
    ];

    const recipes = [
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

    const articles = [
      HomeArticleModel(
        id: 'if',
        title: 'Aralıklı oruç: 16:8 gerçekten size uygun mu?',
        subtitle: 'Başlangıç rehberi',
        route: '/app/blog',
        imageAsset: DiyetselAssets.modernCardBlog,
        tag: 'Blog',
      ),
      HomeArticleModel(
        id: 'keto',
        title: "Keto'ya yumuşak geçiş",
        subtitle: 'Sağlıklı yağlar',
        route: '/app/blog',
        imageAsset: DiyetselAssets.modernCardBlogKeto,
        tag: 'Beslenme',
      ),
    ];

    return ColoredBox(
      color: AppColors.modernWash,
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
                  color: AppColors.primary.withValues(alpha: 0.08),
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
                  color: const Color(0xFFFFE8B8).withValues(alpha: 0.45),
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
              SoftGreetingHeader(userName: name, avatarUrl: avatarUrl)
                  .animate()
                  .fadeIn(duration: 280.ms)
                  .slideY(begin: -0.04, curve: Curves.easeOut),
              const SizedBox(height: 16),
              SoftSearchBar(
                hint: 'Tarif, yazı veya hizmet ara...',
                onTap: () => context.push('/app/recipes'),
              ),
              const SizedBox(height: 18),
              SoftShortcutRail(items: HomeFeedData.modernShortcuts()),
              const SizedBox(height: 16),
              SoftHeroSlider(slides: heroSlides),
              const SizedBox(height: 16),
              SoftQuickActionGrid(items: HomeFeedData.modernQuickActions()),
              const SizedBox(height: 18),
              SoftFeaturedRecipeCard(recipe: featured),
              const SizedBox(height: 14),
              SizedBox(
                height: 188,
                child: Row(
                  children: [
                    Expanded(child: SoftLessonCard(lesson: lesson)),
                    const SizedBox(width: 10),
                    Expanded(child: SoftStreakCard(streak: streak)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SoftProgressChipRow(items: chips),
              const SizedBox(height: 22),
              SoftSectionHeader(title: 'Kampanyalar', onSeeAll: () => context.push('/app/services')),
              const SizedBox(height: 10),
              SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: campaigns.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (_, i) => SoftCampaignCard(campaign: campaigns[i]),
                ),
              ),
              const SizedBox(height: 20),
              SoftSectionHeader(title: 'Sana özel tarifler', onSeeAll: () => context.push('/app/recipes')),
              const SizedBox(height: 10),
              SizedBox(
                height: 188,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: recipes.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (_, i) => SoftRecipeThumbCard(recipe: recipes[i]),
                ),
              ),
              const SizedBox(height: 20),
              SoftSectionHeader(title: 'Öne çıkan yazılar', onSeeAll: () => context.push('/app/blog')),
              const SizedBox(height: 10),
              SizedBox(
                height: 136,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: articles.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (_, i) => SoftArticleCard(article: articles[i]),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ],
      ),
    );
  }
}
