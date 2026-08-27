import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/theme_controller.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/app_modules.dart';
import '../../../core/models/enums.dart';
import '../../../core/utils/reminder_service.dart';
import '../../../core/utils/smart_notification_service.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/diyetsel_widgets.dart';
import '../../../core/widgets/style_icon.dart';
import '../../auth/presentation/auth_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeControllerProvider);
    final auth = ref.watch(authControllerProvider);
    final user = auth.user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(prefsProvider(user.id));
    final prefs = store.prefs(user.id);
    return AppPage(
      title: 'settings.title'.tr(),
      child: ListView(
        children: [
          DiyetselCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Görünüm',
                  subtitle: 'Açık temada metinler koyu mürekkep, koyu temada açık mürekkep kullanır.',
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) return Colors.white;
                        return Theme.of(context).colorScheme.onSurface;
                      }),
                      backgroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) return AppColors.primary;
                        return Theme.of(context).colorScheme.surface;
                      }),
                    ),
                    segments: const [
                      ButtonSegment(value: ThemeMode.light, label: Text('Açık')),
                      ButtonSegment(value: ThemeMode.dark, label: Text('Koyu')),
                      ButtonSegment(value: ThemeMode.system, label: Text('Sistem')),
                    ],
                    selected: {theme.mode},
                    onSelectionChanged: (value) => ref.read(themeControllerProvider.notifier).setMode(value.first),
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  secondary: const StyleIcon(icon: Icons.auto_awesome, emoji: '🎨', size: 22),
                  title: const Text('Karikatür tema'),
                  subtitle: const Text('Pastel sticker’lar, tatlı doodle ikonlar ve yumuşak gölgeler'),
                  value: theme.style == VisualStyle.cartoon,
                  onChanged: (v) => ref.read(themeControllerProvider.notifier).setStyle(v ? VisualStyle.cartoon : VisualStyle.modern),
                ),
                ListTile(
                  title: Text('settings.language'.tr()),
                  trailing: DropdownButton<String>(
                    value: context.locale.languageCode,
                    items: const [
                      DropdownMenuItem(value: 'tr', child: Text('Türkçe')),
                      DropdownMenuItem(value: 'en', child: Text('English')),
                    ],
                    onChanged: (v) {
                      if (v == 'en') {
                        context.setLocale(const Locale('en', 'US'));
                      } else {
                        context.setLocale(const Locale('tr', 'TR'));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          DiyetselCard(
            child: Column(
              children: [
                const SectionHeader(
                  title: 'Hatırlatıcılar',
                  subtitle: 'Akıllı bildirimler su, öğün ve randevuya göre kişiselleşir.',
                ),
                ListTile(
                  title: const Text('Su periyodu (saat)'),
                  trailing: DropdownButton<int>(
                    value: prefs.waterIntervalHours,
                    items: [1, 2, 3, 4].map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(),
                    onChanged: (v) async {
                      final next = prefs.copyWith(waterIntervalHours: v ?? 2);
                      await store.savePrefs(user.id, next);
                      await SmartNotificationService.instance.sync(store, user);
                    },
                  ),
                ),
                SwitchListTile(
                  title: const Text('Akıllı hatırlatıcılar'),
                  subtitle: const Text('Su kaldı, öğün ve randevu bildirimleri'),
                  value: prefs.smartReminders,
                  onChanged: (v) async {
                    final next = prefs.copyWith(smartReminders: v);
                    await store.savePrefs(user.id, next);
                    await SmartNotificationService.instance.sync(store, user);
                  },
                ),
                SwitchListTile(
                  title: const Text('Randevu hatırlatmaları'),
                  value: prefs.appointmentReminders,
                  onChanged: (v) async {
                    final next = prefs.copyWith(appointmentReminders: v);
                    await store.savePrefs(user.id, next);
                    await SmartNotificationService.instance.sync(store, user);
                  },
                ),
                SwitchListTile(
                  title: const Text('Diyetisyen geri bildirimi'),
                  subtitle: const Text('Öğün foto ve check-in notları'),
                  value: prefs.feedbackAlerts,
                  onChanged: (v) => store.savePrefs(user.id, prefs.copyWith(feedbackAlerts: v)),
                ),
                SwitchListTile(
                  title: const Text('Seni özledik / sessiz danışan'),
                  value: prefs.inactivityAlerts,
                  onChanged: (v) async {
                    final next = prefs.copyWith(inactivityAlerts: v);
                    await store.savePrefs(user.id, next);
                    await SmartNotificationService.instance.sync(store, user);
                  },
                ),
                SwitchListTile(
                  title: const Text('Su kısayolu bildirimi'),
                  value: prefs.waterShortcut,
                  onChanged: (v) async {
                    final next = prefs.copyWith(waterShortcut: v);
                    await store.savePrefs(user.id, next);
                    await ReminderService.instance.resync(next);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          DiyetselCard(
            child: ListTile(
              leading: const StyleIcon(icon: Icons.person, emoji: '👤', size: 22),
              title: Text(user.displayName),
              subtitle: Text('${user.email} • ${user.role.name}'),
            ),
          ),
          if (user.isAdmin) ...[
            const SizedBox(height: 12),
            DiyetselCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'Klinik su hedefi',
                    subtitle: 'Yeni danışanlar bu litreyle başlar. İstersen herkese uygula; tek kişiyi Danışanlar’dan ayarlarsın.',
                  ),
                  Builder(
                    builder: (context) {
                      ref.watch(settingsProvider);
                      final store = ref.watch(appStoreProvider);
                      final ml = store.settings().defaultWaterGoalMl;
                      final liters = ml / 1000;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const StyleIcon(icon: Icons.water_drop_rounded, emoji: '💧', size: 22, color: AppColors.accent),
                              const SizedBox(width: 10),
                              Text(
                                '${liters.toStringAsFixed(2)} L  •  $ml ml',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                              ),
                            ],
                          ),
                          Slider(
                            min: 1,
                            max: 4,
                            divisions: 12,
                            value: liters.clamp(1, 4),
                            label: '${liters.toStringAsFixed(2)} L',
                            onChanged: (v) => store.setClinicWaterGoal((v * 1000).round()),
                          ),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final preset in [1.5, 2.0, 2.5, 3.0, 3.5])
                                ActionChip(
                                  label: Text('${preset.toStringAsFixed(1)} L'),
                                  onPressed: () => store.setClinicWaterGoal((preset * 1000).round()),
                                ),
                              ActionChip(
                                avatar: const Icon(Icons.groups_rounded, size: 18),
                                label: const Text('Tüm danışanlara uygula'),
                                onPressed: () async {
                                  await store.setClinicWaterGoal(ml, applyToAllClients: true);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Tüm danışanların su hedefi ${liters.toStringAsFixed(1)} L oldu.')),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            DiyetselCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    title: 'Klinik modülleri',
                    subtitle: 'Kapalı bölüm hiçbir danışanda görünmez. Tek kişilik istisna için Danışanlar’dan ayarla.',
                  ),
                  Builder(
                    builder: (context) {
                      ref.watch(settingsProvider);
                      final store = ref.watch(appStoreProvider);
                      return Column(
                        children: [
                          for (final id in AppModule.all)
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              secondary: StyleIcon(icon: AppModule.icon(id), emoji: AppModule.emoji(id), size: 20),
                              title: Text(AppModule.label(id), style: const TextStyle(fontWeight: FontWeight.w800)),
                              subtitle: Text(AppModule.subtitle(id)),
                              value: store.settings().clinicModules[id] != false,
                              onChanged: (v) => store.setClinicModule(id, v),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          DiyetselButton(
            label: 'auth.logout'.tr(),
            tonal: true,
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
    );
  }
}
