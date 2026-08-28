import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';
import 'kawaii_doodle.dart';
import 'style_icon.dart';

class DiyetselButton extends StatelessWidget {
  const DiyetselButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
    this.tonal = false,
    this.accent = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;
  final bool tonal;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final cartoon = context.isCartoon;
    final luxury = context.isLuxury;
    final color = accent
        ? (luxury ? AppColors.luxuryCopperBright : AppColors.modernSage)
        : context.brandPrimary;
    final radius = cartoon ? 26.0 : (luxury ? 10.0 : 28.0);
    final labelStyle = TextStyle(
      fontWeight: luxury ? FontWeight.w600 : FontWeight.w700,
      letterSpacing: luxury ? 0.7 : -0.1,
    );
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (icon != null) ...[
          if (cartoon)
            KawaiiDoodle(kind: KawaiiKindX.from(icon: icon), size: 22)
          else
            Icon(icon, size: 20, color: tonal ? color : Colors.white),
          const SizedBox(width: 8),
        ],
        Text(label, style: labelStyle),
      ],
    );

    if (cartoon) {
      return Container(
        decoration: BoxDecoration(
          color: tonal ? AppColors.kawaiiMint : color,
          borderRadius: BorderRadius.circular(28),
          boxShadow: tonal
              ? const [
                  BoxShadow(color: AppColors.kawaiiShadow, blurRadius: 12, offset: Offset(0, 4)),
                ]
              : [
                  BoxShadow(
                    color: AppColors.kawaiiGlow,
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                  const BoxShadow(
                    color: AppColors.kawaiiShadow,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(28),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
              child: DefaultTextStyle.merge(
                style: TextStyle(
                  color: tonal ? AppColors.kawaiiLeafDeep : Colors.white,
                  fontWeight: FontWeight.w800,
                ),
                child: IconTheme.merge(
                  data: IconThemeData(color: tonal ? AppColors.kawaiiLeafDeep : Colors.white),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (tonal) {
      if (!cartoon && !luxury) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(radius),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                color: color.withValues(alpha: 0.1),
                boxShadow: const [
                  BoxShadow(color: AppColors.modernSoftShadow, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                  child: IconTheme.merge(
                    data: IconThemeData(color: color),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        );
      }
      return FilledButton.tonal(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color.withValues(alpha: luxury ? 0.12 : 0.1),
          foregroundColor: color,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: luxury
                ? BorderSide(color: AppColors.luxuryCopperBright.withValues(alpha: 0.45), width: 0.9)
                : BorderSide.none,
          ),
        ),
        child: child,
      );
    }

    if (!cartoon && !luxury) {
      return Material(
        color: Colors.transparent,
        elevation: 0,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(radius),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              color: AppColors.primary,
              boxShadow: const [
                BoxShadow(
                  color: AppColors.modernSoftShadow,
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: expanded ? 24 : 20, vertical: 15),
              child: DefaultTextStyle.merge(
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                child: IconTheme.merge(
                  data: const IconThemeData(color: Colors.white),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.luxuryCopperBright,
                AppColors.luxuryCopper,
                AppColors.luxuryCopperDeep,
              ],
              stops: [0, 0.45, 1],
            ),
            border: Border.all(color: AppColors.luxuryCopperBright.withValues(alpha: 0.55), width: 0.9),
            boxShadow: [
              BoxShadow(
                color: AppColors.luxuryCopperDeep.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: expanded ? 22 : 18, vertical: 14),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: luxury ? 0.7 : 0,
              ),
              child: IconTheme.merge(
                data: const IconThemeData(color: Colors.white),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DiyetselCard extends StatelessWidget {
  const DiyetselCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.color,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cartoon = context.isCartoon;
    final luxury = context.isLuxury;
    final scheme = Theme.of(context).colorScheme;
    final radius = cartoon ? 28.0 : (luxury ? 10.0 : 22.0);
    final card = AnimatedContainer(
      duration: 220.ms,
      padding: padding,
      decoration: BoxDecoration(
        color: color ??
            (luxury
                ? AppColors.luxuryPlate
                : (cartoon ? AppColors.kawaiiBubble : scheme.surface)),
        borderRadius: BorderRadius.circular(radius),
        border: cartoon
            ? null
            : Border.all(
                color: luxury
                    ? AppColors.luxuryCopper.withValues(alpha: 0.5)
                    : AppColors.modernLine.withValues(alpha: 0.65),
                width: luxury ? 0.9 : 0.6,
              ),
        boxShadow: cartoon
            ? const [
                BoxShadow(
                  color: AppColors.kawaiiShadow,
                  offset: Offset(0, 8),
                  blurRadius: 24,
                  spreadRadius: 0,
                ),
              ]
            : luxury
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      offset: const Offset(0, 8),
                      blurRadius: 18,
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: AppColors.modernSoftShadow,
                      offset: Offset(0, 8),
                      blurRadius: 24,
                    ),
                  ],
      ),
      child: child,
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: card,
      ),
    );
  }
}

class CartoonContainer extends StatelessWidget {
  const CartoonContainer({super.key, required this.child, this.emoji});

  final Widget child;
  final String? emoji;

  @override
  Widget build(BuildContext context) {
    final cartoon = context.isCartoon;
    final luxury = context.isLuxury;
    return DiyetselCard(
      color: cartoon
          ? AppColors.kawaiiMint.withValues(alpha: 0.45)
          : luxury
              ? AppColors.luxuryWash
              : AppColors.modernSageSoft.withValues(alpha: 0.65),
      child: Row(
        children: [
          if (emoji != null) ...[
            StyleIcon(icon: Icons.auto_awesome, emoji: emoji!, size: 22, selected: true),
            const SizedBox(width: 12),
          ],
          Expanded(child: child),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action, this.subtitle});

  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final luxury = context.isLuxury;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: luxury ? FontWeight.w600 : FontWeight.w800,
                        letterSpacing: luxury ? 0.35 : null,
                      ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          letterSpacing: luxury ? 0.25 : null,
                        ),
                  ),
              ],
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.subtitle, this.emoji});

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? emoji;

  String get _sticker {
    if (emoji != null) return emoji!;
    if (icon == Icons.photo) return '📷';
    if (icon == Icons.restaurant) return '🥗';
    if (icon == Icons.folder) return '📁';
    if (icon == Icons.chat) return '💬';
    if (icon == Icons.event) return '📅';
    return '✨';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StyleIcon(
              icon: icon,
              emoji: _sticker,
              size: context.isCartoon ? 32 : 24,
              selected: true,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: context.isLuxury ? FontWeight.w600 : FontWeight.w800,
                    letterSpacing: context.isLuxury ? 0.3 : null,
                  ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final luxury = context.isLuxury;
    final cartoon = context.isCartoon;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: luxury ? 11 : (cartoon ? 12 : 10),
        vertical: luxury ? 5 : (cartoon ? 6 : 4),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: luxury ? 0.1 : (cartoon ? 0.2 : 0.14)),
        borderRadius: BorderRadius.circular(luxury ? 8 : (cartoon ? 18 : 20)),
        border: cartoon
            ? null
            : luxury
                ? Border.all(color: color.withValues(alpha: 0.35), width: 0.8)
                : null,
        boxShadow: cartoon
            ? const [
                BoxShadow(color: AppColors.kawaiiShadow, blurRadius: 8, offset: Offset(0, 3)),
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: cartoon ? AppColors.kawaiiInk : color,
          fontWeight: luxury ? FontWeight.w600 : FontWeight.w800,
          fontSize: 12,
          letterSpacing: luxury ? 0.4 : 0,
        ),
      ),
    );
  }
}

class FeatureBanner extends StatelessWidget {
  const FeatureBanner({
    super.key,
    required this.icon,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.color = AppColors.primary,
    this.trailing,
  });

  final IconData icon;
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tint = color == AppColors.primary ? context.brandPrimary : color;
    if (context.isCartoon) {
      return DiyetselCard(
        color: Color.lerp(AppColors.kawaiiBubble, tint, 0.22),
        child: Row(
          children: [
            StyleIcon(icon: icon, emoji: emoji, size: 28, color: tint),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      height: 1.2,
                      color: AppColors.kawaiiInk,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.kawaiiInk.withValues(alpha: 0.72),
                        ),
                  ),
                ],
              ),
            ),
            trailing ?? const SizedBox.shrink(),
          ],
        ),
      );
    }
    if (context.isLuxury) {
      return DiyetselCard(
        color: AppColors.luxuryWash,
        child: Row(
          children: [
            StyleIcon(icon: icon, emoji: emoji, size: 24, color: tint),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.25,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            trailing ?? const SizedBox.shrink(),
          ],
        ),
      );
    }
    return DiyetselCard(
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: tint),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Row(
                  children: [
                    Icon(icon, color: tint, size: 26),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    trailing ?? const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TipCard extends StatelessWidget {
  const TipCard({super.key, required this.title, required this.body, required this.icon, required this.emoji, this.color = AppColors.accent});

  final String title;
  final String body;
  final IconData icon;
  final String emoji;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DiyetselCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StyleIcon(icon: icon, emoji: emoji, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(body, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HowToStep extends StatelessWidget {
  const HowToStep({
    super.key,
    required this.index,
    required this.text,
    required this.icon,
    required this.emoji,
  });

  final int index;
  final String text;
  final IconData icon;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    final brand = context.brandPrimary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: brand.withValues(alpha: 0.14),
            foregroundColor: brand,
            child: Text(
              '$index',
              style: TextStyle(
                fontWeight: context.isLuxury ? FontWeight.w600 : FontWeight.w900,
                fontSize: 13,
                letterSpacing: context.isLuxury ? 0.4 : 0,
              ),
            ),
          ),
          const SizedBox(width: 10),
          StyleIcon(icon: icon, emoji: emoji, size: 18, color: brand, sticker: false),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: context.isLuxury ? FontWeight.w600 : FontWeight.w700,
                letterSpacing: context.isLuxury ? 0.15 : 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ModuleLocked extends StatelessWidget {
  const ModuleLocked({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.lock_rounded,
      emoji: '🔒',
      title: '$title kapalı',
      subtitle: 'Diyetisyenin bu bölümü senin için kapatmış. Sormak için sohbeti kullan.',
    );
  }
}
