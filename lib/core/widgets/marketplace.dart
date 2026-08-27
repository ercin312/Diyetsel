import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';
import '../utils/desktop.dart';
import 'diyetsel_widgets.dart';
import 'kawaii_doodle.dart';
import 'modern_glyph.dart';
import 'style_icon.dart';

class PromoSlide {
  const PromoSlide({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.route,
    required this.color,
    this.kind,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final String cta;
  final String route;
  final Color color;
  final KawaiiKind? kind;

  KawaiiKind get doodle => kind ?? KawaiiKindX.from(emoji: emoji);
}

class PromoSlider extends StatefulWidget {
  const PromoSlider({super.key, required this.slides, this.height = 168});

  final List<PromoSlide> slides;
  final double height;

  @override
  State<PromoSlider> createState() => _PromoSliderState();
}

class _PromoSliderState extends State<PromoSlider> {
  final _controller = PageController(viewportFraction: 0.92);
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.slides.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (!mounted || !_controller.hasClients) return;
        final next = (_index + 1) % widget.slides.length;
        _controller.animateToPage(next, duration: 420.ms, curve: Curves.easeOutCubic);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.slides.isEmpty) return const SizedBox.shrink();
    if (context.isDesktopLayout) return _desktopGrid(context);
    final cartoon = context.isCartoon;
    if (!cartoon) return _modernStrip(context);

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _index = i),
            itemCount: widget.slides.length,
            itemBuilder: (context, i) {
              final slide = widget.slides[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.push(slide.route),
                    borderRadius: BorderRadius.circular(28),
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: LinearGradient(
                          colors: [slide.color, slide.color.withValues(alpha: 0.78)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: slide.color.withValues(alpha: 0.28),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        child: Row(
                          children: [
                            KawaiiTile(kind: slide.doodle, size: 64),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    slide.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17),
                                  ),
                                  Text(
                                    slide.subtitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.92), fontSize: 12),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                                    child: Text(slide.cta, style: TextStyle(color: slide.color, fontWeight: FontWeight.w800, fontSize: 12)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < widget.slides.length; i++)
              AnimatedContainer(
                duration: 240.ms,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _index ? 18 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: i == _index ? AppColors.primary : AppColors.primary.withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _desktopGrid(BuildContext context) {
    final cartoon = context.isCartoon;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 900 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.slides.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: cartoon ? 2.4 : 2.55,
          ),
          itemBuilder: (context, i) {
            final slide = widget.slides[i];
            final tint = slide.color;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.push(slide.route),
                borderRadius: BorderRadius.circular(cartoon ? 18 : 10),
                hoverColor: tint.withValues(alpha: 0.08),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(cartoon ? 18 : 10),
                    color: Color.lerp(Theme.of(context).colorScheme.surface, tint, 0.1),
                    border: Border.all(color: tint.withValues(alpha: 0.28)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: Row(
                      children: [
                        if (cartoon)
                          KawaiiTile(kind: slide.doodle, size: 44)
                        else
                          ModernIconTile(kind: slide.doodle, size: 40),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                slide.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, letterSpacing: -0.2),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                slide.subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, size: 18, color: tint),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Colorful editorial tip — soft tinted surface + accent icon.
  Widget _modernStrip(BuildContext context) {
    final slide = widget.slides[_index.clamp(0, widget.slides.length - 1)];
    final tint = slide.color;
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push(slide.route),
            borderRadius: BorderRadius.circular(18),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    tint,
                    Color.lerp(tint, const Color(0xFFFF8A3D), 0.35)!,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: tint.withValues(alpha: 0.32),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
                child: Row(
                  children: [
                    ModernIconTile(kind: slide.doodle, size: 52, inverted: true),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            slide.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            slide.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              slide.cta,
                              style: TextStyle(color: tint, fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (widget.slides.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.slides.length; i++)
                GestureDetector(
                  onTap: () {
                    setState(() => _index = i);
                    _controller.animateToPage(i, duration: 280.ms, curve: Curves.easeOut);
                  },
                  child: AnimatedContainer(
                    duration: 200.ms,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _index ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _index ? AppColors.primary : AppColors.primary.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class HomeCategory {
  const HomeCategory({
    required this.label,
    required this.emoji,
    required this.icon,
    required this.route,
    required this.tint,
  });

  final String label;
  final String emoji;
  final IconData icon;
  final String route;
  final Color tint;
}

class CategoryShortcuts extends StatelessWidget {
  const CategoryShortcuts({super.key, required this.items});

  final List<HomeCategory> items;

  @override
  Widget build(BuildContext context) {
    if (context.isDesktopLayout) return _desktop(context);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 8,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, i) {
        final item = items[i];
        final cartoon = context.isCartoon;
        return InkWell(
          onTap: () => context.push(item.route),
          borderRadius: BorderRadius.circular(cartoon ? 18 : 12),
          child: Column(
            children: [
              if (cartoon)
                KawaiiTile(kind: KawaiiKindX.from(icon: item.icon, emoji: item.emoji), size: 58)
              else
                ModernIconTile(kind: KawaiiKindX.from(icon: item.icon, emoji: item.emoji), size: 48),
              const SizedBox(height: 6),
              Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  height: 1.15,
                  letterSpacing: -0.1,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _desktop(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in items)
          Material(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () => context.push(item.route),
              borderRadius: BorderRadius.circular(8),
              hoverColor: item.tint.withValues(alpha: 0.1),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: scheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.icon, size: 18, color: item.tint),
                      const SizedBox(width: 8),
                      Text(
                        item.label,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class CategoryStrip extends StatelessWidget {
  const CategoryStrip({super.key, required this.items});

  final List<HomeCategory> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    if (context.isDesktopLayout) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final item in items)
            Material(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () => context.push(item.route),
                borderRadius: BorderRadius.circular(8),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(item.icon, size: 18, color: item.tint),
                        const SizedBox(width: 8),
                        Text(item.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }
    if (!context.isCartoon) return _modern(context);

    final mid = (items.length / 2).ceil();
    final rows = [items.take(mid).toList(), items.skip(mid).toList()];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final row in rows)
            if (row.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    for (final item in row)
                      SizedBox(
                        width: 78,
                        child: InkWell(
                          onTap: () => context.push(item.route),
                          borderRadius: BorderRadius.circular(18),
                          child: Column(
                            children: [
                              KawaiiTile(kind: KawaiiKindX.from(icon: item.icon, emoji: item.emoji), size: 58),
                              const SizedBox(height: 6),
                              Text(
                                item.label,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, height: 1.15),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  Widget _modern(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final item = items[i];
          final kind = KawaiiKindX.from(icon: item.icon, emoji: item.emoji);
          return InkWell(
            onTap: () => context.push(item.route),
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 78,
              child: Column(
                children: [
                  ModernIconTile(kind: kind, size: 54),
                  const SizedBox(height: 8),
                  Text(
                    item.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.lightInk,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TodayStat {
  const TodayStat({
    required this.label,
    required this.value,
    required this.kind,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String value;
  final KawaiiKind kind;
  final Color color;
  final VoidCallback onTap;
}

class TodayStrip extends StatelessWidget {
  const TodayStrip({super.key, required this.items});

  final List<TodayStat> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    if (!context.isCartoon) return _modern(context);

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: DiyetselCard(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              onTap: items[i].onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KawaiiTile(kind: items[i].kind, size: 42),
                  const SizedBox(height: 8),
                  Text(items[i].value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                  Text(items[i].label, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _modern(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: DiyetselCard(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              onTap: items[i].onTap,
              color: Color.lerp(Colors.white, ModernPalette.accent(items[i].kind), 0.08),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ModernIconTile(kind: items[i].kind, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    items[i].value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: ModernPalette.accent(items[i].kind),
                    ),
                  ),
                  Text(items[i].label, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class HorizontalRail extends StatelessWidget {
  const HorizontalRail({
    super.key,
    required this.title,
    required this.onSeeAll,
    required this.children,
  });

  final String title;
  final VoidCallback onSeeAll;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (context.isDesktopLayout) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: title,
            action: TextButton(onPressed: onSeeAll, child: const Text('Tümü')),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth >= 1000 ? 4 : 3;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: children.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.15,
                ),
                itemBuilder: (context, i) => children[i],
              );
            },
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          action: TextButton(onPressed: onSeeAll, child: const Text('Tümü')),
        ),
        SizedBox(
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: children.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, i) => children[i],
          ),
        ),
      ],
    );
  }
}

class ProductTile extends StatelessWidget {
  const ProductTile({
    super.key,
    required this.emoji,
    required this.title,
    required this.meta,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String meta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kind = KawaiiKindX.from(emoji: emoji);
    final desktop = context.isDesktopLayout;
    return SizedBox(
      width: desktop ? null : 148,
      height: desktop ? null : 168,
      child: DiyetselCard(
        padding: const EdgeInsets.all(14),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (context.isCartoon)
              KawaiiTile(kind: kind, size: desktop ? 40 : 52)
            else
              ModernIconTile(kind: kind, size: desktop ? 36 : 46),
            if (desktop) const SizedBox(height: 10) else const Spacer(),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: desktop ? 13.5 : 14,
                letterSpacing: -0.2,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 4),
            Text(meta, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class MarketSearchBar extends StatelessWidget {
  const MarketSearchBar({super.key, required this.hint, required this.onSubmitted, this.onTap});

  final String hint;
  final ValueChanged<String> onSubmitted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cartoon = context.isCartoon;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final desktop = context.isDesktopLayout;
    return TextField(
      onSubmitted: onSubmitted,
      onTap: onTap,
      textInputAction: TextInputAction.search,
      style: TextStyle(color: cartoon || dark || desktop ? null : AppColors.lightInk),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: cartoon ? null : AppColors.lightMuted.withValues(alpha: 0.9),
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(10),
          child: cartoon
              ? const KawaiiDoodle(kind: KawaiiKind.search, size: 22)
              : Icon(Icons.search_rounded, color: desktop ? AppColors.primary : AppColors.accent),
        ),
        filled: true,
        fillColor: dark
            ? const Color(0xFF2A2A2A)
            : desktop
                ? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.55)
                : Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: desktop ? 10 : 12),
        isDense: desktop,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cartoon ? 24 : (desktop ? 8 : 14)),
          borderSide: BorderSide(
            color: cartoon
                ? AppColors.kawaiiPeach
                : desktop
                    ? Theme.of(context).colorScheme.outlineVariant
                    : Colors.white,
            width: cartoon ? 1.2 : (desktop ? 1 : 0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cartoon ? 24 : (desktop ? 8 : 14)),
          borderSide: BorderSide(color: cartoon ? AppColors.primary : AppColors.accent, width: 1.6),
        ),
      ),
    );
  }
}

class MarketHeroHeader extends StatelessWidget {
  const MarketHeroHeader({
    super.key,
    required this.greeting,
    required this.subtitle,
    required this.search,
    this.trailing,
  });

  final String greeting;
  final String subtitle;
  final Widget search;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    if (context.isDesktopLayout) return _desktop(context);
    if (context.isCartoon) return _cartoon(context);
    return _modern(context);
  }

  Widget _desktop(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.9))),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(flex: 4, child: search),
              if (trailing != null) const SizedBox(width: 12),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _cartoon(BuildContext context) {
    const onHero = AppColors.kawaiiInk;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD8F4E8), Color(0xFFFFF6E8), Color(0xFFFFE8D6)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const KawaiiDoodle(kind: KawaiiKind.orange, size: 32),
                  const SizedBox(width: 8),
                  const Text('Diyetsel', style: TextStyle(color: onHero, fontWeight: FontWeight.w900, fontSize: 22)),
                  const Spacer(),
                  const KawaiiDoodle(kind: KawaiiKind.sparkle, size: 22),
                  if (trailing != null) const SizedBox(width: 8),
                  ?trailing,
                ],
              ),
              const SizedBox(height: 10),
              Text(greeting, style: const TextStyle(color: onHero, fontWeight: FontWeight.w900, fontSize: 22, height: 1.15)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: onHero.withValues(alpha: 0.78), fontWeight: FontWeight.w600)),
              const SizedBox(height: 14),
              search,
            ],
          ),
        ),
      ),
    );
  }

  Widget _modern(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [Color(0xFF1C1917), Color(0xFF292524)]
              : const [
                  Color(0xFFFF8A3D),
                  Color(0xFFFF6B00),
                  Color(0xFF14B8A6),
                ],
          stops: dark ? null : const [0, 0.55, 1],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Diyetsel',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -1.1,
                            height: 1,
                          ),
                    ),
                  ),
                  ?trailing,
                ],
              ),
              const SizedBox(height: 16),
              Text(
                greeting,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.88),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              search,
            ],
          ),
        ),
      ),
    );
  }
}
