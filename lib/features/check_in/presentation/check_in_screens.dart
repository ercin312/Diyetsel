import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/diyetsel_assets.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/app_modules.dart';
import '../../../core/models/models.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/diyetsel_widgets.dart';
import '../../../core/widgets/module_gate.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../dashboard/presentation/widgets/premium_home_widgets.dart';
import '../../gamification/presentation/gamification_screens.dart';
import '../../../core/utils/smart_notification_service.dart';
import '../domain/check_in_visuals.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key});

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  final _weight = TextEditingController();
  final _waist = TextEditingController();
  final _sleep = TextEditingController();
  final _note = TextEditingController();
  int _mood = 3;
  int _energy = 3;
  int _adherence = 3;
  String? _photo;
  final Set<String> _tags = {};
  bool _prefilled = false;
  bool _saving = false;

  @override
  void dispose() {
    _weight.dispose();
    _waist.dispose();
    _sleep.dispose();
    _note.dispose();
    super.dispose();
  }

  void _prefillFrom(WeeklyCheckIn? last) {
    if (_prefilled || last == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _prefilled) return;
      setState(() {
        _prefilled = true;
        if (last.weight != null) _weight.text = last.weight!.toStringAsFixed(1);
        if (last.waist != null) _waist.text = last.waist!.toStringAsFixed(0);
        if (last.sleepHours != null) _sleep.text = last.sleepHours!.toStringAsFixed(1);
        _mood = last.mood;
        _energy = last.energy;
        _adherence = last.adherence;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final locked = lockedIfOff(ref, module: AppModule.checkIn, title: 'Haftalık check-in');
    if (locked != null) return locked;

    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    final logs = (ref.watch(checkInsProvider).valueOrNull ?? []).where((e) => e.userId == user.id).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final last = logs.firstOrNull;
    final prev = logs.length >= 2 ? logs[1] : null;
    _prefillFrom(last);

    final weightDelta = last?.weight != null && prev?.weight != null ? last!.weight! - prev!.weight! : null;
    final waistDelta = last?.waist != null && prev?.waist != null ? last!.waist! - prev!.waist! : null;
    final daysSince = last == null ? null : DateTime.now().difference(last.createdAt).inDays;
    final due = daysSince == null || daysSince >= 6;
    final cartoon = context.isCartoon;

    if (cartoon) {
      return AppPage(
        title: 'Check-in',
        padding: EdgeInsets.zero,
        child: ColoredBox(
          color: AppColors.kawaiiSurfaceCream,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            children: [
              _CheckInHero(
                due: due,
                last: last,
                count: logs.length,
              )
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: -0.04, curve: Curves.easeOutCubic),
              const SizedBox(height: 14),
              if (last?.dietitianNote != null) ...[
                _DietitianNoteCard(note: last!.dietitianNote!, at: last.dietitianNoteAt)
                    .animate()
                    .fadeIn(delay: 40.ms, duration: 280.ms),
                const SizedBox(height: 12),
              ],
              if (weightDelta != null || waistDelta != null) ...[
                _TrendRow(weightDelta: weightDelta, waistDelta: waistDelta, lastMood: last?.mood)
                    .animate()
                    .fadeIn(delay: 60.ms, duration: 280.ms),
                const SizedBox(height: 14),
              ],
              _FormCard(
                weight: _weight,
                waist: _waist,
                sleep: _sleep,
                note: _note,
                mood: _mood,
                energy: _energy,
                adherence: _adherence,
                photo: _photo,
                tags: _tags,
                saving: _saving,
                onMood: (v) => setState(() => _mood = v),
                onEnergy: (v) => setState(() => _energy = v),
                onAdherence: (v) => setState(() => _adherence = v),
                onToggleTag: (t) => setState(() {
                  if (_tags.contains(t)) {
                    _tags.remove(t);
                  } else {
                    _tags.add(t);
                  }
                }),
                onPickPhoto: () async {
                  final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
                  if (file != null) setState(() => _photo = file.path);
                },
                onClearPhoto: () => setState(() => _photo = null),
                onSubmit: () => _submit(context, store, user),
              ).animate().fadeIn(delay: 80.ms, duration: 300.ms),
              const SizedBox(height: 14),
              _WhyCard(tip: CheckInVisuals.tipOfWeek(DateTime.now().day))
                  .animate()
                  .fadeIn(delay: 110.ms, duration: 280.ms),
              const SizedBox(height: 16),
              const Text(
                'Geçmiş check-in’ler',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.kawaiiInk),
              ),
              const SizedBox(height: 10),
              if (logs.isEmpty)
                const _EmptyHistory()
              else
                for (var i = 0; i < logs.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _HistoryCard(
                      log: logs[i],
                      previous: i + 1 < logs.length ? logs[i + 1] : null,
                      onOpen: () => _openDetail(context, logs[i], i + 1 < logs.length ? logs[i + 1] : null),
                    )
                        .animate()
                        .fadeIn(delay: (40 * i).ms, duration: 260.ms)
                        .slideY(begin: 0.04, curve: Curves.easeOutCubic),
                  ),
            ],
          ),
        ),
      );
    }

    // Modern / luxury fallback — richer form
    return AppPage(
      title: 'Haftalık check-in',
      child: ListView(
        children: [
          FeatureBanner(
            icon: Icons.favorite_rounded,
            emoji: '❤️',
            title: due ? 'Bu haftanın check-in’i bekliyor' : 'İlerlemen kayda geçiyor',
            subtitle: last == null
                ? 'Kilo, bel, uyku ve ruh halini gönder; diyetisyenin paneline düşer.'
                : 'Son kayıt ${DateFormat('d MMMM', 'tr').format(last.createdAt)}',
          ),
          const SizedBox(height: 12),
          DiyetselCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Ölçümler', subtitle: 'Sabah, tuvalet sonrası daha tutarlıdır.'),
                TextField(
                  controller: _weight,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Kilo (kg)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _waist,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Bel çevresi (cm)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _sleep,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Uyku (saat)'),
                ),
                const SizedBox(height: 12),
                const Text('Ruh hali', style: TextStyle(fontWeight: FontWeight.w800)),
                Wrap(
                  spacing: 8,
                  children: [
                    for (var i = 0; i < CheckInVisuals.moods.length; i++)
                      ChoiceChip(
                        selected: _mood == i + 1,
                        label: Text(CheckInVisuals.moods[i].$2),
                        onSelected: (_) => setState(() => _mood = i + 1),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Enerji: ${CheckInVisuals.energyLabels[_energy - 1]}'),
                Slider(
                  value: _energy.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: (v) => setState(() => _energy = v.round()),
                ),
                Text('Diyet uyumu: ${CheckInVisuals.adherenceLabels[_adherence - 1]}'),
                Slider(
                  value: _adherence.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: (v) => setState(() => _adherence = v.round()),
                ),
                TextField(controller: _note, maxLines: 3, decoration: const InputDecoration(labelText: 'Not')),
                const SizedBox(height: 8),
                DiyetselButton(
                  label: _saving ? 'Gönderiliyor…' : 'Check-in gönder',
                  icon: Icons.send,
                  onPressed: () {
                    if (!_saving) _submit(context, store, user);
                  },
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'Geçmiş'),
          if (logs.isEmpty)
            const EmptyState(icon: Icons.favorite, title: 'Henüz check-in yok')
          else
            for (final log in logs)
              DiyetselCard(
                onTap: () => _openDetail(context, log, null),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(DateFormat('d MMMM y', 'tr').format(log.createdAt)),
                  subtitle: Text(CheckInVisuals.summaryLine(log)),
                ),
              ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context, AppStore store, UserProfile user) async {
    setState(() => _saving = true);
    try {
      await store.saveCheckIn(
        WeeklyCheckIn(
          id: newId(),
          userId: user.id,
          userName: user.displayName,
          createdAt: DateTime.now(),
          weight: double.tryParse(_weight.text.replaceAll(',', '.')),
          waist: double.tryParse(_waist.text.replaceAll(',', '.')),
          sleepHours: double.tryParse(_sleep.text.replaceAll(',', '.')),
          mood: _mood,
          energy: _energy,
          adherence: _adherence,
          note: _note.text.trim(),
          photoPath: _photo,
          tags: _tags.toList(),
        ),
      );
      await AchievementService.instance.checkAndAward(store, user.id);
      if (context.mounted) {
        await maybeShowBadgeCelebrations(context, ref, user.id);
      }
      if (context.mounted) {
        _note.clear();
        _photo = null;
        _tags.clear();
        _prefilled = false;
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Check-in diyetisyen paneline düştü')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _openDetail(BuildContext context, WeeklyCheckIn log, WeeklyCheckIn? previous) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CheckInDetailSheet(log: log, previous: previous),
    );
  }
}

class _CheckInHero extends StatelessWidget {
  const _CheckInHero({required this.due, required this.last, required this.count});

  final bool due;
  final WeeklyCheckIn? last;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 10, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: due
              ? const [AppColors.kawaiiPeach, AppColors.kawaiiSurfaceCream, AppColors.kawaiiRose]
              : const [AppColors.kawaiiMint, AppColors.kawaiiSurfaceCream, AppColors.kawaiiLilac],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
        border: Border.all(color: AppColors.kawaiiOutline),
        boxShadow: AppSpacing.soft,
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
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    due ? 'Haftalık ritim' : 'Güncel',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: AppColors.kawaiiLeafDeep),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  due ? 'Check-in zamanı' : 'Bu hafta tamam',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, height: 1.15, color: AppColors.kawaiiInk),
                ),
                const SizedBox(height: 6),
                Text(
                  last == null
                      ? 'Kilo, bel, uyku ve ruh halini gönder — diyetisyenin paneline düşer.'
                      : count == 1
                          ? 'İlk kaydın ${DateFormat('d MMM', 'tr').format(last!.createdAt)} tarihinde.'
                          : '$count kayıt · son ${DateFormat('d MMM', 'tr').format(last!.createdAt)}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 1.35, color: AppColors.kawaiiMuted),
                ),
              ],
            ),
          ),
          Image.asset(DiyetselAssets.characterWoman, height: 92, fit: BoxFit.contain),
        ],
      ),
    );
  }
}

class _DietitianNoteCard extends StatelessWidget {
  const _DietitianNoteCard({required this.note, this.at});

  final String note;
  final DateTime? at;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.kawaiiLilac,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.kawaiiOutline),
        boxShadow: AppSpacing.soft,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.chat_bubble_rounded, color: AppColors.kawaiiPurple, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Diyetisyenin notu', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.kawaiiInk)),
                if (at != null) ...[
                  const SizedBox(height: 2),
                  Text(DateFormat('d MMM y', 'tr').format(at!), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: AppColors.kawaiiMuted)),
                ],
                const SizedBox(height: 6),
                Text(note, style: const TextStyle(fontWeight: FontWeight.w600, height: 1.4, color: AppColors.kawaiiInk)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendRow extends StatelessWidget {
  const _TrendRow({required this.weightDelta, required this.waistDelta, required this.lastMood});

  final double? weightDelta;
  final double? waistDelta;
  final int? lastMood;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (weightDelta != null)
          Expanded(
            child: _TrendChip(
              icon: weightDelta! <= 0 ? Icons.trending_down_rounded : Icons.trending_up_rounded,
              tint: weightDelta! <= 0 ? AppColors.kawaiiMint : AppColors.kawaiiPeach,
              accent: weightDelta! <= 0 ? AppColors.kawaiiLeafDeep : AppColors.kawaiiCoralDeep,
              label: 'Kilo',
              value: '${weightDelta! <= 0 ? '' : '+'}${weightDelta!.toStringAsFixed(1)} kg',
            ),
          ),
        if (weightDelta != null && waistDelta != null) const SizedBox(width: 8),
        if (waistDelta != null)
          Expanded(
            child: _TrendChip(
              icon: Icons.straighten_rounded,
              tint: AppColors.kawaiiSky,
              accent: AppColors.kawaiiSkyBlue,
              label: 'Bel',
              value: '${waistDelta! <= 0 ? '' : '+'}${waistDelta!.toStringAsFixed(1)} cm',
            ),
          ),
        if (lastMood != null) ...[
          const SizedBox(width: 8),
          Expanded(
            child: _TrendChip(
              icon: CheckInVisuals.moodMeta(lastMood!).$1,
              tint: CheckInVisuals.tintForMood(lastMood!),
              accent: CheckInVisuals.moodMeta(lastMood!).$3,
              label: 'Ruh hali',
              value: CheckInVisuals.moodMeta(lastMood!).$2,
            ),
          ),
        ],
      ],
    );
  }
}

class _TrendChip extends StatelessWidget {
  const _TrendChip({
    required this.icon,
    required this.tint,
    required this.accent,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color tint;
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
        border: Border.all(color: AppColors.kawaiiOutline),
        boxShadow: AppSpacing.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 16, color: accent),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: AppColors.kawaiiMuted)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.kawaiiInk)),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({
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
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.kawaiiOutline),
        boxShadow: AppSpacing.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bu haftanın ölçümleri', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.kawaiiInk)),
          const SizedBox(height: 4),
          const Text(
            'Sabah, tuvalet sonrası tartıl — daha tutarlı olur.',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: AppColors.kawaiiMuted),
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
                    prefixIcon: Icon(Icons.monitor_weight_rounded, color: AppColors.kawaiiLeafDeep),
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
                    prefixIcon: Icon(Icons.straighten_rounded, color: AppColors.kawaiiLeafDeep),
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
              prefixIcon: Icon(Icons.bedtime_rounded, color: AppColors.kawaiiLeafDeep),
              hintText: 'Örn. 7.5',
            ),
          ),
          const SizedBox(height: 16),
          const Text('Ruh hali', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.kawaiiInk)),
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
                        color: mood == i + 1 ? CheckInVisuals.tintForMood(i + 1) : AppColors.kawaiiSurfaceCream,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: mood == i + 1 ? CheckInVisuals.moods[i].$3 : AppColors.kawaiiOutline,
                          width: mood == i + 1 ? 1.6 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(CheckInVisuals.moods[i].$1, color: CheckInVisuals.moods[i].$3, size: 22),
                          const SizedBox(height: 4),
                          Text(
                            CheckInVisuals.moods[i].$2,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 9.5,
                              color: mood == i + 1 ? AppColors.kawaiiInk : AppColors.kawaiiMuted,
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
          _ScaleRow(
            title: 'Enerji',
            valueLabel: CheckInVisuals.energyLabels[energy - 1],
            value: energy,
            onChanged: onEnergy,
            color: AppColors.kawaiiSkyBlue,
          ),
          const SizedBox(height: 10),
          _ScaleRow(
            title: 'Diyet uyumu',
            valueLabel: CheckInVisuals.adherenceLabels[adherence - 1],
            value: adherence,
            onChanged: onAdherence,
            color: AppColors.kawaiiLeaf,
          ),
          const SizedBox(height: 14),
          const Text('Bu haftayı etiketle', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.kawaiiInk)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in CheckInVisuals.quickTags)
                FilterChip(
                  selected: tags.contains(t),
                  showCheckmark: false,
                  label: Text(t, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: tags.contains(t) ? Colors.white : AppColors.kawaiiInk)),
                  selectedColor: AppColors.kawaiiLeaf,
                  backgroundColor: AppColors.kawaiiSurfaceCream,
                  side: BorderSide(color: tags.contains(t) ? AppColors.kawaiiLeaf : AppColors.kawaiiOutline),
                  onSelected: (_) => onToggleTag(t),
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
              child: TextButton(onPressed: onClearPhoto, child: const Text('Fotoğrafı kaldır')),
            ),
          ] else
            SoftTap(
              onTap: onPickPhoto,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.kawaiiMint,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.kawaiiOutline),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_camera_rounded, color: AppColors.kawaiiLeafDeep, size: 20),
                    SizedBox(width: 8),
                    Text('İsteğe bağlı foto ekle', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.kawaiiLeafDeep)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 14),
          SoftTap(
            onTap: saving ? null : onSubmit,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: saving ? AppColors.kawaiiLeaf.withValues(alpha: 0.6) : AppColors.kawaiiLeaf,
                borderRadius: BorderRadius.circular(18),
                boxShadow: AppSpacing.soft,
              ),
              child: Text(
                saving ? 'Gönderiliyor…' : 'Check-in gönder',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScaleRow extends StatelessWidget {
  const _ScaleRow({
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
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.kawaiiInk)),
            const Spacer(),
            Text(valueLabel, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: color)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            thumbColor: color,
            inactiveTrackColor: color.withValues(alpha: 0.2),
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

class _WhyCard extends StatelessWidget {
  const _WhyCard({required this.tip});

  final String tip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.kawaiiOutline),
        boxShadow: AppSpacing.soft,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: AppColors.kawaiiLemon, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.lightbulb_rounded, color: AppColors.kawaiiSalmon, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Neden haftalık?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.kawaiiInk)),
                const SizedBox(height: 4),
                Text(tip, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 1.4, color: AppColors.kawaiiMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.kawaiiOutline),
      ),
      child: const Column(
        children: [
          Icon(Icons.favorite_border_rounded, size: 36, color: AppColors.kawaiiLeaf),
          SizedBox(height: 8),
          Text('Henüz check-in yok', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.kawaiiInk)),
          SizedBox(height: 4),
          Text(
            'İlk kaydın burada birikir; trend kartları otomatik dolar.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.kawaiiMuted),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.log, required this.previous, required this.onOpen});

  final WeeklyCheckIn log;
  final WeeklyCheckIn? previous;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final mood = CheckInVisuals.moodMeta(log.mood);
    final wDelta = log.weight != null && previous?.weight != null ? log.weight! - previous!.weight! : null;

    return SoftTap(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(color: AppColors.kawaiiOutline),
          boxShadow: AppSpacing.soft,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: CheckInVisuals.tintForMood(log.mood),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(mood.$1, color: mood.$3),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('d MMMM y', 'tr').format(log.createdAt),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5, color: AppColors.kawaiiInk),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    CheckInVisuals.summaryLine(log),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: AppColors.kawaiiMuted),
                  ),
                  if (wDelta != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Önceki kayda göre ${wDelta <= 0 ? '' : '+'}${wDelta.toStringAsFixed(1)} kg',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: wDelta <= 0 ? AppColors.kawaiiLeafDeep : AppColors.kawaiiCoralDeep,
                      ),
                    ),
                  ],
                  if (log.dietitianNote != null) ...[
                    const SizedBox(height: 4),
                    const Text('Diyetisyen yanıtı var', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5, color: AppColors.kawaiiPurple)),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.kawaiiMuted),
          ],
        ),
      ),
    );
  }
}

class _CheckInDetailSheet extends StatelessWidget {
  const _CheckInDetailSheet({required this.log, this.previous});

  final WeeklyCheckIn log;
  final WeeklyCheckIn? previous;

  @override
  Widget build(BuildContext context) {
    final cartoon = context.isCartoon;
    final mood = CheckInVisuals.moodMeta(log.mood);
    final wDelta = log.weight != null && previous?.weight != null ? log.weight! - previous!.weight! : null;

    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scroll) {
        return Container(
          decoration: BoxDecoration(
            color: cartoon ? AppColors.kawaiiCream : Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: scroll,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(color: AppColors.kawaiiOutline, borderRadius: BorderRadius.circular(99)),
                ),
              ),
              Text(
                DateFormat('d MMMM y · HH:mm', 'tr').format(log.createdAt),
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: cartoon ? AppColors.kawaiiInk : null),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (log.weight != null) _DetailPill(label: 'Kilo', value: '${log.weight!.toStringAsFixed(1)} kg'),
                  if (log.waist != null) _DetailPill(label: 'Bel', value: '${log.waist!.toStringAsFixed(0)} cm'),
                  if (log.sleepHours != null) _DetailPill(label: 'Uyku', value: '${log.sleepHours!.toStringAsFixed(1)} sa'),
                  _DetailPill(label: 'Ruh hali', value: mood.$2),
                  _DetailPill(label: 'Enerji', value: CheckInVisuals.energyLabels[(log.energy - 1).clamp(0, 4)]),
                  _DetailPill(label: 'Uyumu', value: CheckInVisuals.adherenceLabels[(log.adherence - 1).clamp(0, 4)]),
                  if (wDelta != null)
                    _DetailPill(
                      label: 'Δ kilo',
                      value: '${wDelta <= 0 ? '' : '+'}${wDelta.toStringAsFixed(1)}',
                    ),
                ],
              ),
              if (log.tags.isNotEmpty) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final t in log.tags)
                      Chip(
                        label: Text(t, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                        backgroundColor: cartoon ? AppColors.kawaiiMint : null,
                      ),
                  ],
                ),
              ],
              if (log.note.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Senin notun', style: TextStyle(fontWeight: FontWeight.w900, color: cartoon ? AppColors.kawaiiInk : null)),
                const SizedBox(height: 6),
                Text(log.note, style: const TextStyle(fontWeight: FontWeight.w600, height: 1.4)),
              ],
              if (log.dietitianNote != null) ...[
                const SizedBox(height: 16),
                Text('Diyetisyen notu', style: TextStyle(fontWeight: FontWeight.w900, color: cartoon ? AppColors.kawaiiInk : null)),
                const SizedBox(height: 6),
                Text(log.dietitianNote!, style: const TextStyle(fontWeight: FontWeight.w600, height: 1.4)),
              ],
              if (log.photoPath != null && File(log.photoPath!).existsSync()) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
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

class _DetailPill extends StatelessWidget {
  const _DetailPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.kawaiiOutline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: AppColors.kawaiiMuted)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.kawaiiInk)),
        ],
      ),
    );
  }
}
