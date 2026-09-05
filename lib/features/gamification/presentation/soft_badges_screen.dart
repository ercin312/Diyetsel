import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/utils/achievement_logic.dart';
import '../../../core/widgets/soft_ui_kit.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/badge_visuals.dart';
import 'widgets/soft_badges_widgets.dart';

/// Soft premium modern badges & goals.
class SoftBadgesScreen extends ConsumerStatefulWidget {
  const SoftBadgesScreen({super.key});

  @override
  ConsumerState<SoftBadgesScreen> createState() => _SoftBadgesScreenState();
}

class _SoftBadgesScreenState extends ConsumerState<SoftBadgesScreen> {
  String _filter = 'Tümü';

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(userProgressProvider(user.id));
    final progress = store.userProgress(user.id);
    final badges = allBadgeProgress(store, user.id, progress);

    final earnedList = badges.where((b) => b.earned).toList();
    final inProgressList = badges.where((b) => !b.earned && b.current > 0).toList();
    final remaining = badges.where((b) => !b.earned).length;
    final earned = earnedList.length;

    final nextCandidates = badges.where((b) => !b.earned).toList()
      ..sort((a, b) => b.ratio.compareTo(a.ratio));
    final next = nextCandidates.isEmpty ? null : nextCandidates.first;
    final bestPct = next == null ? 0 : (next.ratio * 100).round();

    final filtered = switch (_filter) {
      'Kazanılan' => earnedList,
      'Devam eden' => badges.where((b) => !b.earned).toList()
        ..sort((a, b) => b.ratio.compareTo(a.ratio)),
      _ => badges,
    };

    return Scaffold(
      backgroundColor: AppColors.modernWash,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            const SoftBadgesHeader()
                .animate()
                .fadeIn(duration: 280.ms)
                .slideY(begin: -0.05, curve: Curves.easeOutCubic),
            const SizedBox(height: 14),
            SoftBadgesHero(
              earned: earned,
              total: badges.length,
              tip: BadgeVisuals.tipOfDay(DateTime.now().day),
            )
                .animate()
                .fadeIn(delay: 40.ms, duration: 300.ms)
                .scale(
                  begin: const Offset(0.97, 0.97),
                  curve: Curves.easeOutCubic,
                  duration: 380.ms,
                ),
            const SizedBox(height: 12),
            SoftBadgesStatsRow(
              earned: earned,
              inProgress: inProgressList.length,
              remaining: remaining,
              bestPct: bestPct,
            ).animate().fadeIn(delay: 60.ms, duration: 280.ms),
            const SizedBox(height: 12),
            SoftTipCard(
              title: 'Küçük adım, büyük rozet',
              body: next != null
                  ? 'Sıradaki hedefin yakın: ${next.badge.title}. Bugün bir check-in, su veya ders tamamlamak seni öne taşır.'
                  : 'Tüm rozetler senin — düzenli alışkanlıklar yeni hedefleri açar. Ritmi koru!',
              icon: Icons.emoji_events_outlined,
              accent: const Color(0xFFD4A017),
              tint: const Color(0xFFFFF6E9),
            ).animate().fadeIn(delay: 70.ms, duration: 280.ms),
            if (next != null) ...[
              const SizedBox(height: 14),
              SoftNextBadgeCard(
                item: next,
                onOpen: () => _openDetail(context, next),
              )
                  .animate()
                  .fadeIn(delay: 80.ms, duration: 300.ms)
                  .slideY(begin: 0.04, curve: Curves.easeOutCubic),
            ],
            if (earnedList.isNotEmpty) ...[
              const SizedBox(height: 18),
              SoftEarnedStrip(
                items: earnedList,
                onOpen: (item) => _openDetail(context, item),
              ).animate().fadeIn(delay: 100.ms, duration: 280.ms),
            ],
            const SizedBox(height: 18),
            SoftBadgesFilterChips(
              filter: _filter,
              onChanged: (f) => setState(() => _filter = f),
            ).animate().fadeIn(delay: 115.ms, duration: 280.ms),
            const SizedBox(height: 14),
            if (filtered.isEmpty)
              SoftEmptyRich(
                title: 'Bu filtrede rozet yok',
                body: _filter == 'Kazanılan'
                    ? 'Henüz rozet kazanmadın — küçük günlük adımlar seni buraya getirir.'
                    : 'Filtreyi değiştir veya hedeflerine doğru ilerlemeye devam et.',
                icon: Icons.emoji_events_outlined,
              ).animate().fadeIn(duration: 280.ms)
            else
              for (var i = 0; i < filtered.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SoftBadgeCard(
                    item: filtered[i],
                    onOpen: () => _openDetail(context, filtered[i]),
                  )
                      .animate()
                      .fadeIn(delay: (40 * i).ms, duration: 280.ms)
                      .slideY(begin: 0.04, curve: Curves.easeOutCubic),
                ),
            const SizedBox(height: 6),
            const SoftBadgesFooterTip()
                .animate()
                .fadeIn(delay: 160.ms, duration: 280.ms),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, BadgeProgress item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SoftBadgeDetailSheet(item: item),
    );
  }
}
