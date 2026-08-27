import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';
import '../models/enums.dart';
import '../utils/desktop.dart';
import 'kawaii_doodle.dart';
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

  Widget _mobileGlyph(BuildContext context, NavDest dest, {required bool selected}) {
    if (!context.isCartoon) {
      final muted = Theme.of(context).colorScheme.onSurfaceVariant;
      final accent = ModernPalette.accent(dest.kind);
      return AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 48,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: selected ? accent.withValues(alpha: 0.16) : Colors.transparent,
        ),
        child: Icon(
          dest.kind.materialIcon,
          size: 24,
          color: selected ? accent : muted,
        ),
      );
    }
    return KawaiiTile(kind: dest.kind, size: selected ? 46 : 40, selected: selected);
  }

  @override
  Widget build(BuildContext context) {
    final dest = role == UserRole.admin ? adminDestinations() : clientDestinations();
    final desktop = context.isDesktopLayout;
    final cartoon = context.isCartoon;
    final selected = navigationShell.currentIndex.clamp(0, dest.length - 1);
    final body = KeyedSubtree(
      key: ValueKey(navigationShell.currentIndex),
      child: navigationShell,
    );
    final scheme = Theme.of(context).colorScheme;

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
              onSelect: navigationShell.goBranch,
            ),
            VerticalDivider(width: 1, thickness: 1, color: scheme.outlineVariant.withValues(alpha: 0.9)),
            Expanded(child: body),
          ],
        ),
      );
    } else if (cartoon) {
      scaffold = Scaffold(
        body: body,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(28)),
              boxShadow: [BoxShadow(color: AppColors.kawaiiShadow, blurRadius: 18, offset: Offset(0, 8))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: NavigationBar(
                selectedIndex: selected,
                onDestinationSelected: navigationShell.goBranch,
                destinations: [
                  for (var i = 0; i < dest.length; i++)
                    NavigationDestination(
                      icon: _mobileGlyph(context, dest[i], selected: i == selected),
                      label: dest[i].label,
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      scaffold = Scaffold(
        body: body,
        bottomNavigationBar: Material(
          color: scheme.surface,
          elevation: 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: scheme.outline.withValues(alpha: 0.8))),
            ),
            child: SafeArea(
              top: false,
              child: NavigationBar(
                selectedIndex: selected,
                onDestinationSelected: navigationShell.goBranch,
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
    required this.onSelect,
  });

  final List<NavDest> destinations;
  final int selectedIndex;
  final bool extended;
  final bool cartoon;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final width = extended ? 248.0 : 72.0;
    final pane = cartoon ? const Color(0xFFFFFBF5) : const Color(0xFFF3F2F1);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? scheme.surfaceContainerLowest : pane;

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
                    size: 22,
                    color: AppColors.primary,
                  ),
                  if (extended) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Diyetsel',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
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
                child: Text(
                  'Menü',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
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
                  final accent = cartoon ? AppColors.primary : ModernPalette.accent(d.kind);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Material(
                      color: selected ? accent.withValues(alpha: 0.14) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () => onSelect(i),
                        borderRadius: BorderRadius.circular(8),
                        hoverColor: scheme.onSurface.withValues(alpha: 0.05),
                        child: extended
                            ? SizedBox(
                                height: 40,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Row(
                                    children: [
                                      Icon(
                                        d.kind.materialIcon,
                                        size: 20,
                                        color: selected ? accent : scheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          d.label,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                                            color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
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
                                  height: 40,
                                  child: Center(
                                    child: Icon(
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
              child: Text(
                extended ? 'Ctrl+K · Ctrl+N · Ctrl+B' : '⌘',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                      fontSize: 10,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
