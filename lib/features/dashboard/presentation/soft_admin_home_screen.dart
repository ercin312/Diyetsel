import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/models.dart';
import '../../../core/utils/desktop.dart';
import '../../../core/utils/pdf_report.dart';
import '../../../core/widgets/soft_desktop_frame.dart';
import '../../auth/presentation/auth_controller.dart';
import 'widgets/soft_admin_home_widgets.dart';

/// Soft premium admin home — clinic KPIs, shortcuts, quiet clients, payments.
class SoftAdminHomeScreen extends ConsumerWidget {
  const SoftAdminHomeScreen({super.key});

  Future<void> _addPayment(
    BuildContext context,
    WidgetRef ref,
    List<UserProfile> clients,
  ) async {
    if (clients.isEmpty) return;
    var client = clients.first;
    final amount = TextEditingController();
    final note = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ödeme kaydı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<UserProfile>(
              initialValue: client,
              items: [
                for (final c in clients)
                  DropdownMenuItem(value: c, child: Text(c.displayName)),
              ],
              onChanged: (v) => client = v ?? client,
            ),
            TextField(
              controller: amount,
              decoration: const InputDecoration(labelText: 'Tutar'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: note,
              decoration: const InputDecoration(labelText: 'Not'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
          FilledButton(
            onPressed: () async {
              await ref.read(appStoreProvider).savePayment(
                    PaymentRecord(
                      id: newId(),
                      clientId: client.id,
                      clientName: client.displayName,
                      amount: double.tryParse(amount.text) ?? 0,
                      status: PaymentStatus.due,
                      date: DateTime.now(),
                      note: note.text,
                    ),
                  );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(usersProvider);
    ref.watch(appointmentsProvider);
    ref.watch(paymentsProvider);
    ref.watch(checkInsProvider);

    final clients = store.users().where((u) => u.role == UserRole.client).toList();
    final active = clients.where((c) => c.isActive).length;
    final appointments = store.appointments();
    final payments = [...store.payments()]
      ..sort((a, b) => b.date.compareTo(a.date));
    final monthSessions = appointments
        .where(
          (a) =>
              a.startAt.month == DateTime.now().month &&
              a.startAt.year == DateTime.now().year &&
              a.status == AppointmentStatus.completed,
        )
        .length;
    final pendingAppts =
        appointments.where((a) => a.status == AppointmentStatus.pending).length;
    final due = payments
        .where((p) => p.status != PaymentStatus.paid)
        .fold<double>(0, (s, p) => s + p.amount);
    final paid = payments
        .where((p) => p.status == PaymentStatus.paid)
        .fold<double>(0, (s, p) => s + p.amount);
    final quiet = store.silentClients();
    final desktop = context.isDesktopLayout;
    final pad = desktop
        ? EdgeInsets.fromLTRB(0, context.pagePadding.top, 0, context.pagePadding.bottom)
        : const EdgeInsets.fromLTRB(18, 12, 18, 28);

    final quietCard = SoftAdminHomeQuietCard(quiet: quiet)
        .animate()
        .fadeIn(delay: 110.ms, duration: 280.ms);
    final paymentsCard = SoftAdminHomePaymentsCard(
      payments: payments,
      onAdd: () => _addPayment(context, ref, clients),
    ).animate().fadeIn(delay: 130.ms, duration: 280.ms);

    return Scaffold(
      backgroundColor: AppColors.modernWash,
      body: SafeArea(
        child: SoftDesktopBody(
          child: ListView(
            padding: pad,
            children: [
              SoftAdminHomeHeader(
                name: user.displayName,
                onPdf: () => PdfReport.sharePracticeSummary(
                  clients: clients,
                  appointments: appointments,
                  payments: payments,
                ),
              )
                  .animate()
                  .fadeIn(duration: 280.ms)
                  .slideY(begin: -0.05, curve: Curves.easeOutCubic),
              const SizedBox(height: 14),
              SoftAdminHomeHero(
                active: active,
                total: clients.length,
                pendingAppts: pendingAppts,
                monthSessions: monthSessions,
              )
                  .animate()
                  .fadeIn(delay: 40.ms, duration: 300.ms)
                  .scale(
                    begin: const Offset(0.97, 0.97),
                    curve: Curves.easeOutCubic,
                    duration: 380.ms,
                  ),
              const SizedBox(height: 12),
              SoftAdminHomeKpis(
                activeLabel: '$active / ${clients.length}',
                sessions: '$monthSessions',
                paid: '₺${paid.toStringAsFixed(0)}',
                due: '₺${due.toStringAsFixed(0)}',
              ).animate().fadeIn(delay: 70.ms, duration: 280.ms),
              const SizedBox(height: 16),
              const SoftAdminHomeShortcuts()
                  .animate()
                  .fadeIn(delay: 90.ms, duration: 300.ms),
              const SizedBox(height: 16),
              if (desktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: quietCard),
                    const SizedBox(width: 14),
                    Expanded(flex: 2, child: paymentsCard),
                  ],
                )
              else ...[
                quietCard,
                const SizedBox(height: 12),
                paymentsCard,
              ],
              const SizedBox(height: 12),
              const SoftAdminHomeTip()
                  .animate()
                  .fadeIn(delay: 150.ms, duration: 280.ms),
            ],
          ),
        ),
      ),
    );
  }
}
