import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/diyetsel_assets.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/home_theme_config.dart';
import '../../../core/utils/desktop.dart';
import '../../../core/widgets/cartoon_asset_icon.dart';
import '../../../core/widgets/user_avatar.dart';
import 'profile_photo.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/home_feed_models.dart';
import 'widgets/cartoon_home_extras.dart';
import 'widgets/premium_home_widgets.dart';
import '../../../core/l10n/ui_string.dart';

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
    final themeAsync = ref.watch(homeThemeProvider);
    final config = themeAsync.valueOrNull ?? HomeThemeConfig.defaults();
    final heroSlides = config.heroSlides.isEmpty
        ? HomeHeroSlideConfig.defaults()
        : config.heroSlides;

    final authUser = ref.watch(authControllerProvider).user;
    final store = ref.watch(appStoreProvider);
    ref.watch(waterLogsProvider);
    ref.watch(dietPlansProvider);
    ref.watch(streaksProvider);
    final uid = authUser?.id;
    final water = uid == null ? null : store.waterLog(uid, DateTime.now());
    final waterP =
        water == null || water.goalMl <= 0 ? 0.0 : (water.amountMl / water.goalMl).clamp(0.0, 1.0);
    final plan = uid == null ? null : store.dietPlanForClient(uid);
    var mealsDone = 0;
    var mealsTotal = 0;
    if (plan != null) {
      final today = plan.days.where((d) => DateUtils.isSameDay(d.date, DateTime.now()));
      if (today.isNotEmpty) {
        mealsDone = today.first.meals.where((m) => m.consumed).length;
        mealsTotal = today.first.meals.length;
      }
    }
    final streakDays = uid == null ? 0 : store.streak(uid).current;

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
      imageAsset: DiyetselAssets.characterWoman,
      route: '/app/learn',
    );

    final streak = HomeStreakModel(
      title: 'Ateş serisi',
      subtitle: streakDays <= 0
          ? 'Seriyi başlat — bugün küçük bir adım yeter'
          : '$streakDays/7 · ateşin yanmaya devam ediyor',
      progress: streakDays.clamp(0, 7),
      total: 7,
      imageAsset: DiyetselAssets.characterActiveBoy,
      route: '/app/story',
    );

    final chips = [
      HomeProgressChipModel(
        id: 'streak',
        value: streakDays > 0 ? '$streakDays gün' : 'Başla',
        label: 'Seri',
        accent: AppColors.kawaiiCoral,
        iconAsset: DiyetselAssets.iconStreak,
        icon: Icons.local_fire_department_rounded,
        route: '/app/story',
      ),
      HomeProgressChipModel(
        id: 'water',
        value: '%${(waterP * 100).round()}',
        label: 'Su',
        accent: AppColors.kawaiiSkyBlue,
        iconAsset: DiyetselAssets.iconWaterDrop,
        icon: Icons.water_drop_rounded,
        route: '/app/track',
      ),
      HomeProgressChipModel(
        id: 'meal',
        value: mealsTotal == 0
            ? '—'
            : (mealsDone >= mealsTotal ? 'Tamam' : '$mealsDone/$mealsTotal'),
        label: 'Öğün',
        accent: AppColors.kawaiiLeaf,
        iconAsset: DiyetselAssets.iconCheck,
        icon: Icons.check_circle_rounded,
        route: '/app/diet',
      ),
    ];

    const campaigns = [
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
                _GreetingHeader(
                  userName: name,
                  avatarUrl: avatarUrl,
                  onAvatarTap: () => pickProfilePhoto(context, ref),
                )
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
              CartoonHomeFocusBanner(
                waterProgress: waterP,
                mealsDone: mealsDone,
                mealsTotal: mealsTotal == 0 ? 4 : mealsTotal,
                streakDays: streakDays,
                onWater: () => context.push('/app/track'),
                onDiet: () => context.push('/app/diet'),
                onStory: () => context.push('/app/story'),
              )
                  .animate()
                  .fadeIn(delay: 60.ms, duration: 340.ms)
                  .scale(begin: const Offset(0.97, 0.97), curve: Curves.easeOutCubic),
              const SizedBox(height: 14),
              if (config.isHomeBlockVisible('shortcuts')) ...[
                ShortcutRail(items: HomeFeedData.shortcuts()),
                const SizedBox(height: 16),
              ],
              CartoonHomeTipStrip(onTap: () => context.push('/app/learn'))
                  .animate()
                  .fadeIn(delay: 90.ms, duration: 280.ms),
              const SizedBox(height: 16),
              if (config.isHomeBlockVisible('hero')) ...[
                CartoonHeroSlider(slides: heroSlides),
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
  const _GreetingHeader({required this.userName, this.avatarUrl, this.onAvatarTap});

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
        ? 'Bugün küçük bir adım yeter — planın seni bekliyor.'
        : hour < 17
            ? 'Öğün ve su ritminle enerjini koru.'
            : 'Akşamı tamamla, seriyi bozma.';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DiyetselLogoMark(height: 34),
              const SizedBox(height: 12),
              Text(('$greet, $userName! 👋').ui,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.kawaiiInk,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 4),
              Text((vibe).ui,
                style: const TextStyle(
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
          tooltip: ('Bildirimler').ui,
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
        UserAvatar(
          photoUrl: avatarUrl,
          size: 44,
          onTap: onAvatarTap,
        ),
      ],
    );
  }
}
