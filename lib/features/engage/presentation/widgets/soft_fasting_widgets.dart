import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/diyetsel_assets.dart';
import '../../../../core/models/models.dart';
import '../../../dashboard/presentation/widgets/premium_home_widgets.dart' show SoftTap;
import '../../../dashboard/presentation/widgets/soft_home_widgets.dart' show SoftModernIcon;
import '../../domain/fasting_visuals.dart';

class SoftFastingHeader extends StatelessWidget {
  const SoftFastingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SoftTap(
          onTap: () => Navigator.maybePop(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.modernLine),
              boxShadow: AppSpacing.soft,
            ),
            child: Icon(Icons.arrow_back_rounded, color: AppColors.primary.withValues(alpha: 0.75)),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aralıklı oruç',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDeep,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '16:8 pencere takibi',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0x991A4F45),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: AppColors.modernLine),
            boxShadow: AppSpacing.soft,
          ),
          padding: const EdgeInsets.all(10),
          child: SoftModernIcon(
            DiyetselAssets.modernIconStreak,
            size: 28,
            fallback: Icons.hourglass_bottom_rounded,
            fallbackColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class SoftFastingHero extends StatelessWidget {
  const SoftFastingHero({
    super.key,
    required this.active,
    required this.tip,
    required this.phaseTitle,
  });

  final bool active;
  final String tip;
  final String phaseTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F5F0), Color(0xFFFFF6E9), Color(0xFFE3F2F8)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    active ? phaseTitle : '16:8 penceresi',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  active ? 'Oruç devam ediyor' : 'Orucu başlat',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    height: 1.15,
                    color: AppColors.primaryDeep,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tip,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.35,
                    color: AppColors.primary.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          SoftModernIcon(
            DiyetselAssets.modernIconWaterBottle,
            size: 64,
            fallback: Icons.hourglass_top_rounded,
            fallbackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class SoftFastingStatsRow extends StatelessWidget {
  const SoftFastingStatsRow({
    super.key,
    required this.hours,
    required this.mins,
    required this.progress,
    required this.remainingHours,
    required this.active,
  });

  final int hours;
  final int mins;
  final double progress;
  final double remainingHours;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();
    final items = [
      (Icons.timer_rounded, DiyetselAssets.modernIconStreak, const Color(0xFFE07A5F), 'Geçen', active ? '$hours sa' : '—'),
      (Icons.hourglass_empty_rounded, DiyetselAssets.modernIconPlan, AppColors.primary, 'Kalan', active ? '${remainingHours.toStringAsFixed(1)} sa' : '16 sa'),
      (Icons.percent_rounded, DiyetselAssets.modernIconCheck, const Color(0xFF5BA3C9), 'İlerleme', active ? '%$pct' : '—'),
      (Icons.restaurant_rounded, DiyetselAssets.modernIconWaterDrop, const Color(0xFFD4A017), 'Yeme', '8 sa'),
    ];

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.modernLine),
                boxShadow: AppSpacing.soft,
              ),
              child: Column(
                children: [
                  SoftModernIcon(
                    items[i].$2,
                    size: 22,
                    fallback: items[i].$1,
                    fallbackColor: items[i].$3,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    items[i].$5,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: items[i].$3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    items[i].$4,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 10.5,
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class SoftFastingTimerCard extends StatelessWidget {
  const SoftFastingTimerCard({
    super.key,
    required this.session,
    required this.hours,
    required this.mins,
    required this.phase,
    required this.onToggle,
  });

  final FastingSession session;
  final int hours;
  final int mins;
  final FastingPhaseInfo phase;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final remaining = ((1 - session.progress) * session.windowHours).clamp(0, session.windowHours.toDouble());
    final phaseIdx = FastingVisuals.phaseIndex(hours);
    final accent = FastingVisuals.phaseAccent(phaseIdx);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            width: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 180,
                  width: 180,
                  child: CircularProgressIndicator(
                    value: session.active ? session.progress : 0,
                    strokeWidth: 12,
                    color: accent,
                    backgroundColor: accent.withValues(alpha: 0.12),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SoftModernIcon(
                      DiyetselAssets.modernIconStreak,
                      size: 28,
                      fallback: session.active ? Icons.hourglass_top_rounded : Icons.play_circle_rounded,
                      fallbackColor: accent,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      session.active ? '$hours sa $mins dk' : 'Hazır',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: AppColors.primaryDeep,
                      ),
                    ),
                    Text(
                      session.active
                          ? 'kalan ~${remaining.toStringAsFixed(1)} sa'
                          : '${session.windowHours} saatlik tur',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                        color: AppColors.primary.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            session.active ? phase.title : 'Orucu başlat, süre aksın.',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: AppColors.primaryDeep,
            ),
          ),
          if (session.active) ...[
            const SizedBox(height: 6),
            Text(
              phase.body,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                height: 1.35,
                color: AppColors.primary.withValues(alpha: 0.6),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SoftTap(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: session.active ? const Color(0xFFE07A5F) : AppColors.primary,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: (session.active ? const Color(0xFFE07A5F) : AppColors.primary).withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    session.active ? Icons.stop_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    session.active ? 'Orucu bitir' : '16 saat başlat',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SoftFastingWindowCard extends StatelessWidget {
  const SoftFastingWindowCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF8E8), Color(0xFFE8F5F0)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: Row(
        children: [
          Expanded(
            child: _WindowBlock(
              hours: '16',
              label: 'Oruç',
              sub: 'Kalori yok',
              accent: AppColors.primary,
              tint: const Color(0xFFE8F5F0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.swap_horiz_rounded, color: AppColors.primary.withValues(alpha: 0.45)),
          ),
          Expanded(
            child: _WindowBlock(
              hours: '8',
              label: 'Yeme',
              sub: 'Planına uy',
              accent: const Color(0xFFD4A017),
              tint: const Color(0xFFFFF8E8),
            ),
          ),
        ],
      ),
    );
  }
}

class _WindowBlock extends StatelessWidget {
  const _WindowBlock({
    required this.hours,
    required this.label,
    required this.sub,
    required this.accent,
    required this.tint,
  });

  final String hours;
  final String label;
  final String sub;
  final Color accent;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(
            hours,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 28,
              color: accent,
              height: 1,
            ),
          ),
          Text(
            'saat',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 11,
              color: accent.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              color: AppColors.primaryDeep,
            ),
          ),
          Text(
            sub,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class SoftFastingPhasesCard extends StatelessWidget {
  const SoftFastingPhasesCard({
    super.key,
    required this.hours,
    required this.active,
  });

  final int hours;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fazlar',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15,
              color: AppColors.primaryDeep,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Saat ilerledikçe vurgu değişir',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < FastingVisuals.phases.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _PhaseRow(
              range: FastingVisuals.phases[i].$2,
              title: FastingVisuals.phases[i].$3,
              icon: FastingVisuals.phases[i].$4,
              reached: active && hours >= FastingVisuals.phases[i].$1,
              current: active && FastingVisuals.phaseIndex(hours) == i,
              index: i,
            ),
          ],
        ],
      ),
    );
  }
}

class _PhaseRow extends StatelessWidget {
  const _PhaseRow({
    required this.range,
    required this.title,
    required this.icon,
    required this.reached,
    required this.current,
    required this.index,
  });

  final String range;
  final String title;
  final IconData icon;
  final bool reached;
  final bool current;
  final int index;

  @override
  Widget build(BuildContext context) {
    final accent = FastingVisuals.phaseAccent(index);
    final tint = FastingVisuals.phaseTint(index);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: current ? tint : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: current ? Border.all(color: accent.withValues(alpha: 0.35)) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: reached ? accent.withValues(alpha: 0.15) : AppColors.modernWash,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              reached ? Icons.check_circle_rounded : icon,
              size: 18,
              color: reached ? accent : AppColors.primary.withValues(alpha: 0.35),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            range,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: reached ? accent : AppColors.primary.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.primaryDeep.withValues(alpha: reached ? 1 : 0.65),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SoftFastingTipCard extends StatelessWidget {
  const SoftFastingTipCard({
    super.key,
    required this.title,
    required this.body,
    required this.icon,
    required this.asset,
    required this.accent,
  });

  final String title;
  final String body;
  final IconData icon;
  final String asset;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SoftModernIcon(asset, size: 32, fallback: icon, fallbackColor: accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: AppColors.primaryDeep,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.35,
                    color: AppColors.primary.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
