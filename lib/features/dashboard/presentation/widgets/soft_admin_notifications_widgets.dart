import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/diyetsel_assets.dart';
import '../../../../core/models/models.dart';
import '../../../dashboard/presentation/widgets/premium_home_widgets.dart' show SoftTap;
import '../../../dashboard/presentation/widgets/soft_home_widgets.dart' show SoftModernIcon;
import '../../../../core/widgets/nav_back.dart';


class SoftAdminNotifHeader extends StatelessWidget {
  const SoftAdminNotifHeader({super.key});

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
                'Bildirimler',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDeep,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Danışanlara özel bildirim gönder',
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
            DiyetselAssets.modernIconBell,
            size: 28,
            fallback: Icons.notifications_active_rounded,
            fallbackColor: Color(0xFFE07A5F),
          ),
        ),
      ],
    );
  }
}

class SoftAdminNotifHero extends StatelessWidget {
  const SoftAdminNotifHero({
    super.key,
    required this.clientCount,
    required this.sentCount,
  });

  final int clientCount;
  final int sentCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF0E8), Color(0xFFE8F5F0), Color(0xFFE3F2F8)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE07A5F).withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                    color: const Color(0xFFE07A5F).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Klinik bildirim merkezi',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: Color(0xFFC45A3C),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Özel mesaj gönder',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: AppColors.primaryDeep,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tüm danışanlara veya seçtiklerine anlık bildirim bırak.',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.35,
                    color: AppColors.primary.withValues(alpha: 0.62),
                  ),
                ),
              ],
            ),
          ),
          const SoftModernIcon(
            DiyetselAssets.modernIconBell,
            size: 56,
            fallback: Icons.campaign_rounded,
            fallbackColor: Color(0xFFE07A5F),
          ),
        ],
      ),
    );
  }
}

class SoftAdminNotifStats extends StatelessWidget {
  const SoftAdminNotifStats({
    super.key,
    required this.clientCount,
    required this.sentCount,
  });

  final int clientCount;
  final int sentCount;

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, String value, Color accent, IconData icon) {
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
              Icon(icon, size: 20, color: accent),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: accent),
              ),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11.5,
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
        chip('Danışan', '$clientCount', AppColors.primary, Icons.groups_rounded),
        const SizedBox(width: 10),
        chip('Gönderilen', '$sentCount', const Color(0xFFE07A5F), Icons.send_rounded),
      ],
    );
  }
}

class SoftAdminNotifComposeCard extends StatelessWidget {
  const SoftAdminNotifComposeCard({
    super.key,
    required this.titleController,
    required this.bodyController,
    required this.targetAll,
    required this.onTargetAllChanged,
    required this.clients,
    required this.selectedIds,
    required this.onToggleClient,
    required this.route,
    required this.onRouteChanged,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController titleController;
  final TextEditingController bodyController;
  final bool targetAll;
  final ValueChanged<bool> onTargetAllChanged;
  final List<UserProfile> clients;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggleClient;
  final String route;
  final ValueChanged<String> onRouteChanged;
  final bool sending;
  final VoidCallback onSend;

  static const routes = [
    ('', 'Yönlendirme yok'),
    ('/app/diet', 'Diyet planı'),
    ('/app/track', 'Su / takip'),
    ('/app/appointments', 'Randevu'),
    ('/app/check-in', 'Check-in'),
    ('/app/recipes', 'Tarifler'),
    ('/app/blog', 'Blog'),
    ('/app/chat', 'Sohbet'),
    ('/app/services', 'Hizmetler'),
  ];

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
            'Yeni bildirim',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15,
              color: AppColors.primaryDeep,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: titleController,
            maxLength: 60,
            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryDeep),
            decoration: InputDecoration(
              labelText: 'Başlık',
              hintText: 'Örn. Haftalık check-in hatırlatması',
              filled: true,
              fillColor: AppColors.modernWash,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              counterText: '',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: bodyController,
            maxLength: 180,
            maxLines: 4,
            style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryDeep, height: 1.35),
            decoration: InputDecoration(
              labelText: 'Mesaj',
              hintText: 'Danışanın bildirimde göreceği metin…',
              filled: true,
              fillColor: AppColors.modernWash,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hedef kitle',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primaryDeep),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _AudienceChip(
                  label: 'Tüm danışanlar',
                  selected: targetAll,
                  onTap: () => onTargetAllChanged(true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _AudienceChip(
                  label: 'Seçili danışanlar',
                  selected: !targetAll,
                  onTap: () => onTargetAllChanged(false),
                ),
              ),
            ],
          ),
          if (!targetAll) ...[
            const SizedBox(height: 10),
            if (clients.isEmpty)
              Text(
                'Kayıtlı danışan yok.',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in clients)
                    FilterChip(
                      selected: selectedIds.contains(c.id),
                      label: Text(c.displayName),
                      onSelected: (_) => onToggleClient(c.id),
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: selectedIds.contains(c.id)
                            ? AppColors.primaryDeep
                            : AppColors.primary.withValues(alpha: 0.65),
                      ),
                    ),
                ],
              ),
          ],
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: routes.any((e) => e.$1 == route) ? route : '',
            decoration: InputDecoration(
              labelText: 'Uygulama içi yönlendirme (opsiyonel)',
              filled: true,
              fillColor: AppColors.modernWash,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
            items: [
              for (final r in routes)
                DropdownMenuItem(value: r.$1, child: Text(r.$2)),
            ],
            onChanged: (v) => onRouteChanged(v ?? ''),
          ),
          const SizedBox(height: 16),
          SoftTap(
            onTap: sending ? null : onSend,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: sending
                      ? [AppColors.primary.withValues(alpha: 0.45), AppColors.primary.withValues(alpha: 0.35)]
                      : [AppColors.primary, AppColors.primaryDeep],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (sending)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                    )
                  else
                    const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    sending ? 'Gönderiliyor…' : 'Bildirimi gönder',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: Colors.white,
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

class _AudienceChip extends StatelessWidget {
  const _AudienceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.12) : AppColors.modernWash,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary.withValues(alpha: 0.4) : AppColors.modernLine,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13,
            color: selected ? AppColors.primaryDeep : AppColors.primary.withValues(alpha: 0.55),
          ),
        ),
      ),
    );
  }
}

class SoftAdminNotifHistoryCard extends StatelessWidget {
  const SoftAdminNotifHistoryCard({super.key, required this.items});

  final List<AdminBroadcast> items;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMM · HH:mm', 'tr');
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
            'Gönderim geçmişi',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15,
              color: AppColors.primaryDeep,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            items.isEmpty ? 'Henüz özel bildirim yok.' : '${items.length} kayıt',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const Divider(height: 20),
              _HistoryRow(item: items[i], when: fmt.format(items[i].createdAt)),
            ],
          ],
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.item, required this.when});

  final AdminBroadcast item;
  final String when;

  @override
  Widget build(BuildContext context) {
    final audience = item.targetAll
        ? 'Tüm danışanlar · ${item.recipientCount} kişi'
        : item.targetLabels.isEmpty
            ? '${item.recipientCount} danışan'
            : item.targetLabels.take(2).join(', ') +
                (item.targetLabels.length > 2 ? ' +${item.targetLabels.length - 2}' : '');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0E8),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.notifications_active_rounded, color: Color(0xFFE07A5F), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: AppColors.primaryDeep,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                  height: 1.35,
                  color: AppColors.primary.withValues(alpha: 0.62),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$when · $audience',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                  color: AppColors.primary.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SoftAdminNotifTip extends StatelessWidget {
  const SoftAdminNotifTip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFE8F5F0), Color(0xFFE3F2F8)]),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.modernLine),
      ),
      child: Text(
        'Bildirimler danışanın bir sonraki uygulama açılışında gösterilir. '
        'Android’de sistem bildirimi; Windows/web’de kuyruk yine kaydedilir.',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          height: 1.35,
          color: AppColors.primaryDeep.withValues(alpha: 0.82),
        ),
      ),
    );
  }
}
