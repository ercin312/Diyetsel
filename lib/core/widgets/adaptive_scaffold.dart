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
import 'luxury_glyph.dart';
import 'modern_glyph.dart';

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
    if (context.isCartoon) {
      final asset = _cartoonNavAsset(navIndex);
      return AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? AppColors.kawaiiLeaf.withValues(alpha: 0.16) : Colors.transparent,
        ),
        child: asset != null
            ? Image.asset(
                asset,
                width: selected ? 28 : 26,
                height: selected ? 28 : 26,
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
    if (context.isLuxury) {
      final muted = Theme.of(context).colorScheme.onSurfaceVariant;
      final accent = AppColors.luxuryCopper;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: selected ? AppColors.luxuryPlate : Colors.transparent,
          border: Border.all(
            color: selected ? accent : AppColors.luxuryLine.withValues(alpha: 0.7),
            width: selected ? 1.2 : 0.9,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(color: accent.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 3)),
                ]
              : null,
        ),
        child: Icon(
          dest.kind.materialIcon,
          size: 20,
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
    final desktop = context.isDesktopLayout;
    final cartoon = context.isCartoon;
    final luxury = context.isLuxury;
    final selected = navigationShell.currentIndex.clamp(0, dest.length - 1);
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
        body: Row(
          children: [
            _DesktopSidebar(
              destinations: dest,
              selectedIndex: selected,
              extended: extended,
              cartoon: cartoon,
              luxury: luxury,
              onSelect: selectTab,
            ),
            VerticalDivider(
              width: 1,
              thickness: luxury ? 0.8 : 1,
              color: luxury
                  ? AppColors.luxuryCopper.withValues(alpha: 0.45)
                  : scheme.outlineVariant.withValues(alpha: 0.9),
            ),
            Expanded(child: body),
          ],
        ),
      );
    } else if (cartoon) {
      // Floating-style bar with in-row center + (no Scaffold FAB — avoids tap stealing)
      final mid = dest.length ~/ 2;

      scaffold = Scaffold(
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
                border: Border.all(color: AppColors.kawaiiOutline),
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
                                  color: AppColors.kawaiiLeaf,
                                  shape: const CircleBorder(),
                                  elevation: 4,
                                  shadowColor: AppColors.kawaiiLeaf.withValues(alpha: 0.4),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: () => selectTab(mid),
                                    child: SizedBox(
                                      width: 56,
                                      height: 56,
                                      child: Center(
                                        child: Image.asset(
                                          DiyetselAssets.iconNavPlus,
                                          width: 30,
                                          height: 30,
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
                                  Text(
                                    dest[i].label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: i == selected ? FontWeight.w800 : FontWeight.w600,
                                      color: i == selected
                                          ? AppColors.kawaiiLeaf
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
    } else if (luxury) {
      scaffold = Scaffold(
        body: body,
        bottomNavigationBar: Material(
          color: scheme.surface,
          elevation: 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.luxuryCopper.withValues(alpha: 0.5), width: 0.9),
              ),
              color: AppColors.luxuryPlate,
            ),
            child: SafeArea(
              top: false,
              child: NavigationBar(
                selectedIndex: selected,
                onDestinationSelected: selectTab,
                destinations: [
                  for (var i = 0; i < dest.length; i++)
                    NavigationDestination(
                      icon: _mobileGlyph(context, dest[i], selected: false),
                      selectedIcon: _mobileGlyph(context, dest[i], selected: true),
                      label: dest[i].label,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      // Soft wellness: in-row center + (no Scaffold FAB — avoids tap stealing)
      final mid = dest.length ~/ 2;

      scaffold = Scaffold(
        body: body,
        bottomNavigationBar: Material(
          color: scheme.surface,
          elevation: 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: scheme.outline.withValues(alpha: 0.55))),
              boxShadow: const [
                BoxShadow(color: AppColors.modernSoftShadow, blurRadius: 16, offset: Offset(0, -4)),
              ],
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
                              offset: const Offset(0, -12),
                              child: Material(
                                color: AppColors.primaryDeep,
                                shape: const CircleBorder(),
                                elevation: 4,
                                shadowColor: AppColors.primary.withValues(alpha: 0.4),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: () => selectTab(mid),
                                  child: const SizedBox(
                                    width: 56,
                                    height: 56,
                                    child: Icon(Icons.add_rounded, color: Colors.white, size: 28),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: InkWell(
                            onTap: () => selectTab(i),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _mobileGlyph(context, dest[i], selected: i == selected),
                                const SizedBox(height: 2),
                                Text(
                                  dest[i].label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: i == selected ? FontWeight.w700 : FontWeight.w500,
                                    color: i == selected
                                        ? AppColors.primary
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
      );
    }

    return CallbackShortcuts(
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
    );
  }
}

/// Fluent-inspired navigation pane for Windows / wide desktop.
class _DesktopSidebar extends StatelessWidget {
  const _DesktopSidebar({
    required this.destinations,
    required this.selectedIndex,
    required this.extended,
    required this.cartoon,
    required this.luxury,
    required this.onSelect,
  });

  final List<NavDest> destinations;
  final int selectedIndex;
  final bool extended;
  final bool cartoon;
  final bool luxury;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final width = extended ? 248.0 : 72.0;
    final pane = cartoon
        ? AppColors.kawaiiBubble
        : luxury
            ? AppColors.luxuryCanvas
            : AppColors.lightBg;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark
        ? (luxury ? AppColors.luxuryPlate : scheme.surfaceContainerLowest)
        : pane;
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
                  Icon(
                    Icons.eco_rounded,
                    size: luxury ? 20 : 22,
                    color: brand,
                  ),
                  if (extended) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Diyetsel',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: luxury ? FontWeight.w600 : FontWeight.w700,
                              color: brand,
                              letterSpacing: luxury ? 0.6 : -0.4,
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
                child: Text(
                  luxury ? 'ATÖLYE' : (cartoon ? 'Sevimli menü' : 'Menü'),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: cartoon ? AppColors.kawaiiInk.withValues(alpha: 0.65) : scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: luxury ? 1.4 : 0.4,
                      ),
                ),
              ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: destinations.length,
                itemBuilder: (context, i) {
                  final d = destinations[i];
                  final selected = i == selectedIndex;
                  final accent = cartoon
                      ? AppColors.kawaiiLeaf
                      : luxury
                          ? LuxuryPalette.accent(d.kind)
                          : ModernPalette.accent(d.kind);
                  return Padding(
                    padding: EdgeInsets.only(bottom: cartoon ? 4 : 2),
                    child: Material(
                      color: selected
                          ? (cartoon
                              ? AppColors.kawaiiLeaf.withValues(alpha: 0.14)
                              : accent.withValues(alpha: luxury ? 0.12 : 0.12))
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(cartoon ? 16 : (luxury ? 10 : 10)),
                      child: InkWell(
                        onTap: () => onSelect(i),
                        borderRadius: BorderRadius.circular(cartoon ? 16 : (luxury ? 10 : 10)),
                        hoverColor: scheme.onSurface.withValues(alpha: 0.05),
                        child: DecoratedBox(
                          decoration: selected && luxury
                              ? BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.luxuryCopper.withValues(alpha: 0.55),
                                    width: 0.8,
                                  ),
                                )
                              : const BoxDecoration(),
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
                                            size: luxury ? 18 : 20,
                                            color: selected ? accent : scheme.onSurfaceVariant,
                                          ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            d.label,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: luxury ? 13 : (cartoon ? 14 : 13.5),
                                              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                              color: cartoon
                                                  ? (selected ? AppColors.kawaiiLeaf : AppColors.kawaiiInk)
                                                  : (selected ? scheme.onSurface : scheme.onSurfaceVariant),
                                              letterSpacing: luxury ? 0.3 : -0.1,
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
                                              size: luxury ? 18 : 20,
                                              color: selected ? accent : scheme.onSurfaceVariant,
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
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
              child: Text(
                extended ? 'Ctrl+K · Ctrl+N · Ctrl+B' : '⌘',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                      fontSize: 10,
                      letterSpacing: luxury ? 0.6 : 0,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
