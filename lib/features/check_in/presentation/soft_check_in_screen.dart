import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/app_modules.dart';
import '../../../core/models/models.dart';
import '../../../core/utils/smart_notification_service.dart';
import '../../../core/widgets/module_gate.dart';
import '../../../core/widgets/soft_ui_kit.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../gamification/presentation/gamification_screens.dart';
import '../domain/check_in_visuals.dart';
import 'widgets/soft_check_in_widgets.dart';

/// Soft premium modern weekly check-in.
class SoftCheckInScreen extends ConsumerStatefulWidget {
  const SoftCheckInScreen({super.key});

  @override
  ConsumerState<SoftCheckInScreen> createState() => _SoftCheckInScreenState();
}

class _SoftCheckInScreenState extends ConsumerState<SoftCheckInScreen> {
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

    return Scaffold(
      backgroundColor: AppColors.modernWash,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            const SoftCheckInHeader()
                .animate()
                .fadeIn(duration: 280.ms)
                .slideY(begin: -0.05, curve: Curves.easeOutCubic),
            const SizedBox(height: 14),
            SoftCheckInHero(due: due, last: last, count: logs.length)
                .animate()
                .fadeIn(delay: 40.ms, duration: 300.ms)
                .scale(
                  begin: const Offset(0.97, 0.97),
                  curve: Curves.easeOutCubic,
                  duration: 380.ms,
                ),
            const SizedBox(height: 14),
            SoftCheckInStatsRow(count: logs.length, daysSince: daysSince, due: due)
                .animate()
                .fadeIn(delay: 70.ms, duration: 280.ms),
            const SizedBox(height: 12),
            SoftTipCard(
              title: 'Haftalık tutarlılık',
              body: due
                  ? 'Bu haftanın check-in’i bekliyor. Aynı gün ve saatte kayıt, trendleri daha net gösterir.'
                  : 'Harika tempo — her hafta aynı ritimle ölçüm almak, diyetisyeninin yorumunu güçlendirir.',
              icon: Icons.calendar_month_rounded,
              accent: AppColors.primary,
              tint: AppColors.modernMint,
            ).animate().fadeIn(delay: 75.ms, duration: 280.ms),
            if (last?.dietitianNote != null) ...[
              const SizedBox(height: 12),
              SoftDietitianNoteCard(note: last!.dietitianNote!, at: last.dietitianNoteAt)
                  .animate()
                  .fadeIn(delay: 80.ms, duration: 280.ms),
            ],
            if (weightDelta != null || waistDelta != null) ...[
              const SizedBox(height: 12),
              SoftCheckInTrendRow(
                weightDelta: weightDelta,
                waistDelta: waistDelta,
                lastMood: last?.mood,
              ).animate().fadeIn(delay: 90.ms, duration: 280.ms),
            ],
            const SizedBox(height: 14),
            SoftCheckInFormCard(
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
            ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
            const SizedBox(height: 14),
            SoftCheckInTipCard(tip: CheckInVisuals.tipOfWeek(DateTime.now().day))
                .animate()
                .fadeIn(delay: 120.ms, duration: 280.ms),
            const SizedBox(height: 18),
            const Text(
              'Geçmiş check-in’ler',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: AppColors.primaryDeep,
              ),
            ),
            const SizedBox(height: 10),
            if (logs.isEmpty)
              const SoftCheckInEmptyHistory()
            else
              for (var i = 0; i < logs.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SoftCheckInHistoryCard(
                    log: logs[i],
                    index: i,
                    previous: i + 1 < logs.length ? logs[i + 1] : null,
                    onOpen: () => _openDetail(
                      context,
                      logs[i],
                      i + 1 < logs.length ? logs[i + 1] : null,
                    ),
                  ),
                ),
          ],
        ),
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
      builder: (_) => SoftCheckInDetailSheet(log: log, previous: previous),
    );
  }
}
