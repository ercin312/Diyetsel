import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/l10n/ui_string.dart';
import '../../../core/models/models.dart';
import '../../../core/widgets/app_page.dart';
import '../../auth/presentation/auth_controller.dart';

class NotificationInboxScreen extends ConsumerStatefulWidget {
  const NotificationInboxScreen({super.key});

  @override
  ConsumerState<NotificationInboxScreen> createState() => _NotificationInboxScreenState();
}

class _NotificationInboxScreenState extends ConsumerState<NotificationInboxScreen> {
  var _dietitian = true;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    if (user == null) return const SizedBox.shrink();
    ref.watch(adminBroadcastsProvider);
    ref.watch(inboxNoticesProvider(user.id));
    final store = ref.watch(appStoreProvider);
    final rows = _rows(store, user.id, dietitian: _dietitian);
    final modern = context.isModern;

    return AppPage(
      title: 'Bildirimler',
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: true, label: Text(('Diyetisyen').ui)),
              ButtonSegment(value: false, label: Text(('Hatırlatıcılar').ui)),
            ],
            selected: {_dietitian},
            onSelectionChanged: (value) => setState(() => _dietitian = value.first),
          ),
          const SizedBox(height: 8),
          Text(
            (_dietitian
                    ? 'Diyetisyenin gönderdiği duyurular ve notlar.'
                    : 'Su, öğün ve randevu hatırlatıcıları.')
                .ui,
            style: TextStyle(
              color: modern ? AppColors.lightMuted : AppColors.kawaiiMuted,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: rows.isEmpty
                ? Center(
                    child: Text(
                      (_dietitian ? 'Diyetisyenden henüz bildirim yok.' : 'Henüz hatırlatıcı yok.').ui,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: modern ? AppColors.lightMuted : AppColors.kawaiiMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: rows.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) => _NoticeCard(row: rows[index], modern: modern),
                  ),
          ),
        ],
      ),
    );
  }

  List<_NoticeRow> _rows(AppStore store, String userId, {required bool dietitian}) {
    if (!dietitian) {
      return store
          .inboxFor(userId)
          .where((n) => !n.fromDietitian)
          .map(_NoticeRow.fromNotice)
          .toList();
    }

    final seen = <String>{};
    final rows = <_NoticeRow>[];
    for (final broadcast in store.adminBroadcasts()) {
      final mine = broadcast.targetAll || broadcast.targetUserIds.contains(userId);
      if (!mine) continue;
      final key = '${broadcast.title.trim()}|${broadcast.body.trim()}';
      if (!seen.add(key)) continue;
      rows.add(_NoticeRow(
        title: broadcast.title,
        body: broadcast.body,
        at: broadcast.createdAt,
        route: broadcast.route,
      ));
    }
    for (final notice in store.inboxFor(userId).where((n) => n.fromDietitian)) {
      final key = '${notice.title.trim()}|${notice.body.trim()}';
      if (!seen.add(key)) continue;
      rows.add(_NoticeRow.fromNotice(notice));
    }
    rows.sort((a, b) => b.at.compareTo(a.at));
    return rows;
  }
}

class _NoticeRow {
  const _NoticeRow({
    required this.title,
    required this.body,
    required this.at,
    this.route = '',
  });

  final String title;
  final String body;
  final DateTime at;
  final String route;

  factory _NoticeRow.fromNotice(InboxNotice notice) => _NoticeRow(
        title: notice.title,
        body: notice.body,
        at: notice.createdAt,
        route: notice.route,
      );
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.row, required this.modern});

  final _NoticeRow row;
  final bool modern;

  @override
  Widget build(BuildContext context) {
    final accent = modern ? AppColors.primary : AppColors.kawaiiLeaf;
    return Material(
      color: modern ? AppColors.lightSurface : AppColors.kawaiiBubble,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: row.route.isEmpty ? null : () => context.push(row.route),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      (row.title).ui,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _stamp(row.at),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ),
                ],
              ),
              if (row.body.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  (row.body).ui,
                  style: TextStyle(
                    height: 1.3,
                    color: modern ? AppColors.lightInk : AppColors.kawaiiInk,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _stamp(DateTime d) {
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    final now = DateTime.now();
    final today = d.year == now.year && d.month == now.month && d.day == now.day;
    if (today) return '${('Bugün').ui} $hh:$mm';
    return '${d.day}.${d.month}.${d.year} $hh:$mm';
  }
}
