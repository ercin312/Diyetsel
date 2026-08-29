import 'dart:convert';

import 'package:flutter/material.dart';

Color? parseHexColor(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  var hex = raw.replaceFirst('#', '');
  if (hex.length == 6) hex = 'FF$hex';
  if (hex.length != 8) return null;
  final value = int.tryParse(hex, radix: 16);
  if (value == null) return null;
  return Color(value);
}

/// Dynamic cartoon home theme — admin/JSON driven.
class HomeThemeConfig {
  const HomeThemeConfig({
    this.logoTitle = 'e-Diyet',
    this.userAvatarUrl = '',
    this.welcomeMessage = 'Merhaba, {{userName}}! 👋',
    this.welcomeSubtitle = 'Bugün için tatlı bir plan seni bekliyor',
    this.searchHint = 'Tarif, yazı veya hizmet ara',
    this.categories = const [],
    this.mainPlan = const HomeMainPlanConfig(),
    this.heroSlides = const [],
    this.quickActions = const [],
    this.mealSuggestion = const HomeMealSuggestionConfig(),
    this.miniCards = const [],
    this.statusChips = const [],
    this.sections = const [],
    this.tabs = const [],
    this.colors = const HomeThemeColors(),
  });

  final String logoTitle;
  final String userAvatarUrl;
  final String welcomeMessage;
  final String welcomeSubtitle;
  final String searchHint;
  final List<HomeCategoryConfig> categories;
  final HomeMainPlanConfig mainPlan;
  /// Soft modern home hero carousel — admin editable.
  final List<HomeHeroSlideConfig> heroSlides;
  final List<HomeQuickActionConfig> quickActions;
  final HomeMealSuggestionConfig mealSuggestion;
  final List<HomeMiniCardConfig> miniCards;
  final List<HomeStatusChipConfig> statusChips;
  final List<HomeSectionConfig> sections;
  final List<HomeTabConfig> tabs;
  final HomeThemeColors colors;

  String welcomeFor(String userName) =>
      welcomeMessage.replaceAll('{{userName}}', userName.isEmpty ? 'Dostum' : userName);

  HomeThemeConfig copyWith({
    String? logoTitle,
    String? userAvatarUrl,
    String? welcomeMessage,
    String? welcomeSubtitle,
    String? searchHint,
    List<HomeCategoryConfig>? categories,
    HomeMainPlanConfig? mainPlan,
    List<HomeHeroSlideConfig>? heroSlides,
    List<HomeQuickActionConfig>? quickActions,
    HomeMealSuggestionConfig? mealSuggestion,
    List<HomeMiniCardConfig>? miniCards,
    List<HomeStatusChipConfig>? statusChips,
    List<HomeSectionConfig>? sections,
    List<HomeTabConfig>? tabs,
    HomeThemeColors? colors,
  }) {
    return HomeThemeConfig(
      logoTitle: logoTitle ?? this.logoTitle,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      welcomeMessage: welcomeMessage ?? this.welcomeMessage,
      welcomeSubtitle: welcomeSubtitle ?? this.welcomeSubtitle,
      searchHint: searchHint ?? this.searchHint,
      categories: categories ?? this.categories,
      mainPlan: mainPlan ?? this.mainPlan,
      heroSlides: heroSlides ?? this.heroSlides,
      quickActions: quickActions ?? this.quickActions,
      mealSuggestion: mealSuggestion ?? this.mealSuggestion,
      miniCards: miniCards ?? this.miniCards,
      statusChips: statusChips ?? this.statusChips,
      sections: sections ?? this.sections,
      tabs: tabs ?? this.tabs,
      colors: colors ?? this.colors,
    );
  }

  Map<String, dynamic> toMap() => {
        'logoTitle': logoTitle,
        'userAvatarUrl': userAvatarUrl,
        'welcomeMessage': welcomeMessage,
        'welcomeSubtitle': welcomeSubtitle,
        'searchHint': searchHint,
        'categories': categories.map((e) => e.toMap()).toList(),
        'mainPlan': mainPlan.toMap(),
        'heroSlides': heroSlides.map((e) => e.toMap()).toList(),
        'quickActions': quickActions.map((e) => e.toMap()).toList(),
        'mealSuggestion': mealSuggestion.toMap(),
        'miniCards': miniCards.map((e) => e.toMap()).toList(),
        'statusChips': statusChips.map((e) => e.toMap()).toList(),
        'sections': sections.map((e) => e.toMap()).toList(),
        'tabs': tabs.map((e) => e.toMap()).toList(),
        'colors': colors.toMap(),
      };

  String toJson() => const JsonEncoder.withIndent('  ').convert(toMap());

  factory HomeThemeConfig.fromMap(Map<String, dynamic> map) {
    List<Map<String, dynamic>> listOf(String key) {
      final raw = map[key];
      if (raw is! List) return const [];
      return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }

    return HomeThemeConfig(
      logoTitle: map['logoTitle']?.toString() ?? 'e-Diyet',
      userAvatarUrl: map['userAvatarUrl']?.toString() ?? '',
      welcomeMessage: map['welcomeMessage']?.toString() ?? 'Merhaba, {{userName}}! 👋',
      welcomeSubtitle: map['welcomeSubtitle']?.toString() ?? '',
      searchHint: map['searchHint']?.toString() ?? 'Ara',
      categories: listOf('categories').map(HomeCategoryConfig.fromMap).toList(),
      mainPlan: HomeMainPlanConfig.fromMap(
        map['mainPlan'] is Map ? Map<String, dynamic>.from(map['mainPlan'] as Map) : const {},
      ),
      heroSlides: listOf('heroSlides').isEmpty
          ? HomeHeroSlideConfig.defaults()
          : listOf('heroSlides').map(HomeHeroSlideConfig.fromMap).toList(),
      quickActions: listOf('quickActions').map(HomeQuickActionConfig.fromMap).toList(),
      mealSuggestion: HomeMealSuggestionConfig.fromMap(
        map['mealSuggestion'] is Map
            ? Map<String, dynamic>.from(map['mealSuggestion'] as Map)
            : const {},
      ),
      miniCards: listOf('miniCards').map(HomeMiniCardConfig.fromMap).toList(),
      statusChips: listOf('statusChips').map(HomeStatusChipConfig.fromMap).toList(),
      sections: listOf('sections').map(HomeSectionConfig.fromMap).toList(),
      tabs: listOf('tabs').map(HomeTabConfig.fromMap).toList(),
      colors: HomeThemeColors.fromMap(
        map['colors'] is Map ? Map<String, dynamic>.from(map['colors'] as Map) : const {},
      ),
    );
  }

  factory HomeThemeConfig.fromJson(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return HomeThemeConfig.defaults();
    return HomeThemeConfig.fromMap(Map<String, dynamic>.from(decoded));
  }

  /// Reference-matching mock — admin can override via JSON.
  factory HomeThemeConfig.defaults() => HomeThemeConfig(
        logoTitle: 'e-Diyet',
        welcomeMessage: 'Merhaba, {{userName}}! 👋',
        welcomeSubtitle: 'Bugün için tatlı bir plan seni bekliyor',
        searchHint: 'Tarif, yazı veya hizmet ara',
        categories: const [
          HomeCategoryConfig(id: 'story', title: 'Hikayem', iconKey: 'star', bgColor: '#FFF9E5', route: '/app/story'),
          HomeCategoryConfig(id: 'streak', title: 'Seri', iconKey: 'fire', bgColor: '#FFE8D6', route: '/app/story'),
          HomeCategoryConfig(id: 'water', title: 'Su', iconKey: 'water', bgColor: '#D1EFFF', route: '/app/track'),
          HomeCategoryConfig(id: 'plan', title: 'Plan', iconKey: 'plan', bgColor: '#FFF8F0', route: '/app/diet'),
          HomeCategoryConfig(id: 'all', title: 'Tümü', iconKey: 'more', bgColor: '#F5F0E8', route: '/app/more'),
        ],
        mainPlan: const HomeMainPlanConfig(
          title: 'Bugünkü plan tamam 🎉',
          description: 'Kampanyalar ve tarifler aşağıda seni bekliyor',
          buttonText: 'Diyetim',
          buttonRoute: '/app/diet',
          imageKey: 'bowl',
          bgColor: '#E8F5E9',
        ),
        heroSlides: HomeHeroSlideConfig.defaults(),
        quickActions: const [
          HomeQuickActionConfig(id: 'diet', title: 'Diyet', iconKey: 'scale', route: '/app/diet'),
          HomeQuickActionConfig(id: 'water', title: 'Su', iconKey: 'bottle', route: '/app/track'),
          HomeQuickActionConfig(id: 'appt', title: 'Randevu', iconKey: 'calendar', route: '/app/appointments'),
          HomeQuickActionConfig(id: 'service', title: 'Hizmet', iconKey: 'headset', route: '/app/services'),
        ],
        mealSuggestion: const HomeMealSuggestionConfig(
          title: 'Mercimek çorbası',
          description: 'Bugün protein hedefine yaklaş — sıcak bir kase!',
          bgColor: '#FFE8D6',
          imageKey: 'soup',
          route: '/app/recipes',
          stats: [
            HomeMealStatConfig(type: 'kcal', value: '310', icon: '🔥'),
            HomeMealStatConfig(type: 'duration', value: '35 dk', icon: '🕒'),
            HomeMealStatConfig(type: 'protein', value: '+18g', icon: '🌿'),
          ],
        ),
        miniCards: const [
          HomeMiniCardConfig(
            id: 'lesson',
            title: 'Mini ders',
            subtitle: '2 dk izle',
            characterKey: 'lesson',
            bgColor: '#E8D9FF',
            progress: 0,
            progressColor: '#9B7EDE',
            route: '/app/learn',
            actionLabel: 'Oynat',
          ),
          HomeMiniCardConfig(
            id: 'streak',
            title: 'Ateş serisi',
            subtitle: '3/7 gün',
            characterKey: 'streak',
            bgColor: '#D1EFFF',
            progress: 43,
            progressColor: '#5B9BD5',
            route: '/app/story',
          ),
        ],
        statusChips: const [
          HomeStatusChipConfig(id: 'streak', label: '3 gün Seri', iconKey: 'fire', bgColor: '#FFE4CC'),
          HomeStatusChipConfig(id: 'water', label: '%30 Su', iconKey: 'water', bgColor: '#D1EFFF'),
          HomeStatusChipConfig(id: 'meal', label: 'Tamam Öğün', iconKey: 'avocado', bgColor: '#E8F5E9'),
        ],
        sections: const [
          HomeSectionConfig(
            id: 'campaigns',
            title: 'Kampanyalar',
            seeAllRoute: '/app/services',
            items: [
              HomeSectionItemConfig(
                id: 'clinic',
                title: 'Yüz Yüze Klinik Seansı',
                subtitle: 'Diyetisyenle birebir',
                price: '₺1.200',
                imageKey: 'clinic',
                route: '/app/services',
              ),
            ],
          ),
          HomeSectionConfig(
            id: 'recipes',
            title: 'Sana özel tarifler',
            seeAllRoute: '/app/recipes',
            items: [
              HomeSectionItemConfig(
                id: 'bowl',
                title: 'Akdeniz Protein Bowl',
                subtitle: '420 kcal',
                duration: '25 dk',
                imageKey: 'bowl',
                route: '/app/recipes',
              ),
              HomeSectionItemConfig(
                id: 'soup',
                title: 'Mercimek Çorbası',
                subtitle: '310 kcal',
                duration: '35 dk',
                imageKey: 'soup',
                route: '/app/recipes',
              ),
            ],
          ),
          HomeSectionConfig(
            id: 'articles',
            title: 'Öne çıkan yazılar',
            seeAllRoute: '/app/blog',
            items: [
              HomeSectionItemConfig(
                id: 'if',
                title: 'Aralıklı Oruç Rehberi',
                subtitle: 'Başlangıç için 5 ipucu',
                imageKey: 'clock',
                tag: 'Blog',
                route: '/app/blog',
              ),
              HomeSectionItemConfig(
                id: 'keto',
                title: 'Keto ile Dost Avokado',
                subtitle: 'Sağlıklı yağlar',
                imageKey: 'avocado',
                tag: 'Beslenme',
                route: '/app/blog',
              ),
            ],
          ),
        ],
        tabs: const [
          HomeTabConfig(id: 'home', title: 'Ana Sayfa', iconKey: 'home', route: '/app'),
          HomeTabConfig(id: 'diet', title: 'Diyetim', iconKey: 'apple', route: '/app/diet'),
          HomeTabConfig(id: 'add', title: '+', iconKey: 'add', route: '/app/track'),
          HomeTabConfig(id: 'calendar', title: 'Takvim', iconKey: 'calendar', route: '/app/appointments'),
          HomeTabConfig(id: 'profile', title: 'Profil', iconKey: 'profile', route: '/app/more'),
        ],
        colors: const HomeThemeColors(
          canvas: '#FDFBF5',
          primary: '#74B46E',
          ink: '#3D342C',
          muted: '#7A6F64',
        ),
      );
}

class HomeThemeColors {
  const HomeThemeColors({
    this.canvas = '#FDFBF5',
    this.primary = '#74B46E',
    this.ink = '#3D342C',
    this.muted = '#7A6F64',
  });

  final String canvas;
  final String primary;
  final String ink;
  final String muted;

  Color get canvasColor => parseHexColor(canvas) ?? const Color(0xFFFDFBF5);
  Color get primaryColor => parseHexColor(primary) ?? const Color(0xFF74B46E);
  Color get inkColor => parseHexColor(ink) ?? const Color(0xFF3D342C);
  Color get mutedColor => parseHexColor(muted) ?? const Color(0xFF7A6F64);

  Map<String, dynamic> toMap() => {
        'canvas': canvas,
        'primary': primary,
        'ink': ink,
        'muted': muted,
      };

  factory HomeThemeColors.fromMap(Map<String, dynamic> map) => HomeThemeColors(
        canvas: map['canvas']?.toString() ?? '#FDFBF5',
        primary: map['primary']?.toString() ?? '#74B46E',
        ink: map['ink']?.toString() ?? '#3D342C',
        muted: map['muted']?.toString() ?? '#7A6F64',
      );
}

class HomeCategoryConfig {
  const HomeCategoryConfig({
    required this.id,
    required this.title,
    this.iconKey = 'star',
    this.iconUrl = '',
    this.bgColor = '#FFF9E5',
    this.route = '/app',
  });

  final String id;
  final String title;
  final String iconKey;
  final String iconUrl;
  final String bgColor;
  final String route;

  Color get background => parseHexColor(bgColor) ?? const Color(0xFFFFF9E5);

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'iconKey': iconKey,
        'iconUrl': iconUrl,
        'bgColor': bgColor,
        'route': route,
      };

  factory HomeCategoryConfig.fromMap(Map<String, dynamic> map) => HomeCategoryConfig(
        id: map['id']?.toString() ?? '',
        title: map['title']?.toString() ?? '',
        iconKey: map['iconKey']?.toString() ?? 'star',
        iconUrl: map['iconUrl']?.toString() ?? '',
        bgColor: map['bgColor']?.toString() ?? '#FFF9E5',
        route: map['route']?.toString() ?? '/app',
      );
}

class HomeMainPlanConfig {
  const HomeMainPlanConfig({
    this.title = 'Bugünkü plan tamam 🎉',
    this.description = '',
    this.buttonText = 'Diyetim',
    this.buttonRoute = '/app/diet',
    this.imageUrl = '',
    this.imageKey = 'bowl',
    this.bgColor = '#E8F5E9',
  });

  final String title;
  final String description;
  final String buttonText;
  final String buttonRoute;
  final String imageUrl;
  final String imageKey;
  final String bgColor;

  Color get background => parseHexColor(bgColor) ?? const Color(0xFFE8F5E9);

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'buttonText': buttonText,
        'buttonRoute': buttonRoute,
        'imageUrl': imageUrl,
        'imageKey': imageKey,
        'bgColor': bgColor,
      };

  factory HomeMainPlanConfig.fromMap(Map<String, dynamic> map) => HomeMainPlanConfig(
        title: map['title']?.toString() ?? 'Bugünkü plan tamam 🎉',
        description: map['description']?.toString() ?? '',
        buttonText: map['buttonText']?.toString() ?? 'Diyetim',
        buttonRoute: map['buttonRoute']?.toString() ?? '/app/diet',
        imageUrl: map['imageUrl']?.toString() ?? '',
        imageKey: map['imageKey']?.toString() ?? 'bowl',
        bgColor: map['bgColor']?.toString() ?? '#E8F5E9',
      );
}

/// Soft modern home hero carousel slide (admin editable).
class HomeHeroSlideConfig {
  const HomeHeroSlideConfig({
    required this.id,
    required this.title,
    this.description = '',
    this.buttonText = 'Keşfet',
    this.buttonRoute = '/app/diet',
    this.imageUrl = '',
    this.imageKey = 'bowl',
    this.bgColor = '#E8F5F0',
  });

  final String id;
  final String title;
  final String description;
  final String buttonText;
  final String buttonRoute;
  final String imageUrl;
  final String imageKey;
  final String bgColor;

  Color get background => parseHexColor(bgColor) ?? const Color(0xFFE8F5F0);

  HomeHeroSlideConfig copyWith({
    String? id,
    String? title,
    String? description,
    String? buttonText,
    String? buttonRoute,
    String? imageUrl,
    String? imageKey,
    String? bgColor,
  }) {
    return HomeHeroSlideConfig(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      buttonText: buttonText ?? this.buttonText,
      buttonRoute: buttonRoute ?? this.buttonRoute,
      imageUrl: imageUrl ?? this.imageUrl,
      imageKey: imageKey ?? this.imageKey,
      bgColor: bgColor ?? this.bgColor,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'buttonText': buttonText,
        'buttonRoute': buttonRoute,
        'imageUrl': imageUrl,
        'imageKey': imageKey,
        'bgColor': bgColor,
      };

  factory HomeHeroSlideConfig.fromMap(Map<String, dynamic> map) => HomeHeroSlideConfig(
        id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: map['title']?.toString() ?? '',
        description: map['description']?.toString() ?? '',
        buttonText: map['buttonText']?.toString() ?? 'Keşfet',
        buttonRoute: map['buttonRoute']?.toString() ?? '/app/diet',
        imageUrl: map['imageUrl']?.toString() ?? '',
        imageKey: map['imageKey']?.toString() ?? 'bowl',
        bgColor: map['bgColor']?.toString() ?? '#E8F5F0',
      );

  static List<HomeHeroSlideConfig> defaults() => const [
        HomeHeroSlideConfig(
          id: 'plan',
          title: 'Bugünkü plan tamam 🎉',
          description: 'Kampanyalar ve tarifler aşağıda, günün tek kartta.',
          buttonText: 'Diyetim',
          buttonRoute: '/app/diet',
          imageKey: 'bowl',
          bgColor: '#E8F5F0',
        ),
        HomeHeroSlideConfig(
          id: 'water',
          title: 'Su hedefini yakala',
          description: 'Küçük yudumlar büyük fark yaratır — bir bardak ekle.',
          buttonText: 'Su ekle',
          buttonRoute: '/app/track',
          imageKey: 'smoothie',
          bgColor: '#E3F2F8',
        ),
        HomeHeroSlideConfig(
          id: 'recipe',
          title: 'Akşam için sıcak bir kase',
          description: 'Mercimek çorbası — protein hedefine nazik yaklaşım.',
          buttonText: 'Tarife bak',
          buttonRoute: '/app/recipes',
          imageKey: 'soup',
          bgColor: '#FFF0E8',
        ),
        HomeHeroSlideConfig(
          id: 'checkin',
          title: 'Haftalık check-in',
          description: 'Ruh hali, kilo ve uyumu birkaç dakikada paylaş.',
          buttonText: 'Check-in',
          buttonRoute: '/app/check-in',
          imageKey: 'bowl',
          bgColor: '#FFF8E8',
        ),
      ];
}

class HomeQuickActionConfig {
  const HomeQuickActionConfig({
    required this.id,
    required this.title,
    this.iconKey = 'scale',
    this.iconUrl = '',
    this.route = '/app',
  });

  final String id;
  final String title;
  final String iconKey;
  final String iconUrl;
  final String route;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'iconKey': iconKey,
        'iconUrl': iconUrl,
        'route': route,
      };

  factory HomeQuickActionConfig.fromMap(Map<String, dynamic> map) => HomeQuickActionConfig(
        id: map['id']?.toString() ?? '',
        title: map['title']?.toString() ?? '',
        iconKey: map['iconKey']?.toString() ?? 'scale',
        iconUrl: map['iconUrl']?.toString() ?? '',
        route: map['route']?.toString() ?? '/app',
      );
}

class HomeMealStatConfig {
  const HomeMealStatConfig({
    required this.type,
    required this.value,
    this.icon = '🔥',
  });

  final String type;
  final String value;
  final String icon;

  Map<String, dynamic> toMap() => {'type': type, 'value': value, 'icon': icon};

  factory HomeMealStatConfig.fromMap(Map<String, dynamic> map) => HomeMealStatConfig(
        type: map['type']?.toString() ?? '',
        value: map['value']?.toString() ?? '',
        icon: map['icon']?.toString() ?? '🔥',
      );
}

class HomeMealSuggestionConfig {
  const HomeMealSuggestionConfig({
    this.title = 'Mercimek çorbası',
    this.description = '',
    this.bgColor = '#FFE8D6',
    this.imageUrl = '',
    this.imageKey = 'soup',
    this.route = '/app/recipes',
    this.stats = const [],
  });

  final String title;
  final String description;
  final String bgColor;
  final String imageUrl;
  final String imageKey;
  final String route;
  final List<HomeMealStatConfig> stats;

  Color get background => parseHexColor(bgColor) ?? const Color(0xFFFFE8D6);

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'bgColor': bgColor,
        'imageUrl': imageUrl,
        'imageKey': imageKey,
        'route': route,
        'stats': stats.map((e) => e.toMap()).toList(),
      };

  factory HomeMealSuggestionConfig.fromMap(Map<String, dynamic> map) {
    final statsRaw = map['stats'];
    final stats = statsRaw is List
        ? statsRaw
            .whereType<Map>()
            .map((e) => HomeMealStatConfig.fromMap(Map<String, dynamic>.from(e)))
            .toList()
        : <HomeMealStatConfig>[];
    return HomeMealSuggestionConfig(
      title: map['title']?.toString() ?? 'Mercimek çorbası',
      description: map['description']?.toString() ?? '',
      bgColor: map['bgColor']?.toString() ?? '#FFE8D6',
      imageUrl: map['imageUrl']?.toString() ?? '',
      imageKey: map['imageKey']?.toString() ?? 'soup',
      route: map['route']?.toString() ?? '/app/recipes',
      stats: stats,
    );
  }
}

class HomeMiniCardConfig {
  const HomeMiniCardConfig({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.characterUrl = '',
    this.characterKey = 'lesson',
    this.bgColor = '#E8D9FF',
    this.progress = 0,
    this.progressColor = '#9B7EDE',
    this.route = '/app',
    this.actionLabel = '',
  });

  final String id;
  final String title;
  final String subtitle;
  final String characterUrl;
  final String characterKey;
  final String bgColor;
  final int progress;
  final String progressColor;
  final String route;
  final String actionLabel;

  Color get background => parseHexColor(bgColor) ?? const Color(0xFFE8D9FF);
  Color get barColor => parseHexColor(progressColor) ?? const Color(0xFF9B7EDE);

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'characterUrl': characterUrl,
        'characterKey': characterKey,
        'bgColor': bgColor,
        'progress': progress,
        'progressColor': progressColor,
        'route': route,
        'actionLabel': actionLabel,
      };

  factory HomeMiniCardConfig.fromMap(Map<String, dynamic> map) => HomeMiniCardConfig(
        id: map['id']?.toString() ?? '',
        title: map['title']?.toString() ?? '',
        subtitle: map['subtitle']?.toString() ?? '',
        characterUrl: map['characterUrl']?.toString() ?? '',
        characterKey: map['characterKey']?.toString() ?? 'lesson',
        bgColor: map['bgColor']?.toString() ?? '#E8D9FF',
        progress: map['progress'] is int ? map['progress'] as int : int.tryParse('${map['progress']}') ?? 0,
        progressColor: map['progressColor']?.toString() ?? '#9B7EDE',
        route: map['route']?.toString() ?? '/app',
        actionLabel: map['actionLabel']?.toString() ?? '',
      );
}

class HomeStatusChipConfig {
  const HomeStatusChipConfig({
    required this.id,
    required this.label,
    this.iconKey = 'fire',
    this.bgColor = '#FFE4CC',
  });

  final String id;
  final String label;
  final String iconKey;
  final String bgColor;

  Color get background => parseHexColor(bgColor) ?? const Color(0xFFFFE4CC);

  Map<String, dynamic> toMap() => {
        'id': id,
        'label': label,
        'iconKey': iconKey,
        'bgColor': bgColor,
      };

  factory HomeStatusChipConfig.fromMap(Map<String, dynamic> map) => HomeStatusChipConfig(
        id: map['id']?.toString() ?? '',
        label: map['label']?.toString() ?? '',
        iconKey: map['iconKey']?.toString() ?? 'fire',
        bgColor: map['bgColor']?.toString() ?? '#FFE4CC',
      );
}

class HomeSectionItemConfig {
  const HomeSectionItemConfig({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.price = '',
    this.duration = '',
    this.tag = '',
    this.imageUrl = '',
    this.imageKey = 'bowl',
    this.route = '/app',
  });

  final String id;
  final String title;
  final String subtitle;
  final String price;
  final String duration;
  final String tag;
  final String imageUrl;
  final String imageKey;
  final String route;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'price': price,
        'duration': duration,
        'tag': tag,
        'imageUrl': imageUrl,
        'imageKey': imageKey,
        'route': route,
      };

  factory HomeSectionItemConfig.fromMap(Map<String, dynamic> map) => HomeSectionItemConfig(
        id: map['id']?.toString() ?? '',
        title: map['title']?.toString() ?? '',
        subtitle: map['subtitle']?.toString() ?? '',
        price: map['price']?.toString() ?? '',
        duration: map['duration']?.toString() ?? '',
        tag: map['tag']?.toString() ?? '',
        imageUrl: map['imageUrl']?.toString() ?? '',
        imageKey: map['imageKey']?.toString() ?? 'bowl',
        route: map['route']?.toString() ?? '/app',
      );
}

class HomeSectionConfig {
  const HomeSectionConfig({
    required this.id,
    required this.title,
    this.seeAllLabel = 'Tümü >',
    this.seeAllRoute = '/app',
    this.items = const [],
  });

  final String id;
  final String title;
  final String seeAllLabel;
  final String seeAllRoute;
  final List<HomeSectionItemConfig> items;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'seeAllLabel': seeAllLabel,
        'seeAllRoute': seeAllRoute,
        'items': items.map((e) => e.toMap()).toList(),
      };

  factory HomeSectionConfig.fromMap(Map<String, dynamic> map) {
    final itemsRaw = map['items'];
    final items = itemsRaw is List
        ? itemsRaw
            .whereType<Map>()
            .map((e) => HomeSectionItemConfig.fromMap(Map<String, dynamic>.from(e)))
            .toList()
        : <HomeSectionItemConfig>[];
    return HomeSectionConfig(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      seeAllLabel: map['seeAllLabel']?.toString() ?? 'Tümü >',
      seeAllRoute: map['seeAllRoute']?.toString() ?? '/app',
      items: items,
    );
  }
}

class HomeTabConfig {
  const HomeTabConfig({
    required this.id,
    required this.title,
    this.iconKey = 'home',
    this.iconUrl = '',
    this.route = '/app',
  });

  final String id;
  final String title;
  final String iconKey;
  final String iconUrl;
  final String route;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'iconKey': iconKey,
        'iconUrl': iconUrl,
        'route': route,
      };

  factory HomeTabConfig.fromMap(Map<String, dynamic> map) => HomeTabConfig(
        id: map['id']?.toString() ?? '',
        title: map['title']?.toString() ?? '',
        iconKey: map['iconKey']?.toString() ?? 'home',
        iconUrl: map['iconUrl']?.toString() ?? '',
        route: map['route']?.toString() ?? '/app',
      );
}
