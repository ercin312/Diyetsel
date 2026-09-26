import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/data/app_store.dart';
import '../../../core/models/models.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/diyetsel_widgets.dart';
import '../../../core/l10n/ui_string.dart';

const recipeCategories = [
  'Kahvaltı',
  'Öğle',
  'Akşam',
  'Ara öğün',
  'Çorba',
  'Salata',
  'Tatlı',
  'İçecek',
  'Diğer',
];

/// Admin: create or edit a clinic recipe.
class RecipeEditorScreen extends ConsumerStatefulWidget {
  const RecipeEditorScreen({super.key, this.existing});

  final Recipe? existing;

  @override
  ConsumerState<RecipeEditorScreen> createState() => _RecipeEditorScreenState();
}

class _RecipeEditorScreenState extends ConsumerState<RecipeEditorScreen> {
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _imageUrl;
  late final TextEditingController _calories;
  late final TextEditingController _protein;
  late final TextEditingController _carbs;
  late final TextEditingController _fat;
  late final TextEditingController _prep;
  late final TextEditingController _cook;
  late final TextEditingController _servings;
  late final TextEditingController _allergens;
  late final TextEditingController _tags;
  late final TextEditingController _tips;

  late String _category;
  late List<TextEditingController> _ingredientNames;
  late List<TextEditingController> _ingredientAmounts;
  late List<TextEditingController> _steps;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _title = TextEditingController(text: e?.title ?? '');
    _description = TextEditingController(text: e?.description ?? '');
    _imageUrl = TextEditingController(text: e?.imageUrl ?? '');
    _calories = TextEditingController(text: '${e?.calories ?? 300}');
    _protein = TextEditingController(text: '${e?.proteinGrams ?? 20}');
    _carbs = TextEditingController(text: '${e?.carbsGrams ?? 30}');
    _fat = TextEditingController(text: '${e?.fatGrams ?? 10}');
    _prep = TextEditingController(text: '${e?.prepMinutes ?? 15}');
    _cook = TextEditingController(text: '${e?.cookMinutes ?? 0}');
    _servings = TextEditingController(text: '${e?.servings ?? 1}');
    _allergens = TextEditingController(text: e?.allergens.join(', ') ?? '');
    _tags = TextEditingController(text: e?.tags.join(', ') ?? '');
    _tips = TextEditingController(text: e?.tips.join('\n') ?? '');
    _category = e?.category ?? recipeCategories.first;
    if (!recipeCategories.contains(_category)) {
      _category = recipeCategories.last;
    }
    final ingredients = e?.ingredients ?? const <Ingredient>[];
    if (ingredients.isEmpty) {
      _ingredientNames = [TextEditingController()];
      _ingredientAmounts = [TextEditingController()];
    } else {
      _ingredientNames = [for (final i in ingredients) TextEditingController(text: i.name)];
      _ingredientAmounts = [for (final i in ingredients) TextEditingController(text: i.amount)];
    }
    final steps = e?.steps ?? const <String>[];
    _steps = steps.isEmpty
        ? [TextEditingController()]
        : [for (final s in steps) TextEditingController(text: s)];
  }

  @override
  void dispose() {
    for (final c in [
      _title,
      _description,
      _imageUrl,
      _calories,
      _protein,
      _carbs,
      _fat,
      _prep,
      _cook,
      _servings,
      _allergens,
      _tags,
      _tips,
      ..._ingredientNames,
      ..._ingredientAmounts,
      ..._steps,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  int _parseInt(TextEditingController c, [int fallback = 0]) =>
      int.tryParse(c.text.trim()) ?? fallback;

  List<String> _splitCsv(String raw) => raw
      .split(RegExp(r'[,;\n]'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  Future<void> _save() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(('Başlık gerekli').ui), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final ingredients = <Ingredient>[];
    for (var i = 0; i < _ingredientNames.length; i++) {
      final name = _ingredientNames[i].text.trim();
      final amount = _ingredientAmounts[i].text.trim();
      if (name.isEmpty) continue;
      ingredients.add(Ingredient(name: name, amount: amount.isEmpty ? '—' : amount));
    }
    final steps = _steps.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();
    if (ingredients.isEmpty || steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(('En az bir malzeme ve bir adım ekleyin').ui),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final recipe = Recipe(
        id: widget.existing?.id ?? newId(),
        title: title,
        description: _description.text.trim(),
        calories: _parseInt(_calories, 0),
        prepMinutes: _parseInt(_prep, 0),
        cookMinutes: _parseInt(_cook, 0),
        servings: _parseInt(_servings, 1).clamp(1, 99),
        proteinGrams: _parseInt(_protein, 0),
        carbsGrams: _parseInt(_carbs, 0),
        fatGrams: _parseInt(_fat, 0),
        allergens: _splitCsv(_allergens.text),
        tags: _splitCsv(_tags.text),
        tips: _tips.text
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        steps: steps,
        ingredients: ingredients,
        category: _category,
        imageUrl: _imageUrl.text.trim().isEmpty ? null : _imageUrl.text.trim(),
        likes: widget.existing?.likes ?? 0,
      );
      await ref.read(appStoreProvider).saveRecipe(recipe);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text((widget.existing == null ? 'Tarif eklendi' : 'Tarif güncellendi').ui),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, recipe);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(('Kayıt hatası: $e').ui), behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: widget.existing == null ? 'Yeni tarif' : 'Tarifi düzenle',
      actions: [
        TextButton(
          onPressed: _saving ? null : _save,
          child: Text((_saving ? 'Kaydediliyor…' : 'Kaydet').ui),
        ),
      ],
      child: ListView(
        children: [
          TextField(
            controller: _title,
            decoration: InputDecoration(labelText: ('Başlık').ui),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _description,
            decoration: InputDecoration(labelText: ('Kısa açıklama').ui),
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: InputDecoration(labelText: ('Kategori').ui),
            items: [
              for (final c in recipeCategories) DropdownMenuItem(value: c, child: Text((c).ui)),
            ],
            onChanged: (v) => setState(() => _category = v ?? _category),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _imageUrl,
            decoration: InputDecoration(
              labelText: ('Görsel URL (isteğe bağlı)').ui,
              hintText: ('https://…').ui,
            ),
          ),
          const SizedBox(height: 16),
          Text(('Makrolar').ui,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _numField(_calories, 'kcal')),
              const SizedBox(width: 8),
              Expanded(child: _numField(_protein, 'Protein g')),
              const SizedBox(width: 8),
              Expanded(child: _numField(_carbs, 'Karb g')),
              const SizedBox(width: 8),
              Expanded(child: _numField(_fat, 'Yağ g')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _numField(_prep, 'Hazırlık dk')),
              const SizedBox(width: 8),
              Expanded(child: _numField(_cook, 'Pişirme dk')),
              const SizedBox(width: 8),
              Expanded(child: _numField(_servings, 'Porsiyon')),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _allergens,
            decoration: InputDecoration(
              labelText: ('Alerjenler').ui,
              hintText: ('Gluten, süt, …').ui,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _tags,
            decoration: InputDecoration(
              labelText: ('Etiketler').ui,
              hintText: ('protein, hızlı, …').ui,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(('Malzemeler').ui,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => setState(() {
                  _ingredientNames.add(TextEditingController());
                  _ingredientAmounts.add(TextEditingController());
                }),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(('Ekle').ui),
              ),
            ],
          ),
          for (var i = 0; i < _ingredientNames.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _ingredientNames[i],
                      decoration: InputDecoration(labelText: ('Malzeme ${i + 1}').ui),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _ingredientAmounts[i],
                      decoration: InputDecoration(labelText: ('Miktar').ui),
                    ),
                  ),
                  IconButton(
                    onPressed: _ingredientNames.length <= 1
                        ? null
                        : () => setState(() {
                              _ingredientNames.removeAt(i).dispose();
                              _ingredientAmounts.removeAt(i).dispose();
                            }),
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(('Adımlar').ui,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => setState(() => _steps.add(TextEditingController())),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(('Ekle').ui),
              ),
            ],
          ),
          for (var i = 0; i < _steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                      child: Text(('${i + 1}').ui,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _steps[i],
                      decoration: InputDecoration(labelText: ('Adım').ui),
                      maxLines: 2,
                    ),
                  ),
                  IconButton(
                    onPressed: _steps.length <= 1
                        ? null
                        : () => setState(() => _steps.removeAt(i).dispose()),
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          TextField(
            controller: _tips,
            decoration: InputDecoration(
              labelText: ('İpuçları').ui,
              hintText: ('Her satır bir ipucu').ui,
              alignLabelWithHint: true,
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 20),
          DiyetselButton(
            label: _saving
                ? 'Kaydediliyor…'
                : (widget.existing == null ? 'Tarifi kaydet' : 'Değişiklikleri kaydet'),
            onPressed: _saving ? null : _save,
            icon: Icons.restaurant_rounded,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _numField(TextEditingController c, String label) {
    return TextField(
      controller: c,
      decoration: InputDecoration(labelText: (label).ui),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }
}
