import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/models.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/diyetsel_widgets.dart';
import '../../../core/widgets/visuals.dart';
import '../../../core/widgets/module_gate.dart';
import '../../../core/models/app_modules.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../engage/presentation/engage_screens.dart';

class TrackerHubScreen extends ConsumerStatefulWidget {
  const TrackerHubScreen({super.key});

  @override
  ConsumerState<TrackerHubScreen> createState() => _TrackerHubScreenState();
}

class _TrackerHubScreenState extends ConsumerState<TrackerHubScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locked = lockedIfOff(ref, module: AppModule.water, title: 'Takip');
    if (locked != null) return locked;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Takip'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Su'),
            Tab(text: 'Vücut'),
            Tab(text: 'Öğün foto'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          WaterTrackerScreen(),
          BodyTrackerScreen(),
          MealPhotoScreen(),
        ],
      ),
    );
  }
}

class WaterTrackerScreen extends ConsumerWidget {
  const WaterTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(waterLogsProvider);
    final log = store.waterLog(user.id, DateTime.now());
    final cartoon = context.isCartoon;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: WaterSipGlass(
            progress: log.progress,
            amountMl: log.amountMl,
            cartoon: cartoon,
            sipLabel: '+ ${AppConstants.waterSipMl} ml',
            onAdd: () => store.addWaterSip(user.id),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${log.amountMl} / ${log.goalMl} ml',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            log.progress >= 1
                ? 'Kahraman gibi içtin! 🏆'
                : cartoon
                    ? 'Damla ya da + tuşuna bas, bardak dolsun.'
                    : 'Bardağa veya + tuşuna basarak su ekle.',
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        DiyetselButton(
          label: 'Su ekle  +${AppConstants.waterSipMl} ml',
          accent: true,
          icon: Icons.water_drop,
          onPressed: () => store.addWaterSip(user.id),
        ),
      ],
    );
  }
}

class BodyTrackerScreen extends ConsumerWidget {
  const BodyTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(measurementsProvider);
    final items = store.measurements(user.id);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        DiyetselCard(
          child: SizedBox(
            height: 220,
            child: items.length < 2
                ? const Center(child: Text('En az iki ölçüm ekleyin'))
                : LineChart(
                    LineChartData(
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          color: AppColors.primary,
                          spots: [
                            for (var i = 0; i < items.length; i++)
                              FlSpot(i.toDouble(), items[i].weight ?? 0),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        BeforeAfterSlider(
          before: items.isNotEmpty && items.first.beforePhotoPath != null
              ? FileImage(File(items.first.beforePhotoPath!))
              : null,
          after: items.isNotEmpty && items.last.afterPhotoPath != null
              ? FileImage(File(items.last.afterPhotoPath!))
              : null,
        ),
        const SizedBox(height: 12),
        DiyetselButton(
          label: 'Ölçüm ekle',
          icon: Icons.add,
          onPressed: () => _add(context, store, user.id),
        ),
        for (final m in items.reversed)
          ListTile(
            title: Text('${m.weight ?? '-'} kg • bel ${m.waist ?? '-'}'),
            subtitle: Text(DateFormat('d MMM y', 'tr').format(m.date)),
          ),
      ],
    );
  }

  Future<void> _add(BuildContext context, AppStore store, String userId) async {
    final w = TextEditingController();
    final waist = TextEditingController();
    final fat = TextEditingController();
    String? before;
    String? after;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
        title: const Text('Yeni ölçüm'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: w, decoration: const InputDecoration(labelText: 'Kilo'), keyboardType: TextInputType.number),
            TextField(controller: waist, decoration: const InputDecoration(labelText: 'Bel cm')),
            TextField(controller: fat, decoration: const InputDecoration(labelText: 'Yağ %')),
            TextButton(
              onPressed: () async {
                final file = await ImagePicker().pickImage(source: ImageSource.gallery);
                setLocal(() => before = file?.path ?? before);
              },
              child: Text(before == null ? 'Önce foto' : 'Önce foto seçildi'),
            ),
            TextButton(
              onPressed: () async {
                final file = await ImagePicker().pickImage(source: ImageSource.gallery);
                setLocal(() => after = file?.path ?? after);
              },
              child: Text(after == null ? 'Sonra foto' : 'Sonra foto seçildi'),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () async {
              await store.saveMeasurement(
                BodyMeasurement(
                  id: newId(),
                  userId: userId,
                  date: DateTime.now(),
                  weight: double.tryParse(w.text),
                  waist: double.tryParse(waist.text),
                  bodyFat: double.tryParse(fat.text),
                  beforePhotoPath: before,
                  afterPhotoPath: after,
                ),
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
      ),
    );
  }
}

class MealPhotoScreen extends ConsumerWidget {
  const MealPhotoScreen({super.key, this.admin = false});
  final bool admin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    final logs = (ref.watch(mealLogsProvider).valueOrNull ?? []).where((e) => admin || e.clientId == user.id).toList();
    return AppPage(
      title: 'Öğün foto günlüğü',
      fab: admin
          ? null
          : FloatingActionButton(
              onPressed: () => capturePlatePhoto(context, ref),
              child: const Icon(Icons.camera_alt),
            ),
      child: logs.isEmpty
          ? const EmptyState(icon: Icons.photo, title: 'Henüz foto yok')
          : ListView(
              children: [
                for (final log in logs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DiyetselCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(log.clientName, style: const TextStyle(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(File(log.photoPath), height: 180, width: double.infinity, fit: BoxFit.cover, errorBuilder: (context, error, stack) => const SizedBox(height: 80, child: Center(child: Text('Görsel yüklenemedi')))),
                          ),
                          if (log.caption != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(log.caption!)),
                          if (log.stamp != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: StatusChip(label: stampLabel(log.stamp), color: stampColor(log.stamp)),
                            ),
                          Wrap(
                            spacing: 8,
                            children: [
                              for (final e in ['👏 Harika seçim', '⚠️ Porsiyon fazla', '💪 Devam'])
                                ActionChip(
                                  label: Text(e),
                                  onPressed: admin
                                      ? () async {
                                          await store.saveMealLog(
                                            log.copyWith(
                                              feedbackEmoji: e.split(' ').first,
                                              feedbackNote: e,
                                            ),
                                            countActivity: false,
                                          );
                                          await store.queueFeedbackNotification(
                                            log.clientId,
                                            'Diyetisyenin bugün senin için bir not bıraktı: $e',
                                          );
                                        }
                                      : null,
                                ),
                            ],
                          ),
                          if (log.feedbackNote != null)
                            Text('Diyetisyen: ${log.feedbackNote}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
