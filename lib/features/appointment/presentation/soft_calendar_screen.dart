import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/data/seed_data.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/models.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/diyetsel_widgets.dart';
import '../../../core/widgets/soft_ui_kit.dart';
import '../../auth/presentation/auth_controller.dart';
import 'widgets/soft_calendar_widgets.dart';

/// Soft premium modern calendar / appointments — cream / teal wellness language.
class SoftCalendarScreen extends ConsumerStatefulWidget {
  const SoftCalendarScreen({super.key, this.admin = false});

  final bool admin;

  @override
  ConsumerState<SoftCalendarScreen> createState() => _SoftCalendarScreenState();
}

class _SoftCalendarScreenState extends ConsumerState<SoftCalendarScreen> {
  DateTime _focused = DateTime.now();
  DateTime _selected = DateTime.now();
  CalendarFormat _format = CalendarFormat.week;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user!;
    final all = ref.watch(appointmentsProvider).valueOrNull ?? [];
    final items = all.where((a) => widget.admin || a.clientId == user.id).toList()
      ..sort((a, b) => a.startAt.compareTo(b.startAt));
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
    final next = upcoming.isEmpty ? null : upcoming.first;

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

    String heroTitle;
    String heroSubtitle;
    if (next != null) {
      heroTitle = next.serviceTitle?.isNotEmpty == true
          ? next.serviceTitle!
          : (widget.admin ? next.clientName : 'Diyetisyen seansı');
      heroSubtitle =
          '${DateFormat('d MMMM · HH:mm', 'tr').format(next.startAt)} · ${softApptStatusLabel(next.status)}';
    } else {
      heroTitle = widget.admin ? 'Takvim özeti' : 'Seansını planla';
      heroSubtitle = widget.admin
          ? 'Danışan randevularını buradan yönet'
          : 'Müsait slotlardan randevu talep et';
    }

    return AppPage(
      title: widget.admin ? 'Takvim' : 'Randevularım',
      padding: EdgeInsets.zero,
      child: ColoredBox(
        color: AppColors.modernWash,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
          children: [
            SoftCalendarHero(
              title: heroTitle,
              subtitle: heroSubtitle,
              next: next,
              onBook: widget.admin ? null : () => _book(context, store, user),
            ),
            const SizedBox(height: 12),
            SoftCalendarStatStrip(
              upcoming: upcoming.length,
              thisWeek: thisWeek,
              pending: pending,
            ).animate().fadeIn(delay: 40.ms, duration: 280.ms),
            const SizedBox(height: 12),
            SoftTipCard(
              title: widget.admin ? 'Klinik ritmi' : 'Randevu ipucu',
              body: widget.admin
                  ? (pending > 0
                      ? '$pending bekleyen talep var — hızlı onay danışan bağlılığını artırır.'
                      : 'Bu hafta $thisWeek seans. Sessiz danışanlara kısa bir kontrol mesajı at.')
                  : (next == null
                      ? 'Düzenli seanslar planı güncel tutar. Müsait bir slot seçip talep gönder.'
                      : 'Seansından 1 gün önce check-in ve ölçülerini güncelle — görüşme daha verimli olur.'),
              icon: widget.admin ? Icons.event_available_rounded : Icons.calendar_month_rounded,
              accent: AppColors.primary,
              tint: AppColors.modernMint,
              onTap: widget.admin ? null : () => _book(context, store, user),
              actionLabel: widget.admin ? null : 'Randevu talep et →',
            ),
            const SizedBox(height: 14),
            SoftFormatToggle(
              format: _format,
              onChanged: (f) => setState(() => _format = f),
            ),
            const SizedBox(height: 12),
            SoftTableCalendarCard(
              focused: _focused,
              selected: _selected,
              format: _format,
              locale: context.locale.toString(),
              eventLoader: (day) => items.where((a) => DateUtils.isSameDay(a.startAt, day)).toList(),
              onDaySelected: (s, f) => setState(() {
                _selected = s;
                _focused = f;
              }),
              onFormatChanged: (f) => setState(() => _format = f),
              onPageChanged: (f) => setState(() => _focused = f),
            ).animate().fadeIn(delay: 60.ms, duration: 300.ms),
            const SizedBox(height: 18),
            SoftDayHeader(day: _selected, count: dayItems.length),
            const SizedBox(height: 12),
            if (dayItems.isEmpty)
              SoftCalendarEmptyDay(
                onBook: widget.admin ? null : () => _book(context, store, user),
              )
            else
              for (var i = 0; i < dayItems.length; i++) ...[
                SoftAppointmentCard(
                  appointment: dayItems[i],
                  index: i,
                  admin: widget.admin,
                  onTap: widget.admin
                      ? () => _adminActions(context, store, dayItems[i])
                      : null,
                ),
                const SizedBox(height: 10),
              ],
            if (!widget.admin) ...[
              const SizedBox(height: 8),
              SoftCalendarBookButton(onBook: () => _book(context, store, user)),
            ],
            if (upcoming.length > 1) ...[
              const SizedBox(height: 20),
              SoftUpcomingList(
                items: upcoming.skip(1).take(5).toList(),
                admin: widget.admin,
                onTap: widget.admin ? (a) => _adminActions(context, store, a) : null,
              ),
            ],
            if (widget.admin) ...[
              const SizedBox(height: 20),
              SoftAvailabilityChips(rules: store.availability()),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _book(BuildContext context, AppStore store, UserProfile user) async {
    final slots = store.openSlots(dietitianId: SeedData.adminId, day: _selected);
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SoftSlotPickerSheet(day: _selected, slots: slots),
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
        serviceTitle: 'Online / klinik seans',
      ),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Randevu talebi gönderildi · ${DateFormat('d MMM HH:mm', 'tr').format(picked)}',
          ),
        ),
      );
    }
    setState(() {});
  }

  Future<void> _adminActions(BuildContext context, AppStore store, Appointment a) async {
    final notes = TextEditingController(text: a.clinicalNotes ?? '');
    final rec = TextEditingController(text: a.recommendations ?? '');
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.modernWash,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(ctx).bottom + 16,
          left: 18,
          right: 18,
          top: 14,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.modernLine,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              a.clientName,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: AppColors.primaryDeep,
              ),
            ),
            Text(
              DateFormat('d MMMM · HH:mm', 'tr').format(a.startAt),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primary.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _adminChip('Onayla', AppColors.primary, () {
                  store.saveAppointment(a.copyWith(status: AppointmentStatus.approved));
                  Navigator.pop(ctx);
                }),
                _adminChip('Reddet', AppColors.danger, () {
                  store.saveAppointment(a.copyWith(status: AppointmentStatus.rejected));
                  Navigator.pop(ctx);
                }),
                _adminChip('Ertele +1 gün', const Color(0xFF5BA3C9), () {
                  store.saveAppointment(
                    a.copyWith(
                      status: AppointmentStatus.rescheduled,
                      startAt: a.startAt.add(const Duration(days: 1)),
                      endAt: a.endAt.add(const Duration(days: 1)),
                    ),
                  );
                  Navigator.pop(ctx);
                }),
                _adminChip('Tamamla', AppColors.success, () {
                  store.saveAppointment(a.copyWith(status: AppointmentStatus.completed));
                  Navigator.pop(ctx);
                }),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notes,
              decoration: const InputDecoration(labelText: 'Klinik notlar'),
              maxLines: 3,
            ),
            TextField(
              controller: rec,
              decoration: const InputDecoration(labelText: 'Tavsiyeler'),
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            DiyetselButton(
              label: 'Notları kaydet',
              onPressed: () {
                store.saveAppointment(
                  a.copyWith(clinicalNotes: notes.text, recommendations: rec.text),
                );
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
    setState(() {});
  }

  Widget _adminChip(String label, Color color, VoidCallback onTap) {
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w800, color: color),
      ),
      backgroundColor: color.withValues(alpha: 0.12),
      side: BorderSide(color: color.withValues(alpha: 0.25)),
      onPressed: onTap,
    );
  }
}

class SoftCalendarBookButton extends StatelessWidget {
  const SoftCalendarBookButton({super.key, required this.onBook});

  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onBook,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.28),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Text(
                'Müsait saat seç',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
