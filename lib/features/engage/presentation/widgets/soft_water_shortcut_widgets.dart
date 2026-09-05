import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/diyetsel_assets.dart';
import '../../../dashboard/presentation/widgets/premium_home_widgets.dart' show SoftTap;
import '../../../dashboard/presentation/widgets/soft_home_widgets.dart' show SoftModernIcon;
import '../../domain/water_shortcut_visuals.dart';
import '../../../../core/widgets/nav_back.dart';


class SoftWaterShortcutHeader extends StatelessWidget {
  const SoftWaterShortcutHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SoftNavBackButton(),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Su kısayolu',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDeep,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Kalıcı bildirim & hızlı ekleme',
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
          child: const SoftModernIcon(
            DiyetselAssets.modernIconWaterDrop,
            size: 28,
            fallback: Icons.water_drop_rounded,
            fallbackColor: WaterShortcutVisuals.blue,
          ),
        ),
      ],
    );
  }
}

class SoftWaterShortcutHero extends StatelessWidget {
  const SoftWaterShortcutHero({
    super.key,
    required this.enabled,
    required this.supportsNative,
    required this.tip,
    required this.progress,
    required this.amountMl,
    required this.goalMl,
  });

  final bool enabled;
  final bool supportsNative;
  final String tip;
  final double progress;
  final int amountMl;
  final int goalMl;

  @override
  Widget build(BuildContext context) {
    final status = WaterShortcutVisuals.statusLabel(
      enabled: enabled,
      supportsNative: supportsNative,
    );
    final accent = WaterShortcutVisuals.statusAccent(enabled: enabled);
    final pct = (progress * 100).round().clamp(0, 100);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [WaterShortcutVisuals.sky, Color(0xFFFFF6E9), WaterShortcutVisuals.mint],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFB8DCEC)),
        boxShadow: [
          BoxShadow(
            color: WaterShortcutVisuals.blue.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      enabled ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
                      size: 14,
                      color: accent,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      status,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'Bugün %$pct',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: WaterShortcutVisuals.blueDeep,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$amountMl ml',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 32,
                        height: 1,
                        color: AppColors.primaryDeep,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hedef $goalMl ml',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.primary.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              const SoftModernIcon(
                DiyetselAssets.modernIconWaterBottle,
                size: 72,
                fallback: Icons.local_drink_rounded,
                fallbackColor: WaterShortcutVisuals.blue,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.75),
              color: WaterShortcutVisuals.blue,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFB8DCEC).withValues(alpha: 0.6)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_rounded, size: 18, color: WaterShortcutVisuals.blue.withValues(alpha: 0.85)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tip,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      height: 1.35,
                      color: AppColors.primaryDeep.withValues(alpha: 0.88),
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
}

class SoftWaterShortcutStatsRow extends StatelessWidget {
  const SoftWaterShortcutStatsRow({
    super.key,
    required this.remainingMl,
    required this.sipCount,
    required this.progress,
    required this.sipMl,
  });

  final int remainingMl;
  final int sipCount;
  final double progress;
  final int sipMl;

  @override
  Widget build(BuildContext context) {
    Widget stat(String label, String value, String asset, Color accent) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.modernLine),
            boxShadow: AppSpacing.soft,
          ),
          child: Column(
            children: [
              SoftModernIcon(
                asset,
                size: 22,
                fallback: Icons.water_drop_rounded,
                fallbackColor: accent,
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: accent,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        stat('Kalan', '$remainingMl ml', DiyetselAssets.modernIconWaterBottle, WaterShortcutVisuals.blue),
        const SizedBox(width: 8),
        stat('Yudum', '$sipCount×', DiyetselAssets.modernIconWaterDrop, AppColors.primary),
        const SizedBox(width: 8),
        stat('İlerleme', '${(progress * 100).round()}%', DiyetselAssets.modernIconStreak, const Color(0xFF5BA3C9)),
      ],
    );
  }
}

class SoftWaterShortcutToggleCard extends StatelessWidget {
  const SoftWaterShortcutToggleCard({
    super.key,
    required this.enabled,
    required this.supportsNative,
    required this.onToggle,
  });

  final bool enabled;
  final bool supportsNative;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final hint = WaterShortcutVisuals.platformMessage(
      supportsNative: supportsNative,
      enabled: enabled,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: WaterShortcutVisuals.sky,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(
                  enabled ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
                  color: WaterShortcutVisuals.blueDeep,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kalıcı su bildirimi',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: AppColors.primaryDeep,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Tek dokunuşla +250 ml',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                        color: Color(0x991A4F45),
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: enabled,
                activeTrackColor: WaterShortcutVisuals.blue.withValues(alpha: 0.45),
                activeThumbColor: WaterShortcutVisuals.blue,
                onChanged: (_) => onToggle(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            hint,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              height: 1.4,
              color: AppColors.primary.withValues(alpha: 0.62),
            ),
          ),
        ],
      ),
    );
  }
}

class SoftWaterShortcutPrimaryAdd extends StatelessWidget {
  const SoftWaterShortcutPrimaryAdd({
    super.key,
    required this.sipMl,
    required this.onAdd,
  });

  final int sipMl;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: onAdd,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              WaterShortcutVisuals.blue,
              WaterShortcutVisuals.blue.withValues(alpha: 0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: WaterShortcutVisuals.blue.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_rounded, color: Colors.white, size: 26),
            const SizedBox(width: 8),
            Text(
              '+$sipMl ml ekle',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 17,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SoftWaterShortcutQuickAdds extends StatelessWidget {
  const SoftWaterShortcutQuickAdds({super.key, required this.onAdd});

  final ValueChanged<int> onAdd;

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, int ml) {
      return Expanded(
        child: SoftTap(
          onTap: () => onAdd(ml),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFB8DCEC)),
              boxShadow: AppSpacing.soft,
            ),
            child: Column(
              children: [
                Text(
                  '+$ml',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: WaterShortcutVisuals.blueDeep,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hızlı miktarlar',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            color: AppColors.primaryDeep,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            chip('yudum', 200),
            const SizedBox(width: 8),
            chip('bardak', AppConstants.waterSipMl),
            const SizedBox(width: 8),
            chip('şişe', 500),
          ],
        ),
      ],
    );
  }
}

class SoftWaterShortcutNotificationPreview extends StatelessWidget {
  const SoftWaterShortcutNotificationPreview({
    super.key,
    required this.amountMl,
    required this.goalMl,
    required this.enabled,
  });

  final int amountMl;
  final int goalMl;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Bildirim önizleme',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: AppColors.primaryDeep,
                ),
              ),
              const Spacer(),
              if (!enabled)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.modernWash,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Kapalı',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 10.5,
                      color: AppColors.primary.withValues(alpha: 0.45),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Opacity(
            opacity: enabled ? 1 : 0.45,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE0E4EA)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: WaterShortcutVisuals.sky,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.water_drop_rounded, size: 16, color: WaterShortcutVisuals.blue),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Su • $amountMl / $goalMl ml',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 38),
                    child: Text(
                      'Hızlı eklemek için +${AppConstants.waterSipMl} ml',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.black.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFD0D5DD)),
                    ),
                    child: Text(
                      '+${AppConstants.waterSipMl} ml',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                        color: WaterShortcutVisuals.blueDeep,
                      ),
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

class SoftWaterShortcutStepsCard extends StatelessWidget {
  const SoftWaterShortcutStepsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [WaterShortcutVisuals.mint, Colors.white],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nasıl çalışır?',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              color: AppColors.primaryDeep,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < WaterShortcutVisuals.steps.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _StepRow(
              index: i + 1,
              icon: WaterShortcutVisuals.steps[i].$1,
              title: WaterShortcutVisuals.steps[i].$2,
              body: WaterShortcutVisuals.steps[i].$3,
            ),
          ],
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.index,
    required this.icon,
    required this.title,
    required this.body,
  });

  final int index;
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: WaterShortcutVisuals.sky,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFB8DCEC)),
          ),
          alignment: Alignment.center,
          child: Text(
            '$index',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              color: WaterShortcutVisuals.blueDeep,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: WaterShortcutVisuals.blue),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5,
                      color: AppColors.primaryDeep,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                body,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                  height: 1.35,
                  color: AppColors.primary.withValues(alpha: 0.58),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SoftWaterShortcutTipCard extends StatelessWidget {
  const SoftWaterShortcutTipCard({
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: SoftModernIcon(
              asset,
              size: 24,
              fallback: icon,
              fallbackColor: accent,
            ),
          ),
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
                    color: AppColors.primary.withValues(alpha: 0.6),
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

class SoftWaterShortcutTrackerLink extends StatelessWidget {
  const SoftWaterShortcutTrackerLink({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE3F2F8), Color(0xFFE8F5F0)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFB8DCEC)),
        ),
        child: Row(
          children: [
            const SoftModernIcon(
              DiyetselAssets.modernIconWaterBottle,
              size: 36,
              fallback: Icons.analytics_outlined,
              fallbackColor: WaterShortcutVisuals.blue,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detaylı su takibi',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: AppColors.primaryDeep,
                    ),
                  ),
                  Text(
                    'Haftalık grafik, vücut ölçümü ve öğün fotoğrafı',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColors.primary.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: AppColors.primary.withValues(alpha: 0.45)),
          ],
        ),
      ),
    );
  }
}
