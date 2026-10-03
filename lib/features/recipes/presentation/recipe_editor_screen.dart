import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/data/app_store.dart';
import '../../../core/l10n/ui_string.dart';
import '../../../core/models/models.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/diyetsel_widgets.dart';
import '../domain/recipe_text_parser.dart';

const _recipeHint = '''Tavuklu Kabak Sandal

Öğün: Ana öğün
Hazırlama süresi: 15 dakika
Pişirme süresi: 25–30 dakika
Servis: 1–2 kişilik

Malzemeler
1 küçük boy tavuk göğsü
2–3 adet kabak
Sosu için
1 tatlı kaşığı zeytinyağı

Hazırlanışı
Tavuğu haşlayıp didikleyin.
Kabakları rendeleyip suyunu sıkın.''';

class RecipeEditorScreen extends ConsumerStatefulWidget {
  const RecipeEditorScreen({super.key, this.existing});
  final Recipe? existing;

  @override
  ConsumerState<RecipeEditorScreen> createState() => _RecipeEditorScreenState();
}

class _RecipeEditorScreenState extends ConsumerState<RecipeEditorScreen> {
  late final TextEditingController _source;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _source = TextEditingController(
      text: existing == null ? '' : RecipeTextParser.format(existing),
    );
  }

  @override
  void dispose() {
    _source.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final parsed = RecipeTextParser.parse(_source.text);
    if (parsed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(('Başlık ve hazırlanış adımları gerekli.').ui)),
      );
      return;
    }
    final existing = widget.existing;
    setState(() => _saving = true);
    final recipe = Recipe(
      id: existing?.id ?? 'recipe-${DateTime.now().millisecondsSinceEpoch}',
      title: parsed.title,
      description: existing?.description ?? '',
      imageUrl: existing?.imageUrl,
      calories: 0,
      proteinGrams: 0,
      carbsGrams: 0,
      fatGrams: 0,
      prepMinutes: parsed.prepMinutes,
      cookMinutes: parsed.cookMinutes,
      servings: parsed.servings,
      ingredients: parsed.ingredients,
      steps: parsed.steps,
      tags: existing?.tags ?? const [],
      allergens: existing?.allergens ?? const [],
      category: parsed.category,
      tips: existing?.tips ?? const [],
      likes: existing?.likes ?? 0,
    );
    await ref.read(appStoreProvider).saveRecipe(recipe);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: widget.existing == null ? 'Yeni tarif' : 'Tarifi düzenle',
      padding: EdgeInsets.zero,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            ('Tarifi aşağıdaki düzende yapıştırın. Başlık, öğün, süreler, malzemeler ve adımlar bu metinden alınır.').ui,
            style: const TextStyle(color: AppColors.lightMuted, height: 1.35),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _source,
            minLines: 18,
            maxLines: 28,
            decoration: InputDecoration(
              alignLabelWithHint: true,
              labelText: ('Tarif metni').ui,
              hintText: _recipeHint,
            ),
          ),
          const SizedBox(height: 20),
          DiyetselButton(
            label: _saving
                ? 'Kaydediliyor…'
                : (widget.existing == null ? 'Tarifi kaydet' : 'Değişiklikleri kaydet'),
            onPressed: _saving ? null : _save,
            icon: Icons.restaurant_rounded,
          ),
        ],
      ),
    );
  }
}
