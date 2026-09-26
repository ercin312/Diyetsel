import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';
import 'kawaii_doodle.dart';
import 'modern_glyph.dart';
import 'style_icon.dart';
import '../l10n/ui_string.dart';

class StoryPageData {
  const StoryPageData({
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.colors,
    this.detail,
    this.ctaLabel,
    this.ctaRoute,
  });

  final String title;
  final String subtitle;
  final String? detail;
  final KawaiiKind kind;
  final List<Color> colors;
  final String? ctaLabel;
  final String? ctaRoute;
}

class StoryBundle {
  const StoryBundle({
    required this.id,
    required this.label,
    required this.kind,
    this.isMine = false,
    this.pages = const [],
    this.createRoute,
  });

  final String id;
  final String label;
  final KawaiiKind kind;
  final bool isMine;
  final List<StoryPageData> pages;
  final String? createRoute;
}

class StoryRail extends StatelessWidget {
  const StoryRail({
    super.key,
    required this.items,
    required this.seenIds,
    required this.onSeen,
  });

  final List<StoryBundle> items;
  final Set<String> seenIds;
  final ValueChanged<String> onSeen;

  @override
  Widget build(BuildContext context) {
    final modern = context.isModern;
    return SizedBox(
      height: modern ? 120 : 114,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (context, index) => SizedBox(width: modern ? 14 : 12),
        itemBuilder: (context, i) {
          final item = items[i];
          final seen = seenIds.contains(item.id) && !item.isMine;
          return _StoryAvatar(
            item: item,
            seen: seen,
            onTap: () {
              if (item.isMine) {
                context.push(item.createRoute ?? '/app/story');
                return;
              }
              onSeen(item.id);
              final watchable = items.where((s) => !s.isMine && s.pages.isNotEmpty).toList();
              StoryViewer.open(
                context,
                items: watchable,
                initialId: item.id,
                onSeen: onSeen);
            });
        }));
  }
}

class _StoryAvatar extends StatelessWidget {
  const _StoryAvatar({required this.item, required this.seen, required this.onTap});

  final StoryBundle item;
  final bool seen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cartoon = context.isCartoon;
    final modern = context.isModern;
    final brand = context.brandPrimary;
    final List<Color> ring;
    if (item.isMine) {
      ring = cartoon
              ? [AppColors.kawaiiCoral, AppColors.kawaiiMint, AppColors.kawaiiSky]
              : [AppColors.primary, AppColors.modernSage, AppColors.primaryBright];
    } else if (seen) {
      ring = cartoon
              ? const [AppColors.kawaiiOutline, AppColors.kawaiiSage]
              : const [AppColors.modernLine, AppColors.modernSageSoft];
    }  else if (cartoon) {
      ring = const [
        AppColors.kawaiiRose,
        AppColors.kawaiiMint,
        AppColors.kawaiiSky,
        AppColors.kawaiiLilac,
      ];
    } else {
      ring = const [
        AppColors.primary,
        AppColors.modernSage,
        AppColors.primaryBright,
        AppColors.modernSageSoft,
      ];
    }

    Widget tile;
    if (cartoon) {
      tile = KawaiiTile(kind: item.kind, size: 54);
    }  else {
      tile = ModernIconTile(kind: item.kind, color: ModernPalette.accent(item.kind), size: 54);
    }

    final ringPad = modern ? 2.2 : (cartoon ? 3.5 : 3.0);
    final innerPad = modern ? 2.2 : (cartoon ? 3.5 : 3.0);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: EdgeInsets.all(ringPad),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(colors: [...ring, ring.first]),
                    border: cartoon
                        ? Border.all(color: AppColors.kawaiiOutline.withValues(alpha: 0.25), width: 1)
                        : null),
                  child: Container(
                    padding: EdgeInsets.all(innerPad),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cartoon ? AppColors.kawaiiBubble : Theme.of(context).colorScheme.surface,
                      border: cartoon
                          ? Border.all(color: AppColors.kawaiiOutline.withValues(alpha: 0.3), width: 1)
                          : null),
                    child: ClipOval(child: tile))),
                if (item.isMine)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: brand,
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).colorScheme.surface, width: 2)),
                      child: cartoon
                          ? const KawaiiDoodle(kind: KawaiiKind.sparkle, size: 14)
                          : Icon(
                              Icons.add_rounded,
                              size: 14,
                              color: Colors.white))),
              ]),
            const SizedBox(height: 6),
            Text((item.label).ui,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: (modern ? FontWeight.w600 : FontWeight.w800),
                letterSpacing: null,
                color: seen ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55) : null)),
          ])));
  }
}

class StoryViewer extends StatefulWidget {
  const StoryViewer({
    super.key,
    required this.items,
    required this.initialIndex,
    required this.onSeen,
  });

  final List<StoryBundle> items;
  final int initialIndex;
  final ValueChanged<String> onSeen;

  static Future<void> open(
    BuildContext context, {
    required List<StoryBundle> items,
    required String initialId,
    required ValueChanged<String> onSeen,
  }) {
    if (items.isEmpty) return Future.value();
    final index = items.indexWhere((s) => s.id == initialId);
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: true,
        pageBuilder: (context, animation, secondaryAnimation) => StoryViewer(
          items: items,
          initialIndex: index < 0 ? 0 : index,
          onSeen: onSeen),
        transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child)));
  }

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> with SingleTickerProviderStateMixin {
  late final PageController _bundles;
  late final AnimationController _progress;
  late int _index;
  int _page = 0;

  StoryBundle get _current => widget.items[_index];
  List<StoryPageData> get _pages => _current.pages;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.items.length - 1);
    _bundles = PageController(initialPage: _index);
    _progress = AnimationController(vsync: this, duration: const Duration(seconds: 5))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _next();
      });
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    _progress.dispose();
    _bundles.dispose();
    super.dispose();
  }

  void _start() {
    widget.onSeen(_current.id);
    _progress.forward(from: 0);
  }

  void _goBundle(int i) {
    if (i < 0 || i >= widget.items.length) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _index = i;
      _page = 0;
    });
    _bundles.jumpToPage(i);
    _start();
  }

  void _next() {
    if (_page < _pages.length - 1) {
      setState(() => _page += 1);
      _start();
      return;
    }
    _goBundle(_index + 1);
  }

  void _prev() {
    if (_page > 0) {
      setState(() => _page -= 1);
      _start();
      return;
    }
    _goBundle(_index - 1);
  }

  List<Color> _pageColors(StoryPageData page) => page.colors;

  @override
  Widget build(BuildContext context) {
    final cartoon = context.isCartoon;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTapUp: (d) {
            final w = MediaQuery.sizeOf(context).width;
            if (d.globalPosition.dx < w * 0.32) {
              _prev();
            } else {
              _next();
            }
          },
          onLongPressStart: (_) => _progress.stop(),
          onLongPressEnd: (_) => _progress.forward(),
          onVerticalDragEnd: (d) {
            if ((d.primaryVelocity ?? 0) > 280) Navigator.pop(context);
          },
          child: PageView.builder(
            controller: _bundles,
            onPageChanged: (i) {
              setState(() {
                _index = i;
                _page = 0;
              });
              _start();
            },
            itemCount: widget.items.length,
            itemBuilder: (context, i) {
              final bundle = widget.items[i];
              final page = bundle.pages[i == _index ? _page.clamp(0, bundle.pages.length - 1) : 0];
              final colors = _pageColors(page);
              return Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: colors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight))),
                  if (cartoon)
                    const Positioned(
                      top: 88,
                      right: -18,
                      child: KawaiiDoodle(kind: KawaiiKind.sparkle, size: 72)),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              for (var p = 0; p < bundle.pages.length; p++)
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2),
                                    child: AnimatedBuilder(
                                      animation: _progress,
                                      builder: (context, child) {
                                        final v = i != _index
                                            ? 0.0
                                            : p < _page
                                                ? 1.0
                                                : p == _page
                                                    ? _progress.value
                                                    : 0.0;
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            (cartoon ? 8 : 6)),
                                          child: LinearProgressIndicator(
                                            value: v,
                                            minHeight: (cartoon ? 4 : 3.5),
                                            backgroundColor: Colors.white24,
                                            color: cartoon
                                                    ? AppColors.kawaiiLemon
                                                    : Colors.white));
                                      }))),
                            ]),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              if (cartoon)
                                KawaiiTile(kind: bundle.kind, size: 42)
                              else
                                ModernIconTile(kind: bundle.kind, color: Colors.white, size: 42, inverted: true),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text((bundle.label).ui,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    letterSpacing: null))),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close_rounded, color: Colors.white)),
                            ]),
                          const Spacer(),
                          Center(
                            child: cartoon
                                ? KawaiiTile(kind: page.kind, size: 120)
                                : ModernIconTile(kind: page.kind, color: Colors.white, size: 96, inverted: true)),
                          const SizedBox(height: 28),
                          Text((page.title).ui,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 32,
                              height: 1.1,
                              letterSpacing: null)),
                          const SizedBox(height: 8),
                          Text((page.subtitle).ui,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.92),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                              letterSpacing: null)),
                          if (page.detail != null) ...[
                            const SizedBox(height: 10),
                            Text((page.detail!).ui,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.82), fontSize: 15, height: 1.35)),
                          ],
                          const SizedBox(height: 28),
                          if (page.ctaLabel != null && page.ctaRoute != null)
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: cartoon
                                        ? AppColors.kawaiiCoral
                                        : Colors.white,
                                foregroundColor: cartoon
                                        ? Colors.white
                                        : colors.first,
                                padding: EdgeInsets.symmetric(
                                  horizontal: cartoon ? 24 : 22,
                                  vertical: cartoon ? 15 : 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    (cartoon ? 28 : 28)),
                                  side: BorderSide.none)),
                              onPressed: () {
                                Navigator.pop(context);
                                context.push(page.ctaRoute!);
                              },
                              child: Text((page.ctaLabel!).ui,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: null))),
                          const SizedBox(height: 12),
                          Text(('Basılı tut  •  sağ / sol dokun').ui,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.55),
                              fontSize: 12,
                              letterSpacing: null)),
                        ]))),
                ]);
            }))));
  }
}
