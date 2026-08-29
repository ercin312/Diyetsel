import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/lesson_catalog.dart';
import '../../../core/data/providers.dart';
import '../../../core/utils/smart_notification_service.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/diyetsel_widgets.dart';
import '../../../core/widgets/style_icon.dart';
import '../../auth/presentation/auth_controller.dart';

class LearnHubScreen extends ConsumerWidget {
  const LearnHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(userProgressProvider(user.id));
    final progress = store.userProgress(user.id);

    return AppPage(
      title: 'Mini dersler',
      child: ListView(
        children: [
          const DiyetselCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: '7 günlük seriler',
                  subtitle: 'Her gün 3 dakika — quiz ile pekiştir, rozet kazan.'),
              ])),
          const SizedBox(height: 12),
          for (final series in LessonCatalog.all)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _SeriesHeroCard(
                series: series,
                done: progress.completedLessonDays[series.id]?.length ?? 0,
                onTap: () => context.push('/app/learn/${series.id}'))).animate().fadeIn(delay: (LessonCatalog.all.indexOf(series) * 80).ms),
        ]));
  }
}

class _SeriesHeroCard extends StatelessWidget {
  const _SeriesHeroCard({required this.series, required this.done, required this.onTap});

  final LessonSeries series;
  final int done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cartoon = context.isCartoon;
    final c1 = cartoon
        ? AppColors.kawaiiLemon
        : Color(series.gradient[0]);
    final c2 = cartoon
        ? AppColors.kawaiiSky
        : Color(series.gradient[1]);
    final radius = cartoon ? 28.0 : (22.0);
    Widget card = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [c1, c2], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(radius),
            border: cartoon
                ? null
                : null,
            boxShadow: [
              BoxShadow(
                color: cartoon
                    ? AppColors.kawaiiShadow
                    : AppColors.modernSoftShadow,
                blurRadius: cartoon ? 16 : 24,
                offset: const Offset(0, 8)),
            ]),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(series.emoji, style: const TextStyle(fontSize: 34)),
                    const Spacer(),
                    DoodleBadge(label: '$done/7 gün', emoji: '📚'),
                  ]),
                const SizedBox(height: 12),
                Text(
                  series.title,
                  style: TextStyle(
                    color: cartoon ? AppColors.kawaiiInk : Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    letterSpacing: null)),
                const SizedBox(height: 6),
                Text(
                  series.subtitle,
                  style: TextStyle(
                    color: cartoon
                        ? AppColors.kawaiiInk.withValues(alpha: 0.8)
                        : Colors.white.withValues(alpha: 0.88))),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: done / 7,
                    minHeight: 7,
                    backgroundColor: cartoon
                        ? AppColors.kawaiiBubble.withValues(alpha: 0.7)
                        : Colors.white.withValues(alpha: 0.25),
                    color: cartoon
                        ? AppColors.kawaiiCoral
                        : Colors.white)),
              ])))));
    if (cartoon) {
      return card
          .animate()
          .fadeIn(duration: 300.ms)
          .scale(begin: const Offset(0.94, 0.94), curve: Curves.easeOutBack, duration: 420.ms);
    }
    return card;
  }
}

class LessonSeriesScreen extends ConsumerWidget {
  const LessonSeriesScreen({super.key, required this.seriesId});

  final String seriesId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = LessonCatalog.byId(seriesId);
    if (series == null) {
      return const AppPage(title: 'Ders', child: EmptyState(icon: Icons.school, title: 'Seri bulunamadı'));
    }
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(userProgressProvider(user.id));
    final done = store.userProgress(user.id).completedLessonDays[seriesId] ?? const [];

    return AppPage(
      title: series.title,
      child: ListView(
        children: [
          for (final day in series.days)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: DiyetselCard(
                onTap: _unlocked(day.day, done)
                    ? () => context.push('/app/learn/$seriesId/${day.day}')
                    : null,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _unlocked(day.day, done)
                          ? Color(series.gradient[0]).withValues(alpha: 0.18)
                          : Colors.grey.withValues(alpha: 0.15),
                      child: Text('${day.day}', style: const TextStyle(fontWeight: FontWeight.w900))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${day.emoji} ${day.title}', style: const TextStyle(fontWeight: FontWeight.w900)),
                          Text(day.lead, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                        ])),
                    Icon(
                      done.contains(day.day)
                          ? Icons.check_circle_rounded
                          : (_unlocked(day.day, done) ? Icons.play_circle_fill_rounded : Icons.lock_rounded),
                      color: done.contains(day.day) ? AppColors.success : context.brandPrimary),
                  ]))),
        ]));
  }

  bool _unlocked(int day, List<int> done) => day == 1 || done.contains(day - 1) || done.contains(day);
}

class LessonDayScreen extends ConsumerStatefulWidget {
  const LessonDayScreen({super.key, required this.seriesId, required this.day});

  final String seriesId;
  final int day;

  @override
  ConsumerState<LessonDayScreen> createState() => _LessonDayScreenState();
}

class _LessonDayScreenState extends ConsumerState<LessonDayScreen> {
  int? _picked;
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final series = LessonCatalog.byId(widget.seriesId);
    LessonDay? lesson;
    if (series != null) {
      for (final d in series.days) {
        if (d.day == widget.day) {
          lesson = d;
          break;
        }
      }
    }
    if (series == null || lesson == null) {
      return const AppPage(title: 'Ders', child: EmptyState(icon: Icons.school, title: 'Ders bulunamadı'));
    }
    final quiz = lesson.quiz;
    final correct = _picked == quiz.correctIndex;

    return AppPage(
      title: 'Gün ${lesson.day}',
      child: ListView(
        children: [
          DiyetselCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(lesson.emoji, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(lesson.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))),
                  ]),
                const SizedBox(height: 10),
                Text(
                  lesson.lead,
                  style: TextStyle(fontWeight: FontWeight.w700, color: context.brandPrimary)),
                const SizedBox(height: 12),
                for (final p in lesson.paragraphs) ...[
                  Text(p, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45)),
                  const SizedBox(height: 10),
                ],
                FeatureBanner(
                  icon: Icons.lightbulb_rounded,
                  emoji: '💡',
                  title: 'Bugünkü ipucu',
                  subtitle: lesson.tip,
                  color: Color(series.gradient[0])),
              ])),
          const SizedBox(height: 14),
          DiyetselCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Mini quiz', subtitle: 'Doğru cevap rozet ilerlemeni hızlandırır'),
                Text(quiz.question, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 12),
                for (var i = 0; i < quiz.options.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ChoiceChip(
                      label: Text(quiz.options[i]),
                      selected: _picked == i,
                      onSelected: _revealed
                          ? null
                          : (v) => setState(() {
                                if (v) _picked = i;
                              }))),
                if (_revealed) ...[
                  const SizedBox(height: 8),
                  Text(
                    quiz.explanation,
                    style: TextStyle(
                      color: correct ? AppColors.success : AppColors.danger,
                      fontWeight: FontWeight.w700)),
                ],
                const SizedBox(height: 12),
                DiyetselButton(
                  label: _revealed ? (correct ? 'Günü tamamla ✓' : 'Tekrar dene') : 'Cevabı kontrol et',
                  icon: Icons.quiz_rounded,
                  onPressed: _picked == null
                      ? null
                      : () async {
                          if (!_revealed) {
                            setState(() => _revealed = true);
                            return;
                          }
                          if (!correct) {
                            setState(() {
                              _revealed = false;
                              _picked = null;
                            });
                            return;
                          }
                          final user = ref.read(authControllerProvider).user!;
                          final store = ref.read(appStoreProvider);
                          await AchievementService.instance.completeLessonDay(
                            store,
                            user.id,
                            widget.seriesId,
                            widget.day);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Gün tamamlandı — harika gidiyorsun!')));
                            context.pop();
                          }
                        }),
              ])),
        ]));
  }
}

class LearnHomeRail extends ConsumerWidget {
  const LearnHomeRail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(userProgressProvider(user.id));
    final progress = store.userProgress(user.id);
    final series = LessonCatalog.all.first;
    final done = progress.completedLessonDays[series.id]?.length ?? 0;
    final nextDay = done >= 7 ? 7 : done + 1;
    final day = series.days[(nextDay - 1).clamp(0, 6)];

    return DiyetselCard(
      onTap: () => context.push('/app/learn/${series.id}/${day.day}'),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: context.isCartoon
                    ? const [AppColors.kawaiiRose, AppColors.kawaiiLilac]
                    : [Color(series.gradient[0]), Color(series.gradient[1])]),
              borderRadius: BorderRadius.circular(
                context.isCartoon ? 24 : (20)),
              border: null,
              boxShadow: context.isCartoon
                  ? const [
                      BoxShadow(
                        color: AppColors.kawaiiShadow,
                        blurRadius: 10,
                        offset: Offset(0, 4)),
                    ]
                  : null),
            alignment: Alignment.center,
            child: Text(series.emoji, style: const TextStyle(fontSize: 26))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mini ders • Gün $nextDay', style: const TextStyle(fontWeight: FontWeight.w900)),
                Text('${day.emoji} ${day.title}', maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text(series.title, style: Theme.of(context).textTheme.bodySmall),
              ])),
          StyleIcon(icon: Icons.play_circle_fill_rounded, emoji: '▶️', size: 28, color: context.brandPrimary),
        ]));
  }
}
