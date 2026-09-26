import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/diyetsel_assets.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/app_modules.dart';
import '../../../core/utils/reminder_service.dart';
import '../../../core/widgets/module_gate.dart';
import '../../../core/widgets/soft_ui_kit.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../tracker/presentation/widgets/soft_tracker_widgets.dart';
import '../domain/water_shortcut_visuals.dart';
import 'widgets/soft_water_shortcut_widgets.dart';
import '../../../core/l10n/ui_string.dart';

/// Soft premium modern su kısayolu — bildirim, hızlı ekleme, günlük ilerleme.
class SoftWaterShortcutScreen extends ConsumerStatefulWidget {
  const SoftWaterShortcutScreen({super.key});

  @override
  ConsumerState<SoftWaterShortcutScreen> createState() => _SoftWaterShortcutScreenState();
}

class _SoftWaterShortcutScreenState extends ConsumerState<SoftWaterShortcutScreen> {
  Future<void> _toggleShortcut(AppStore store, String userId, bool next) async {
    final prefs = store.prefs(userId);
    await store.savePrefs(userId, prefs.copyWith(waterShortcut: next));
    if (next) {
      await ReminderService.instance.showWaterShortcut();
    } else {
      await ReminderService.instance.hideWaterShortcut();
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text((next
              ? (ReminderService.instance.supportsNative
                  ? 'Kalıcı su bildirimi açıldı'
                  : 'Kısayol açık — buradan +${AppConstants.waterSipMl} ml ekleyebilirsin')
              : 'Su kısayolu kapatıldı').ui,
        ),
      ),
    );
    setState(() {});
  }

  Future<void> _addWater(AppStore store, String userId, int ml) async {
    await store.addWaterSip(userId, ml: ml);
    final enabled = store.prefs(userId).waterShortcut;
    if (enabled) {
      await ReminderService.instance.showWaterShortcut();
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(('+$ml ml eklendi').ui)),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final locked = lockedIfOff(ref, module: AppModule.water, title: 'Su kısayolu');
    if (locked != null) return locked;

    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(waterLogsProvider);
    ref.watch(settingsProvider);

    final log = store.waterLog(user.id, DateTime.now());
    final prefs = store.prefs(user.id);
    final enabled = prefs.waterShortcut;
    final supportsNative = ReminderService.instance.supportsNative;
    final remaining = (log.goalMl - log.amountMl).clamp(0, log.goalMl);
    final sipCount = log.amountMl ~/ AppConstants.waterSipMl;

    final week = <(String, double)>[];
    for (var i = 6; i >= 0; i--) {
      final d = DateTime.now().subtract(Duration(days: i));
      final w = store.waterLog(user.id, d);
      week.add((DateFormat('E', 'tr').format(d).substring(0, 1), w.progress));
    }

    return Scaffold(
      backgroundColor: AppColors.modernWash,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            const SoftWaterShortcutHeader()
                .animate()
                .fadeIn(duration: 280.ms)
                .slideY(begin: -0.05, curve: Curves.easeOutCubic),
            const SizedBox(height: 14),
            SoftWaterShortcutHero(
              enabled: enabled,
              supportsNative: supportsNative,
              tip: WaterShortcutVisuals.tipOfDay(DateTime.now().day),
              progress: log.progress,
              amountMl: log.amountMl,
              goalMl: log.goalMl,
            )
                .animate()
                .fadeIn(delay: 40.ms, duration: 300.ms)
                .scale(
                  begin: const Offset(0.97, 0.97),
                  curve: Curves.easeOutCubic,
                  duration: 380.ms,
                ),
            const SizedBox(height: 12),
            SoftWaterShortcutStatsRow(
              remainingMl: remaining,
              sipCount: sipCount,
              progress: log.progress,
              sipMl: AppConstants.waterSipMl,
            ).animate().fadeIn(delay: 60.ms, duration: 280.ms),
            const SizedBox(height: 12),
            SoftTipCard(
              title: enabled ? 'Kısayol açık' : 'Tek dokunuşla su',
                  body: enabled
                  ? 'Bildirimden veya buradan +${AppConstants.waterSipMl} ml ekle. Hedefe $remaining ml kaldı.'
                  : 'Kalıcı bildirimi aç; yoğun günde bile su hedefini unutma.',
              icon: Icons.notifications_active_outlined,
              accent: const Color(0xFF5BA3C9),
              tint: const Color(0xFFE3F2F8),
              onTap: () => context.push('/app/track'),
              actionLabel: 'Tam takip ekranı →',
            ),
            const SizedBox(height: 14),
            SoftWaterShortcutToggleCard(
              enabled: enabled,
              supportsNative: supportsNative,
              onToggle: () => _toggleShortcut(store, user.id, !enabled),
            ).animate().fadeIn(delay: 75.ms, duration: 280.ms),
            const SizedBox(height: 14),
            SoftWaterShortcutPrimaryAdd(
              sipMl: AppConstants.waterSipMl,
              onAdd: () => _addWater(store, user.id, AppConstants.waterSipMl),
            )
                .animate()
                .fadeIn(delay: 90.ms, duration: 300.ms)
                .slideY(begin: 0.04, curve: Curves.easeOutCubic),
            const SizedBox(height: 12),
            SoftWaterShortcutQuickAdds(
              onAdd: (ml) => _addWater(store, user.id, ml),
            ).animate().fadeIn(delay: 105.ms, duration: 280.ms),
            const SizedBox(height: 14),
            SoftWaterShortcutNotificationPreview(
              amountMl: log.amountMl,
              goalMl: log.goalMl,
              enabled: enabled,
            ).animate().fadeIn(delay: 120.ms, duration: 280.ms),
            const SizedBox(height: 14),
            const SoftWaterShortcutStepsCard()
                .animate()
                .fadeIn(delay: 135.ms, duration: 280.ms),
            const SizedBox(height: 14),
            SoftWaterWeekStrip(days: week)
                .animate()
                .fadeIn(delay: 150.ms, duration: 300.ms),
            const SizedBox(height: 12),
            const SoftWaterShortcutTipCard(
              title: 'Oruçta da serbest',
              body: 'Aralıklı oruçta su, sade çay ve şekersiz kahve serbest — kalori eklemez.',
              icon: Icons.hourglass_bottom_rounded,
              asset: DiyetselAssets.modernIconCalendar,
              accent: AppColors.primary,
            ).animate().fadeIn(delay: 165.ms, duration: 280.ms),
            const SizedBox(height: 10),
            const SoftWaterShortcutTipCard(
              title: 'Hedefini koru',
              body: 'Diyetisyeninin belirlediği günlük ml hedefi burada ve takipte senkron kalır.',
              icon: Icons.flag_rounded,
              asset: DiyetselAssets.modernIconPlan,
              accent: WaterShortcutVisuals.blue,
            ).animate().fadeIn(delay: 180.ms, duration: 280.ms),
            const SizedBox(height: 14),
            SoftWaterShortcutTrackerLink(
              onTap: () => context.push('/app/track'),
            )
                .animate()
                .fadeIn(delay: 195.ms, duration: 280.ms),
          ],
        ),
      ),
    );
  }
}
