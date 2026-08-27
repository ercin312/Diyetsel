import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/app_modules.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/models.dart';
import '../../../core/utils/engage_logic.dart';
import '../../../core/utils/reminder_service.dart';
import '../../../core/utils/smart_notification_service.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/diyetsel_widgets.dart';
import '../../../core/widgets/kawaii_doodle.dart';
import '../../../core/widgets/module_gate.dart';
import '../../../core/widgets/style_icon.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../gamification/presentation/gamification_screens.dart';

bool get _canScanCamera {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;
}

Color stampColor(String? stamp) {
  switch (stamp) {
    case 'fazla':
      return AppColors.danger;
    case 'eksik':
      return AppColors.warning;
    default:
      return AppColors.success;
  }
}

String stampLabel(String? stamp) {
  switch (stamp) {
    case 'fazla':
      return 'Fazla';
    case 'eksik':
      return 'Eksik';
    case 'uygun':
      return 'Uygun';
    default:
      return 'Damga yok';
  }
}

class BarcodeScreen extends ConsumerStatefulWidget {
  const BarcodeScreen({super.key});

  @override
  ConsumerState<BarcodeScreen> createState() => _BarcodeScreenState();
}

class _BarcodeScreenState extends ConsumerState<BarcodeScreen> {
  final _manual = TextEditingController();
  OffProduct? _product;
  String? _error;
  bool _loading = false;
  String? _lastCode;

  @override
  void dispose() {
    _manual.dispose();
    super.dispose();
  }

  Future<void> _lookup(String raw) async {
    final code = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (code.length < 8 || code == _lastCode) return;
    setState(() {
      _loading = true;
      _error = null;
      _lastCode = code;
    });
    try {
      final uri = Uri.parse('https://world.openfoodfacts.org/api/v2/product/$code.json');
      final res = await http.get(uri, headers: {'User-Agent': 'Diyetsel/1.0 (Flutter; diet-app)'});
      if (res.statusCode != 200) {
        setState(() => _error = 'Ürün bulunamadı (${res.statusCode}).');
        return;
      }
      final body = res.body;
      if (!body.contains('"status":1') && !body.contains('"status": 1')) {
        setState(() => _error = 'Bu barkod Open Food Facts\'te yok. Kodu kontrol et.');
        return;
      }
      final name = _extract(body, 'product_name') ?? _extract(body, 'generic_name') ?? 'Ürün';
      final brand = _extract(body, 'brands');
      final kcal100 = int.tryParse(_extract(body, 'energy-kcal_100g') ?? '') ??
          int.tryParse(_extract(body, 'energy-kcal') ?? '') ??
          0;
      setState(() {
        _product = OffProduct(barcode: code, name: name, kcal: kcal100, brand: brand);
      });
    } catch (_) {
      setState(() => _error = 'Ağ hatası. İnterneti kontrol edip tekrar dene.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _extract(String json, String key) {
    final match = RegExp('"$key"\\s*:\\s*"?([^",}]+)"?').firstMatch(json);
    return match?.group(1)?.replaceAll('"', '').trim();
  }

  @override
  Widget build(BuildContext context) {
    final locked = lockedIfOff(ref, module: AppModule.barcode, title: 'Barkod');
    if (locked != null) return locked;
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(dietPlansProvider);
    ref.watch(waterLogsProvider);
    final remaining = store.remainingKcal(user.id);
    final snackLeft = store
        .mealsToday(user.id)
        .where((m) => !m.consumed)
        .fold<int>(9999, (s, m) => m.calories < s ? m.calories : s);
    final budget = snackLeft == 9999 ? remaining : (snackLeft < remaining ? snackLeft : remaining);
    final stamp = _product == null ? null : barcodeStamp(productKcal: _product!.kcal, remaining: budget);

    return AppPage(
      title: 'Barkod — yiyebilir miyim?',
      child: ListView(
        children: [
          FeatureBanner(
            icon: Icons.qr_code_scanner_rounded,
            emoji: '📷',
            title: 'Rafa bakmadan karar ver',
            subtitle: 'Ürünü tara; 100 g kalorisi bugünkü kalan bütçenle kıyaslanır.',
            trailing: StatusChip(label: '$budget kcal', color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DiyetselCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const StyleIcon(icon: Icons.local_fire_department_rounded, emoji: '🔥', size: 18, color: AppColors.primary),
                      const SizedBox(height: 8),
                      Text('$remaining', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
                      Text('Kalan gün', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DiyetselCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const StyleIcon(icon: Icons.cookie_rounded, emoji: '🍪', size: 18, color: AppColors.peachDeep),
                      const SizedBox(height: 8),
                      Text('$budget', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
                      Text('Ara öğün tavanı', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const DiyetselCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(title: 'Nasıl kullanılır'),
                HowToStep(index: 1, text: 'Kamerayı barkoda tut veya kodu yaz.', icon: Icons.qr_code_2_rounded, emoji: '📷'),
                HowToStep(index: 2, text: '100 g kalorisi kalan bütçenle karşılaştırılır.', icon: Icons.scale_rounded, emoji: '⚖️'),
                HowToStep(index: 3, text: 'Uygun / fazla damgasına göre porsiyonu ayarla.', icon: Icons.verified_rounded, emoji: '✅'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (_canScanCamera)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 220,
                child: MobileScanner(
                  onDetect: (capture) {
                    final code = capture.barcodes.firstOrNull?.rawValue;
                    if (code != null) _lookup(code);
                  },
                ),
              ),
            )
          else
            const TipCard(
              title: 'Kamera bu cihazda yok',
              body: 'Windows’ta tarama kapalı. Paketin altındaki 8–13 haneli barkodu kutuya yazıp ara.',
              icon: Icons.desktop_windows_rounded,
              emoji: '💻',
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _manual,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Barkod numarası',
              hintText: 'Örn. 8690504…',
              prefixIcon: const Padding(
                padding: EdgeInsets.all(10),
                child: StyleIcon(icon: Icons.qr_code_rounded, emoji: '📷', size: 18, sticker: false),
              ),
              suffixIcon: IconButton(
                icon: const StyleIcon(icon: Icons.search_rounded, emoji: '🔎', size: 18, sticker: false),
                onPressed: () => _lookup(_manual.text),
              ),
            ),
            onSubmitted: _lookup,
          ),
          if (_loading) const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TipCard(
                title: 'Bulunamadı',
                body: _error!,
                icon: Icons.error_outline_rounded,
                emoji: '⚠️',
                color: AppColors.danger,
              ),
            ),
          if (_product != null) ...[
            const SizedBox(height: 16),
            DiyetselCard(
              color: stampColor(stamp).withValues(alpha: context.isCartoon ? 0.16 : 0.08),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      StyleIcon(
                        icon: stamp == 'uygun' ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                        emoji: stamp == 'uygun' ? '✅' : '⚠️',
                        size: 22,
                        color: stampColor(stamp),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(_product!.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                      ),
                      StatusChip(label: stampLabel(stamp), color: stampColor(stamp)),
                    ],
                  ),
                  if (_product!.brand != null) ...[
                    const SizedBox(height: 4),
                    Text(_product!.brand!, style: Theme.of(context).textTheme.bodySmall),
                  ],
                  const SizedBox(height: 8),
                  Text('${_product!.kcal} kcal / ${_product!.per}', style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(
                    stamp == 'uygun'
                        ? 'Bu porsiyon kalan planına sığıyor. Dilediğin gibi ekleyebilirsin.'
                        : 'Kalori bütçesini aşıyor. Daha küçük porsiyon, paylaşım veya başka öğün dene.',
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          const TipCard(
            title: 'Etiket tuzağı',
            body: 'Open Food Facts çoğu ürünü 100 g olarak verir. Paket 30 g ise kaloriyi üçe böl; damga değişebilir.',
            icon: Icons.lightbulb_rounded,
            emoji: '💡',
          ),
        ],
      ),
    );
  }
}

class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key});

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  final _weight = TextEditingController();
  final _waist = TextEditingController();
  final _note = TextEditingController();
  int _mood = 3;
  String? _photo;

  @override
  void dispose() {
    _weight.dispose();
    _waist.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locked = lockedIfOff(ref, module: AppModule.checkIn, title: 'Haftalık check-in');
    if (locked != null) return locked;
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    final logs = (ref.watch(checkInsProvider).valueOrNull ?? []).where((e) => e.userId == user.id).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final last = logs.firstOrNull;
    final prev = logs.length >= 2 ? logs[1] : null;
    final weightDelta = last?.weight != null && prev?.weight != null ? last!.weight! - prev!.weight! : null;
    const moods = [
      (Icons.sentiment_very_dissatisfied_rounded, 'Zor', '😞'),
      (Icons.sentiment_dissatisfied_rounded, 'Eh işte', '😐'),
      (Icons.sentiment_neutral_rounded, 'Normal', '🙂'),
      (Icons.sentiment_satisfied_rounded, 'İyi', '😊'),
      (Icons.sentiment_very_satisfied_rounded, 'Harika', '🤩'),
    ];

    return AppPage(
      title: 'Haftalık check-in',
      child: ListView(
        children: [
          FeatureBanner(
            icon: Icons.favorite_rounded,
            emoji: '❤️',
            color: AppColors.accent,
            title: 'Bu haftanın raporu',
            subtitle: last == null
                ? 'Kilo, bel ve ruh halini gönder; diyetisyenin paneline düşer.'
                : 'Son kayıt ${DateFormat('d MMMM', 'tr').format(last.createdAt)}',
          ),
          if (weightDelta != null) ...[
            const SizedBox(height: 12),
            DiyetselCard(
              color: (weightDelta <= 0 ? AppColors.success : AppColors.warning).withValues(alpha: 0.1),
              child: Row(
                children: [
                  StyleIcon(
                    icon: weightDelta <= 0 ? Icons.trending_down_rounded : Icons.trending_up_rounded,
                    emoji: weightDelta <= 0 ? '📉' : '📈',
                    size: 22,
                    color: weightDelta <= 0 ? AppColors.success : AppColors.warning,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      weightDelta <= 0
                          ? 'Son check-in’e göre ${weightDelta.abs().toStringAsFixed(1)} kg düşüş'
                          : 'Son check-in’e göre +${weightDelta.toStringAsFixed(1)} kg',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (last?.dietitianNote != null) ...[
            const SizedBox(height: 12),
            DiyetselCard(
              color: AppColors.primary.withValues(alpha: context.isCartoon ? 0.12 : 0.08),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StyleIcon(icon: Icons.chat_bubble_rounded, emoji: '💬', size: 24, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Diyetisyenin notu', style: TextStyle(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Text(last!.dietitianNote!),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          DiyetselCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Ölçümler', subtitle: 'Sabah, tuvalet sonrası daha tutarlıdır.'),
                TextField(
                  controller: _weight,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Kilo (kg)',
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(10),
                      child: StyleIcon(icon: Icons.monitor_weight_rounded, emoji: '⚖️', size: 18, sticker: false),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _waist,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Bel çevresi (cm)',
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(10),
                      child: StyleIcon(icon: Icons.straighten_rounded, emoji: '📏', size: 18, sticker: false),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Ruh hali', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < moods.length; i++)
                      ChoiceChip(
                        selected: _mood == i + 1,
                        avatar: StyleIcon(icon: moods[i].$1, emoji: moods[i].$3, size: 16, sticker: false, color: AppColors.accent),
                        label: Text(moods[i].$2),
                        onSelected: (_) => setState(() => _mood = i + 1),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _note,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Not (uyku, spor, zorlandığın öğün…)',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () async {
                    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
                    if (file != null) setState(() => _photo = file.path);
                  },
                  icon: const StyleIcon(icon: Icons.photo_rounded, emoji: '📷', size: 18, sticker: false),
                  label: Text(_photo == null ? 'İsteğe bağlı foto ekle' : 'Foto seçildi'),
                ),
                DiyetselButton(
                  label: 'Check-in gönder',
                  icon: Icons.send,
                  onPressed: () async {
                    await store.saveCheckIn(
                      WeeklyCheckIn(
                        id: newId(),
                        userId: user.id,
                        userName: user.displayName,
                        createdAt: DateTime.now(),
                        weight: double.tryParse(_weight.text.replaceAll(',', '.')),
                        waist: double.tryParse(_waist.text.replaceAll(',', '.')),
                        mood: _mood,
                        note: _note.text.trim(),
                        photoPath: _photo,
                      ),
                    );
                    await AchievementService.instance.checkAndAward(store, user.id);
                    if (context.mounted) {
                      await maybeShowBadgeCelebrations(context, ref, user.id);
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Check-in diyetisyen paneline düştü.')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const TipCard(
            title: 'Neden her hafta?',
            body: 'Günlük tartı dalgalanır. Haftalık ritim hem seni hem diyetisyenini gerçek trende bakmaya alıştırır.',
            icon: Icons.calendar_month_rounded,
            emoji: '📅',
          ),
          const SectionHeader(title: 'Geçmiş'),
          if (logs.isEmpty)
            const EmptyState(icon: Icons.favorite, emoji: '❤️', title: 'Henüz check-in yok', subtitle: 'İlk kaydın burada birikmeye başlar.')
          else
            for (final log in logs)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: DiyetselCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: StyleIcon(
                      icon: moods[(log.mood - 1).clamp(0, 4)].$1,
                      emoji: moods[(log.mood - 1).clamp(0, 4)].$3,
                      size: 22,
                      color: AppColors.accent,
                    ),
                    title: Text(DateFormat('d MMMM y', 'tr').format(log.createdAt)),
                    subtitle: Text(
                      [
                        if (log.weight != null) '${log.weight} kg',
                        if (log.waist != null) 'bel ${log.waist} cm',
                        moods[(log.mood - 1).clamp(0, 4)].$2,
                        if (log.note.isNotEmpty) log.note,
                      ].join(' • '),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class EatOutScreen extends ConsumerWidget {
  const EatOutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locked = lockedIfOff(ref, module: AppModule.eatOut, title: 'Dışarıda ne yesem?');
    if (locked != null) return locked;
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(dietPlansProvider);
    final remaining = store.remainingKcal(user.id);
    final fits = eatOutMenu.where((e) => e.kcal <= remaining + 40).toList();
    final tight = remaining < 200;
    final shown = fits.isEmpty ? eatOutMenu.where((e) => e.kcal <= 120).toList() : fits;

    return AppPage(
      title: 'Dışarıda ne yesem?',
      child: ListView(
        children: [
          FeatureBanner(
            icon: Icons.restaurant_menu_rounded,
            emoji: '🍽️',
            color: AppColors.peachDeep,
            title: tight ? 'Bütçe dar — hafif seç' : 'Kalan $remaining kcal',
            subtitle: tight
                ? 'Kahve, çorba veya paylaşım porsiyonu daha güvenli.'
                : 'Menüden bunlara sığanları öne çıkardık. Sosu ayrı iste, pilavı çıkar.',
            trailing: StatusChip(label: '$remaining kcal', color: AppColors.peachDeep),
          ),
          const SizedBox(height: 12),
          const DiyetselCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(title: 'Sipariş kuralı'),
                HowToStep(index: 1, text: 'Izgara / buğulama seç, kızartmayı bırak.', icon: Icons.outdoor_grill_rounded, emoji: '🔥'),
                HowToStep(index: 2, text: 'Sos, mayonez ve ekmeği ayrı veya yarım iste.', icon: Icons.no_meals_rounded, emoji: '🚫'),
                HowToStep(index: 3, text: 'Yanına ayran, salata veya maden suyu koy.', icon: Icons.water_drop_rounded, emoji: '💧'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionHeader(
            title: fits.isEmpty ? 'En hafif kaçışlar' : 'Sana uyan öneriler',
            subtitle: '${shown.length} seçenek',
          ),
          for (final idea in shown)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: DiyetselCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StyleIcon(icon: idea.icon, emoji: idea.emoji, size: 24, color: AppColors.peachDeep),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(idea.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                          const SizedBox(height: 2),
                          Text('${idea.place} • ${idea.kcal} kcal', style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 6),
                          Text(idea.tip),
                        ],
                      ),
                    ),
                    StatusChip(
                      label: idea.kcal <= remaining + 40 ? 'sığar' : 'dikkat',
                      color: idea.kcal <= remaining + 40 ? AppColors.success : AppColors.warning,
                    ),
                  ],
                ),
              ),
            ),
          const TipCard(
            title: 'Sos konuşması',
            body: '“Sosu ayrı, ekmek yok, salata bol” cümlesi çoğu restoranda 150–300 kcal kazandırır.',
            icon: Icons.chat_rounded,
            emoji: '💬',
          ),
        ],
      ),
    );
  }
}

class StoryCardScreen extends ConsumerStatefulWidget {
  const StoryCardScreen({super.key});

  @override
  ConsumerState<StoryCardScreen> createState() => _StoryCardScreenState();
}

class _StoryCardScreenState extends ConsumerState<StoryCardScreen> {
  final _boundary = GlobalKey();
  int _template = 0;

  Future<void> _share() async {
    final boundary = _boundary.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;
    final image = await boundary.toImage(pixelRatio: 3);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) return;
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/diyetsel-hikaye.png');
    await file.writeAsBytes(bytes.buffer.asUint8List());
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: 'Diyetsel serim'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locked = lockedIfOff(ref, module: AppModule.story, title: 'Hikaye kartı');
    if (locked != null) return locked;
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(streaksProvider);
    ref.watch(waterLogsProvider);
    ref.watch(measurementsProvider);
    final streak = store.streak(user.id);
    final water = store.waterLog(user.id, DateTime.now());
    final measures = store.measurements(user.id);
    final delta = measures.length >= 2 && measures.last.weight != null && measures[measures.length - 2].weight != null
        ? measures.last.weight! - measures[measures.length - 2].weight!
        : null;
    final dietitian = store.users().where((u) => u.isAdmin).firstOrNull?.displayName ?? 'Diyetisyen';
    final cartoon = context.isCartoon;
    final templates = [
      (
        colors: const [Color(0xFFFF7A18), Color(0xFFFFB347)],
        kind: KawaiiKind.fire,
        title: '${streak.current} günlük seri',
        subtitle: 'En iyi ${streak.best} gün',
        foot: streak.freezeUsed ? 'Bu ay dondurma kullanıldı' : 'Planına sadık gün',
        chip: 'Seri',
        icon: Icons.local_fire_department_rounded,
      ),
      (
        colors: const [Color(0xFF2EC4B6), Color(0xFF4D96FF)],
        kind: KawaiiKind.water,
        title: 'Su %${(water.progress * 100).round()}',
        subtitle: '${water.amountMl} / ${water.goalMl} ml',
        foot: water.progress >= 1 ? 'Hedef doldu' : 'Bir bardak daha',
        chip: 'Su',
        icon: Icons.water_drop_rounded,
      ),
      (
        colors: const [Color(0xFFFF5C8A), Color(0xFF7C5CFF)],
        kind: KawaiiKind.heart,
        title: delta == null
            ? 'İlerleme kartı'
            : (delta <= 0 ? '${delta.abs().toStringAsFixed(1)} kg düşüş' : '+${delta.toStringAsFixed(1)} kg'),
        subtitle: 'Diyetisyen: $dietitian',
        foot: 'Diyetsel ile devam',
        chip: 'İlerleme',
        icon: Icons.favorite_rounded,
      ),
    ];
    final t = templates[_template];

    return AppPage(
      title: 'Hikaye kartı',
      actions: [
        IconButton(
          onPressed: _share,
          icon: const StyleIcon(icon: Icons.ios_share_rounded, emoji: '✨', size: 18, sticker: false),
        ),
      ],
      child: ListView(
        children: [
          const FeatureBanner(
            icon: Icons.auto_awesome_rounded,
            emoji: '✨',
            title: 'Paylaşılabilir kart',
            subtitle: 'Şablon seç, kartı kaydet veya hikâyene koy. Marka ve ismin üstte durur.',
          ),
          const SizedBox(height: 12),
          const DiyetselCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(title: 'Nasıl paylaşılır'),
                HowToStep(index: 1, text: 'Seri, su veya ilerleme şablonunu seç.', icon: Icons.palette_rounded, emoji: '🎨'),
                HowToStep(index: 2, text: 'Kartı önizle — rakamlar senin verinden gelir.', icon: Icons.visibility_rounded, emoji: '👀'),
                HowToStep(index: 3, text: 'Paylaş ile PNG olarak gönder.', icon: Icons.ios_share_rounded, emoji: '✨'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (var i = 0; i < templates.length; i++)
                ChoiceChip(
                  selected: _template == i,
                  avatar: StyleIcon(icon: templates[i].icon, emoji: '✨', size: 16, sticker: false),
                  label: Text(templates[i].chip),
                  onSelected: (_) => setState(() => _template = i),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: RepaintBoundary(
              key: _boundary,
              child: Container(
                width: 320,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: t.colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(color: t.colors.first.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 12)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (cartoon)
                          KawaiiTile(kind: t.kind, size: 54)
                        else
                          ModernIconTile(kind: t.kind, color: Colors.white, size: 48, inverted: true),
                        const Spacer(),
                        const Text('DİYETSEL', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, letterSpacing: 2)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(user.displayName, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                    Text('Diyetisyen: $dietitian', style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 18),
                    Text(t.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                    Text(t.subtitle, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),
                    Text(t.foot, style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          DiyetselButton(label: 'Paylaş', icon: Icons.share, onPressed: _share),
          const SizedBox(height: 12),
          const TipCard(
            title: 'Gizlilik',
            body: 'Kartta sadece ismin, serin ve seçtiğin özet görünür. Kilo grafiğin veya sohbetin paylaşılmaz.',
            icon: Icons.lock_rounded,
            emoji: '🔒',
          ),
        ],
      ),
    );
  }
}

class FastingScreen extends ConsumerWidget {
  const FastingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locked = lockedIfOff(ref, module: AppModule.fasting, title: 'Aralıklı oruç');
    if (locked != null) return locked;
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(fastingProvider);
    final session = store.fasting(user.id);
    final hours = session.elapsed.inHours;
    final mins = session.elapsed.inMinutes % 60;
    final phase = hours < 4
        ? (title: 'Sindirim', body: 'Son öğün hâlâ işleniyor. Su iç, kafein istersen sade tut.')
        : hours < 12
            ? (title: 'Yağ yakımı', body: 'Glikojen azalıyor. Açlık dalgaları geçer; yürüyüş yardımcı olur.')
            : (title: 'Pencere', body: '16:8’in asıl dilimi. Elektrolit ve suyu ihmal etme.');
    const phases = [
      (0, '0–4 sa', 'Sindirim'),
      (4, '4–12 sa', 'Yağ yakımı'),
      (12, '12–16 sa', 'Pencere'),
    ];

    return AppPage(
      title: 'Aralıklı oruç',
      child: ListView(
        children: [
          FeatureBanner(
            icon: Icons.hourglass_bottom_rounded,
            emoji: '⏳',
            color: AppColors.primaryDeep,
            title: '16:8 penceresi',
            subtitle: '16 saat oruç, 8 saat yeme. Diyet planın yeme penceresine sığmalı.',
          ),
          const SizedBox(height: 12),
          DiyetselCard(
            child: Column(
              children: [
                SizedBox(
                  height: 168,
                  width: 168,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 168,
                        width: 168,
                        child: CircularProgressIndicator(
                          value: session.active ? session.progress : 0,
                          strokeWidth: 12,
                          color: AppColors.primaryDeep,
                          backgroundColor: AppColors.primaryDeep.withValues(alpha: 0.12),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StyleIcon(
                            icon: session.active ? Icons.hourglass_top_rounded : Icons.play_circle_rounded,
                            emoji: '⏳',
                            size: 22,
                            color: AppColors.primaryDeep,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            session.active ? '$hours sa $mins dk' : 'Hazır',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                          ),
                          Text(
                            session.active ? 'kalan ~${((1 - session.progress) * 16).clamp(0, 16).toStringAsFixed(1)} sa' : '16 saatlik tur',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(session.active ? phase.title : 'Orucu başlat, süre aksın.', style: const TextStyle(fontWeight: FontWeight.w800)),
                if (session.active) ...[
                  const SizedBox(height: 4),
                  Text(phase.body, textAlign: TextAlign.center),
                ],
                const SizedBox(height: 14),
                DiyetselButton(
                  label: session.active ? 'Orucu bitir' : '16 saat başlat',
                  icon: session.active ? Icons.stop : Icons.play_arrow,
                  onPressed: () => session.active ? store.stopFasting(user.id) : store.startFasting(user.id),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          DiyetselCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Fazlar', subtitle: 'Saat ilerledikçe vurgu değişir.'),
                for (final p in phases)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        StyleIcon(
                          icon: hours >= p.$1 && session.active ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                          emoji: hours >= p.$1 && session.active ? '✅' : '⚪',
                          size: 18,
                          color: hours >= p.$1 && session.active ? AppColors.success : AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Text(p.$2, style: const TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(width: 8),
                        Expanded(child: Text(p.$3)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const TipCard(
            title: 'Su serbest',
            body: 'Oruçta kalori yok: su, sade çay, şekersiz kahve. Sütlü kahve pencereyi bozar.',
            icon: Icons.water_drop_rounded,
            emoji: '💧',
          ),
          const SizedBox(height: 8),
          const TipCard(
            title: 'Planla çakıştır',
            body: 'Kahvaltıyı geç, akşamı erken bitir. Diyet listen yeme penceresine sığmıyorsa diyetisyenine yaz.',
            icon: Icons.restaurant_rounded,
            emoji: '🥗',
          ),
        ],
      ),
    );
  }
}

class WaterShortcutTile extends ConsumerWidget {
  const WaterShortcutTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    final prefs = (ref.watch(prefsProvider(user.id)).valueOrNull) ?? const NotificationPrefs();
    return DiyetselCard(
      onTap: () async {
        final next = !prefs.waterShortcut;
        await store.savePrefs(user.id, prefs.copyWith(waterShortcut: next));
        if (next) {
          await ReminderService.instance.showWaterShortcut();
        } else {
          await ReminderService.instance.hideWaterShortcut();
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                next
                    ? (ReminderService.instance.supportsNative
                        ? 'Kalıcı su bildirimi açıldı. +250 ml ile hızlı ekle.'
                        : 'Windows’ta widget yok; bildirim Android’de çalışır. Buradan +${AppConstants.waterSipMl} ml ekleyebilirsin.')
                    : 'Su kısayolu kapatıldı.',
              ),
            ),
          );
        }
      },
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const StyleIcon(icon: Icons.notifications_active, emoji: '💧', size: 28),
        title: const Text('Su kısayolu', style: TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(prefs.waterShortcut ? 'Açık' : 'Kapalı — Android bildirim / +250 ml'),
        trailing: Switch(value: prefs.waterShortcut, onChanged: (_) {}),
      ),
    );
  }
}

Future<void> capturePlatePhoto(BuildContext context, WidgetRef ref) async {
  final user = ref.read(authControllerProvider).user!;
  final store = ref.read(appStoreProvider);
  final file = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (file == null || !context.mounted) return;

  var type = MealType.lunch;
  var portion = 1.0;
  final result = await showDialog<(MealType, double)>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setLocal) {
          return AlertDialog(
            title: const Text('Tabak damgası'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<MealType>(
                  value: type,
                  isExpanded: true,
                  items: [
                    for (final t in MealType.values) DropdownMenuItem(value: t, child: Text('${t.emoji} ${t.tr}')),
                  ],
                  onChanged: (v) => setLocal(() => type = v ?? type),
                ),
                const SizedBox(height: 8),
                SegmentedButton<double>(
                  segments: const [
                    ButtonSegment(value: 0.7, label: Text('Küçük')),
                    ButtonSegment(value: 1.0, label: Text('Normal')),
                    ButtonSegment(value: 1.35, label: Text('Büyük')),
                  ],
                  selected: {portion},
                  onSelectionChanged: (s) => setLocal(() => portion = s.first),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
              FilledButton(onPressed: () => Navigator.pop(ctx, (type, portion)), child: const Text('Kaydet')),
            ],
          );
        },
      );
    },
  );
  if (result == null) return;
  final meals = store.mealsToday(user.id);
  final planned = meals.where((m) => m.type == result.$1).map((m) => m.calories).firstOrNull ?? 0;
  final estimated = (planned > 0 ? planned * result.$2 : 400 * result.$2).round();
  final stamp = plateStamp(estimated: estimated, planned: planned);
  await store.saveMealLog(
    MealPhotoLog(
      id: newId(),
      clientId: user.id,
      clientName: user.displayName,
      photoPath: file.path,
      createdAt: DateTime.now(),
      caption: '${result.$1.tr} • porsiyon ${result.$2}',
      mealType: result.$1,
      estimatedKcal: estimated,
      stamp: stamp,
    ),
  );
  await AchievementService.instance.checkAndAward(store, user.id);
  if (context.mounted) {
    await maybeShowBadgeCelebrations(context, ref, user.id);
  }
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Damga: ${stampLabel(stamp)} ($estimated kcal)')),
    );
  }
}
