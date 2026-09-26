import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/theme_controller.dart';
import '../../../core/constants/diyetsel_assets.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/app_modules.dart';
import '../../../core/models/models.dart';
import '../../../core/utils/reminder_service.dart';
import '../../../core/utils/smart_notification_service.dart';
import '../../../core/widgets/soft_ui_kit.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/settings_visuals.dart';
import 'account_deletion.dart';
import 'profile_photo.dart';
import 'widgets/soft_settings_widgets.dart';
import '../../../core/l10n/ui_string.dart';

/// Soft premium modern ayarlar — tema, bildirimler, hesap ve klinik yönetimi.
class SoftSettingsScreen extends ConsumerWidget {
  const SoftSettingsScreen({super.key});

  Future<void> _savePrefs(
    WidgetRef ref,
    BuildContext context,
    AppStore store,
    UserProfile user,
    NotificationPrefs next, {
    bool syncSmart = false,
    bool resyncWater = false,
  }) async {
    await store.savePrefs(user.id, next);
    if (syncSmart) {
      await SmartNotificationService.instance.sync(store, user);
    }
    if (resyncWater) {
      await ReminderService.instance.resync(next);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeControllerProvider);
    final auth = ref.watch(authControllerProvider);
    final user = auth.user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(prefsProvider(user.id));
    ref.watch(settingsProvider);
    final prefs = store.prefs(user.id);
    final reminderCount = SettingsVisuals.activeReminderCount(prefs);

    return Scaffold(
      backgroundColor: AppColors.modernWash,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            const SoftSettingsHeader()
                .animate()
                .fadeIn(duration: 280.ms)
                .slideY(begin: -0.05, curve: Curves.easeOutCubic),
            const SizedBox(height: 14),
            SoftSettingsProfileHero(
              name: user.displayName,
              email: user.email,
              roleLabel: user.isAdmin ? 'Diyetisyen' : 'Danışan',
              isAdmin: user.isAdmin,
              tip: SettingsVisuals.tipOfDay(DateTime.now().day),
              photoUrl: user.photoUrl,
              onAvatarTap: () => pickProfilePhoto(context, ref),
            )
                .animate()
                .fadeIn(delay: 40.ms, duration: 300.ms)
                .scale(
                  begin: const Offset(0.97, 0.97),
                  curve: Curves.easeOutCubic,
                  duration: 380.ms,
                ),
            const SizedBox(height: 12),
            SoftSettingsStatsRow(
              styleLabel: SettingsVisuals.visualStyleLabel(theme.style),
              reminderCount: reminderCount,
            ).animate().fadeIn(delay: 60.ms, duration: 280.ms),
            const SizedBox(height: 12),
            SoftTipCard(
              title: 'Bildirim ritmi',
              body: reminderCount == 0
                  ? 'Su ve öğün hatırlatıcılarını aç — tutarlılık, iradeden daha çok sistemle gelir.'
                  : '$reminderCount aktif hatırlatıcı var. Sessiz saatlerini ayarlardan kişiselleştir.',
              icon: Icons.notifications_outlined,
              accent: AppColors.primary,
              tint: AppColors.modernMint,
            ),
            const SizedBox(height: 16),
            SoftSettingsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SoftSettingsSectionTitle(
                    title: 'Görünüm',
                    subtitle: 'Modern veya karikatür görünüm.',
                    icon: Icons.palette_outlined,
                    asset: DiyetselAssets.modernIconStory,
                  ),
                  Text(('Görsel stil').ui,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: AppColors.primaryDeep,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SoftSettingsStylePicker(
                    selected: theme.style,
                    onChanged: (style) => ref.read(themeControllerProvider.notifier).setStyle(style),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 75.ms, duration: 280.ms),
            const SizedBox(height: 12),
            SoftSettingsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SoftSettingsSectionTitle(
                    title: 'Dil',
                    subtitle: 'Uygulama arayüz dili.',
                    icon: Icons.translate_rounded,
                  ),
                  SoftSettingsLanguagePicker(
                    languageCode: context.locale.languageCode,
                    onChanged: (code) {
                      if (code == 'en') {
                        context.setLocale(const Locale('en', 'US'));
                      } else {
                        context.setLocale(const Locale('tr', 'TR'));
                      }
                    },
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 90.ms, duration: 280.ms),
            const SizedBox(height: 12),
            SoftSettingsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SoftSettingsSectionTitle(
                    title: 'Hatırlatıcılar',
                    subtitle: 'Su, öğün ve randevu bildirimlerini yönet.',
                    icon: Icons.notifications_active_rounded,
                    asset: DiyetselAssets.modernIconBell,
                    accent: SettingsVisuals.coral,
                  ),
                  Text(('Su periyodu').ui,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: AppColors.primaryDeep,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SoftSettingsIntervalPicker(
                    hours: prefs.waterIntervalHours,
                    onChanged: (v) => _savePrefs(
                      ref,
                      context,
                      store,
                      user,
                      prefs.copyWith(waterIntervalHours: v),
                      syncSmart: true,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SoftSettingsToggleRow(
                    title: 'Akıllı hatırlatıcılar',
                    subtitle: 'Su kaldı, öğün ve randevu bildirimleri',
                    value: prefs.smartReminders,
                    asset: DiyetselAssets.modernIconBell,
                    accent: SettingsVisuals.coral,
                    onChanged: (v) => _savePrefs(
                      ref,
                      context,
                      store,
                      user,
                      prefs.copyWith(smartReminders: v),
                      syncSmart: true,
                    ),
                  ),
                  SoftSettingsToggleRow(
                    title: 'Randevu hatırlatmaları',
                    subtitle: 'Yaklaşan seanslar için bildirim',
                    value: prefs.appointmentReminders,
                    icon: Icons.event_available_rounded,
                    asset: DiyetselAssets.modernIconCalendar,
                    accent: SettingsVisuals.blue,
                    onChanged: (v) => _savePrefs(
                      ref,
                      context,
                      store,
                      user,
                      prefs.copyWith(appointmentReminders: v),
                      syncSmart: true,
                    ),
                  ),
                  SoftSettingsToggleRow(
                    title: 'Diyetisyen geri bildirimi',
                    subtitle: 'Öğün foto ve check-in notları',
                    value: prefs.feedbackAlerts,
                    icon: Icons.rate_review_rounded,
                    accent: AppColors.primary,
                    onChanged: (v) => _savePrefs(
                      ref,
                      context,
                      store,
                      user,
                      prefs.copyWith(feedbackAlerts: v),
                    ),
                  ),
                  SoftSettingsToggleRow(
                    title: 'Seni özledik / sessiz danışan',
                    subtitle: 'Uzun süre giriş yoksa nazik hatırlatma',
                    value: prefs.inactivityAlerts,
                    icon: Icons.favorite_outline_rounded,
                    accent: SettingsVisuals.coral,
                    onChanged: (v) => _savePrefs(
                      ref,
                      context,
                      store,
                      user,
                      prefs.copyWith(inactivityAlerts: v),
                      syncSmart: true,
                    ),
                  ),
                  SoftSettingsToggleRow(
                    title: 'Su kısayolu bildirimi',
                    subtitle: 'Kalıcı bildirimden +250 ml ekle',
                    value: prefs.waterShortcut,
                    icon: Icons.water_drop_rounded,
                    asset: DiyetselAssets.modernIconWaterDrop,
                    accent: SettingsVisuals.blue,
                    onChanged: (v) => _savePrefs(
                      ref,
                      context,
                      store,
                      user,
                      prefs.copyWith(waterShortcut: v),
                      resyncWater: true,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 110.ms, duration: 300.ms)
                .slideY(begin: 0.03, curve: Curves.easeOutCubic),
            if (user.isAdmin) ...[
              const SizedBox(height: 12),
              Builder(
                builder: (context) {
                  final ml = store.settings().defaultWaterGoalMl;
                  final liters = ml / 1000;
                  return SoftSettingsAdminWaterCard(
                    liters: liters,
                    ml: ml,
                    onSlider: (v) => store.setClinicWaterGoal((v * 1000).round()),
                    onPreset: (v) => store.setClinicWaterGoal((v * 1000).round()),
                    onApplyAll: () async {
                      await store.setClinicWaterGoal(ml, applyToAllClients: true);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(('Tüm danışanların su hedefi ${liters.toStringAsFixed(1)} L oldu.').ui,
                            ),
                          ),
                        );
                      }
                    },
                  ).animate().fadeIn(delay: 130.ms, duration: 280.ms);
                },
              ),
              const SizedBox(height: 12),
              SoftSettingsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SoftSettingsSectionTitle(
                      title: 'Klinik modülleri',
                      subtitle: 'Kapalı bölüm hiçbir danışanda görünmez.',
                      icon: Icons.grid_view_rounded,
                      asset: DiyetselAssets.modernIconAppsAll,
                    ),
                    for (final id in AppModule.all)
                      SoftSettingsModuleRow(
                        moduleId: id,
                        enabled: store.settings().clinicModules[id] != false,
                        onChanged: (v) => store.setClinicModule(id, v),
                      ),
                  ],
                ),
              ).animate().fadeIn(delay: 150.ms, duration: 280.ms),
            ],
            const SizedBox(height: 18),
            const SoftSettingsLegalLinks()
                .animate()
                .fadeIn(delay: 160.ms, duration: 280.ms),
            const SizedBox(height: 18),
            SoftSettingsDeleteAccountButton(
              onTap: () => confirmAndDeleteAccount(context, ref),
            ).animate().fadeIn(delay: 165.ms, duration: 280.ms),
            const SizedBox(height: 10),
            SoftSettingsLogoutButton(
              onTap: () => ref.read(authControllerProvider.notifier).logout(),
            ).animate().fadeIn(delay: 170.ms, duration: 280.ms),
            const SizedBox(height: 12),
            SoftSettingsFooterTip(admin: user.isAdmin)
                .animate()
                .fadeIn(delay: 185.ms, duration: 280.ms),
          ],
        ),
      ),
    );
  }
}
