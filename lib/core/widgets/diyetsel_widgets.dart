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
    final color = accent ? AppColors.accent : AppColors.primary;
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
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.1)),
      ],
    );

    if (cartoon) {
      return Container(
        decoration: BoxDecoration(
          color: tonal ? color.withValues(alpha: 0.14) : color,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.32),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(22),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: tonal ? color : Colors.white),
                  child: IconTheme.merge(
                    data: IconThemeData(color: tonal ? color : Colors.white),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
      );
    }

    if (tonal) {
      return FilledButton.tonal(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.1),
          foregroundColor: color,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: child,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: expanded ? 22 : 18, vertical: 14),
            child: DefaultTextStyle.merge(
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
    final scheme = Theme.of(context).colorScheme;
    final card = AnimatedContainer(
      duration: 220.ms,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? scheme.surface,
        borderRadius: BorderRadius.circular(cartoon ? 28 : 16),
        border: Border.all(
          color: cartoon ? Colors.transparent : scheme.outline.withValues(alpha: 0.65),
          width: cartoon ? 0 : 1,
        ),
        boxShadow: cartoon
            ? const [
                BoxShadow(
                  color: AppColors.kawaiiShadow,
                  offset: Offset(0, 8),
                  blurRadius: 16,
                ),
              ]
            : null,
      ),
      child: child,
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(cartoon ? 28 : 16),
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
    return DiyetselCard(
      color: cartoon ? AppColors.peach.withValues(alpha: 0.55) : AppColors.modernWarm.withValues(alpha: 0.65),
      child: Row(
        children: [
          if (emoji != null) ...[
            if (cartoon)
              KawaiiTile(kind: KawaiiKindX.from(emoji: emoji), size: 52)
            else
              ModernIconTile(kind: KawaiiKindX.from(emoji: emoji), size: 44, selected: true),
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
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                if (subtitle != null)
                  Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
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
            if (context.isCartoon)
              KawaiiTile(kind: KawaiiKindX.from(icon: icon, emoji: _sticker), size: 86)
            else
              ModernIconTile(
                kind: KawaiiKindX.from(icon: icon, emoji: _sticker),
                size: 64,
              ),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: context.isCartoon ? Border.all(color: color, width: 1.6) : null,
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12),
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
    if (context.isCartoon) {
      return DiyetselCard(
        color: color.withValues(alpha: 0.16),
        child: Row(
          children: [
            StyleIcon(icon: icon, emoji: emoji, size: 28, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, height: 1.2)),
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
            Container(width: 4, color: color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Row(
                  children: [
                    Icon(icon, color: color, size: 26),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withValues(alpha: 0.14),
            foregroundColor: AppColors.primary,
            child: Text('$index', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
          ),
          const SizedBox(width: 10),
          StyleIcon(icon: icon, emoji: emoji, size: 18, color: AppColors.primary, sticker: false),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700))),
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
