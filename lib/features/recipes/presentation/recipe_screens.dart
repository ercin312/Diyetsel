import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/utils/recipe_logic.dart';
import '../../../core/widgets/marketplace.dart';
import '../../../core/widgets/style_icon.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/recipe_visuals.dart';
import 'cartoon_recipe_screen.dart';
import 'soft_recipe_screen.dart';

class RecipeTonightCard extends ConsumerWidget {
  const RecipeTonightCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    final recipes = ref.watch(recipesProvider).valueOrNull ?? [];
    final pick = tonightPick(store, user.id, recipes);
    if (pick == null) return const SizedBox.shrink();

    final cartoon = context.isCartoon;
    final modern = context.isModern;
    final r = pick.recipe;
    final radius = cartoon ? 28.0 : (24.0);
    final photo = diyetselFoodImage(imageUrl: r.imageUrl, seed: r.title);

    if (modern) {
      Widget card = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/app/recipes'),
          borderRadius: BorderRadius.circular(radius),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.modernTealCard,
              borderRadius: BorderRadius.circular(radius),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.modernSoftShadow,
                  blurRadius: 24,
                  offset: Offset(0, 10)),
              ]),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 108, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Bugün akşam bunu dene',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.88),
                                    fontWeight: FontWeight.w600))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.modernFire,
                              borderRadius: BorderRadius.circular(16)),
                            child: Text(
                              pick.highlight,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 11))),
                        ]),
                      const SizedBox(height: 10),
                      Text(
                        r.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              height: 1.15)),
                      const SizedBox(height: 6),
                      Text(
                        pick.reason,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.72), height: 1.3)),
                      const SizedBox(height: 8),
                      Text(
                        '${r.calories} kcal • ${r.prepMinutes} dk • ${recipeProtein(r)} g protein',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.modernSageSoft)),
                    ])),
                Positioned(
                  right: -8,
                  top: 18,
                  bottom: 18,
                  child: Center(
                    child: Container(
                      width: 108,
                      height: 108,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6)),
                        ]),
                      clipBehavior: Clip.antiAlias,
                      child: diyetselFoodPhoto(url: photo, width: 108, height: 108)))),
              ]))));
      return card.animate().fadeIn().slideY(begin: 0.05);
    }

    Widget card = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/app/recipes'),
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: cartoon
                  ? const [AppColors.kawaiiCream, AppColors.kawaiiMint]
                  : const [AppColors.primaryDeep, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(radius),
            border: null,
            boxShadow: cartoon
                ? const [
                    BoxShadow(
                      color: AppColors.kawaiiShadow,
                      blurRadius: 20,
                      offset: Offset(0, 8)),
                  ]
                : null),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Bugün akşam bunu dene',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                    letterSpacing: null,
                                    color: cartoon ? AppColors.kawaiiInk : Colors.white))),
                              DoodleBadge(label: pick.highlight, emoji: '💪'),
                            ]),
                          const SizedBox(height: 10),
                          Text(
                            r.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              letterSpacing: null,
                              color: cartoon ? AppColors.kawaiiInk : Colors.white)),
                          const SizedBox(height: 6),
                          Text(
                            pick.reason,
                            style: TextStyle(
                              color: cartoon ? AppColors.kawaiiInk.withValues(alpha: 0.78) : Colors.white70)),
                          const SizedBox(height: 8),
                          Text(
                            '${r.calories} kcal • ${r.prepMinutes} dk • ${recipeProtein(r)} g protein',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: cartoon
                                  ? AppColors.kawaiiCoral
                                  : Colors.white70)),
                        ])),
                    if (cartoon) ...[
                      const SizedBox(width: 8),
                      diyetselFoodPhoto(
                        url: RecipeVisuals.imageFor(r),
                        width: 96,
                        height: 96,
                        fit: BoxFit.contain),
                    ],
                  ])))));
    if (cartoon) {
      return card
          .animate()
          .fadeIn(duration: 320.ms)
          .scale(begin: const Offset(0.94, 0.94), curve: Curves.easeOutBack, duration: 420.ms);
    }
    return card.animate().fadeIn().slideY(begin: 0.05);
  }
}

class RecipesScreen extends ConsumerStatefulWidget {
  const RecipesScreen({super.key, this.admin = false});
  final bool admin;

  @override
  ConsumerState<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends ConsumerState<RecipesScreen> {
  @override
  Widget build(BuildContext context) {
    if (context.isCartoon) {
      return CartoonRecipesScreen(admin: widget.admin);
    }
    return SoftRecipesScreen(admin: widget.admin);
  }
}
