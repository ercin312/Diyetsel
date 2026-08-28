import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/diyetsel_assets.dart';

/// Home feed models — backend-ready, UI-agnostic.
class HomeShortcutModel {
  const HomeShortcutModel({
    required this.id,
    required this.title,
    required this.route,
    required this.accent,
    required this.iconAsset,
    this.icon = Icons.star_rounded,
  });

  final String id;
  final String title;
  final String route;
  final Color accent;
  final String iconAsset;
  final IconData icon;
}

class HomeQuickActionModel {
  const HomeQuickActionModel({
    required this.id,
    required this.title,
    required this.route,
    required this.iconAsset,
    this.icon = Icons.circle,
    this.accent = AppColors.kawaiiLeaf,
  });

  final String id;
  final String title;
  final String route;
  final String iconAsset;
  final IconData icon;
  final Color accent;
}

class HomeRecipeModel {
  const HomeRecipeModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.route,
    this.kcal = 0,
    this.minutes = 0,
    this.proteinG = 0,
    this.badge = '',
    this.sectionLabel = '',
  });

  final String id;
  final String title;
  final String subtitle;
  final String imageAsset;
  final String route;
  final int kcal;
  final int minutes;
  final int proteinG;
  final String badge;
  final String sectionLabel;
}

class HomeCampaignModel {
  const HomeCampaignModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.route,
    this.price = '',
    this.bgColor = AppColors.kawaiiSurfaceCream,
  });

  final String id;
  final String title;
  final String subtitle;
  final String imageAsset;
  final String route;
  final String price;
  final Color bgColor;
}

class HomeArticleModel {
  const HomeArticleModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.route,
    this.imageAsset = '',
    this.tag = '',
  });

  final String id;
  final String title;
  final String subtitle;
  final String route;
  final String imageAsset;
  final String tag;
}

class HomeProgressChipModel {
  const HomeProgressChipModel({
    required this.id,
    required this.value,
    required this.label,
    required this.accent,
    required this.iconAsset,
    this.icon = Icons.circle,
    this.route = '/app',
  });

  final String id;
  final String value;
  final String label;
  final Color accent;
  final String iconAsset;
  final IconData icon;
  final String route;
}

class HomeLessonModel {
  const HomeLessonModel({
    required this.title,
    required this.headline,
    required this.subtitle,
    required this.imageAsset,
    required this.route,
  });

  final String title;
  final String headline;
  final String subtitle;
  final String imageAsset;
  final String route;
}

class HomeStreakModel {
  const HomeStreakModel({
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.total,
    required this.imageAsset,
    required this.route,
  });

  final String title;
  final String subtitle;
  final int progress;
  final int total;
  final String imageAsset;
  final String route;

  double get ratio => total <= 0 ? 0 : (progress / total).clamp(0.0, 1.0);
}

/// Seed content for Premium Cartoon Wellness home.
class HomeFeedData {
  HomeFeedData._();

  static List<HomeShortcutModel> shortcuts() => const [
        HomeShortcutModel(
          id: 'story',
          title: 'Hikayem',
          route: '/app/story',
          accent: AppColors.kawaiiWarmYellow,
          iconAsset: DiyetselAssets.iconStory,
          icon: Icons.auto_awesome_rounded,
        ),
        HomeShortcutModel(
          id: 'streak',
          title: 'Seri',
          route: '/app/story',
          accent: AppColors.kawaiiCoral,
          iconAsset: DiyetselAssets.iconStreak,
          icon: Icons.local_fire_department_rounded,
        ),
        HomeShortcutModel(
          id: 'water',
          title: 'Su',
          route: '/app/track',
          accent: AppColors.kawaiiSkyBlue,
          iconAsset: DiyetselAssets.iconWaterDrop,
          icon: Icons.water_drop_rounded,
        ),
        HomeShortcutModel(
          id: 'plan',
          title: 'Plan',
          route: '/app/diet',
          accent: AppColors.kawaiiPurple,
          iconAsset: DiyetselAssets.iconPlan,
          icon: Icons.assignment_rounded,
        ),
        HomeShortcutModel(
          id: 'all',
          title: 'Tümü',
          route: '/app/more',
          accent: AppColors.kawaiiLeaf,
          iconAsset: DiyetselAssets.iconAppsAll,
          icon: Icons.apps_rounded,
        ),
      ];

  static List<HomeQuickActionModel> quickActions() => const [
        HomeQuickActionModel(
          id: 'diet',
          title: 'Diyet',
          route: '/app/diet',
          iconAsset: DiyetselAssets.iconDietScale,
          icon: Icons.monitor_weight_outlined,
        ),
        HomeQuickActionModel(
          id: 'water',
          title: 'Su',
          route: '/app/track',
          iconAsset: DiyetselAssets.iconWaterBottle,
          icon: Icons.water_drop_outlined,
          accent: AppColors.kawaiiSkyBlue,
        ),
        HomeQuickActionModel(
          id: 'appt',
          title: 'Randevu',
          route: '/app/appointments',
          iconAsset: DiyetselAssets.iconCalendar,
          icon: Icons.event_available_outlined,
          accent: AppColors.kawaiiPurple,
        ),
        HomeQuickActionModel(
          id: 'svc',
          title: 'Hizmet',
          route: '/app/services',
          iconAsset: DiyetselAssets.iconService,
          icon: Icons.support_agent_outlined,
          accent: AppColors.kawaiiCoral,
        ),
      ];
}
