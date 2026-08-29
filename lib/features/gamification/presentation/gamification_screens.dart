import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/achievements.dart';
import '../../../core/utils/achievement_logic.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/diyetsel_widgets.dart';
import '../../../core/widgets/kawaii_doodle.dart';
import '../../../core/widgets/style_icon.dart';
import '../../auth/presentation/auth_controller.dart';
import 'soft_badges_screen.dart';
import 'widgets/soft_badges_widgets.dart';

class BadgeCelebration {
  static Future<void> show(BuildContext context, BadgeDef badge) {
    final cartoon = context.isCartoon;
    final modern = context.isModern;
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'rozet',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 420),
      pageBuilder: (ctx, a1, a2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, _, child) {
        final curve = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        if (modern) {
          return Opacity(
            opacity: anim.value,
            child: Transform.scale(
              scale: 0.88 + curve.value * 0.12,
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: SoftBadgeCelebrationCard(
                    badge: badge,
                    onClose: () => Navigator.pop(ctx),
                  ),
                ),
              ),
            ),
          );
        }
        return Opacity(
          opacity: anim.value,
          child: Transform.scale(
            scale: 0.85 + curve.value * 0.15,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 28),
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: cartoon
                          ? const [AppColors.kawaiiLemon, AppColors.kawaiiPeach, AppColors.kawaiiRose]
                          : [AppColors.primaryDeep, AppColors.modernTealCard],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(cartoon ? 30 : (22)),
                    boxShadow: [
                      BoxShadow(
                        color: cartoon ? AppColors.kawaiiGlow : AppColors.modernSoftShadow,
                        blurRadius: cartoon ? 28 : 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Yeni rozet!',
                        style: TextStyle(
                          color: cartoon ? AppColors.kawaiiInk : Colors.white70,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (cartoon)
                        KawaiiDoodle(kind: KawaiiKind.sparkle, size: 88)
                      else
                        Text(badge.emoji, style: const TextStyle(fontSize: 72)),
                      const SizedBox(height: 12),
                      Text(
                        badge.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: cartoon ? AppColors.kawaiiInk : Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        badge.subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: cartoon
                              ? AppColors.kawaiiInk.withValues(alpha: 0.75)
                              : Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 20),
                      DiyetselButton(
                        label: 'Harika!',
                        expanded: false,
                        accent: cartoon,
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.03, 1.03),
                      duration: cartoon ? 700.ms : 900.ms,
                      curve: cartoon ? Curves.easeInOut : Curves.linear,
                    ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (context.isModern) {
      return const SoftBadgesScreen();
    }

    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(userProgressProvider(user.id));
    final progress = store.userProgress(user.id);
    final badges = allBadgeProgress(store, user.id, progress);
    final earned = badges.where((b) => b.earned).length;

    return AppPage(
      title: 'Rozetler & hedefler',
      child: ListView(
        children: [
          DiyetselCard(
            child: Row(
              children: [
                StyleIcon(icon: Icons.emoji_events_rounded, emoji: '🏆', size: 36, color: context.brandPrimary),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$earned / ${badges.length} rozet', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                      Text(
                        'Su, check-in, fotoğraf ve mini ders serileriyle kazan',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.06),
          const SizedBox(height: 14),
          for (final item in badges)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BadgeCard(item: item),
            ).animate().fadeIn(delay: (badges.indexOf(item) * 60).ms).scale(
                  begin: context.isCartoon ? const Offset(0.94, 0.94) : const Offset(1, 1),
                  curve: Curves.easeOutBack,
                  duration: context.isCartoon ? 400.ms : 0.ms,
                ),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.item});
  final BadgeProgress item;

  @override
  Widget build(BuildContext context) {
    final b = item.badge;
    final cartoon = context.isCartoon;
    return DiyetselCard(
      color: cartoon ? AppColors.kawaiiBubble : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: cartoon
                      ? Color.lerp(b.tint, AppColors.kawaiiPeach, 0.55)!.withValues(alpha: 0.85)
                      : b.tint.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(cartoon ? 24 : (20)),
                  border: null,
                  boxShadow: cartoon
                      ? const [
                          BoxShadow(
                            color: AppColors.kawaiiShadow,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(b.emoji, style: const TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    Text(b.subtitle, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              if (item.earned)
                const DoodleBadge(label: 'Kazanıldı', emoji: '⭐')
              else
                Text('${item.current}/${b.target}', style: TextStyle(color: b.tint, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: item.ratio,
              minHeight: 8,
              backgroundColor: cartoon
                  ? AppColors.kawaiiCream.withValues(alpha: 0.55)
                  : b.tint.withValues(alpha: 0.12),
              color: b.tint,
            ),
          ),
        ],
      ),
    );
  }
}

class BadgeHomeStrip extends ConsumerWidget {
  const BadgeHomeStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(userProgressProvider(user.id));
    final progress = store.userProgress(user.id);
    final badges = allBadgeProgress(store, user.id, progress);
    final next = badges.where((b) => !b.earned).toList()
      ..sort((a, b) => b.ratio.compareTo(a.ratio));
    if (next.isEmpty) return const SizedBox.shrink();
    final focus = next.first;

    return DiyetselCard(
      onTap: () => context.push('/app/badges'),
      child: Row(
        children: [
          Text(focus.badge.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(focus.badge.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                Text(
                  '${focus.current}/${focus.badge.target} • ${focus.badge.subtitle}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: focus.ratio,
                    minHeight: 6,
                    backgroundColor: focus.badge.tint.withValues(alpha: 0.15),
                    color: focus.badge.tint,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

Future<void> maybeShowBadgeCelebrations(BuildContext context, WidgetRef ref, String userId) async {
  final store = ref.read(appStoreProvider);
  var progress = store.userProgress(userId);
  while (progress.pendingCelebrations.isNotEmpty && context.mounted) {
    final id = progress.pendingCelebrations.first;
    final badge = BadgeCatalog.byId(id);
    progress = progress.copyWith(pendingCelebrations: progress.pendingCelebrations.sublist(1));
    await store.saveUserProgress(progress);
    if (badge != null && context.mounted) {
      await BadgeCelebration.show(context, badge);
    }
  }
}
