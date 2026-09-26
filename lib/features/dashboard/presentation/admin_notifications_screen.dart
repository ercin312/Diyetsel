import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/enums.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/diyetsel_widgets.dart';
import '../../auth/presentation/auth_controller.dart';
import 'soft_admin_notifications_screen.dart';
import '../../../core/l10n/ui_string.dart';

class AdminNotificationsScreen extends ConsumerStatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  ConsumerState<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends ConsumerState<AdminNotificationsScreen> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  bool _targetAll = true;
  final Set<String> _selected = {};
  bool _sending = false;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final title = _title.text.trim();
    final body = _body.text.trim();
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(('Başlık ve mesaj gerekli').ui)),
      );
      return;
    }
    if (!_targetAll && _selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(('En az bir danışan seç').ui)),
      );
      return;
    }

    setState(() => _sending = true);
    try {
      final user = ref.read(authControllerProvider).user!;
      final store = ref.read(appStoreProvider);
      final broadcast = await store.sendAdminBroadcast(
        adminId: user.id,
        title: title,
        body: body,
        targetAll: _targetAll,
        targetUserIds: _selected.toList(),
      );
      if (!mounted) return;
      _title.clear();
      _body.clear();
      setState(() {
        _selected.clear();
        _targetAll = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(('${broadcast.recipientCount} danışana kuyruğa alındı').ui)),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (context.isModern) {
      return const SoftAdminNotificationsScreen();
    }

    final store = ref.watch(appStoreProvider);
    ref.watch(usersProvider);
    ref.watch(adminBroadcastsProvider);
    final clients = store.users().where((u) => u.role == UserRole.client).toList();
    final history = store.adminBroadcasts();

    return AppPage(
      title: 'Bildirimler',
      child: ListView(
        children: [
          DiyetselCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Özel bildirim',
                  subtitle: 'Danışanlara başlık ve mesaj gönder.',
                ),
                TextField(
                  controller: _title,
                  decoration: InputDecoration(labelText: ('Başlık').ui),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _body,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: ('Mesaj').ui),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(('Tüm danışanlar').ui),
                  value: _targetAll,
                  onChanged: (v) => setState(() => _targetAll = v),
                ),
                if (!_targetAll)
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final c in clients)
                        FilterChip(
                          selected: _selected.contains(c.id),
                          label: Text((c.displayName).ui),
                          onSelected: (_) => setState(() {
                            if (_selected.contains(c.id)) {
                              _selected.remove(c.id);
                            } else {
                              _selected.add(c.id);
                            }
                          }),
                        ),
                    ],
                  ),
                const SizedBox(height: 12),
                DiyetselButton(
                  label: _sending ? 'Gönderiliyor…' : 'Gönder',
                  onPressed: _sending ? null : _send,
                  icon: Icons.send_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          DiyetselCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Geçmiş'),
                if (history.isEmpty)
                  Text(('Henüz bildirim yok.').ui)
                else
                  for (final item in history.take(15))
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text((item.title).ui, style: const TextStyle(fontWeight: FontWeight.w800)),
                      subtitle: Text(('${item.body}\n${item.recipientCount} alıcı').ui),
                      isThreeLine: true,
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
