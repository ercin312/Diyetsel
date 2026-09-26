import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/diyetsel_assets.dart';
import '../../../../core/models/enums.dart';
import '../../../../core/models/models.dart';
import '../../../dashboard/presentation/widgets/premium_home_widgets.dart' show SoftTap;
import '../../../dashboard/presentation/widgets/soft_home_widgets.dart' show SoftModernIcon;
import '../../../../core/l10n/ui_string.dart';

Color softApptStatusColor(AppointmentStatus s) => switch (s) {
      AppointmentStatus.approved => AppColors.primary,
      AppointmentStatus.pending => const Color(0xFFE8B86D),
      AppointmentStatus.rejected => AppColors.danger,
      AppointmentStatus.completed => AppColors.success,
      AppointmentStatus.rescheduled => const Color(0xFF5BA3C9),
    };

String softApptStatusLabel(AppointmentStatus s) => switch (s) {
      AppointmentStatus.approved => 'Onaylı',
      AppointmentStatus.pending => 'Bekliyor',
      AppointmentStatus.rejected => 'Reddedildi',
      AppointmentStatus.completed => 'Tamamlandı',
      AppointmentStatus.rescheduled => 'Ertelendi',
    };

class SoftCalendarHero extends StatelessWidget {
  const SoftCalendarHero({
    super.key,
    required this.title,
    required this.subtitle,
    this.next,
    this.onBook,
  });

  final String title;
  final String subtitle;
  final Appointment? next;
  final VoidCallback? onBook;

  @override
  Widget build(BuildContext context) {
    final hasNext = next != null;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: hasNext
              ? const [Color(0xFFE8F5F0), Color(0xFFFFF6E9)]
              : const [Color(0xFFFFF0D6), Color(0xFFFFF6E9)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 22,
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
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text((hasNext ? 'Yaklaşan seans' : 'Takvimin').ui,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text((title).ui,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 19,
                    color: AppColors.primaryDeep,
                    height: 1.2,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text((subtitle).ui,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.primary.withValues(alpha: 0.55),
                  ),
                ),
                if (onBook != null) ...[
                  const SizedBox(height: 14),
                  SoftTap(
                    onTap: onBook,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Text(('Müsait saat seç').ui,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.12), width: 2),
              boxShadow: AppSpacing.soft,
            ),
            padding: const EdgeInsets.all(14),
            child: SoftModernIcon(
              DiyetselAssets.modernIconCalendar,
              size: 56,
              fallback: Icons.event_available_rounded,
              fallbackColor: AppColors.primary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 320.ms).slideY(begin: -0.04, curve: Curves.easeOut);
  }
}

class SoftCalendarStatStrip extends StatelessWidget {
  const SoftCalendarStatStrip({
    super.key,
    required this.upcoming,
    required this.thisWeek,
    required this.pending,
  });

  final int upcoming;
  final int thisWeek;
  final int pending;

  @override
  Widget build(BuildContext context) {
    Widget chip(String value, String label, Color accent, String asset, IconData fallback) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Color.lerp(accent, Colors.white, 0.82),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accent.withValues(alpha: 0.22)),
          ),
          child: Column(
            children: [
              SoftModernIcon(asset, size: 22, fallback: fallback, fallbackColor: accent),
              const SizedBox(height: 6),
              Text((value).ui,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: accent),
              ),
              Text((label).ui,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: AppColors.primary.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        chip(
          '$upcoming',
          'yaklaşan',
          AppColors.primary,
          DiyetselAssets.modernIconCalendar,
          Icons.event_rounded,
        ),
        const SizedBox(width: 8),
        chip(
          '$thisWeek',
          'bu hafta',
          const Color(0xFF5BA3C9),
          DiyetselAssets.modernIconCheck,
          Icons.calendar_view_week_rounded,
        ),
        const SizedBox(width: 8),
        chip(
          '$pending',
          'bekleyen',
          const Color(0xFFE8B86D),
          DiyetselAssets.modernIconBell,
          Icons.hourglass_top_rounded,
        ),
      ],
    );
  }
}

class SoftFormatToggle extends StatelessWidget {
  const SoftFormatToggle({
    super.key,
    required this.format,
    required this.onChanged,
  });

  final CalendarFormat format;
  final ValueChanged<CalendarFormat> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget pill(String label, CalendarFormat value) {
      final selected = format == value;
      return Expanded(
        child: SoftTap(
          onTap: () => onChanged(value),
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text((label).ui,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: selected ? Colors.white : AppColors.primaryDeep,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.modernLine),
      ),
      child: Row(
        children: [
          pill('Hafta', CalendarFormat.week),
          pill('Ay', CalendarFormat.month),
        ],
      ),
    );
  }
}

class SoftTableCalendarCard extends StatelessWidget {
  const SoftTableCalendarCard({
    super.key,
    required this.focused,
    required this.selected,
    required this.format,
    required this.locale,
    required this.eventLoader,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.onPageChanged,
  });

  final DateTime focused;
  final DateTime selected;
  final CalendarFormat format;
  final String locale;
  final List<Appointment> Function(DateTime day) eventLoader;
  final void Function(DateTime selected, DateTime focused) onDaySelected;
  final ValueChanged<CalendarFormat> onFormatChanged;
  final ValueChanged<DateTime> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.softLift,
      ),
      child: TableCalendar<Appointment>(
        firstDay: DateTime.now().subtract(const Duration(days: 365)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: focused,
        selectedDayPredicate: (d) => DateUtils.isSameDay(d, selected),
        calendarFormat: format,
        startingDayOfWeek: StartingDayOfWeek.monday,
        locale: locale,
        availableCalendarFormats: const {
          CalendarFormat.month: 'Ay',
          CalendarFormat.week: 'Hafta',
        },
        eventLoader: eventLoader,
        onDaySelected: onDaySelected,
        onFormatChanged: onFormatChanged,
        onPageChanged: onPageChanged,
        calendarStyle: CalendarStyle(
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
          ),
          todayTextStyle: const TextStyle(
            color: AppColors.primaryDeep,
            fontWeight: FontWeight.w900,
          ),
          defaultTextStyle: const TextStyle(
            color: AppColors.primaryDeep,
            fontWeight: FontWeight.w600,
          ),
          weekendTextStyle: TextStyle(
            color: AppColors.primary.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
          ),
          outsideTextStyle: TextStyle(
            color: AppColors.primary.withValues(alpha: 0.28),
          ),
          markerDecoration: const BoxDecoration(
            color: Color(0xFFE07A5F),
            shape: BoxShape.circle,
          ),
          markersMaxCount: 3,
          markerSize: 6,
          cellMargin: const EdgeInsets.all(4),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: AppColors.primary.withValues(alpha: 0.55),
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
          weekendStyle: TextStyle(
            color: AppColors.primary.withValues(alpha: 0.45),
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          leftChevronIcon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.modernWash,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.chevron_left_rounded, color: AppColors.primary),
          ),
          rightChevronIcon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.modernWash,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
          ),
          titleTextStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: AppColors.primaryDeep,
          ),
        ),
      ),
    );
  }
}

class SoftDayHeader extends StatelessWidget {
  const SoftDayHeader({
    super.key,
    required this.day,
    required this.count,
  });

  final DateTime day;
  final int count;

  @override
  Widget build(BuildContext context) {
    final isToday = DateUtils.isSameDay(day, DateTime.now());
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text((isToday ? 'Bugün' : DateFormat('EEEE', 'tr').format(day)).ui,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  color: AppColors.primaryDeep,
                ),
              ),
              Text((DateFormat('d MMMM yyyy', 'tr').format(day)).ui,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.primary.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: count > 0
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: count > 0 ? AppColors.primary.withValues(alpha: 0.2) : AppColors.modernLine,
            ),
          ),
          child: Text((count == 0 ? 'Boş gün' : '$count randevu').ui,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: count > 0 ? AppColors.primary : AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }
}

class SoftAppointmentCard extends StatelessWidget {
  const SoftAppointmentCard({
    super.key,
    required this.appointment,
    required this.index,
    this.admin = false,
    this.onTap,
  });

  final Appointment appointment;
  final int index;
  final bool admin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    final accent = softApptStatusColor(a.status);
    final time = DateFormat('HH:mm', 'tr').format(a.startAt);
    final end = DateFormat('HH:mm', 'tr').format(a.endAt);
    final duration = a.endAt.difference(a.startAt).inMinutes;

    return SoftTap(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(accent, Colors.white, 0.88)!,
              Colors.white,
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: accent.withValues(alpha: 0.28)),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.12),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 58,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accent.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Text((time).ui,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: accent,
                    ),
                  ),
                  Text((end).ui,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: AppColors.primary.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text((a.serviceTitle?.isNotEmpty == true
                              ? a.serviceTitle!
                              : (admin ? a.clientName : 'Diyetisyen seansı')).ui,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            color: AppColors.primaryDeep,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text((softApptStatusLabel(a.status)).ui,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            color: accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (admin) ...[
                    const SizedBox(height: 4),
                    Text((a.clientName).ui,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        color: AppColors.primary.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(('$duration dk · ${DateFormat('d MMM', 'tr').format(a.startAt)}').ui,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ),
                  if (a.clinicalNotes?.isNotEmpty == true) ...[
                    const SizedBox(height: 6),
                    Text(('Not: ${a.clinicalNotes}').ui,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: AppColors.primary.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: (45 * index).ms)
        .fadeIn(duration: 280.ms)
        .slideY(begin: 0.05, end: 0, duration: 340.ms, curve: Curves.easeOutCubic);
  }
}

class SoftCalendarEmptyDay extends StatelessWidget {
  const SoftCalendarEmptyDay({super.key, this.onBook});

  final VoidCallback? onBook;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.modernLine),
      ),
      child: Column(
        children: [
          SoftModernIcon(
            DiyetselAssets.modernIconCalendar,
            size: 48,
            fallback: Icons.event_busy_rounded,
            fallbackColor: AppColors.primary.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 12),
          Text(('Bu günde randevu yok').ui,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15,
              color: AppColors.primaryDeep,
            ),
          ),
          const SizedBox(height: 4),
          Text(('Müsait bir slot seçerek yeni seans talep edebilirsin.').ui,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
          if (onBook != null) ...[
            const SizedBox(height: 14),
            SoftTap(
              onTap: onBook,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(('Saat seç').ui,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SoftUpcomingList extends StatelessWidget {
  const SoftUpcomingList({
    super.key,
    required this.items,
    required this.admin,
    this.onTap,
  });

  final List<Appointment> items;
  final bool admin;
  final void Function(Appointment a)? onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(('Yaklaşanlar').ui,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: AppColors.primaryDeep,
          ),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < items.length; i++) ...[
          SoftAppointmentCard(
            appointment: items[i],
            index: i,
            admin: admin,
            onTap: onTap == null ? null : () => onTap!(items[i]),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class SoftAvailabilityChips extends StatelessWidget {
  const SoftAvailabilityChips({super.key, required this.rules});

  final List<AvailabilityRule> rules;

  String _dayName(int w) => const ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'][w - 1];

  @override
  Widget build(BuildContext context) {
    if (rules.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(('Uygunluk saatleri').ui,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 15,
            color: AppColors.primaryDeep,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final r in rules)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.modernLine),
                ),
                child: Text(('${_dayName(r.weekday)}  ${r.start}–${r.end}').ui,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                    color: AppColors.primaryDeep,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class SoftSlotPickerSheet extends StatelessWidget {
  const SoftSlotPickerSheet({
    super.key,
    required this.day,
    required this.slots,
  });

  final DateTime day;
  final List<DateTime> slots;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.modernWash,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
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
              const SizedBox(height: 16),
              Text((DateFormat('d MMMM EEEE', 'tr').format(day)).ui,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: AppColors.primaryDeep,
                ),
              ),
              const SizedBox(height: 4),
              Text(('Müsait bir saat seç').ui,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.primary.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 16),
              if (slots.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(('Bu gün için boş slot yok').ui,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.45,
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.2,
                    ),
                    itemCount: slots.length,
                    itemBuilder: (context, i) {
                      final s = slots[i];
                      final label = DateFormat('HH:mm').format(s);
                      return SoftTap(
                        onTap: () => Navigator.pop(context, s),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                            boxShadow: AppSpacing.soft,
                          ),
                          child: Text((label).ui,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
