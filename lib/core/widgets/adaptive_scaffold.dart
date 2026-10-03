import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';
import '../../app/theme/app_spacing.dart';
import '../constants/diyetsel_assets.dart';
import '../models/enums.dart';
import '../utils/desktop.dart';
import 'kawaii_doodle.dart';
import 'modern_glyph.dart';
import '../l10n/ui_string.dart';

class NavDest {
  const NavDest({
    required this.label,
    required this.icon,
    required this.emoji,
    required this.location,
    required this.kind,
  });
  final String label;
  final IconData icon;
  final String emoji;
  final String location;
  final KawaiiKind kind;
}

List<NavDest> adminDestinations() => [
      NavDest(label: 'nav.dashboard'.tr(), icon: Icons.space_dashboard_rounded, emoji: '📊', location: '/admin', kind: KawaiiKind.chart),
      NavDest(label: 'nav.calendar'.tr(), icon: Icons.calendar_month_rounded, emoji: '📅', location: '/admin/appointments', kind: KawaiiKind.calendar),
      NavDest(label: 'nav.clients'.tr(), icon: Icons.groups_rounded, emoji: '👥', location: '/admin/clients', kind: KawaiiKind.people),
      NavDest(label: 'nav.chat'.tr(), icon: Icons.chat_bubble_rounded, emoji: '💬', location: '/admin/chat', kind: KawaiiKind.chat),
      NavDest(label: 'nav.more'.tr(), icon: Icons.grid_view_rounded, emoji: '✨', location: '/admin/more', kind: KawaiiKind.sparkle),
    ];

List<NavDest> adminToolDestinations() => const [
      NavDest(label: 'Akademi', icon: Icons.article_rounded, emoji: '📰', location: '/admin/blog', kind: KawaiiKind.blog),
      NavDest(label: 'Hizmetler', icon: Icons.medical_services_rounded, emoji: '🎁', location: '/admin/services', kind: KawaiiKind.gift),
      NavDest(label: 'Tarifler', icon: Icons.menu_book_rounded, emoji: '🍲', location: '/admin/recipes', kind: KawaiiKind.recipe),
      NavDest(label: 'Diyet planları', icon: Icons.restaurant_rounded, emoji: '🥗', location: '/admin/diet-plans', kind: KawaiiKind.diet),
      NavDest(label: 'Öğün günlüğü', icon: Icons.photo_camera_rounded, emoji: '📷', location: '/admin/meals', kind: KawaiiKind.camera),
      NavDest(label: 'Bildirimler', icon: Icons.notifications_active_rounded, emoji: '🔔', location: '/admin/notifications', kind: KawaiiKind.sparkle),
      NavDest(label: 'Ayarlar', icon: Icons.settings_rounded, emoji: '⚙️', location: '/admin/settings', kind: KawaiiKind.settings),
    ];

List<NavDest> clientDestinations() => [
      NavDest(label: 'nav.home'.tr(), icon: Icons.home_rounded, emoji: '🏠', location: '/app', kind: KawaiiKind.home),
      NavDest(label: 'nav.diet'.tr(), icon: Icons.restaurant_rounded, emoji: '🥗', location: '/app/diet', kind: KawaiiKind.diet),
      NavDest(label: 'nav.track'.tr(), icon: Icons.water_drop_rounded, emoji: '💧', location: '/app/track', kind: KawaiiKind.water),
      NavDest(label: 'nav.calendar'.tr(), icon: Icons.event_available_rounded, emoji: '📅', location: '/app/appointments', kind: KawaiiKind.calendar),
      NavDest(label: 'nav.more'.tr(), icon: Icons.grid_view_rounded, emoji: '✨', location: '/app/more', kind: KawaiiKind.sparkle),
    ];

class AdaptiveScaffold extends StatelessWidget {
  const AdaptiveScaffold({
    super.key,
    required this.navigationShell,
    required this.role,
  });

  final StatefulNavigationShell navigationShell;
  final UserRole role;

  Widget _mobileGlyph(BuildContext context, NavDest dest, {required bool selected, int? navIndex}) {
    // Cartoon: colorful sticker PNGs (never tint — tint ruins them)
    if (context.isCartoon) {
      final asset = _cartoonNavAsset(navIndex);
      return AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? AppColors.kawaiiLeaf.withValues(alpha: 0.14) : Colors.transparent,
        ),
        child: asset != null
            ? Image.asset(
                asset,
                width: 32,
                height: 32,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, _, _) => Icon(
                  dest.icon,
                  size: selected ? 24 : 22,
                  color: selected ? AppColors.kawaiiLeaf : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              )
            : Icon(
                dest.icon,
                size: selected ? 24 : 22,
                color: selected ? AppColors.kawaiiLeaf : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
      );
    }
    // Modern: clean Material line icons (no PNG on nav)
    if (context.isModern) {
      final accent = AppColors.primary;
      final muted = Theme.of(context).colorScheme.onSurfaceVariant;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? accent.withValues(alpha: 0.12) : Colors.transparent,
        ),
        child: Icon(
          dest.icon,
          size: selected ? 24 : 22,
          color: selected ? accent : muted,
        ),
      );
    }
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final accent = ModernPalette.accent(dest.kind);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 44,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: selected ? accent.withValues(alpha: 0.12) : Colors.transparent,
      ),
      child: Icon(
        dest.kind.materialIcon,
        size: 22,
        color: selected ? AppColors.primary : muted,
      ),
    );
  }

  static String? _cartoonNavAsset(int? index) {
    if (index == null) return null;
    return switch (index) {
      0 => DiyetselAssets.iconNavHome,
      1 => DiyetselAssets.iconNavApple,
      3 => DiyetselAssets.iconNavCalendar,
      4 => DiyetselAssets.iconNavProfile,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final dest = role == UserRole.admin ? adminDestinations() : clientDestinations();
    final tools = role == UserRole.admin && isDesktopOs ? adminToolDestinations() : const <NavDest>[];
    final desktop = context.isDesktopLayout;
    final cartoon = context.isCartoon;
    final modern = context.isModern;
    final path = GoRouterState.of(context).uri.path;
    final exact = dest.indexWhere((d) => d.location == path);
    final selected = exact >= 0 ? exact : (tools.any((d) => d.location == path) ? -1 : navigationShell.currentIndex);
    final body = KeyedSubtree(
      key: ValueKey(navigationShell.currentIndex),
      child: navigationShell,
    );
    final scheme = Theme.of(context).colorScheme;

    void selectTab(int i) {
      final loc = dest[i].location;
      if (navigationShell.currentIndex == i) {
        navigationShell.goBranch(i, initialLocation: true);
      } else {
        context.go(loc);
      }
    }

    Widget scaffold;
    if (desktop) {
      final extended = context.isExtraWide || isWindowsDesktop;
      scaffold = Scaffold(
        backgroundColor: modern ? AppColors.modernWash : null,
        body: Row(
          children: [
            _DesktopSidebar(
              destinations: dest,
              tools: tools,
              selectedIndex: selected,
              extended: extended,
              cartoon: cartoon,
              modern: modern,
              onSelect: selectTab,
            ),
            if (!modern)
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: scheme.outlineVariant.withValues(alpha: 0.9),
              ),
            Expanded(child: body),
          ],
        ),
      );
    } else {
      // Soft premium floating bar (cartoon + modern cream wellness)
      final mid = dest.length ~/ 2;
      final softModern = !cartoon;

      scaffold = Scaffold(
        backgroundColor: softModern ? AppColors.modernWash : null,
        body: body,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          child: Material(
            color: Colors.transparent,
            elevation: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusNav),
                border: Border.all(color: softModern ? AppColors.modernLine : AppColors.kawaiiOutline),
                boxShadow: AppSpacing.nav,
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 68,
                  child: Row(
                    children: [
                      for (var i = 0; i < dest.length; i++)
                        if (i == mid)
                          Expanded(
                            child: Center(
                              child: Transform.translate(
                                offset: const Offset(0, -14),
                                child: Material(
                                  color: softModern ? AppColors.primary : AppColors.kawaiiLeaf,
                                  shape: const CircleBorder(),
                                  elevation: 4,
                                  shadowColor: (softModern ? AppColors.primary : AppColors.kawaiiLeaf)
                                      .withValues(alpha: 0.4),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: () => selectTab(mid),
                                    child: SizedBox(
                                      width: 56,
                                      height: 56,
                                      child: Center(
                                        child: softModern
                                            ? const Icon(Icons.add_rounded, color: Colors.white, size: 30)
                                            : Image.asset(
                                                DiyetselAssets.iconNavPlus,
                                                width: 34,
                                                height: 34,
                                                fit: BoxFit.contain,
                                                filterQuality: FilterQuality.high,
                                                errorBuilder: (_, _, _) =>
                                                    const Icon(Icons.add_rounded, color: Colors.white, size: 30),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () => selectTab(i),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedScale(
                                    scale: i == selected ? 1.08 : 1,
                                    duration: const Duration(milliseconds: 180),
                                    child: _mobileGlyph(context, dest[i], selected: i == selected, navIndex: i),
                                  ),
                                  const SizedBox(height: 2),
                                  Text((dest[i].label).ui,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: i == selected ? FontWeight.w800 : FontWeight.w600,
                                      color: i == selected
                                          ? (softModern ? AppColors.primary : AppColors.kawaiiLeaf)
                                          : scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final router = GoRouter.of(context);
        if (router.canPop()) {
          router.pop();
          return;
        }
        if (navigationShell.currentIndex != 0) {
          navigationShell.goBranch(0);
        }
      },
      child: CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () {
          context.push(role == UserRole.admin ? '/admin/clients' : '/app/more');
        },
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): () {
          context.go(role == UserRole.admin ? '/admin/appointments' : '/app/appointments');
        },
        const SingleActivator(LogicalKeyboardKey.keyB, control: true): () {
          context.push(role == UserRole.admin ? '/admin/blog' : '/app/blog');
        },
      },
      child: Focus(autofocus: true, child: scaffold),
    ),
    );
  }
}

/// Fluent-inspired navigation pane for Windows / wide desktop.
class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({
    required this.destinations,
    required this.tools,
    required this.selectedIndex,
    required this.extended,
    required this.cartoon,
    required this.modern,
    required this.onSelect,
  });

  final List<NavDest> destinations;
  final List<NavDest> tools;
  final int selectedIndex;
  final bool extended;
  final bool cartoon;
  final bool modern;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    if (modern) {
      return _SoftDesktopSidebar(
        destinations: destinations,
        tools: tools,
        selectedIndex: selectedIndex,
        extended: extended,
        onSelect: onSelect,
      );
    }

    final scheme = Theme.of(context).colorScheme;
    final width = extended ? 248.0 : 72.0;
    final pane = cartoon ? AppColors.kawaiiBubble : AppColors.lightBg;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? scheme.surfaceContainerLowest : pane;
    final brand = context.brandPrimary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: width,
      color: bg,
      child: SafeArea(
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(extended ? 16 : 12, 16, extended ? 16 : 12, 12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      DiyetselAssets.logo,
                      width: 28,
                      height: 28,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(Icons.eco_rounded, size: 22, color: brand),
                    ),
                  ),
                  if (extended) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(('e-Diyet').ui,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: brand,
                              letterSpacing: -0.4,
                            ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (extended)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text((cartoon ? 'Sevimli menü' : 'Menü').ui,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: cartoon ? AppColors.kawaiiInk.withValues(alpha: 0.65) : scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                ),
              ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: destinations.length + tools.length,
                itemBuilder: (context, i) {
                  if (i >= destinations.length) {
                    return _ToolTile(
                      dest: tools[i - destinations.length],
                      extended: extended,
                      cartoon: cartoon,
                      modern: false,
                    );
                  }
                  final d = destinations[i];
                  final selected = i == selectedIndex;
                  final accent = cartoon ? AppColors.kawaiiLeaf : ModernPalette.accent(d.kind);
                  return Padding(
                    padding: EdgeInsets.only(bottom: cartoon ? 4 : 2),
                    child: Material(
                      color: selected
                          ? (cartoon
                              ? AppColors.kawaiiLeaf.withValues(alpha: 0.14)
                              : accent.withValues(alpha: 0.12))
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(cartoon ? 16 : 10),
                      child: InkWell(
                        onTap: () => onSelect(i),
                        borderRadius: BorderRadius.circular(cartoon ? 16 : 10),
                        hoverColor: scheme.onSurface.withValues(alpha: 0.05),
                        child: extended
                            ? SizedBox(
                                height: cartoon ? 44 : 40,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Row(
                                    children: [
                                      if (cartoon)
                                        KawaiiDoodle(kind: d.kind, size: 22)
                                      else
                                        Icon(
                                          d.kind.materialIcon,
                                          size: 20,
                                          color: selected ? accent : scheme.onSurfaceVariant,
                                        ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text((d.label).ui,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: cartoon ? 14 : 13.5,
                                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                            color: cartoon
                                                ? (selected ? AppColors.kawaiiLeaf : AppColors.kawaiiInk)
                                                : (selected ? scheme.onSurface : scheme.onSurfaceVariant),
                                            letterSpacing: -0.1,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Tooltip(
                                message: d.label,
                                waitDuration: const Duration(milliseconds: 400),
                                child: SizedBox(
                                  height: cartoon ? 44 : 40,
                                  child: Center(
                                    child: cartoon
                                        ? KawaiiDoodle(kind: d.kind, size: 22)
                                        : Icon(
                                            d.kind.materialIcon,
                                            size: 20,
                                            color: selected ? accent : scheme.onSurfaceVariant,
                                          ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
              child: Text((extended ? 'Ctrl+K · Ctrl+N · Ctrl+B' : '⌘').ui,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                      fontSize: 10,
                      letterSpacing: 0,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Soft premium modern desktop sidebar — cream wash, teal selection.
class _SoftDesktopSidebar extends StatelessWidget {
  const _SoftDesktopSidebar({
    required this.destinations,
    required this.tools,
    required this.selectedIndex,
    required this.extended,
    required this.onSelect,
  });

  final List<NavDest> destinations;
  final List<NavDest> tools;
  final int selectedIndex;
  final bool extended;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final width = extended ? 256.0 : 76.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: AppColors.modernLine.withValues(alpha: 0.9)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: ColoredBox(
        color: AppColors.modernWash.withValues(alpha: 0.45),
        child: SafeArea(
          right: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(extended ? 18 : 12, 18, extended ? 18 : 12, 10),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.modernLine),
                        boxShadow: AppSpacing.soft,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        DiyetselAssets.logo,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const ColoredBox(
                          color: Colors.white,
                          child: Icon(
                            Icons.eco_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    if (extended) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(('e-Diyet').ui,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                                color: AppColors.primaryDeep,
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(('Klinik paneli').ui,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Color(0x991A4F45),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (extended)
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 4, 20, 10),
                  child: Text(('Menü').ui,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      letterSpacing: 0.6,
                      color: Color(0x991A4F45),
                    ),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: destinations.length + tools.length,
                  itemBuilder: (context, i) {
                    if (i >= destinations.length) {
                      return _ToolTile(
                        dest: tools[i - destinations.length],
                        extended: extended,
                        cartoon: false,
                        modern: true,
                      );
                    }
                    final d = destinations[i];
                    final selected = i == selectedIndex;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Material(
                        color: selected
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () => onSelect(i),
                          borderRadius: BorderRadius.circular(16),
                          hoverColor: AppColors.primary.withValues(alpha: 0.06),
                          child: extended
                              ? SizedBox(
                                  height: 48,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: selected
                                                ? AppColors.primary.withValues(alpha: 0.14)
                                                : Colors.white,
                                            border: Border.all(
                                              color: selected
                                                  ? AppColors.primary.withValues(alpha: 0.2)
                                                  : AppColors.modernLine,
                                            ),
                                          ),
                                          child: Icon(
                                            d.icon,
                                            size: 18,
                                            color: selected
                                                ? AppColors.primary
                                                : AppColors.primary.withValues(alpha: 0.55),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text((d.label).ui,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                                              color: selected
                                                  ? AppColors.primaryDeep
                                                  : AppColors.primary.withValues(alpha: 0.7),
                                              letterSpacing: -0.15,
                                            ),
                                          ),
                                        ),
                                        if (selected)
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                )
                              : Tooltip(
                                  message: d.label,
                                  waitDuration: const Duration(milliseconds: 350),
                                  child: SizedBox(
                                    height: 52,
                                    child: Center(
                                      child: Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: selected
                                              ? AppColors.primary.withValues(alpha: 0.14)
                                              : Colors.transparent,
                                        ),
                                        child: Icon(
                                          d.icon,
                                          size: 22,
                                          color: selected
                                              ? AppColors.primary
                                              : AppColors.primary.withValues(alpha: 0.55),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: extended ? 12 : 6,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.modernLine),
                  ),
                  child: Text((extended ? 'Ctrl+K · Ctrl+N · Ctrl+B' : '⌘').ui,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                      color: AppColors.primary.withValues(alpha: 0.45),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({
    required this.dest,
    required this.extended,
    required this.cartoon,
    required this.modern,
  });

  final NavDest dest;
  final bool extended;
  final bool cartoon;
  final bool modern;

  @override
  Widget build(BuildContext context) {
    final selected = GoRouterState.of(context).uri.path == dest.location;
    final accent = cartoon ? AppColors.kawaiiLeaf : AppColors.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected ? accent.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(modern ? 16 : 12),
        child: InkWell(
          onTap: () => context.go(dest.location),
          borderRadius: BorderRadius.circular(modern ? 16 : 12),
          child: SizedBox(
            height: extended ? 44 : 40,
            child: extended
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Icon(dest.icon, size: 18, color: selected ? accent : accent.withValues(alpha: 0.55)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text((dest.label).ui,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                              fontSize: 13.5,
                              color: cartoon ? AppColors.kawaiiInk : AppColors.primaryDeep,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Tooltip(
                    message: dest.label.ui,
                    child: Center(
                      child: Icon(dest.icon, size: 18, color: selected ? accent : accent.withValues(alpha: 0.55)),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
