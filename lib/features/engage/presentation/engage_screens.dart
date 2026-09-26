import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/diyetsel_assets.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/app_modules.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/models.dart';
import '../../../core/utils/engage_logic.dart';
import '../../../core/utils/reminder_service.dart';
import '../../../core/utils/smart_notification_service.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/cartoon_glyph.dart';
import '../../../core/widgets/diyetsel_widgets.dart';
import '../../../core/widgets/module_gate.dart';
import '../../../core/widgets/style_icon.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../gamification/presentation/gamification_screens.dart';
import 'soft_eat_out_screen.dart';
import 'soft_barcode_screen.dart';
import 'soft_fasting_screen.dart';
import 'soft_water_shortcut_screen.dart';
import '../../../core/l10n/ui_string.dart';

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
      final res = await http.get(uri, headers: {'User-Agent': 'e-Diyet/1.0 (Flutter; diet-app)'});
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
    if (context.isModern) {
      return const SoftBarcodeScreen();
    }

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
            trailing: StatusChip(label: '$budget kcal', color: context.brandPrimary),
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
                      StyleIcon(
                        icon: Icons.local_fire_department_rounded,
                        emoji: '🔥',
                        size: 18,
                        color: (context.isCartoon ? AppColors.kawaiiCoral : AppColors.modernFire),
                      ),
                      const SizedBox(height: 8),
                      Text(('$remaining').ui, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
                      Text(('Kalan gün').ui, style: Theme.of(context).textTheme.bodySmall),
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
                      StyleIcon(icon: Icons.cookie_rounded, emoji: '🍪', size: 18, color: context.brandPrimary),
                      const SizedBox(height: 8),
                      Text(('$budget').ui, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
                      Text(('Ara öğün tavanı').ui, style: Theme.of(context).textTheme.bodySmall),
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
              borderRadius: BorderRadius.circular(context.isCartoon ? 26 : 20),
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
              labelText: ('Barkod numarası').ui,
              hintText: ('Örn. 8690504…').ui,
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
              color: context.isCartoon
                  ? (stamp == 'uygun'
                      ? AppColors.kawaiiMint.withValues(alpha: 0.75)
                      : AppColors.kawaiiRose.withValues(alpha: 0.75))
                  : stampColor(stamp).withValues(alpha: 0.08),
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
                        child: Text((_product!.name).ui, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                      ),
                      StatusChip(label: stampLabel(stamp), color: stampColor(stamp)),
                    ],
                  ),
                  if (_product!.brand != null) ...[
                    const SizedBox(height: 4),
                    Text((_product!.brand!).ui, style: Theme.of(context).textTheme.bodySmall),
                  ],
                  const SizedBox(height: 8),
                  Text(('${_product!.kcal} kcal / ${_product!.per}').ui, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text((stamp == 'uygun'
                        ? 'Bu porsiyon kalan planına sığıyor. Dilediğin gibi ekleyebilirsin.'
                        : 'Kalori bütçesini aşıyor. Daha küçük porsiyon, paylaşım veya başka öğün dene.').ui,
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

class EatOutScreen extends ConsumerStatefulWidget {
  const EatOutScreen({super.key});

  @override
  ConsumerState<EatOutScreen> createState() => _EatOutScreenState();
}

class _EatOutScreenState extends ConsumerState<EatOutScreen> {
  String _filter = 'Tümü';

  @override
  Widget build(BuildContext context) {
    final locked = lockedIfOff(ref, module: AppModule.eatOut, title: 'Dışarıda ne yesem?');
    if (locked != null) return locked;

    if (context.isModern) {
      return const SoftEatOutScreen();
    }

    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(dietPlansProvider);
    final remaining = store.remainingKcal(user.id);
    final fits = eatOutMenu.where((e) => e.kcal <= remaining + 40).toList();
    final tight = remaining < 200;
    final pool = fits.isEmpty ? eatOutMenu.where((e) => e.kcal <= 120).toList() : fits;
    final categories = ['Tümü', ...{for (final e in eatOutMenu) e.category}];
    final shown = _filter == 'Tümü' ? pool : pool.where((e) => e.category == _filter).toList();
    final cartoon = context.isCartoon;

    if (cartoon) {
      return AppPage(
        title: 'Dışarıda ne yesem?',
        padding: EdgeInsets.zero,
        child: ColoredBox(
          color: AppColors.kawaiiSurfaceCream,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            children: [
              _EatOutHero(remaining: remaining, tight: tight)
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: -0.05, curve: Curves.easeOutCubic),
              const SizedBox(height: 14),
              _EatOutRulesCard()
                  .animate()
                  .fadeIn(delay: 60.ms, duration: 300.ms)
                  .slideY(begin: 0.04, curve: Curves.easeOutCubic),
              const SizedBox(height: 16),
              Text((fits.isEmpty ? 'En hafif kaçışlar' : 'Sana uyan öneriler').ui,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppColors.kawaiiInk),
              ),
              const SizedBox(height: 4),
              Text(('${shown.length} seçenek · kalan $remaining kcal').ui,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: AppColors.kawaiiMuted),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final c = categories.elementAt(i);
                    final selected = c == _filter;
                    return FilterChip(
                      selected: selected,
                      showCheckmark: false,
                      label: Text((c).ui,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                          color: selected ? Colors.white : AppColors.kawaiiInk,
                        ),
                      ),
                      selectedColor: AppColors.kawaiiLeaf,
                      backgroundColor: Colors.white,
                      side: BorderSide(color: selected ? AppColors.kawaiiLeaf : AppColors.kawaiiOutline),
                      onSelected: (_) => setState(() => _filter = c),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              for (var i = 0; i < shown.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CartoonEatOutCard(
                    idea: shown[i],
                    remaining: remaining,
                    onOpen: () => _openDetail(context, shown[i], remaining),
                  )
                      .animate()
                      .fadeIn(delay: (40 * i).ms, duration: 300.ms)
                      .slideY(begin: 0.06, curve: Curves.easeOutCubic)
                      .scale(begin: const Offset(0.97, 0.97), curve: Curves.easeOutBack, duration: 400.ms),
                ),
              if (shown.isEmpty)
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(('Bu kategoride uyan seçenek yok — filtreyi değiştir.').ui,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.kawaiiMuted),
                  ),
                ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                  border: Border.all(color: AppColors.kawaiiOutline),
                  boxShadow: AppSpacing.soft,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.chat_bubble_rounded, color: AppColors.kawaiiCoral, size: 22),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(('Sos konuşması').ui,
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.kawaiiInk),
                          ),
                          SizedBox(height: 4),
                          Text(('“Sosu ayrı, ekmek yok, salata bol” cümlesi çoğu restoranda 150–300 kcal kazandırır.').ui,
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 1.4, color: AppColors.kawaiiMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 320.ms),
            ],
          ),
        ),
      );
    }

    return const SoftEatOutScreen();
  }

  void _openDetail(BuildContext context, EatOutIdea idea, int remaining) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EatOutDetailSheet(idea: idea, remaining: remaining),
    );
  }
}

class _EatOutHero extends StatelessWidget {
  const _EatOutHero({required this.remaining, required this.tight});
  final int remaining;
  final bool tight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: tight
              ? [AppColors.kawaiiPeach, AppColors.kawaiiSurfaceCream]
              : [AppColors.kawaiiMint, AppColors.kawaiiSurfaceCream],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
        border: Border.all(color: AppColors.kawaiiOutline),
        boxShadow: AppSpacing.softLift,
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
                    color: Colors.white.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  child: Text((tight ? 'Bütçe dar' : 'Bugünkü kalan').ui,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: AppColors.kawaiiInk),
                  ),
                ),
                const SizedBox(height: 10),
                Text((tight ? 'Hafif seç, sonra teşekkür et' : '$remaining kcal kaldı').ui,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: AppColors.kawaiiInk,
                    height: 1.15,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text((tight
                      ? 'Kahve, çorba veya paylaşım porsiyonu daha güvenli.'
                      : 'Sığan menüleri öne çıkardık. Sos ayrı, pilavı çıkar.').ui,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 1.35, color: AppColors.kawaiiMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Image.asset(
            DiyetselAssets.foodSaladBowl,
            width: 88,
            height: 88,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Icon(Icons.restaurant_menu_rounded, size: 48, color: AppColors.kawaiiLeaf),
          ),
        ],
      ),
    );
  }
}

class _EatOutRulesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const rules = [
      (Icons.outdoor_grill_rounded, AppColors.kawaiiCoral, 'Izgara / buğulama seç'),
      (Icons.no_meals_rounded, AppColors.kawaiiPurple, 'Sos ve ekmeği ayrı iste'),
      (Icons.water_drop_rounded, AppColors.kawaiiSkyBlue, 'Yanına ayran veya salata'),
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.kawaiiOutline),
        boxShadow: AppSpacing.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(('3 sipariş kuralı').ui,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.kawaiiInk),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < rules.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            Row(
              children: [
                CartoonGlyph(icon: rules[i].$1, accent: rules[i].$2, size: 40, radius: 12, iconSize: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(('${i + 1}. ${rules[i].$3}').ui,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.kawaiiInk),
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

class _CartoonEatOutCard extends StatelessWidget {
  const _CartoonEatOutCard({
    required this.idea,
    required this.remaining,
    required this.onOpen,
  });

  final EatOutIdea idea;
  final int remaining;
  final VoidCallback onOpen;

  bool get _fits => idea.kcal <= remaining + 40;

  Color get _tint {
    switch (idea.category) {
      case 'Salata':
        return AppColors.kawaiiMint;
      case 'Balık':
        return AppColors.kawaiiSky;
      case 'Kafe':
        return AppColors.kawaiiPeach;
      case 'Kahvaltı':
        return AppColors.kawaiiLemon;
      case 'Izgara':
        return AppColors.kawaiiLilac;
      default:
        return AppColors.kawaiiSurfaceCream;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
            border: Border.all(color: AppColors.kawaiiOutline),
            boxShadow: AppSpacing.softLift,
          ),
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
                      Color.lerp(_tint, Colors.white, 0.2)!,
                      Color.lerp(_tint, AppColors.kawaiiCream, 0.45)!,
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusHero - 1)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CartoonGlyph(icon: idea.icon, accent: AppColors.kawaiiLeafDeep, size: 48, radius: 16, iconSize: 24),
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
                                    color: AppColors.kawaiiInk,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _fits ? AppColors.kawaiiLeaf : AppColors.kawaiiCoral,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text((_fits ? 'sığar' : 'dikkat').ui,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(('${idea.place} · ${idea.category}').ui,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: AppColors.kawaiiMuted),
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
                        color: AppColors.kawaiiInk.withValues(alpha: 0.78),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _MiniPill(label: 'kcal', value: '${idea.kcal}', color: AppColors.kawaiiCoral),
                        if (idea.proteinG > 0)
                          _MiniPill(label: 'protein', value: '${idea.proteinG}g', color: AppColors.kawaiiLeaf),
                        for (final t in idea.tags.take(2))
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.kawaiiCream,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.kawaiiOutline),
                            ),
                            child: Text((t).ui, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.kawaiiInk)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline_rounded, size: 16, color: AppColors.kawaiiWarmYellow),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text((idea.tip).ui,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: AppColors.kawaiiMuted),
                          ),
                        ),
                        Text(('Detay').ui,
                          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.kawaiiLeafDeep, fontSize: 13),
                        ),
                        Icon(Icons.chevron_right_rounded, color: AppColors.kawaiiLeafDeep, size: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Color.lerp(color, Colors.white, 0.78),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '$value ', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: color)),
            TextSpan(text: label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: AppColors.kawaiiMuted)),
          ],
        ),
      ),
    );
  }
}

class _EatOutDetailSheet extends StatelessWidget {
  const _EatOutDetailSheet({required this.idea, required this.remaining});
  final EatOutIdea idea;
  final int remaining;

  bool get _fits => idea.kcal <= remaining + 40;

  @override
  Widget build(BuildContext context) {
    final cartoon = context.isCartoon;
    final bg = cartoon ? AppColors.kawaiiCream : Theme.of(context).colorScheme.surface;

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, scroll) {
        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                    color: cartoon ? AppColors.kawaiiOutline : Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              if (cartoon)
                Center(
                  child: CartoonGlyph(icon: idea.icon, accent: AppColors.kawaiiLeaf, size: 72, radius: 22, iconSize: 34),
                ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack),
              if (!cartoon)
                Center(child: StyleIcon(icon: idea.icon, emoji: idea.emoji, size: 40, selected: true)),
              const SizedBox(height: 14),
              Text((idea.title).ui,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: cartoon ? AppColors.kawaiiInk : null,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(('${idea.place} · ${idea.category}').ui,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: cartoon ? AppColors.kawaiiMuted : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MiniPill(label: 'kcal', value: '${idea.kcal}', color: cartoon ? AppColors.kawaiiCoral : context.brandPrimary),
                  if (idea.proteinG > 0)
                    _MiniPill(label: 'protein', value: '${idea.proteinG}g', color: cartoon ? AppColors.kawaiiLeaf : context.brandPrimary),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _fits
                          ? (cartoon ? AppColors.kawaiiLeaf : AppColors.success)
                          : (cartoon ? AppColors.kawaiiCoral : AppColors.warning),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text((_fits ? 'Bütçene sığar' : 'Dikkatli ol').ui,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text((idea.blurb.isNotEmpty ? idea.blurb : idea.tip).ui,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                  fontSize: 14,
                  color: cartoon ? AppColors.kawaiiInk.withValues(alpha: 0.85) : null,
                ),
              ),
              if (idea.orderLine.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(('Garsona söyle').ui,
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: cartoon ? AppColors.kawaiiInk : null),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cartoon ? Colors.white : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: cartoon ? Border.all(color: AppColors.kawaiiOutline) : null,
                  ),
                  child: Text(('“${idea.orderLine}”').ui,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      height: 1.4,
                      fontStyle: FontStyle.italic,
                      color: cartoon ? AppColors.kawaiiLeafDeep : context.brandPrimary,
                    ),
                  ),
                ),
              ],
              if (idea.swaps.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(('Akıllı değişimler').ui,
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: cartoon ? AppColors.kawaiiInk : null),
                ),
                const SizedBox(height: 10),
                for (var i = 0; i < idea.swaps.length; i++)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: cartoon ? Colors.white : Theme.of(context).colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      border: cartoon ? Border.all(color: AppColors.kawaiiOutline) : null,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: cartoon ? AppColors.kawaiiLeaf : context.brandPrimary,
                          child: Text(('${i + 1}').ui, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text((idea.swaps[i]).ui,
                            style: TextStyle(fontWeight: FontWeight.w700, color: cartoon ? AppColors.kawaiiInk : null),
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: (50 * i).ms, duration: 260.ms)
                      .slideX(begin: 0.04, curve: Curves.easeOutCubic),
              ],
              if (idea.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final t in idea.tags)
                      Chip(
                        label: Text((t).ui, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: cartoon ? AppColors.kawaiiInk : null)),
                        backgroundColor: cartoon ? AppColors.kawaiiMint : null,
                        side: cartoon ? const BorderSide(color: AppColors.kawaiiOutline) : null,
                      ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class FastingScreen extends ConsumerWidget {
  const FastingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (context.isModern) {
      return const SoftFastingScreen();
    }

    final locked = lockedIfOff(ref, module: AppModule.fasting, title: 'Aralıklı oruç');
    if (locked != null) return locked;
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(fastingProvider);
    final session = store.fasting(user.id);
    final hours = session.elapsed.inHours;
    final mins = session.elapsed.inMinutes % 60;
    final brand = context.brandPrimary;
    final brandDeep = context.brandDeep;
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
            color: brandDeep,
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
                          color: brandDeep,
                          backgroundColor: brandDeep.withValues(alpha: 0.12),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StyleIcon(
                            icon: session.active ? Icons.hourglass_top_rounded : Icons.play_circle_rounded,
                            emoji: '⏳',
                            size: 22,
                            color: brandDeep,
                          ),
                          const SizedBox(height: 6),
                          Text((session.active ? '$hours sa $mins dk' : 'Hazır').ui,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                          ),
                          Text((session.active ? 'kalan ~${((1 - session.progress) * 16).clamp(0, 16).toStringAsFixed(1)} sa' : '16 saatlik tur').ui,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text((session.active ? phase.title : 'Orucu başlat, süre aksın.').ui, style: const TextStyle(fontWeight: FontWeight.w800)),
                if (session.active) ...[
                  const SizedBox(height: 4),
                  Text((phase.body).ui, textAlign: TextAlign.center),
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
                          color: hours >= p.$1 && session.active ? AppColors.success : brand,
                        ),
                        const SizedBox(width: 10),
                        Text((p.$2).ui, style: const TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(width: 8),
                        Expanded(child: Text((p.$3).ui)),
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
              content: Text((next
                    ? (ReminderService.instance.supportsNative
                        ? 'Kalıcı su bildirimi açıldı. +250 ml ile hızlı ekle.'
                        : 'Windows’ta widget yok; bildirim Android’de çalışır. Buradan +${AppConstants.waterSipMl} ml ekleyebilirsin.')
                    : 'Su kısayolu kapatıldı.').ui,
              ),
            ),
          );
        }
      },
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const StyleIcon(icon: Icons.notifications_active, emoji: '💧', size: 28),
        title: Text(('Su kısayolu').ui, style: TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text((prefs.waterShortcut ? 'Açık' : 'Kapalı — Android bildirim / +250 ml').ui),
        trailing: Switch(value: prefs.waterShortcut, onChanged: (_) {}),
      ),
    );
  }
}

class WaterShortcutScreen extends ConsumerWidget {
  const WaterShortcutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (context.isModern) {
      return const SoftWaterShortcutScreen();
    }

    final locked = lockedIfOff(ref, module: AppModule.water, title: 'Su kısayolu');
    if (locked != null) return locked;

    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(waterLogsProvider);
    final log = store.waterLog(user.id, DateTime.now());

    return AppPage(
      title: 'Su kısayolu',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const WaterShortcutTile(),
          const SizedBox(height: 12),
          TipCard(
            title: 'Bugün ${log.amountMl} / ${log.goalMl} ml',
            body: ReminderService.instance.supportsNative
                ? 'Android’de kalıcı bildirim açıkken kilit ekranından su ekleyebilirsin.'
                : 'Bu cihazda kalıcı bildirim yok; su takibinden ml ekleyebilirsin.',
            icon: Icons.water_drop_rounded,
            emoji: '💧',
          ),
        ],
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
            title: Text(('Tabak damgası').ui),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<MealType>(
                  value: type,
                  isExpanded: true,
                  items: [
                    for (final t in MealType.values) DropdownMenuItem(value: t, child: Text(('${t.emoji} ${t.tr}').ui)),
                  ],
                  onChanged: (v) => setLocal(() => type = v ?? type),
                ),
                const SizedBox(height: 8),
                SegmentedButton<double>(
                  segments: [
                    ButtonSegment(value: 0.7, label: Text(('Küçük').ui)),
                    ButtonSegment(value: 1.0, label: Text(('Normal').ui)),
                    ButtonSegment(value: 1.35, label: Text(('Büyük').ui)),
                  ],
                  selected: {portion},
                  onSelectionChanged: (s) => setLocal(() => portion = s.first),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(('Vazgeç').ui)),
              FilledButton(onPressed: () => Navigator.pop(ctx, (type, portion)), child: Text(('Kaydet').ui)),
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
      SnackBar(content: Text(('Damga: ${stampLabel(stamp)} ($estimated kcal)').ui)),
    );
  }
}
