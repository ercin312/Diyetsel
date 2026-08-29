import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/enums.dart';
import '../../../core/utils/desktop.dart';
import '../../../core/widgets/soft_desktop_frame.dart';
import '../../auth/presentation/auth_controller.dart';
import 'widgets/soft_admin_notifications_widgets.dart';

/// Soft premium admin — özel danışan bildirimleri gönder / geçmiş.
class SoftAdminNotificationsScreen extends ConsumerStatefulWidget {
  const SoftAdminNotificationsScreen({super.key});

  @override
  ConsumerState<SoftAdminNotificationsScreen> createState() =>
      _SoftAdminNotificationsScreenState();
}

class _SoftAdminNotificationsScreenState
    extends ConsumerState<SoftAdminNotificationsScreen> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  bool _targetAll = true;
  final Set<String> _selected = {};
  String _route = '';
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
        const SnackBar(content: Text('Başlık ve mesaj gerekli')),
      );
      return;
    }
    if (!_targetAll && _selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('En az bir danışan seç')),
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
        route: _route,
        targetAll: _targetAll,
        targetUserIds: _selected.toList(),
      );
      if (!mounted) return;
      _title.clear();
      _body.clear();
      setState(() {
        _selected.clear();
        _targetAll = true;
        _route = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            broadcast.recipientCount == 0
                ? 'Alıcı bulunamadı'
                : '${broadcast.recipientCount} danışana bildirim kuyruğa alındı',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gönderilemedi: $e')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    if (auth.user == null || !auth.user!.isAdmin) {
      return const Scaffold(
        backgroundColor: AppColors.modernWash,
        body: Center(child: Text('Bu bölüm yalnızca diyetisyen içindir.')),
      );
    }

    final store = ref.watch(appStoreProvider);
    ref.watch(usersProvider);
    ref.watch(adminBroadcastsProvider);

    final clients = store.users().where((u) => u.role == UserRole.client).toList()
      ..sort((a, b) => a.displayName.compareTo(b.displayName));
    final history = store.adminBroadcasts();
    final desktop = context.isDesktopLayout;
    final pad = desktop
        ? EdgeInsets.fromLTRB(0, context.pagePadding.top, 0, context.pagePadding.bottom)
        : const EdgeInsets.fromLTRB(18, 12, 18, 28);

    final compose = SoftAdminNotifComposeCard(
      titleController: _title,
      bodyController: _body,
      targetAll: _targetAll,
      onTargetAllChanged: (v) => setState(() => _targetAll = v),
      clients: clients,
      selectedIds: _selected,
      onToggleClient: (id) => setState(() {
        if (_selected.contains(id)) {
          _selected.remove(id);
        } else {
          _selected.add(id);
        }
      }),
      route: _route,
      onRouteChanged: (v) => setState(() => _route = v),
      sending: _sending,
      onSend: _send,
    )
        .animate()
        .fadeIn(delay: 80.ms, duration: 300.ms)
        .slideY(begin: 0.04, curve: Curves.easeOutCubic);

    final historyCard = SoftAdminNotifHistoryCard(items: history.take(20).toList())
        .animate()
        .fadeIn(delay: 110.ms, duration: 280.ms);

    return Scaffold(
      backgroundColor: AppColors.modernWash,
      body: SafeArea(
        child: SoftDesktopBody(
          child: ListView(
            padding: pad,
            children: [
              const SoftAdminNotifHeader()
                  .animate()
                  .fadeIn(duration: 280.ms)
                  .slideY(begin: -0.05, curve: Curves.easeOutCubic),
              const SizedBox(height: 14),
              SoftAdminNotifHero(
                clientCount: clients.length,
                sentCount: history.length,
              )
                  .animate()
                  .fadeIn(delay: 40.ms, duration: 300.ms)
                  .scale(
                    begin: const Offset(0.97, 0.97),
                    curve: Curves.easeOutCubic,
                    duration: 380.ms,
                  ),
              const SizedBox(height: 12),
              SoftAdminNotifStats(
                clientCount: clients.length,
                sentCount: history.length,
              ).animate().fadeIn(delay: 60.ms, duration: 280.ms),
              const SizedBox(height: 14),
              if (desktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: compose),
                    const SizedBox(width: 14),
                    Expanded(flex: 4, child: historyCard),
                  ],
                )
              else ...[
                compose,
                const SizedBox(height: 14),
                historyCard,
              ],
              const SizedBox(height: 12),
              const SoftAdminNotifTip()
                  .animate()
                  .fadeIn(delay: 140.ms, duration: 280.ms),
            ],
          ),
        ),
      ),
    );
  }
}
