import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/diyetsel_assets.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/home_theme_config.dart';
import '../../../core/utils/desktop.dart';
import '../../auth/presentation/auth_controller.dart';
import 'profile_photo.dart';
import '../domain/home_feed_models.dart';
import 'widgets/soft_home_palette.dart';
import 'widgets/soft_home_widgets.dart';

/// Soft premium modern home — warm ember / orange-red wellness language.
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
    final hPad = width < 360 ? 14.0 : 18.0;
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
      subtitle: 'Akşam için sıcak, protein dolu bir kase',
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

    final streak = HomeStreakModel(
      title: 'Ateş serisi',
      subtitle: streakDays <= 0
          ? 'Seriyi başlat — bugün küçük bir adım yeter'
          : '$streakDays/7 · ateşin yanmaya devam ediyor',
      progress: streakDays.clamp(0, 7),
      total: 7,
      imageAsset: DiyetselAssets.modernCardStreak,
      route: '/app/story',
    );

    final chips = [
      HomeProgressChipModel(
        id: 'streak',
        value: streakDays > 0 ? '$streakDays gün' : 'Başla',
        label: 'Seri',
        accent: SoftHomeColors.ember,
        iconAsset: DiyetselAssets.modernIconStreak,
        icon: Icons.local_fire_department_rounded,
        route: '/app/story',
      ),
      HomeProgressChipModel(
        id: 'water',
        value: '%${(waterP * 100).round()}',
        label: 'Su',
        accent: SoftHomeColors.water,
        iconAsset: DiyetselAssets.modernIconWaterDrop,
        icon: Icons.water_drop_rounded,
        route: '/app/track',
      ),
      HomeProgressChipModel(
        id: 'meal',
        value: mealsTotal == 0
            ? '—'
            : (mealsDone >= mealsTotal ? 'Tamam' : '$mealsDone/$mealsTotal'),
        label: 'Öğün',
        accent: SoftHomeColors.wine,
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
        bgColor: SoftHomeColors.blushSoft,
      ),
      HomeCampaignModel(
        id: 'detox',
        title: 'Detoks Programı',
        subtitle: '7 günlük taze başlangıç',
        imageAsset: DiyetselAssets.modernCardDetox,
        route: '/app/services',
        price: '₺890',
        bgColor: SoftHomeColors.amberSoft,
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

    return DecoratedBox(
      decoration: const BoxDecoration(gradient: SoftHomeColors.washGradient),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -40,
            child: IgnorePointer(
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      SoftHomeColors.emberBright.withValues(alpha: 0.28),
                      SoftHomeColors.ember.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 180,
            left: -70,
            child: IgnorePointer(
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SoftHomeColors.apricot.withValues(alpha: 0.18),
                ),
              ),
            ),
          ),
          ListView(
            padding: EdgeInsets.fromLTRB(
              hPad,
              context.isDesktopLayout ? 18 : 6,
              hPad,
              32,
            ),
            children: [
              if (config.isHomeBlockVisible('greeting')) ...[
                SoftGreetingHeader(
                  userName: name,
                  avatarUrl: avatarUrl,
                  onAvatarTap: () => pickProfilePhoto(context, ref),
                )
                    .animate()
                    .fadeIn(duration: 320.ms)
                    .slideY(begin: -0.05, curve: Curves.easeOutCubic),
                const SizedBox(height: 14),
              ],
              if (config.isHomeBlockVisible('search')) ...[
                SoftSearchBar(hint: 'Tarif, yazı veya hizmet ara...')
                    .animate()
                    .fadeIn(delay: 40.ms, duration: 280.ms),
                const SizedBox(height: 16),
              ],
              SoftHomeFocusBanner(
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
                SoftShortcutRail(items: HomeFeedData.modernShortcuts()),
                const SizedBox(height: 16),
              ],
              SoftHomeTipStrip(onTap: () => context.push('/app/learn'))
                  .animate()
                  .fadeIn(delay: 90.ms, duration: 280.ms),
              const SizedBox(height: 16),
              if (config.isHomeBlockVisible('hero')) ...[
                SoftHeroSlider(slides: heroSlides),
                const SizedBox(height: 16),
              ],
              if (config.isHomeBlockVisible('quickActions')) ...[
                SoftQuickActionGrid(items: HomeFeedData.modernQuickActions()),
                const SizedBox(height: 18),
              ],
              if (config.isHomeBlockVisible('featuredRecipe')) ...[
                SoftFeaturedRecipeCard(recipe: featured)
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 320.ms)
                    .slideY(begin: 0.04, curve: Curves.easeOutCubic),
                const SizedBox(height: 14),
              ],
              if (config.isHomeBlockVisible('lessonStreak')) ...[
                SizedBox(
                  height: 196,
                  child: Row(
                    children: [
                      Expanded(child: SoftLessonCard(lesson: lesson)),
                      const SizedBox(width: 10),
                      Expanded(child: SoftStreakCard(streak: streak)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              if (config.isHomeBlockVisible('progressChips')) ...[
                SoftProgressChipRow(items: chips),
                const SizedBox(height: 22),
              ],
              if (config.isHomeBlockVisible('campaigns')) ...[
                SoftSectionHeader(
                  title: 'Kampanyalar',
                  subtitle: 'Klinik ve online paketler',
                  onSeeAll: () => context.push('/app/services'),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 148,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: campaigns.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => SoftCampaignCard(campaign: campaigns[i]),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              if (config.isHomeBlockVisible('recipes')) ...[
                SoftSectionHeader(
                  title: 'Sana özel tarifler',
                  subtitle: 'Sıcak, ölçülü, protein odaklı',
                  onSeeAll: () => context.push('/app/recipes'),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 196,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: recipes.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => SoftRecipeThumbCard(recipe: recipes[i]),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              if (config.isHomeBlockVisible('articles')) ...[
                SoftSectionHeader(
                  title: 'Öne çıkan yazılar',
                  subtitle: '3 dakikalık okumalar',
                  onSeeAll: () => context.push('/app/blog'),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 140,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: articles.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => SoftArticleCard(article: articles[i]),
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ],
      ),
    );
  }
}
