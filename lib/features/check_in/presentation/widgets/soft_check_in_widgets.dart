import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/diyetsel_assets.dart';
import '../../../../core/models/models.dart';
import '../../../dashboard/presentation/widgets/premium_home_widgets.dart' show SoftTap;
import '../../../dashboard/presentation/widgets/soft_home_widgets.dart' show SoftModernIcon;
import '../../domain/check_in_visuals.dart';
import '../../../../core/widgets/nav_back.dart';


class SoftCheckInHeader extends StatelessWidget {
  const SoftCheckInHeader({super.key});

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
                'Check-in',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDeep,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Haftalık kilo, bel ve ruh hali',
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
            DiyetselAssets.modernIconDietScale,
            size: 28,
            fallback: Icons.favorite_rounded,
            fallbackColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class SoftCheckInHero extends StatelessWidget {
  const SoftCheckInHero({
    super.key,
    required this.due,
    required this.last,
    required this.count,
  });

  final bool due;
  final WeeklyCheckIn? last;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: due
              ? const [Color(0xFFFFF0E8), Color(0xFFFFF6E9)]
              : const [Color(0xFFE8F5F0), Color(0xFFFFF6E9), Color(0xFFE3F2F8)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: [
          BoxShadow(
            color: (due ? const Color(0xFFE07A5F) : AppColors.primary).withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: (due ? const Color(0xFFE07A5F) : AppColors.primary).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    due ? 'Haftalık ritim' : 'Güncel',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                      color: due ? const Color(0xFFE07A5F) : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  due ? 'Check-in zamanı' : 'Bu hafta tamam',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    height: 1.15,
                    color: AppColors.primaryDeep,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  last == null
                      ? 'Kilo, bel, uyku ve ruh halini gönder — diyetisyenin paneline düşer.'
                      : count == 1
                          ? 'İlk kaydın ${DateFormat('d MMM', 'tr').format(last!.createdAt)} tarihinde.'
                          : '$count kayıt · son ${DateFormat('d MMM', 'tr').format(last!.createdAt)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.35,
                    color: AppColors.primaryDeep.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          SoftModernIcon(
            DiyetselAssets.modernIconDietScale,
            size: 72,
            fallback: Icons.monitor_weight_outlined,
            fallbackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class SoftCheckInStatsRow extends StatelessWidget {
  const SoftCheckInStatsRow({
    super.key,
    required this.count,
    required this.daysSince,
    required this.due,
  });

  final int count;
  final int? daysSince;
  final bool due;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Kayıt', '$count', DiyetselAssets.modernIconCheck, Icons.favorite_rounded, AppColors.primary),
      (
        'Son',
        daysSince == null ? '—' : '$daysSince g',
        DiyetselAssets.modernIconCalendar,
        Icons.schedule_rounded,
        const Color(0xFF5BA3C9),
      ),
      (
        'Durum',
        due ? 'Bekliyor' : 'Tamam',
        DiyetselAssets.modernIconBell,
        Icons.flag_rounded,
        due ? const Color(0xFFE07A5F) : AppColors.primary,
      ),
    ];
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.modernLine),
                boxShadow: AppSpacing.soft,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SoftModernIcon(
                    items[i].$3,
                    size: 24,
                    fallback: items[i].$4,
                    fallbackColor: items[i].$5,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    items[i].$1,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11.5,
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    items[i].$2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: items[i].$5,
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

class SoftDietitianNoteCard extends StatelessWidget {
  const SoftDietitianNoteCard({super.key, required this.note, this.at});

  final String note;
  final DateTime? at;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE3F2F8), Color(0xFFE8F5F0)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFB8DCEC)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SoftModernIcon(
            DiyetselAssets.modernIconService,
            size: 36,
            fallback: Icons.chat_bubble_rounded,
            fallbackColor: const Color(0xFF5BA3C9),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Diyetisyenin notu',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: AppColors.primaryDeep,
                  ),
                ),
                if (at != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('d MMM y', 'tr').format(at!),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  note,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: AppColors.primaryDeep.withValues(alpha: 0.88),
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

class SoftCheckInTrendRow extends StatelessWidget {
  const SoftCheckInTrendRow({
    super.key,
    required this.weightDelta,
    required this.waistDelta,
    required this.lastMood,
  });

  final double? weightDelta;
  final double? waistDelta;
  final int? lastMood;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (weightDelta != null)
          Expanded(
            child: SoftTrendChip(
              icon: weightDelta! <= 0 ? Icons.trending_down_rounded : Icons.trending_up_rounded,
              accent: weightDelta! <= 0 ? AppColors.primary : const Color(0xFFE07A5F),
              label: 'Kilo',
              value: '${weightDelta! <= 0 ? '' : '+'}${weightDelta!.toStringAsFixed(1)} kg',
            ),
          ),
        if (weightDelta != null && waistDelta != null) const SizedBox(width: 8),
        if (waistDelta != null)
          Expanded(
            child: SoftTrendChip(
              icon: Icons.straighten_rounded,
              accent: const Color(0xFF5BA3C9),
              label: 'Bel',
              value: '${waistDelta! <= 0 ? '' : '+'}${waistDelta!.toStringAsFixed(1)} cm',
            ),
          ),
        if (lastMood != null) ...[
          const SizedBox(width: 8),
          Expanded(
            child: SoftTrendChip(
              icon: CheckInVisuals.moodMeta(lastMood!).$1,
              accent: CheckInVisuals.softAccentForMood(lastMood!),
              label: 'Ruh hali',
              value: CheckInVisuals.moodMeta(lastMood!).$2,
            ),
          ),
        ],
      ],
    );
  }
}

class SoftTrendChip extends StatelessWidget {
  const SoftTrendChip({
    super.key,
    required this.icon,
    required this.accent,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color accent;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Color.lerp(accent, Colors.white, 0.82),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: accent),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              color: AppColors.primaryDeep,
            ),
          ),
        ],
      ),
    );
  }
}

class SoftCheckInFormCard extends StatelessWidget {
  const SoftCheckInFormCard({
    super.key,
    required this.weight,
    required this.waist,
    required this.sleep,
    required this.note,
    required this.mood,
    required this.energy,
    required this.adherence,
    required this.photo,
    required this.tags,
    required this.saving,
    required this.onMood,
    required this.onEnergy,
    required this.onAdherence,
    required this.onToggleTag,
    required this.onPickPhoto,
    required this.onClearPhoto,
    required this.onSubmit,
  });

  final TextEditingController weight;
  final TextEditingController waist;
  final TextEditingController sleep;
  final TextEditingController note;
  final int mood;
  final int energy;
  final int adherence;
  final String? photo;
  final Set<String> tags;
  final bool saving;
  final ValueChanged<int> onMood;
  final ValueChanged<int> onEnergy;
  final ValueChanged<int> onAdherence;
  final ValueChanged<String> onToggleTag;
  final VoidCallback onPickPhoto;
  final VoidCallback onClearPhoto;
  final VoidCallback onSubmit;

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
          const Text(
            'Bu haftanın ölçümleri',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: AppColors.primaryDeep,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sabah, tuvalet sonrası tartıl — daha tutarlı olur.',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: weight,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Kilo (kg)',
                    prefixIcon: Icon(Icons.monitor_weight_rounded, color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: waist,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Bel (cm)',
                    prefixIcon: Icon(Icons.straighten_rounded, color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: sleep,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Ortalama uyku (saat)',
              prefixIcon: Icon(Icons.bedtime_rounded, color: AppColors.primary),
              hintText: 'Örn. 7.5',
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ruh hali',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.primaryDeep),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < CheckInVisuals.moods.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: SoftTap(
                    onTap: () => onMood(i + 1),
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: mood == i + 1
                            ? CheckInVisuals.softTintForMood(i + 1)
                            : AppColors.modernWash,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: mood == i + 1
                              ? CheckInVisuals.softAccentForMood(i + 1)
                              : AppColors.modernLine,
                          width: mood == i + 1 ? 1.6 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            CheckInVisuals.moods[i].$1,
                            color: CheckInVisuals.softAccentForMood(i + 1),
                            size: 22,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CheckInVisuals.moods[i].$2,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 9.5,
                              color: mood == i + 1
                                  ? AppColors.primaryDeep
                                  : AppColors.primary.withValues(alpha: 0.45),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          SoftScaleRow(
            title: 'Enerji',
            valueLabel: CheckInVisuals.energyLabels[energy - 1],
            value: energy,
            onChanged: onEnergy,
            color: const Color(0xFF5BA3C9),
          ),
          const SizedBox(height: 10),
          SoftScaleRow(
            title: 'Diyet uyumu',
            valueLabel: CheckInVisuals.adherenceLabels[adherence - 1],
            value: adherence,
            onChanged: onAdherence,
            color: AppColors.primary,
          ),
          const SizedBox(height: 14),
          const Text(
            'Bu haftayı etiketle',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.primaryDeep),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in CheckInVisuals.quickTags)
                SoftTap(
                  onTap: () => onToggleTag(t),
                  borderRadius: BorderRadius.circular(999),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: tags.contains(t) ? AppColors.primary : AppColors.modernWash,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: tags.contains(t) ? AppColors.primary : AppColors.modernLine,
                      ),
                    ),
                    child: Text(
                      t,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: tags.contains(t) ? Colors.white : AppColors.primaryDeep,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: note,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Not',
              hintText: 'Uyku, spor, zorlandığın öğün…',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          if (photo != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(File(photo!), height: 140, width: double.infinity, fit: BoxFit.cover),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onClearPhoto,
                child: Text(
                  'Fotoğrafı kaldır',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary.withValues(alpha: 0.65),
                  ),
                ),
              ),
            ),
          ] else
            SoftTap(
              onTap: onPickPhoto,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.modernWash,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.modernLine),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SoftModernIcon(
                      DiyetselAssets.modernIconPlan,
                      size: 22,
                      fallback: Icons.add_a_photo_rounded,
                      fallbackColor: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Fotoğraf ekle (isteğe bağlı)',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          SoftTap(
            onTap: saving ? null : onSubmit,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  saving ? 'Gönderiliyor…' : 'Check-in gönder',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SoftScaleRow extends StatelessWidget {
  const SoftScaleRow({
    super.key,
    required this.title,
    required this.valueLabel,
    required this.value,
    required this.onChanged,
    required this.color,
  });

  final String title;
  final String valueLabel;
  final int value;
  final ValueChanged<int> onChanged;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryDeep),
            ),
            const Spacer(),
            Text(
              valueLabel,
              style: TextStyle(fontWeight: FontWeight.w800, color: color),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            thumbColor: color,
            inactiveTrackColor: color.withValues(alpha: 0.18),
            overlayColor: color.withValues(alpha: 0.12),
          ),
          child: Slider(
            value: value.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
      ],
    );
  }
}

class SoftCheckInTipCard extends StatelessWidget {
  const SoftCheckInTipCard({super.key, required this.tip});

  final String tip;

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
          SoftModernIcon(
            DiyetselAssets.modernIconBell,
            size: 28,
            fallback: Icons.lightbulb_outline_rounded,
            fallbackColor: const Color(0xFFD4A017),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Neden önemli?',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: AppColors.primaryDeep,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.4,
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

class SoftCheckInHistoryCard extends StatelessWidget {
  const SoftCheckInHistoryCard({
    super.key,
    required this.log,
    required this.onOpen,
    this.previous,
    this.index = 0,
  });

  final WeeklyCheckIn log;
  final WeeklyCheckIn? previous;
  final VoidCallback onOpen;
  final int index;

  @override
  Widget build(BuildContext context) {
    final mood = CheckInVisuals.moodMeta(log.mood);
    final accent = CheckInVisuals.softAccentForMood(log.mood);
    double? wDelta;
    if (log.weight != null && previous?.weight != null) {
      wDelta = log.weight! - previous!.weight!;
    }

    return SoftTap(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.modernLine),
          boxShadow: AppSpacing.soft,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: CheckInVisuals.softTintForMood(log.mood),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: accent.withValues(alpha: 0.25)),
              ),
              child: Icon(mood.$1, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('d MMMM y', 'tr').format(log.createdAt),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14.5,
                      color: AppColors.primaryDeep,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    CheckInVisuals.summaryLine(log),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                      color: AppColors.primary.withValues(alpha: 0.55),
                    ),
                  ),
                  if (wDelta != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Kilo ${wDelta <= 0 ? '' : '+'}${wDelta.toStringAsFixed(1)} kg',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: wDelta <= 0 ? AppColors.primary : const Color(0xFFE07A5F),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.primary.withValues(alpha: 0.35)),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (40 * index).ms, duration: 260.ms).slideY(
          begin: 0.04,
          curve: Curves.easeOutCubic,
        );
  }
}

class SoftCheckInEmptyHistory extends StatelessWidget {
  const SoftCheckInEmptyHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.modernLine),
      ),
      child: Column(
        children: [
          SoftModernIcon(
            DiyetselAssets.modernIconDietScale,
            size: 44,
            fallback: Icons.favorite_outline_rounded,
            fallbackColor: AppColors.primary.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 10),
          const Text(
            'Henüz check-in yok',
            style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryDeep),
          ),
          const SizedBox(height: 4),
          Text(
            'İlk kaydını yukarıdan gönder.',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class SoftCheckInDetailSheet extends StatelessWidget {
  const SoftCheckInDetailSheet({
    super.key,
    required this.log,
    this.previous,
  });

  final WeeklyCheckIn log;
  final WeeklyCheckIn? previous;

  @override
  Widget build(BuildContext context) {
    final mood = CheckInVisuals.moodMeta(log.mood);
    final accent = CheckInVisuals.softAccentForMood(log.mood);
    double? wDelta;
    double? waistDelta;
    if (log.weight != null && previous?.weight != null) wDelta = log.weight! - previous!.weight!;
    if (log.waist != null && previous?.waist != null) waistDelta = log.waist! - previous!.waist!;

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.45,
      maxChildSize: 0.94,
      builder: (context, scroll) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.modernWash,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: scroll,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppColors.modernLine,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      CheckInVisuals.softTintForMood(log.mood),
                      const Color(0xFFFFF6E9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.modernLine),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.modernLine),
                      ),
                      child: Icon(mood.$1, size: 32, color: accent),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      DateFormat('d MMMM y', 'tr').format(log.createdAt),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: AppColors.primaryDeep,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mood.$2,
                      style: TextStyle(fontWeight: FontWeight.w800, color: accent),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (log.weight != null)
                    SoftDetailPill(label: 'Kilo', value: '${log.weight!.toStringAsFixed(1)} kg'),
                  if (log.waist != null)
                    SoftDetailPill(label: 'Bel', value: '${log.waist!.toStringAsFixed(0)} cm'),
                  if (log.sleepHours != null)
                    SoftDetailPill(label: 'Uyku', value: '${log.sleepHours!.toStringAsFixed(1)} sa'),
                  SoftDetailPill(label: 'Enerji', value: CheckInVisuals.energyLabels[log.energy - 1]),
                  SoftDetailPill(label: 'Uyumu', value: CheckInVisuals.adherenceLabels[log.adherence - 1]),
                ],
              ),
              if (wDelta != null || waistDelta != null) ...[
                const SizedBox(height: 14),
                SoftCheckInTrendRow(
                  weightDelta: wDelta,
                  waistDelta: waistDelta,
                  lastMood: log.mood,
                ),
              ],
              if (log.tags.isNotEmpty) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in log.tags)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.modernLine),
                        ),
                        child: Text(
                          t,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: AppColors.primary.withValues(alpha: 0.75),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
              if (log.note.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Not',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.primaryDeep),
                ),
                const SizedBox(height: 6),
                Text(
                  log.note,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    color: AppColors.primaryDeep.withValues(alpha: 0.85),
                  ),
                ),
              ],
              if (log.dietitianNote != null && log.dietitianNote!.isNotEmpty) ...[
                const SizedBox(height: 16),
                SoftDietitianNoteCard(note: log.dietitianNote!, at: log.dietitianNoteAt),
              ],
              if (log.photoPath != null) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.file(File(log.photoPath!), height: 180, width: double.infinity, fit: BoxFit.cover),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class SoftDetailPill extends StatelessWidget {
  const SoftDetailPill({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.modernLine),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label · ',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: AppColors.primaryDeep,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
