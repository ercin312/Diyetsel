import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/enums.dart';
import '../../../core/utils/desktop.dart';
import '../../../core/widgets/soft_desktop_frame.dart';
import 'client_care_screen.dart';
import 'widgets/soft_clients_widgets.dart';

/// Soft premium admin CRM — danışan listesi.
class SoftClientsScreen extends ConsumerStatefulWidget {
  const SoftClientsScreen({super.key});

  @override
  ConsumerState<SoftClientsScreen> createState() => _SoftClientsScreenState();
}

class _SoftClientsScreenState extends ConsumerState<SoftClientsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(appStoreProvider);
    ref.watch(usersProvider);

    final clients = store.users().where((u) => u.role == UserRole.client).toList()
      ..sort((a, b) => a.displayName.compareTo(b.displayName));
    final active = clients.where((c) => c.isActive).length;
    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? clients
        : clients
            .where(
              (c) =>
                  c.displayName.toLowerCase().contains(q) ||
                  c.email.toLowerCase().contains(q),
            )
            .toList();
    final desktop = context.isDesktopLayout;
    final pad = desktop
        ? EdgeInsets.fromLTRB(0, context.pagePadding.top, 0, context.pagePadding.bottom)
        : const EdgeInsets.fromLTRB(18, 12, 18, 28);

    Widget tile(int i) => SoftClientTile(
          client: filtered[i],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => ClientCareScreen(clientId: filtered[i].id),
            ),
          ),
        )
            .animate()
            .fadeIn(delay: (90 + 18 * i).ms, duration: 260.ms)
            .slideY(begin: 0.04, curve: Curves.easeOutCubic);

    return Scaffold(
      backgroundColor: AppColors.modernWash,
      body: SafeArea(
        child: SoftDesktopBody(
          child: ListView(
            padding: pad,
            children: [
              const SoftClientsHeader()
                  .animate()
                  .fadeIn(duration: 280.ms)
                  .slideY(begin: -0.05, curve: Curves.easeOutCubic),
              const SizedBox(height: 14),
              SoftClientsHero(active: active, total: clients.length)
                  .animate()
                  .fadeIn(delay: 40.ms, duration: 300.ms)
                  .scale(
                    begin: const Offset(0.97, 0.97),
                    curve: Curves.easeOutCubic,
                    duration: 380.ms,
                  ),
              const SizedBox(height: 12),
              const SoftClientsQuickLinks()
                  .animate()
                  .fadeIn(delay: 60.ms, duration: 280.ms),
              const SizedBox(height: 12),
              SoftClientsSearchField(
                onChanged: (v) => setState(() => _query = v),
              ).animate().fadeIn(delay: 80.ms, duration: 280.ms),
              const SizedBox(height: 16),
              if (filtered.isEmpty)
                const SoftClientsEmpty()
              else if (desktop)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: context.isExtraWide ? 3 : 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.55,
                  ),
                  itemBuilder: (_, i) => tile(i),
                )
              else
                for (var i = 0; i < filtered.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: tile(i),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
