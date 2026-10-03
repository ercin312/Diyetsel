import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

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
Kabakları rendeleyip suyunu sıkın.

İpucu
Kabağı çok sıkma, biraz nem lezzeti tutar.

Dipnot
Aynı gün içinde tüketin.''';

class RecipeEditorScreen extends ConsumerStatefulWidget {
  const RecipeEditorScreen({super.key, this.existing});
  final Recipe? existing;

  @override
  ConsumerState<RecipeEditorScreen> createState() => _RecipeEditorScreenState();
}

class _RecipeEditorScreenState extends ConsumerState<RecipeEditorScreen> {
  late final TextEditingController _source;
  String? _imageUrl;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _imageUrl = existing?.imageUrl;
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
      imageUrl: _imageUrl,
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
      tips: parsed.tips,
      sauce: parsed.sauce,
      footnote: parsed.footnote,
      likes: existing?.likes ?? 0,
    );
    await ref.read(appStoreProvider).saveRecipe(recipe);
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 72,
      maxWidth: 1280,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    if (bytes.length > 450000) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(('Görsel çok büyük. Daha küçük bir fotoğraf seç.').ui)),
      );
      return;
    }
    setState(() => _imageUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}');
  }

  Widget _imagePreview() {
    final url = _imageUrl?.trim() ?? '';
    if (url.isEmpty) {
      return const Icon(Icons.add_photo_alternate_outlined, color: AppColors.lightMuted);
    }
    if (url.startsWith('data:image')) {
      final comma = url.indexOf(',');
      if (comma >= 0) {
        try {
          return Image.memory(
            base64Decode(url.substring(comma + 1)),
            width: 72,
            height: 72,
            fit: BoxFit.cover,
          );
        } catch (_) {}
      }
    }
    return Image.network(url, width: 72, height: 72, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: widget.existing == null ? 'Yeni tarif' : 'Tarifi düzenle',
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              children: [
                Text(
                  ('Tarifi aşağıdaki düzende yapıştırın. Başlık, öğün, süreler, malzemeler, sos, hazırlanış, ipucu ve dipnot bu metinden alınır.').ui,
                  style: const TextStyle(color: AppColors.lightMuted, height: 1.35),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 72,
                        height: 72,
                        color: AppColors.modernWash,
                        alignment: Alignment.center,
                        child: _imagePreview(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.photo_outlined),
                            label: Text(('Görsel ekle').ui),
                          ),
                          if ((_imageUrl ?? '').isNotEmpty)
                            TextButton(
                              onPressed: () => setState(() => _imageUrl = null),
                              child: Text(('Görseli kaldır').ui),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _source,
                  minLines: 8,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    alignLabelWithHint: true,
                    labelText: ('Tarif metni').ui,
                    hintText: _recipeHint,
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: DiyetselButton(
                label: _saving
                    ? 'Kaydediliyor…'
                    : (widget.existing == null ? 'Tarifi kaydet' : 'Değişiklikleri kaydet'),
                onPressed: _saving ? null : _save,
                icon: Icons.restaurant_rounded,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
