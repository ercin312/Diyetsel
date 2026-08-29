import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/diyetsel_assets.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/app_modules.dart';
import '../../../core/widgets/module_gate.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/fasting_visuals.dart';
import 'widgets/soft_fasting_widgets.dart';

/// Soft premium modern intermittent fasting — 16:8 timer, fazlar, ipuçları.
class SoftFastingScreen extends ConsumerStatefulWidget {
  const SoftFastingScreen({super.key});

  @override
  ConsumerState<SoftFastingScreen> createState() => _SoftFastingScreenState();
}

class _SoftFastingScreenState extends ConsumerState<SoftFastingScreen> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locked = lockedIfOff(ref, module: AppModule.fasting, title: 'Aralıklı oruç');
    if (locked != null) return locked;

    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(fastingProvider);
    final session = store.fasting(user.id);

    final hours = session.elapsed.inHours;
    final mins = session.elapsed.inMinutes % 60;
    final phase = FastingVisuals.phaseForHours(hours);
    final remaining = ((1 - session.progress) * session.windowHours)
        .clamp(0.0, session.windowHours.toDouble());

    return Scaffold(
      backgroundColor: AppColors.modernWash,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            const SoftFastingHeader()
                .animate()
                .fadeIn(duration: 280.ms)
                .slideY(begin: -0.05, curve: Curves.easeOutCubic),
            const SizedBox(height: 14),
            SoftFastingHero(
              active: session.active,
              tip: FastingVisuals.tipOfDay(DateTime.now().day),
              phaseTitle: phase.title,
            )
                .animate()
                .fadeIn(delay: 40.ms, duration: 300.ms)
                .scale(
                  begin: const Offset(0.97, 0.97),
                  curve: Curves.easeOutCubic,
                  duration: 380.ms,
                ),
            const SizedBox(height: 12),
            SoftFastingStatsRow(
              hours: hours,
              mins: mins,
              progress: session.progress,
              remainingHours: remaining,
              active: session.active,
            ).animate().fadeIn(delay: 60.ms, duration: 280.ms),
            const SizedBox(height: 14),
            const SoftFastingWindowCard()
                .animate()
                .fadeIn(delay: 75.ms, duration: 280.ms),
            const SizedBox(height: 14),
            SoftFastingTimerCard(
              session: session,
              hours: hours,
              mins: mins,
              phase: phase,
              onToggle: () => session.active
                  ? store.stopFasting(user.id)
                  : store.startFasting(user.id),
            )
                .animate()
                .fadeIn(delay: 90.ms, duration: 300.ms)
                .slideY(begin: 0.04, curve: Curves.easeOutCubic),
            const SizedBox(height: 14),
            SoftFastingPhasesCard(hours: hours, active: session.active)
                .animate()
                .fadeIn(delay: 110.ms, duration: 280.ms),
            const SizedBox(height: 12),
            const SoftFastingTipCard(
              title: 'Su serbest',
              body: 'Oruçta kalori yok: su, sade çay, şekersiz kahve. Sütlü kahve pencereyi bozar.',
              icon: Icons.water_drop_rounded,
              asset: DiyetselAssets.modernIconWaterDrop,
              accent: Color(0xFF5BA3C9),
            ).animate().fadeIn(delay: 130.ms, duration: 280.ms),
            const SizedBox(height: 10),
            const SoftFastingTipCard(
              title: 'Planla çakıştır',
              body: 'Kahvaltıyı geç, akşamı erken bitir. Diyet listen yeme penceresine sığmıyorsa diyetisyenine yaz.',
              icon: Icons.restaurant_rounded,
              asset: DiyetselAssets.modernIconPlan,
              accent: AppColors.primary,
            ).animate().fadeIn(delay: 150.ms, duration: 280.ms),
          ],
        ),
      ),
    );
  }
}
