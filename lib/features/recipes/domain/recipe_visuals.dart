import '../../../core/constants/diyetsel_assets.dart';
import '../../../core/models/models.dart';
import '../../../core/utils/recipe_logic.dart';
import '../../../core/widgets/marketplace.dart';

/// Visual + display helpers for Premium Cartoon recipe UI.
class RecipeVisuals {
  RecipeVisuals._();

  static String imageFor(Recipe r) {
    if (r.imageUrl != null && r.imageUrl!.trim().isNotEmpty) {
      return r.imageUrl!.trim();
    }
    switch (r.id) {
      case 'rcp-bowl':
        return DiyetselAssets.foodSaladBowl;
      case 'rcp-soup':
        return DiyetselAssets.foodLentilSoup;
      case 'rcp-yogurt':
      case 'rcp-omlet':
        return DiyetselAssets.foodGreenSmoothie;
      case 'rcp-salmon':
        return DiyetselAssets.foodSaladBowl;
      default:
        break;
    }
    final t = r.title.toLowerCase();
    if (t.contains('mercimek') || t.contains('çorba')) return DiyetselAssets.foodLentilSoup;
    if (t.contains('smoothie') || t.contains('yoğurt')) return DiyetselAssets.foodGreenSmoothie;
    if (t.contains('kase') || t.contains('salata') || t.contains('bowl')) {
      return DiyetselAssets.foodSaladBowl;
    }
    return diyetselFoodImage(imageUrl: r.imageUrl, seed: r.title);
  }

  static List<String> displayTags(Recipe r) {
    if (r.tags.isNotEmpty) return r.tags;
    final out = <String>[r.category];
    final protein = recipeProtein(r);
    if (protein >= 25) out.add('Yüksek protein');
    if (r.prepMinutes <= 15) out.add('Hızlı');
    if (r.allergens.isEmpty) out.add('Temiz');
    if (r.calories <= 350) out.add('Hafif');
    return out.take(4).toList();
  }

  static ColorTint tintFor(Recipe r) {
    final c = r.category.toLowerCase();
    if (c.contains('kahvalt')) return ColorTint.lemon;
    if (c.contains('öğle') || c.contains('ogle')) return ColorTint.mint;
    if (c.contains('akşam') || c.contains('aksam')) return ColorTint.lilac;
    return ColorTint.peach;
  }
}

enum ColorTint { lemon, mint, lilac, peach, sky }
