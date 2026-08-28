import '../../../core/models/enums.dart';
import '../../../core/models/models.dart';

class DietNextMeal {
  const DietNextMeal({
    required this.meal,
    required this.index,
    this.minutesUntil,
    this.isOverdue = false,
  });

  final DietMeal meal;
  final int index;
  final int? minutesUntil;
  final bool isOverdue;
}

class DietInteraction {
  DietInteraction._();

  static DietNextMeal? nextMeal(List<DietMeal> meals, [DateTime? now]) {
    final n = now ?? DateTime.now();
    final pending = <(DietMeal, int, int)>[];
    for (var i = 0; i < meals.length; i++) {
      final m = meals[i];
      if (m.consumed) continue;
      final mins = _minutesFromReminder(m.effectiveReminderTime, n);
      pending.add((m, i, mins));
    }
    if (pending.isEmpty) return null;
    pending.sort((a, b) => a.$3.compareTo(b.$3));
    // Prefer upcoming (positive) then least overdue
    final upcoming = pending.where((e) => e.$3 >= 0).toList();
    final pick = upcoming.isNotEmpty ? upcoming.first : pending.last;
    return DietNextMeal(
      meal: pick.$1,
      index: pick.$2,
      minutesUntil: pick.$3.abs(),
      isOverdue: pick.$3 < 0,
    );
  }

  static int _minutesFromReminder(String hhmm, DateTime now) {
    final parts = hhmm.split(':');
    final h = int.tryParse(parts[0]) ?? 8;
    final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    final target = DateTime(now.year, now.month, now.day, h, m);
    return target.difference(now).inMinutes;
  }

  static String countdownLabel(DietNextMeal next) {
    final mins = next.minutesUntil ?? 0;
    if (next.isOverdue) {
      if (mins < 60) return '$mins dk gecikti';
      return '${mins ~/ 60} sa gecikti';
    }
    if (mins < 60) return '$mins dk kaldı';
    final h = mins ~/ 60;
    final r = mins % 60;
    return r == 0 ? '$h sa kaldı' : '$h sa $r dk';
  }

  static String tipOfDay(int seed) {
    const tips = [
      'Öğünü yedikten sonra “Yedim”e dokun — makrolar ve seri anında güncellenir.',
      'Malzemeleri işaretleyerek hazırlığı takip et; unutulanlar azalır.',
      'Hatırlatma saatine dokunarak bildirim zamanını kendine göre ayarla.',
      'Su hedefini öğünlerle birlikte tut; her yemek yanında 1 bardak pratik bir ritüel.',
      'Haftalık chip’lerdeki mini bar, hangi günün eksik kaldığını gösterir.',
    ];
    return tips[seed.abs() % tips.length];
  }

  static int remainingKcal({
    required DietPlan plan,
    required DietDay day,
  }) {
    final eaten = day.meals.where((m) => m.consumed).fold(0, (s, m) => s + m.calories);
    return (plan.calorieTarget - eaten).clamp(0, plan.calorieTarget);
  }

  static String mealTypeEmoji(MealType t) => t.emoji;
}
