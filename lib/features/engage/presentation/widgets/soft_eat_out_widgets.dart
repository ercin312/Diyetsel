import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/diyetsel_assets.dart';
import '../../../../core/utils/engage_logic.dart';
import '../../../dashboard/presentation/widgets/premium_home_widgets.dart' show SoftTap;
import '../../../dashboard/presentation/widgets/soft_home_widgets.dart' show SoftModernIcon;
import '../../../../core/widgets/nav_back.dart';
import '../../../../core/l10n/ui_string.dart';


Color softEatTint(String category) {
  switch (category) {
    case 'Salata':
      return const Color(0xFFE8F5F0);
    case 'Balık':
      return const Color(0xFFE3F2F8);
    case 'Kafe':
      return const Color(0xFFFFF0E8);
    case 'Kahvaltı':
      return const Color(0xFFFFF8E8);
    case 'Izgara':
      return const Color(0xFFFFF0E8);
    case 'Sokak':
      return const Color(0xFFFFF6E9);
    case 'Lokanta':
      return const Color(0xFFE8F5F0);
    default:
      return const Color(0xFFE8F5F0);
  }
}

Color softEatAccent(String category) {
  switch (category) {
    case 'Salata':
      return AppColors.primary;
    case 'Balık':
      return const Color(0xFF5BA3C9);
    case 'Kafe':
      return const Color(0xFFE07A5F);
    case 'Kahvaltı':
      return const Color(0xFFD4A017);
    case 'Izgara':
      return const Color(0xFFE07A5F);
    case 'Sokak':
      return const Color(0xFF5BA3C9);
    case 'Lokanta':
      return AppColors.primary;
    default:
      return AppColors.primary;
  }
}

class SoftEatOutHeader extends StatelessWidget {
  const SoftEatOutHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SoftNavBackButton(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(('Dışarıda ne yesem?').ui,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDeep,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 2),
              Text(('Kaloriye sığan menü önerileri').ui,
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
          child: SoftModernIcon(
            DiyetselAssets.modernIconPlan,
            size: 28,
            fallback: Icons.restaurant_menu_rounded,
            fallbackColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class SoftEatOutHero extends StatelessWidget {
  const SoftEatOutHero({
    super.key,
    required this.remaining,
    required this.tight,
    required this.optionCount,
  });

  final int remaining;
  final bool tight;
  final int optionCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: tight
              ? const [Color(0xFFFFF0E8), Color(0xFFFFF6E9)]
              : const [Color(0xFFE8F5F0), Color(0xFFFFF6E9), Color(0xFFE3F2F8)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: [
          BoxShadow(
            color: (tight ? const Color(0xFFE07A5F) : AppColors.primary).withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
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
                    color: (tight ? const Color(0xFFE07A5F) : AppColors.primary).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text((tight ? 'Bütçe dar' : 'Bugünkü kalan').ui,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                      color: tight ? const Color(0xFFE07A5F) : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text((tight ? 'Hafif seç, sonra teşekkür et' : '$remaining kcal kaldı').ui,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 21,
                    height: 1.15,
                    color: AppColors.primaryDeep,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text((tight
                      ? 'Kahve, çorba veya paylaşım porsiyonu daha güvenli.'
                      : '$optionCount seçenek · sos ayrı, pilavı çıkar').ui,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.35,
                    color: AppColors.primaryDeep.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          SoftModernIcon(
            DiyetselAssets.modernCardDetox,
            size: 78,
            fallback: Icons.restaurant_menu_rounded,
            fallbackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class SoftEatOutStatsRow extends StatelessWidget {
  const SoftEatOutStatsRow({
    super.key,
    required this.remaining,
    required this.fits,
    required this.categories,
  });

  final int remaining;
  final int fits;
  final int categories;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Kalan', '$remaining', DiyetselAssets.modernIconCheck, Icons.local_fire_department_rounded, AppColors.primary),
      ('Sığan', '$fits', DiyetselAssets.modernIconPlan, Icons.restaurant_rounded, const Color(0xFF5BA3C9)),
      ('Tür', '$categories', DiyetselAssets.modernIconAppsAll, Icons.category_rounded, const Color(0xFFE07A5F)),
    ];
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.modernLine),
                boxShadow: AppSpacing.soft,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SoftModernIcon(
                    items[i].$3,
                    size: 24,
                    fallback: items[i].$4,
                    fallbackColor: items[i].$5,
                  ),
                  const SizedBox(height: 8),
                  Text((items[i].$1).ui,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11.5,
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ),
                  Text((items[i].$2).ui,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: items[i].$5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class SoftEatOutRulesCard extends StatelessWidget {
  const SoftEatOutRulesCard({super.key});

  static const _rules = [
    (Icons.outdoor_grill_rounded, Color(0xFFE07A5F), 'Izgara / buğulama seç'),
    (Icons.no_meals_rounded, Color(0xFF5BA3C9), 'Sos ve ekmeği ayrı iste'),
    (Icons.water_drop_rounded, AppColors.primary, 'Yanına ayran veya salata'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(('3 sipariş kuralı').ui,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15.5,
              color: AppColors.primaryDeep,
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < _rules.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color.lerp(_rules[i].$2, Colors.white, 0.82),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _rules[i].$2.withValues(alpha: 0.22)),
                  ),
                  child: Icon(_rules[i].$1, size: 20, color: _rules[i].$2),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(('${i + 1}. ${_rules[i].$3}').ui,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      color: AppColors.primaryDeep,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class SoftEatOutCategoryChip extends StatelessWidget {
  const SoftEatOutCategoryChip({
    super.key,
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
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? AppColors.primary : AppColors.modernLine),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : AppSpacing.soft,
        ),
        child: Text((label).ui,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 12.5,
            color: selected ? Colors.white : AppColors.primaryDeep.withValues(alpha: 0.75),
          ),
        ),
      ),
    );
  }
}

class SoftEatOutFeaturedCard extends StatelessWidget {
  const SoftEatOutFeaturedCard({
    super.key,
    required this.idea,
    required this.remaining,
    required this.onOpen,
  });

  final EatOutIdea idea;
  final int remaining;
  final VoidCallback onOpen;

  bool get _fits => idea.kcal <= remaining + 40;

  @override
  Widget build(BuildContext context) {
    final tint = softEatTint(idea.category);
    final accent = softEatAccent(idea.category);

    return SoftTap(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppColors.modernLine),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.14),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(tint, Colors.white, 0.1)!,
                    Color.lerp(tint, const Color(0xFFFFF6E9), 0.35)!,
                  ],
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(idea.icon, size: 28, color: accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(('Önerilen · ${idea.category}').ui,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                  color: accent,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _fits ? AppColors.primary : const Color(0xFFE07A5F),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text((_fits ? 'sığar' : 'dikkat').ui,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text((idea.title).ui,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 19,
                            height: 1.2,
                            color: AppColors.primaryDeep,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(('${idea.place} · ${idea.kcal} kcal').ui,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColors.primary.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text((idea.blurb.isNotEmpty ? idea.blurb : idea.tip).ui,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                      height: 1.35,
                      color: AppColors.primary.withValues(alpha: 0.65),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      SoftEatMiniPill(label: 'kcal', value: '${idea.kcal}', color: const Color(0xFFE07A5F)),
                      if (idea.proteinG > 0) ...[
                        const SizedBox(width: 6),
                        SoftEatMiniPill(label: 'protein', value: '${idea.proteinG}g', color: AppColors.primary),
                      ],
                      const Spacer(),
                      Text(('Detay').ui,
                        style: TextStyle(fontWeight: FontWeight.w800, color: accent, fontSize: 13.5),
                      ),
                      Icon(Icons.arrow_forward_rounded, size: 18, color: accent),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SoftEatOutCard extends StatelessWidget {
  const SoftEatOutCard({
    super.key,
    required this.idea,
    required this.remaining,
    required this.onOpen,
    this.index = 0,
  });

  final EatOutIdea idea;
  final int remaining;
  final VoidCallback onOpen;
  final int index;

  bool get _fits => idea.kcal <= remaining + 40;

  @override
  Widget build(BuildContext context) {
    final tint = softEatTint(idea.category);
    final accent = softEatAccent(idea.category);

    return SoftTap(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.modernLine),
          boxShadow: AppSpacing.soft,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(tint, Colors.white, 0.15)!,
                    Color.lerp(tint, const Color(0xFFFFF6E9), 0.4)!,
                  ],
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(idea.icon, size: 24, color: accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text((idea.title).ui,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16.5,
                                  height: 1.2,
                                  color: AppColors.primaryDeep,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _fits ? AppColors.primary : const Color(0xFFE07A5F),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text((_fits ? 'sığar' : 'dikkat').ui,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(('${idea.place} · ${idea.category}').ui,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12.5,
                            color: AppColors.primary.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text((idea.blurb.isNotEmpty ? idea.blurb : idea.tip).ui,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      height: 1.35,
                      color: AppColors.primaryDeep.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      SoftEatMiniPill(label: 'kcal', value: '${idea.kcal}', color: const Color(0xFFE07A5F)),
                      if (idea.proteinG > 0)
                        SoftEatMiniPill(label: 'protein', value: '${idea.proteinG}g', color: AppColors.primary),
                      for (final t in idea.tags.take(2))
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.modernWash,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.modernLine),
                          ),
                          child: Text((t).ui,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              color: AppColors.primary.withValues(alpha: 0.75),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline_rounded, size: 16, color: accent),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text((idea.tip).ui,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                            color: AppColors.primary.withValues(alpha: 0.55),
                          ),
                        ),
                      ),
                      Text(('Detay').ui,
                        style: TextStyle(fontWeight: FontWeight.w800, color: accent, fontSize: 13),
                      ),
                      Icon(Icons.chevron_right_rounded, color: accent, size: 20),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (40 * index).ms, duration: 280.ms).slideY(
          begin: 0.04,
          curve: Curves.easeOutCubic,
        );
  }
}

class SoftEatMiniPill extends StatelessWidget {
  const SoftEatMiniPill({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Color.lerp(color, Colors.white, 0.82),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$value ',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: color),
            ),
            TextSpan(
              text: label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SoftEatOutEmpty extends StatelessWidget {
  const SoftEatOutEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.modernLine),
      ),
      child: Column(
        children: [
          SoftModernIcon(
            DiyetselAssets.modernIconSearch,
            size: 48,
            fallback: Icons.restaurant_outlined,
            fallbackColor: AppColors.primary.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 12),
          Text(('Bu kategoride uyan seçenek yok').ui,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: AppColors.primaryDeep,
            ),
          ),
          const SizedBox(height: 6),
          Text(('Filtreyi değiştir veya tümünü görüntüle.').ui,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class SoftEatOutTipCard extends StatelessWidget {
  const SoftEatOutTipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SoftModernIcon(
            DiyetselAssets.modernIconBell,
            size: 28,
            fallback: Icons.chat_bubble_rounded,
            fallbackColor: const Color(0xFFE07A5F),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(('Sos konuşması').ui,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: AppColors.primaryDeep,
                  ),
                ),
                const SizedBox(height: 4),
                Text(('“Sosu ayrı, ekmek yok, salata bol” cümlesi çoğu restoranda 150–300 kcal kazandırır.').ui,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.primary.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SoftEatOutDetailSheet extends StatelessWidget {
  const SoftEatOutDetailSheet({
    super.key,
    required this.idea,
    required this.remaining,
  });

  final EatOutIdea idea;
  final int remaining;

  bool get _fits => idea.kcal <= remaining + 40;

  @override
  Widget build(BuildContext context) {
    final tint = softEatTint(idea.category);
    final accent = softEatAccent(idea.category);

    return DraggableScrollableSheet(
      initialChildSize: 0.86,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, scroll) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.modernWash,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: scroll,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppColors.modernLine,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.lerp(tint, Colors.white, 0.12)!,
                      const Color(0xFFFFF6E9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.modernLine),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.modernLine),
                      ),
                      child: Icon(idea.icon, size: 34, color: accent),
                    ).animate().fadeIn().scale(
                          begin: const Offset(0.9, 0.9),
                          curve: Curves.easeOutBack,
                        ),
                    const SizedBox(height: 14),
                    Text((idea.title).ui,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: AppColors.primaryDeep,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(('${idea.place} · ${idea.category}').ui,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        SoftEatMiniPill(label: 'kcal', value: '${idea.kcal}', color: const Color(0xFFE07A5F)),
                        if (idea.proteinG > 0)
                          SoftEatMiniPill(label: 'protein', value: '${idea.proteinG}g', color: AppColors.primary),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _fits ? AppColors.primary : const Color(0xFFE07A5F),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text((_fits ? 'Bütçene sığar' : 'Dikkatli ol').ui,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (idea.blurb.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text((idea.blurb).ui,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                    fontSize: 14.5,
                    color: AppColors.primaryDeep.withValues(alpha: 0.88),
                  ),
                ),
              ],
              if (idea.orderLine.isNotEmpty) ...[
                const SizedBox(height: 18),
                Text(('Şöyle söyle').ui,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: AppColors.primaryDeep,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.modernLine),
                    boxShadow: AppSpacing.soft,
                  ),
                  child: Text(('“${idea.orderLine}”').ui,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                      color: AppColors.primaryDeep.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
              if (idea.swaps.isNotEmpty) ...[
                const SizedBox(height: 18),
                Text(('Akıllı swap’ler').ui,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: AppColors.primaryDeep,
                  ),
                ),
                const SizedBox(height: 8),
                for (var i = 0; i < idea.swaps.length; i++)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.modernLine),
                    ),
                    child: Row(
                      children: [
                        SoftModernIcon(
                          DiyetselAssets.modernIconCheck,
                          size: 20,
                          fallback: Icons.swap_horiz_rounded,
                          fallbackColor: accent,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text((idea.swaps[i]).ui,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDeep,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: (40 * i).ms, duration: 260.ms),
              ],
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.modernLine),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline_rounded, color: accent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text((idea.tip).ui,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                          color: AppColors.primary.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
