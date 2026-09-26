import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/diyetsel_assets.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/app_modules.dart';
import '../../../core/models/models.dart';
import '../../../core/utils/desktop.dart';
import '../../../core/widgets/soft_desktop_frame.dart';
import '../../../core/widgets/soft_ui_kit.dart';
import '../../dashboard/presentation/widgets/premium_home_widgets.dart' show SoftTap;
import '../../dashboard/presentation/widgets/soft_home_widgets.dart' show SoftModernIcon;
import '../../../core/widgets/nav_back.dart';
import '../../../core/l10n/ui_string.dart';


/// Soft premium client care — modules, water goal, reports.
class SoftClientCareScreen extends ConsumerWidget {
  const SoftClientCareScreen({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(usersProvider);
    ref.watch(settingsProvider);
    ref.watch(waterLogsProvider);
    ref.watch(checkInsProvider);
    final store = ref.watch(appStoreProvider);
    final client = store.user(clientId);

    if (client == null) {
      return Scaffold(
        backgroundColor: AppColors.modernWash,
        body: Center(child: Text(('Danışan bulunamadı').ui)),
      );
    }

    final clinic = store.settings().clinicModules;
    final liters = client.waterGoalMl / 1000;
    final checkIns = store.checkIns(userId: client.id)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final desktop = context.isDesktopLayout;
    final pad = desktop
        ? EdgeInsets.fromLTRB(0, context.pagePadding.top, 0, context.pagePadding.bottom)
        : const EdgeInsets.fromLTRB(18, 12, 18, 28);

    return Scaffold(
      backgroundColor: AppColors.modernWash,
      body: SafeArea(
        child: SoftDesktopBody(
          child: ListView(
            padding: pad,
            children: [
              _Header(name: client.displayName)
                  .animate()
                  .fadeIn(duration: 280.ms)
                  .slideY(begin: -0.05, curve: Curves.easeOutCubic),
              const SizedBox(height: 14),
              _ProfileHero(client: client)
                  .animate()
                  .fadeIn(delay: 40.ms, duration: 300.ms)
                  .scale(
                    begin: const Offset(0.97, 0.97),
                    curve: Curves.easeOutCubic,
                    duration: 380.ms,
                  ),
              const SizedBox(height: 12),
              SoftTipCard(
                title: 'Danışan bakımı',
                body: checkIns.isEmpty
                    ? 'Henüz check-in yok. İlk ölçüm ve ruh hali kaydı için nazik bir hatırlatma gönder.'
                    : 'Son check-in: ${DateFormat('d MMM', 'tr').format(checkIns.first.createdAt)}. Trend ve raporları düzenli incele.',
                icon: Icons.favorite_outline_rounded,
                accent: AppColors.primary,
                tint: AppColors.modernMint,
              ),
              const SizedBox(height: 12),
              if (desktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _Card(
                            child: SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              secondary: const SoftModernIcon(
                                DiyetselAssets.modernIconCheck,
                                size: 28,
                                fallback: Icons.verified_user_rounded,
                                fallbackColor: AppColors.primary,
                              ),
                              title: Text(('Hesap aktif').ui,
                                style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryDeep),
                              ),
                              subtitle: Text(('Kapalıysa danışan giriş yapamaz').ui,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.5,
                                  color: AppColors.primary.withValues(alpha: 0.55),
                                ),
                              ),
                              value: client.isActive,
                              activeThumbColor: AppColors.primary,
                              onChanged: (v) => store.saveUser(client.copyWith(isActive: v)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _waterCard(store, client, liters),
                          const SizedBox(height: 12),
                          SoftTap(
                            onTap: () => context.push('/admin/reports?clientId=${client.id}'),
                            borderRadius: BorderRadius.circular(20),
                            child: _Card(
                              child: Row(
                                children: [
                                  const SoftModernIcon(
                                    DiyetselAssets.modernIconCheck,
                                    size: 32,
                                    fallback: Icons.insights_rounded,
                                    fallbackColor: AppColors.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(('Haftalık / aylık rapor').ui,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.primaryDeep,
                                          ),
                                        ),
                                        Text(('Su, diyet uyumu, kilo ve seans özeti').ui,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12.5,
                                            color: AppColors.primary.withValues(alpha: 0.55),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppColors.primary.withValues(alpha: 0.4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _checkInCard(context, store, checkIns),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: _modulesCard(store, client, clinic)),
                  ],
                )
              else ...[
                _Card(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const SoftModernIcon(
                      DiyetselAssets.modernIconCheck,
                      size: 28,
                      fallback: Icons.verified_user_rounded,
                      fallbackColor: AppColors.primary,
                    ),
                    title: Text(('Hesap aktif').ui,
                      style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryDeep),
                    ),
                    subtitle: Text(('Kapalıysa danışan giriş yapamaz').ui,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                        color: AppColors.primary.withValues(alpha: 0.55),
                      ),
                    ),
                    value: client.isActive,
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) => store.saveUser(client.copyWith(isActive: v)),
                  ),
                ).animate().fadeIn(delay: 60.ms, duration: 280.ms),
                const SizedBox(height: 12),
                _waterCard(store, client, liters).animate().fadeIn(delay: 80.ms, duration: 280.ms),
                const SizedBox(height: 12),
                SoftTap(
                  onTap: () => context.push('/admin/reports?clientId=${client.id}'),
                  borderRadius: BorderRadius.circular(20),
                  child: _Card(
                    child: Row(
                      children: [
                        const SoftModernIcon(
                          DiyetselAssets.modernIconCheck,
                          size: 32,
                          fallback: Icons.insights_rounded,
                          fallbackColor: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(('Haftalık / aylık rapor').ui,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryDeep,
                                ),
                              ),
                              Text(('Su, diyet uyumu, kilo ve seans özeti').ui,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.5,
                                  color: AppColors.primary.withValues(alpha: 0.55),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.primary.withValues(alpha: 0.4),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 280.ms),
                const SizedBox(height: 12),
                _checkInCard(context, store, checkIns).animate().fadeIn(delay: 120.ms, duration: 280.ms),
                const SizedBox(height: 12),
                _modulesCard(store, client, clinic).animate().fadeIn(delay: 140.ms, duration: 280.ms),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _waterCard(AppStore store, UserProfile client, double liters) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(
            title: 'Günlük su hedefi',
            subtitle: 'Ana sayfa ve su takibi buna göre dolar',
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const SoftModernIcon(
                DiyetselAssets.modernIconWaterDrop,
                size: 28,
                fallback: Icons.water_drop_rounded,
                fallbackColor: Color(0xFF5BA3C9),
              ),
              const SizedBox(width: 10),
              Text(('${liters.toStringAsFixed(2)} L  ·  ${client.waterGoalMl} ml').ui,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: AppColors.primaryDeep,
                ),
              ),
            ],
          ),
          Slider(
            min: 1,
            max: 4,
            divisions: 12,
            activeColor: AppColors.primary,
            value: liters.clamp(1, 4),
            label: '${liters.toStringAsFixed(2)} L',
            onChanged: (v) => store.setWaterGoal(client.id, (v * 1000).round()),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final preset in [1.5, 2.0, 2.5, 3.0, 3.5])
                SoftTap(
                  onTap: () => store.setWaterGoal(client.id, (preset * 1000).round()),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.modernWash,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.modernLine),
                    ),
                    child: Text(('${preset.toStringAsFixed(1)} L').ui,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _checkInCard(BuildContext context, AppStore store, List<WeeklyCheckIn> checkIns) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(
            title: 'Check-in geri bildirimi',
            subtitle: 'Not bırakınca danışana bildirim gider',
          ),
          if (checkIns.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(('Henüz check-in yok.').ui,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
              ),
            )
          else
            for (final c in checkIns.take(3))
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text((DateFormat('d MMM y', 'tr').format(c.createdAt)).ui,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDeep,
                  ),
                ),
                subtitle: Text((c.dietitianNote ?? (c.note.isEmpty ? 'Henüz not yok' : c.note)).ui,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary.withValues(alpha: 0.55),
                  ),
                ),
                trailing: SoftTap(
                  onTap: () => _noteCheckIn(context, store, c),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.modernWash,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.modernLine),
                    ),
                    child: Icon(
                      Icons.edit_note_rounded,
                      color: AppColors.primary.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _modulesCard(AppStore store, UserProfile client, Map<String, bool> clinic) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel(
            title: 'Bu danışanın modülleri',
            subtitle: 'Klinik genelinde kapalı bölüm buradan açılamaz',
          ),
          for (final id in AppModule.all)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text((AppModule.label(id)).ui,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDeep,
                ),
              ),
              subtitle: Text((clinic[id] == false ? 'Klinik genelinde kapalı' : AppModule.subtitle(id)).ui,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
              ),
              value: store.moduleOn(client.id, id),
              activeThumbColor: AppColors.primary,
              onChanged: clinic[id] == false ? null : (v) => store.setUserModule(client.id, id, v),
            ),
        ],
      ),
    );
  }

  Future<void> _noteCheckIn(
    BuildContext context,
    AppStore store,
    WeeklyCheckIn checkIn,
  ) async {
    final controller = TextEditingController(text: checkIn.dietitianNote ?? '');
    final note = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(('Diyetisyen notu').ui),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(hintText: ('Bugün harika gidiyorsun...').ui),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(('İptal').ui)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(('Gönder').ui),
          ),
        ],
      ),
    );
    if (note == null || note.isEmpty) return;
    await store.saveCheckIn(
      checkIn.copyWith(dietitianNote: note, dietitianNoteAt: DateTime.now()),
    );
    await store.queueFeedbackNotification(
      checkIn.userId,
      'Diyetisyenin bugün senin için bir not bıraktı: $note',
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(('Not kaydedildi ve bildirim sıraya alındı').ui)),
      );
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SoftNavBackButton(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text((name).ui,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDeep,
                  letterSpacing: -0.3,
                ),
              ),
              Text(('Danışan bakımı').ui,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0x991A4F45),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.client});
  final UserProfile client;

  @override
  Widget build(BuildContext context) {
    final initial = client.displayName.isNotEmpty ? client.displayName[0].toUpperCase() : '?';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F5F0), Color(0xFFFFF6E9)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.modernLine),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Text((initial).ui,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text((client.displayName).ui,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    color: AppColors.primaryDeep,
                  ),
                ),
                Text((client.email).ui,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                    color: AppColors.primary.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: client.isActive
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : const Color(0xFFE07A5F).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text((client.isActive ? 'aktif' : 'pasif').ui,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: client.isActive ? AppColors.primary : const Color(0xFFC45A3C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text((title).ui,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 15.5,
            color: AppColors.primaryDeep,
          ),
        ),
        const SizedBox(height: 2),
        Text((subtitle).ui,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
            color: AppColors.primary.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
