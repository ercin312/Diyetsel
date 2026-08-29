import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/app_modules.dart';
import '../../../core/utils/engage_logic.dart';
import '../../../core/widgets/module_gate.dart';
import '../../auth/presentation/auth_controller.dart';
import 'widgets/soft_eat_out_widgets.dart';

/// Soft premium modern "Dışarıda ne yesem?" hub.
class SoftEatOutScreen extends ConsumerStatefulWidget {
  const SoftEatOutScreen({super.key});

  @override
  ConsumerState<SoftEatOutScreen> createState() => _SoftEatOutScreenState();
}

class _SoftEatOutScreenState extends ConsumerState<SoftEatOutScreen> {
  String _filter = 'Tümü';

  @override
  Widget build(BuildContext context) {
    final locked = lockedIfOff(ref, module: AppModule.eatOut, title: 'Dışarıda ne yesem?');
    if (locked != null) return locked;

    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(dietPlansProvider);
    final remaining = store.remainingKcal(user.id);
    final fits = eatOutMenu.where((e) => e.kcal <= remaining + 40).toList();
    final tight = remaining < 200;
    final pool = fits.isEmpty ? eatOutMenu.where((e) => e.kcal <= 120).toList() : fits;
    final categories = ['Tümü', ...{for (final e in eatOutMenu) e.category}];
    final shown = _filter == 'Tümü' ? pool : pool.where((e) => e.category == _filter).toList();
    final catCount = {for (final e in eatOutMenu) e.category}.length;

    return Scaffold(
      backgroundColor: AppColors.modernWash,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            const SoftEatOutHeader()
                .animate()
                .fadeIn(duration: 280.ms)
                .slideY(begin: -0.05, curve: Curves.easeOutCubic),
            const SizedBox(height: 14),
            SoftEatOutHero(
              remaining: remaining,
              tight: tight,
              optionCount: pool.length,
            )
                .animate()
                .fadeIn(delay: 40.ms, duration: 300.ms)
                .scale(
                  begin: const Offset(0.97, 0.97),
                  curve: Curves.easeOutCubic,
                  duration: 380.ms,
                ),
            const SizedBox(height: 14),
            SoftEatOutStatsRow(
              remaining: remaining,
              fits: fits.length,
              categories: catCount,
            ).animate().fadeIn(delay: 70.ms, duration: 280.ms),
            const SizedBox(height: 14),
            const SoftEatOutRulesCard()
                .animate()
                .fadeIn(delay: 90.ms, duration: 280.ms),
            const SizedBox(height: 16),
            Text(
              fits.isEmpty ? 'En hafif kaçışlar' : 'Sana uyan öneriler',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 17,
                color: AppColors.primaryDeep,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${shown.length} seçenek · kalan $remaining kcal',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final c = categories.elementAt(i);
                  return SoftEatOutCategoryChip(
                    label: c,
                    selected: c == _filter,
                    onTap: () => setState(() => _filter = c),
                  );
                },
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 280.ms),
            const SizedBox(height: 14),
            if (shown.isEmpty)
              const SoftEatOutEmpty()
            else ...[
              SoftEatOutFeaturedCard(
                idea: shown.first,
                remaining: remaining,
                onOpen: () => _openDetail(context, shown.first, remaining),
              )
                  .animate()
                  .fadeIn(delay: 120.ms, duration: 320.ms)
                  .scale(begin: const Offset(0.96, 0.96), curve: Curves.easeOutBack),
              if (shown.length > 1) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Diğer seçenekler',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: AppColors.primaryDeep,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${shown.length - 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 11.5,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                for (var i = 1; i < shown.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SoftEatOutCard(
                      idea: shown[i],
                      index: i,
                      remaining: remaining,
                      onOpen: () => _openDetail(context, shown[i], remaining),
                    ),
                  ),
              ],
            ],
            const SizedBox(height: 8),
            const SoftEatOutTipCard()
                .animate()
                .fadeIn(delay: 180.ms, duration: 280.ms),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, EatOutIdea idea, int remaining) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SoftEatOutDetailSheet(idea: idea, remaining: remaining),
    );
  }
}
