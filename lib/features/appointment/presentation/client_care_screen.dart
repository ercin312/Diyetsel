import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/app_modules.dart';
import '../../../core/models/models.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/diyetsel_widgets.dart';
import '../../../core/widgets/style_icon.dart';

class ClientCareScreen extends ConsumerWidget {
  const ClientCareScreen({super.key, required this.clientId});

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
      return const AppPage(title: 'Danışan', child: EmptyState(icon: Icons.person, title: 'Danışan bulunamadı'));
    }
    final clinic = store.settings().clinicModules;
    final liters = client.waterGoalMl / 1000;
    final cartoon = context.isCartoon;

    return AppPage(
      title: client.displayName,
      child: ListView(
        children: [
          () {
            final header = DiyetselCard(
              color: cartoon ? AppColors.kawaiiCream : null,
              child: Row(
                children: [
                  CartoonAvatar(name: client.displayName, size: 56),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(client.displayName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                        Text(client.email, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  StatusChip(label: client.isActive ? 'aktif' : 'pasif', color: client.isActive ? AppColors.success : AppColors.danger),
                ],
              ),
            );
            if (!cartoon) return header;
            return header
                .animate()
                .fadeIn(duration: 280.ms)
                .scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutBack, duration: 400.ms);
          }(),
          const SizedBox(height: 12),
          DiyetselCard(
            color: cartoon ? AppColors.kawaiiLemon.withValues(alpha: 0.55) : null,
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const StyleIcon(icon: Icons.verified_user, emoji: '✅', size: 22),
              title: const Text('Hesap aktif', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Text('Kapalıysa danışan giriş yapamaz'),
              value: client.isActive,
              onChanged: (v) => store.saveUser(client.copyWith(isActive: v)),
            ),
          ),
          const SizedBox(height: 12),
          DiyetselCard(
            color: cartoon ? AppColors.kawaiiSky.withValues(alpha: 0.65) : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Günlük su hedefi', subtitle: 'Litre cinsinden. Anasayfa ve su takibi buna göre dolar.'),
                Row(
                  children: [
                    StyleIcon(icon: Icons.water_drop_rounded, emoji: '💧', size: 24, color: context.brandPrimary),
                    const SizedBox(width: 10),
                    Text(
                      '${liters.toStringAsFixed(2)} L  •  ${client.waterGoalMl} ml',
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
                  onChanged: (v) => store.setWaterGoal(client.id, (v * 1000).round()),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final preset in [1.5, 2.0, 2.5, 3.0, 3.5])
                      ActionChip(
                        label: Text('${preset.toStringAsFixed(1)} L'),
                        onPressed: () => store.setWaterGoal(client.id, (preset * 1000).round()),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          DiyetselCard(
            color: cartoon ? AppColors.kawaiiMint.withValues(alpha: 0.65) : null,
            onTap: () => context.push('/admin/reports?clientId=${client.id}'),
            child: Row(
              children: [
                StyleIcon(icon: Icons.insights_rounded, emoji: '📊', size: 24, color: context.brandPrimary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Haftalık / aylık rapor', style: TextStyle(fontWeight: FontWeight.w900)),
                      Text('Su, diyet uyumu, kilo ve seans özeti', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
          const SizedBox(height: 12),
          DiyetselCard(
            color: cartoon ? AppColors.kawaiiLilac.withValues(alpha: 0.55) : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Check-in geri bildirimi', subtitle: 'Not bırakınca danışana bildirim gider.'),
                for (final c in store.checkIns(userId: client.id).take(3))
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(DateFormat('d MMM y', 'tr').format(c.createdAt), style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text(c.dietitianNote ?? (c.note.isEmpty ? 'Henüz not yok' : c.note)),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_note_rounded),
                      onPressed: () => _noteCheckIn(context, store, c),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          DiyetselCard(
            color: cartoon ? AppColors.kawaiiRose.withValues(alpha: 0.45) : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Bu danışanın modülleri',
                  subtitle: 'Klinik genelinde kapalı bir bölüm buradan açılamaz.',
                ),
                for (final id in AppModule.all)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: StyleIcon(icon: AppModule.icon(id), emoji: AppModule.emoji(id), size: 20),
                    title: Text(AppModule.label(id), style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text(
                      clinic[id] == false ? 'Klinik genelinde kapalı' : AppModule.subtitle(id),
                    ),
                    value: store.moduleOn(client.id, id),
                    onChanged: clinic[id] == false
                        ? null
                        : (v) => store.setUserModule(client.id, id, v),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _noteCheckIn(BuildContext context, AppStore store, WeeklyCheckIn checkIn) async {
    final controller = TextEditingController(text: checkIn.dietitianNote ?? '');
    final note = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Diyetisyen notu'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Bugün harika gidiyorsun...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
          DiyetselButton(
            label: 'Gönder',
            expanded: false,
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not kaydedildi ve bildirim sıraya alındı')));
    }
  }
}
