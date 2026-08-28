import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/constants/diyetsel_assets.dart';
import '../../../../core/models/enums.dart';
import '../../../../core/models/models.dart';
import '../../../../core/widgets/cartoon_asset_icon.dart';
import '../../../../core/widgets/diyetsel_widgets.dart';
import '../../../../core/widgets/luxury_glyph.dart';
import '../../../../core/widgets/style_icon.dart';
import '../../domain/meal_display.dart';

/// Themed, animated meal section with reminder time control.
class MealSectionCard extends StatelessWidget {
  const MealSectionCard({
    super.key,
    required this.meal,
    required this.index,
    required this.onToggleConsumed,
    required this.onPickReminder,
    this.adminPreview = false,
    this.onEditDescription,
    this.isNext = false,
  });

  final DietMeal meal;
  final int index;
  final VoidCallback onToggleConsumed;
  final VoidCallback onPickReminder;
  final bool adminPreview;
  final VoidCallback? onEditDescription;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    final cartoon = context.isCartoon;
    final luxury = context.isLuxury;
    Widget card;
    if (cartoon) {
      card = _CartoonMealCard(
        meal: meal,
        onToggle: onToggleConsumed,
        onPickReminder: onPickReminder,
        adminPreview: adminPreview,
        onEdit: onEditDescription,
        isNext: isNext,
      );
    } else if (luxury) {
      card = _LuxuryMealCard(
        meal: meal,
        onToggle: onToggleConsumed,
        onPickReminder: onPickReminder,
        adminPreview: adminPreview,
        onEdit: onEditDescription,
      );
    } else {
      card = _ModernMealCard(
        meal: meal,
        onToggle: onToggleConsumed,
        onPickReminder: onPickReminder,
        adminPreview: adminPreview,
        onEdit: onEditDescription,
      );
    }

    if (cartoon) {
      return card
          .animate(delay: (50 * index).ms)
          .fadeIn(duration: 280.ms)
          .scale(
            begin: const Offset(0.94, 0.94),
            end: const Offset(1, 1),
            duration: 420.ms,
            curve: Curves.easeOutBack,
          )
          .moveY(begin: 12, end: 0, duration: 420.ms, curve: Curves.easeOutCubic);
    }
    return card
        .animate(delay: (60 * index).ms)
        .fadeIn(duration: 380.ms, curve: Curves.easeOutCubic)
        .slideY(begin: 0.12, end: 0, duration: 420.ms, curve: Curves.easeOutCubic);
  }
}

class _ModernMealCard extends StatelessWidget {
  const _ModernMealCard({
    required this.meal,
    required this.onToggle,
    required this.onPickReminder,
    required this.adminPreview,
    this.onEdit,
  });

  final DietMeal meal;
  final VoidCallback onToggle;
  final VoidCallback onPickReminder;
  final bool adminPreview;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ingredients = MealDisplay.resolvedIngredients(meal);
    final headline = MealDisplay.headline(meal);
    final hook = MealDisplay.hook(meal);

    return DiyetselCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StyleIcon(icon: meal.type.icon, emoji: meal.type.emoji, size: 26, selected: meal.consumed),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.type.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                        letterSpacing: 0.2,
                      ),
                    ),
                    Text(
                      headline,
                      style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.2, fontSize: 16),
                    ),
                  ],
                ),
              ),
              _ReminderChip(time: meal.effectiveReminderTime, onTap: onPickReminder),
            ],
          ),
          const SizedBox(height: 10),
          Text(hook, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4)),
          if (ingredients.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final ing in ingredients)
                  _IngredientChip(
                    label: ing.amount.isEmpty ? ing.name : '${ing.name} · ${ing.amount}',
                    soft: true,
                  ),
              ],
            ),
          ],
          if (meal.calories > 0) ...[
            const SizedBox(height: 10),
            _MacroRow(calories: meal.calories, protein: meal.protein, carbs: meal.carbs, fat: meal.fat),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (!adminPreview)
                Expanded(
                  child: DiyetselButton(
                    label: meal.consumed ? 'Yenildi' : 'Yenildi olarak işaretle',
                    icon: meal.consumed ? Icons.check_circle : Icons.radio_button_unchecked,
                    onPressed: onToggle,
                    tonal: meal.consumed,
                  ),
                ),
              if (onEdit != null) ...[
                if (!adminPreview) const SizedBox(width: 8),
                IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_rounded)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _CartoonMealCard extends StatefulWidget {
  const _CartoonMealCard({
    required this.meal,
    required this.onToggle,
    required this.onPickReminder,
    required this.adminPreview,
    this.onEdit,
    this.isNext = false,
  });

  final DietMeal meal;
  final VoidCallback onToggle;
  final VoidCallback onPickReminder;
  final bool adminPreview;
  final VoidCallback? onEdit;
  final bool isNext;

  @override
  State<_CartoonMealCard> createState() => _CartoonMealCardState();
}

class _CartoonMealCardState extends State<_CartoonMealCard> {
  bool _expanded = false;
  final Set<int> _checkedIng = {};

  Color get _tint => switch (widget.meal.type) {
        MealType.breakfast => AppColors.kawaiiLemon,
        MealType.morningSnack => AppColors.kawaiiPeach,
        MealType.lunch => AppColors.kawaiiMint,
        MealType.afternoonSnack => AppColors.kawaiiSky,
        MealType.dinner => AppColors.kawaiiLilac,
      };

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;
    final ingredients = MealDisplay.resolvedIngredients(meal);
    final headline = MealDisplay.headline(meal);
    final hook = MealDisplay.hook(meal);
    final detail = MealDisplay.detailNote(meal);
    final tint = meal.consumed ? AppColors.kawaiiMint : _tint;
    final checkedCount = _checkedIng.length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
        border: Border.all(
          color: widget.isNext && !meal.consumed
              ? AppColors.kawaiiLeaf.withValues(alpha: 0.75)
              : AppColors.kawaiiOutline.withValues(alpha: 0.9),
          width: widget.isNext && !meal.consumed ? 1.8 : 1,
        ),
        boxShadow: AppSpacing.softLift,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(tint, Colors.white, 0.35)!,
                  Color.lerp(tint, AppColors.kawaiiCream, 0.55)!,
                ],
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                              border: Border.all(color: AppColors.kawaiiOutline.withValues(alpha: 0.7)),
                            ),
                            child: Text(
                              '${meal.type.emoji} ${MealDisplay.accentLabel(meal.type)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 11.5,
                                color: AppColors.kawaiiInk,
                              ),
                            ),
                          ),
                          if (widget.isNext && !meal.consumed) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.kawaiiLeaf,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Sıradaki',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10.5),
                              ),
                            ),
                          ],
                          const Spacer(),
                          _ReminderChip(time: meal.effectiveReminderTime, onTap: widget.onPickReminder, playful: true),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        headline,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 19,
                          height: 1.2,
                          color: AppColors.kawaiiInk,
                          letterSpacing: -0.3,
                          decoration: meal.consumed ? TextDecoration.lineThrough : null,
                          decorationColor: AppColors.kawaiiMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        hook,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                          height: 1.4,
                          color: AppColors.kawaiiInk.withValues(alpha: 0.78),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Image.asset(
                  MealDisplay.foodAsset(meal.type),
                  width: 78,
                  height: 78,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => CartoonAssetIcon(
                    DiyetselAssets.mascotAvocado,
                    size: 64,
                    fallback: meal.type.icon,
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
                if (ingredients.isNotEmpty) ...[
                  InkWell(
                    onTap: () => setState(() => _expanded = !_expanded),
                    borderRadius: BorderRadius.circular(10),
                    child: Row(
                      children: [
                        const Text(
                          'Tabakta neler var?',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                            color: AppColors.kawaiiMuted,
                          ),
                        ),
                        const Spacer(),
                        if (checkedCount > 0)
                          Text(
                            '$checkedCount/${ingredients.length}',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.kawaiiLeafDeep),
                          ),
                        Icon(
                          _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                          color: AppColors.kawaiiMuted,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (!_expanded)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final ing in ingredients.take(4))
                          _IngredientChip(
                            label: ing.amount.isEmpty ? ing.name : '${ing.name}  ·  ${ing.amount}',
                          ),
                        if (ingredients.length > 4)
                          _IngredientChip(label: '+${ingredients.length - 4}'),
                      ],
                    )
                  else
                    Column(
                      children: [
                        for (var i = 0; i < ingredients.length; i++)
                          InkWell(
                            onTap: () => setState(() {
                              if (_checkedIng.contains(i)) {
                                _checkedIng.remove(i);
                              } else {
                                _checkedIng.add(i);
                              }
                            }),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 160),
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: _checkedIng.contains(i) ? AppColors.kawaiiLeaf : Colors.transparent,
                                      borderRadius: BorderRadius.circular(7),
                                      border: Border.all(
                                        color: _checkedIng.contains(i) ? AppColors.kawaiiLeaf : AppColors.kawaiiOutline,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: _checkedIng.contains(i)
                                        ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      ingredients[i].name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        decoration: _checkedIng.contains(i) ? TextDecoration.lineThrough : null,
                                        color: _checkedIng.contains(i) ? AppColors.kawaiiMuted : AppColors.kawaiiInk,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    ingredients[i].amount,
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: AppColors.kawaiiLeafDeep),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
                if (detail != null && detail != hook) ...[
                  const SizedBox(height: 10),
                  Text(
                    detail,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                      color: AppColors.kawaiiInk.withValues(alpha: 0.7),
                    ),
                  ),
                ],
                if (meal.calories > 0) ...[
                  const SizedBox(height: 12),
                  _MacroRow(
                    calories: meal.calories,
                    protein: meal.protein,
                    carbs: meal.carbs,
                    fat: meal.fat,
                    playful: true,
                  ),
                ],
                const SizedBox(height: 14),
                if (!widget.adminPreview)
                  SizedBox(
                    width: double.infinity,
                    child: Material(
                      color: meal.consumed ? AppColors.kawaiiMint : AppColors.kawaiiLeaf,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      child: InkWell(
                        onTap: widget.onToggle,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                meal.consumed ? Icons.check_circle_rounded : Icons.restaurant_rounded,
                                color: meal.consumed ? AppColors.kawaiiLeafDeep : Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                meal.consumed ? 'Afiyet olsun! ✓' : 'Yedim — işaretle',
                                style: TextStyle(
                                  color: meal.consumed ? AppColors.kawaiiLeafDeep : Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (widget.onEdit != null)
                  TextButton.icon(onPressed: widget.onEdit, icon: const Icon(Icons.edit), label: const Text('Düzenle')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LuxuryMealCard extends StatelessWidget {
  const _LuxuryMealCard({
    required this.meal,
    required this.onToggle,
    required this.onPickReminder,
    required this.adminPreview,
    this.onEdit,
  });

  final DietMeal meal;
  final VoidCallback onToggle;
  final VoidCallback onPickReminder;
  final bool adminPreview;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final headline = MealDisplay.headline(meal);
    final hook = MealDisplay.hook(meal);
    return LuxurySheen(
      borderRadius: BorderRadius.circular(10),
      child: DiyetselCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StyleIcon(icon: meal.type.icon, emoji: meal.type.emoji, size: 24, selected: meal.consumed),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.type.tr.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.4,
                          fontSize: 11,
                          color: AppColors.luxuryGoldSoft,
                        ),
                      ),
                      Text(
                        headline,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                      ),
                    ],
                  ),
                ),
                _ReminderChip(time: meal.effectiveReminderTime, onTap: onPickReminder, luxury: true),
              ],
            ),
            const SizedBox(height: 12),
            Container(height: 0.8, color: AppColors.luxuryCopper.withValues(alpha: 0.35)),
            const SizedBox(height: 12),
            Text(
              hook,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.55, letterSpacing: 0.15),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                if (!adminPreview)
                  Expanded(
                    child: DiyetselButton(
                      label: meal.consumed ? 'Tamamlandı' : 'Tamamla',
                      onPressed: onToggle,
                      tonal: meal.consumed,
                    ),
                  ),
                if (onEdit != null) IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IngredientChip extends StatelessWidget {
  const _IngredientChip({required this.label, this.soft = false});

  final String label;
  final bool soft;

  @override
  Widget build(BuildContext context) {
    if (soft) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.kawaiiCream,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: AppColors.kawaiiOutline),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: AppColors.kawaiiInk,
        ),
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  const _MacroRow({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.playful = false,
  });

  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final bool playful;

  @override
  Widget build(BuildContext context) {
    final items = [
      (label: 'kcal', value: '$calories', color: playful ? AppColors.kawaiiCoral : AppColors.primary),
      (label: 'protein', value: '${protein}g', color: playful ? AppColors.kawaiiLeaf : const Color(0xFF2F9E7C)),
      (label: 'karb', value: '${carbs}g', color: playful ? AppColors.kawaiiWarmYellow : const Color(0xFFD4A017)),
      (label: 'yağ', value: '${fat}g', color: playful ? AppColors.kawaiiPurple : const Color(0xFF7C6CF0)),
    ];
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final m in items)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Color.lerp(m.color, Colors.white, playful ? 0.78 : 0.85),
              borderRadius: BorderRadius.circular(playful ? 16 : 12),
              border: Border.all(color: m.color.withValues(alpha: 0.35)),
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${m.value} ',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: m.color),
                  ),
                  TextSpan(
                    text: m.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: playful ? AppColors.kawaiiMuted : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ReminderChip extends StatelessWidget {
  const _ReminderChip({
    required this.time,
    required this.onTap,
    this.playful = false,
    this.luxury = false,
  });

  final String time;
  final VoidCallback onTap;
  final bool playful;
  final bool luxury;

  @override
  Widget build(BuildContext context) {
    final brand = context.brandPrimary;
    if (playful) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white.withValues(alpha: 0.92),
              border: Border.all(color: AppColors.kawaiiOutline),
              boxShadow: AppSpacing.soft,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CartoonAssetIcon(
                  DiyetselAssets.iconBell,
                  size: 16,
                  fallback: Icons.notifications_active_rounded,
                  fallbackColor: AppColors.kawaiiCoral,
                ),
                const SizedBox(width: 5),
                Text(
                  time,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                    color: AppColors.kawaiiInk,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(luxury ? 8 : 20),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(luxury ? 8 : 20),
            color: luxury ? AppColors.luxuryPlate : brand.withValues(alpha: 0.1),
            border: Border.all(
              color: luxury ? AppColors.luxuryCopper.withValues(alpha: 0.55) : brand.withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: luxury ? Colors.black.withValues(alpha: 0.25) : AppColors.modernSoftShadow,
                blurRadius: luxury ? 6 : 12,
                offset: Offset(0, luxury ? 2 : 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.notifications_active_rounded, size: 16, color: luxury ? AppColors.luxuryGoldSoft : brand),
              const SizedBox(width: 6),
              Text(
                time,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: luxury ? AppColors.luxuryInk : brand,
                  letterSpacing: luxury ? 0.6 : 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
