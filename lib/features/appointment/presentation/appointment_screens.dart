import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/data/seed_data.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/models.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/diyetsel_widgets.dart';
import '../../../core/widgets/style_icon.dart';
import '../../auth/presentation/auth_controller.dart';
import 'client_care_screen.dart';
import 'soft_calendar_screen.dart';
import 'soft_clients_screen.dart';

class AppointmentCalendarScreen extends ConsumerStatefulWidget {
  const AppointmentCalendarScreen({super.key, this.admin = false});
  final bool admin;

  @override
  ConsumerState<AppointmentCalendarScreen> createState() => _AppointmentCalendarScreenState();
}

class _AppointmentCalendarScreenState extends ConsumerState<AppointmentCalendarScreen> {
  DateTime _focused = DateTime.now();
  DateTime _selected = DateTime.now();
  CalendarFormat _format = CalendarFormat.week;

  @override
  Widget build(BuildContext context) {
    if (context.isModern) {
      return SoftCalendarScreen(admin: widget.admin);
    }

    final user = ref.watch(authControllerProvider).user!;
    final all = ref.watch(appointmentsProvider).valueOrNull ?? [];
    final items = all.where((a) => widget.admin || a.clientId == user.id).toList();
    final dayItems = items.where((a) => DateUtils.isSameDay(a.startAt, _selected)).toList();
    final store = ref.watch(appStoreProvider);
    ref.watch(availabilityProvider);

    final now = DateTime.now();
    final upcoming = items
        .where(
          (a) =>
              a.startAt.isAfter(now) &&
              a.status != AppointmentStatus.rejected &&
              a.status != AppointmentStatus.completed,
        )
        .toList();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    final thisWeek = items
        .where(
          (a) =>
              !a.startAt.isBefore(weekStart) &&
              a.startAt.isBefore(weekEnd) &&
              a.status != AppointmentStatus.rejected,
        )
        .length;
    final pending = items.where((a) => a.status == AppointmentStatus.pending).length;
    final cartoon = context.isCartoon;

    return AppPage(
      title: widget.admin ? 'Takvim' : 'Randevularım',
      actions: [
        IconButton(
          icon: const Icon(Icons.view_week),
          onPressed: () => setState(() {
            _format = _format == CalendarFormat.month ? CalendarFormat.week : CalendarFormat.month;
          }),
        ),
      ],
      child: ListView(
        children: [
          if (cartoon) ...[
            _CartoonCalendarStatStrip(
              upcoming: upcoming.length,
              thisWeek: thisWeek,
              pending: pending,
            ).animate().fadeIn(duration: 280.ms),
            const SizedBox(height: 12),
            _CartoonCalendarTipCard(
              admin: widget.admin,
              pending: pending,
              thisWeek: thisWeek,
              hasNext: upcoming.isNotEmpty,
              onBook: widget.admin ? null : () => _book(context, store, user),
            ).animate().fadeIn(delay: 40.ms, duration: 280.ms),
            const SizedBox(height: 12),
          ],
          DiyetselCard(
            color: cartoon ? AppColors.kawaiiLemon.withValues(alpha: 0.55) : null,
            padding: const EdgeInsets.all(8),
            child: TableCalendar<Appointment>(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focused,
              selectedDayPredicate: (d) => DateUtils.isSameDay(d, _selected),
              calendarFormat: _format,
              startingDayOfWeek: StartingDayOfWeek.monday,
              locale: context.locale.toString(),
              eventLoader: (day) => items.where((a) => DateUtils.isSameDay(a.startAt, day)).toList(),
              onDaySelected: (s, f) => setState(() {
                _selected = s;
                _focused = f;
              }),
              onFormatChanged: (f) => setState(() => _format = f),
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: context.brandPrimary,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                todayDecoration: BoxDecoration(
                  color: cartoon
                      ? AppColors.kawaiiRose.withValues(alpha: 0.85)
                      : AppColors.modernSageSoft.withValues(
                              alpha: Theme.of(context).brightness == Brightness.dark ? 0.45 : 0.95,
                            ),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  color: cartoon
                      ? AppColors.kawaiiInk
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
                defaultTextStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                weekendTextStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                outsideTextStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.55)),
                markerDecoration: BoxDecoration(
                  color: cartoon ? AppColors.kawaiiCoral : context.brandPrimary,
                  shape: BoxShape.circle,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w700),
                weekendStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w700),
              ),
              headerStyle: HeaderStyle(
                titleTextStyle: Theme.of(context).textTheme.titleMedium!,
                formatButtonTextStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                leftChevronIcon: Icon(Icons.chevron_left, color: Theme.of(context).colorScheme.onSurface),
                rightChevronIcon: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (!widget.admin)
            DiyetselButton(
              label: 'Müsait saat seç',
              icon: Icons.add,
              onPressed: () => _book(context, store, user),
            ),
          const SizedBox(height: 8),
          if (dayItems.isEmpty && cartoon && !widget.admin)
            _CartoonEmptyDay(onBook: () => _book(context, store, user))
          else
            ...dayItems.map((a) => _tile(context, a, store, user)),
          if (widget.admin) ...[
            const SectionHeader(title: 'Uygunluk'),
            Wrap(
              spacing: 8,
              children: [
                for (final r in store.availability())
                  Chip(label: Text('${_dayName(r.weekday)} ${r.start}-${r.end}')),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _dayName(int w) => const ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'][w - 1];

  Widget _tile(BuildContext context, Appointment a, AppStore store, UserProfile user) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: ValueKey(a.id),
        background: Container(color: AppColors.danger.withValues(alpha: 0.2), alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 16), child: const Icon(Icons.delete)),
        confirmDismiss: (_) async {
          if (!widget.admin) return false;
          await store.saveAppointment(a.copyWith(status: AppointmentStatus.rejected));
          return false;
        },
        child: DiyetselCard(
          color: context.isCartoon ? AppColors.kawaiiMint.withValues(alpha: 0.65) : null,
          onTap: widget.admin ? () => _adminActions(context, store, a) : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text('${a.clientName} • ${TimeOfDay.fromDateTime(a.startAt).format(context)}', style: const TextStyle(fontWeight: FontWeight.w800))),
                  StatusChip(label: a.status.name, color: _color(a.status)),
                ],
              ),
              if (a.serviceTitle != null) Text(a.serviceTitle!),
              if (a.clinicalNotes != null) Text('Not: ${a.clinicalNotes}'),
              if (a.recommendations != null) Text('Tavsiye: ${a.recommendations}'),
            ],
          ),
        ),
      ),
    );
  }

  Color _color(AppointmentStatus s) => switch (s) {
        AppointmentStatus.approved => AppColors.success,
        AppointmentStatus.pending => AppColors.warning,
        AppointmentStatus.rejected => AppColors.danger,
        AppointmentStatus.completed => AppColors.calorie,
        AppointmentStatus.rescheduled => AppColors.warning,
      };

  Future<void> _book(BuildContext context, AppStore store, UserProfile user) async {
    final slots = store.openSlots(dietitianId: SeedData.adminId, day: _selected);
    if (slots.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bu gün için boş slot yok')));
      }
      return;
    }
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      builder: (ctx) => ListView(
        children: [
          for (final s in slots)
            ListTile(
              title: Text(TimeOfDay.fromDateTime(s).format(context)),
              onTap: () => Navigator.pop(ctx, s),
            ),
        ],
      ),
    );
    if (picked == null) return;
    await store.saveAppointment(
      Appointment(
        id: newId(),
        dietitianId: SeedData.adminId,
        clientId: user.id,
        clientName: user.displayName,
        startAt: picked,
        endAt: picked.add(const Duration(minutes: 45)),
        status: AppointmentStatus.pending,
      ),
    );
  }

  Future<void> _adminActions(BuildContext context, AppStore store, Appointment a) async {
    final notes = TextEditingController(text: a.clinicalNotes ?? '');
    final rec = TextEditingController(text: a.recommendations ?? '');
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom, left: 16, right: 16, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 8,
              children: [
                ActionChip(label: const Text('Onayla'), onPressed: () => store.saveAppointment(a.copyWith(status: AppointmentStatus.approved))),
                ActionChip(label: const Text('Reddet'), onPressed: () => store.saveAppointment(a.copyWith(status: AppointmentStatus.rejected))),
                ActionChip(
                  label: const Text('Ertele +1 gün'),
                  onPressed: () => store.saveAppointment(
                    a.copyWith(
                      status: AppointmentStatus.rescheduled,
                      startAt: a.startAt.add(const Duration(days: 1)),
                      endAt: a.endAt.add(const Duration(days: 1)),
                    ),
                  ),
                ),
                ActionChip(label: const Text('Tamamla'), onPressed: () => store.saveAppointment(a.copyWith(status: AppointmentStatus.completed))),
              ],
            ),
            TextField(controller: notes, decoration: const InputDecoration(labelText: 'Klinik notlar'), maxLines: 3),
            TextField(controller: rec, decoration: const InputDecoration(labelText: 'Tavsiyeler'), maxLines: 2),
            const SizedBox(height: 8),
            DiyetselButton(
              label: 'Notları kaydet',
              onPressed: () {
                store.saveAppointment(a.copyWith(clinicalNotes: notes.text, recommendations: rec.text));
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _CartoonCalendarStatStrip extends StatelessWidget {
  const _CartoonCalendarStatStrip({
    required this.upcoming,
    required this.thisWeek,
    required this.pending,
  });

  final int upcoming;
  final int thisWeek;
  final int pending;

  @override
  Widget build(BuildContext context) {
    Widget chip(String value, String label, Color tint, Color accent, IconData icon) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.kawaiiOutline),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: accent),
              const SizedBox(height: 6),
              Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: accent)),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.kawaiiMuted)),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        chip('$upcoming', 'yaklaşan', AppColors.kawaiiMint, AppColors.kawaiiLeafDeep, Icons.event_rounded),
        const SizedBox(width: 8),
        chip('$thisWeek', 'bu hafta', AppColors.kawaiiSky, AppColors.kawaiiSkyBlue, Icons.calendar_view_week_rounded),
        const SizedBox(width: 8),
        chip('$pending', 'bekleyen', AppColors.kawaiiLemon, AppColors.kawaiiCoralDeep, Icons.hourglass_top_rounded),
      ],
    );
  }
}

class _CartoonCalendarTipCard extends StatelessWidget {
  const _CartoonCalendarTipCard({
    required this.admin,
    required this.pending,
    required this.thisWeek,
    required this.hasNext,
    this.onBook,
  });

  final bool admin;
  final int pending;
  final int thisWeek;
  final bool hasNext;
  final VoidCallback? onBook;

  @override
  Widget build(BuildContext context) {
    final title = admin ? 'Klinik ritmi' : 'Randevu ipucu';
    final body = admin
        ? (pending > 0
            ? '$pending bekleyen talep var — hızlı onay danışan bağlılığını artırır.'
            : 'Bu hafta $thisWeek seans. Sessiz danışanlara kısa bir kontrol mesajı at.')
        : (hasNext
            ? 'Seansından 1 gün önce check-in ve ölçülerini güncelle — görüşme daha verimli olur.'
            : 'Düzenli seanslar planı güncel tutar. Müsait bir slot seçip talep gönder.');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onBook,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.kawaiiMint, AppColors.kawaiiLemon]),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.kawaiiOutline),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                admin ? Icons.event_available_rounded : Icons.calendar_month_rounded,
                color: AppColors.kawaiiLeafDeep,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: AppColors.kawaiiInk)),
                    const SizedBox(height: 4),
                    Text(body, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: AppColors.kawaiiMuted, height: 1.35)),
                    if (onBook != null) ...[
                      const SizedBox(height: 6),
                      const Text(
                        'Randevu talep et →',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.kawaiiLeafDeep),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartoonEmptyDay extends StatelessWidget {
  const _CartoonEmptyDay({this.onBook});

  final VoidCallback? onBook;

  @override
  Widget build(BuildContext context) {
    return DiyetselCard(
      color: AppColors.kawaiiBubble,
      child: Column(
        children: [
          const Icon(Icons.event_busy_rounded, size: 40, color: AppColors.kawaiiMuted),
          const SizedBox(height: 10),
          const Text(
            'Bu günde randevu yok',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.kawaiiInk),
          ),
          const SizedBox(height: 4),
          const Text(
            'Müsait bir slot seçerek yeni seans talep edebilirsin.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: AppColors.kawaiiMuted),
          ),
          if (onBook != null) ...[
            const SizedBox(height: 12),
            DiyetselButton(label: 'Randevu al', icon: Icons.add, onPressed: onBook),
          ],
        ],
      ),
    );
  }
}

class ClientsScreen extends ConsumerWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (context.isModern) return const SoftClientsScreen();

    final users = (ref.watch(usersProvider).valueOrNull ?? []).where((u) => !u.isAdmin).toList();
    return AppPage(
      title: 'Danışanlar',
      child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('Bir danışana dokun: su hedefi, aktiflik ve bölümleri aç/kapa.'),
          ),
          for (final c in users)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: DiyetselCard(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => ClientCareScreen(clientId: c.id)),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CartoonAvatar(name: c.displayName, size: 44),
                  title: Text(c.displayName, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('${c.email}\nSu ${(c.waterGoalMl / 1000).toStringAsFixed(1)} L • hedef ${c.targetWeightKg ?? '-'} kg'),
                  isThreeLine: true,
                  trailing: StatusChip(label: c.isActive ? 'aktif' : 'pasif', color: c.isActive ? AppColors.success : AppColors.danger),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
