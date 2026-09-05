import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../app/theme/app_colors.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/app_modules.dart';
import '../../../core/utils/engage_logic.dart';
import '../../../core/widgets/module_gate.dart';
import '../../../core/widgets/soft_ui_kit.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/barcode_visuals.dart';
import 'widgets/soft_barcode_widgets.dart';

bool get _canScanCamera {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;
}

/// Soft premium modern barcode scanner — tara, kıyasla, karar ver.
class SoftBarcodeScreen extends ConsumerStatefulWidget {
  const SoftBarcodeScreen({super.key});

  @override
  ConsumerState<SoftBarcodeScreen> createState() => _SoftBarcodeScreenState();
}

class _SoftBarcodeScreenState extends ConsumerState<SoftBarcodeScreen> {
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
      _product = null;
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

    return Scaffold(
      backgroundColor: AppColors.modernWash,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            const SoftBarcodeHeader()
                .animate()
                .fadeIn(duration: 280.ms)
                .slideY(begin: -0.05, curve: Curves.easeOutCubic),
            const SizedBox(height: 14),
            SoftBarcodeHero(
              remaining: remaining,
              budget: budget,
              tip: BarcodeVisuals.tipOfDay(DateTime.now().day),
              hasProduct: _product != null,
              stamp: stamp,
            )
                .animate()
                .fadeIn(delay: 40.ms, duration: 300.ms)
                .scale(
                  begin: const Offset(0.97, 0.97),
                  curve: Curves.easeOutCubic,
                  duration: 380.ms,
                ),
            const SizedBox(height: 12),
            SoftBarcodeStatsRow(
              remaining: remaining,
              budget: budget,
              canScan: _canScanCamera,
              stamp: stamp,
            ).animate().fadeIn(delay: 60.ms, duration: 280.ms),
            const SizedBox(height: 12),
            SoftTipCard(
              title: 'Etiket oku',
              body: '100 g kalorisine bak; porsiyonu kendi tabağınla kıyasla. Bütçen ~$budget kcal.',
              icon: Icons.qr_code_scanner_rounded,
              accent: AppColors.primary,
              tint: AppColors.modernMint,
            ),
            const SizedBox(height: 14),
            const SoftBarcodeHowItWorksCard()
                .animate()
                .fadeIn(delay: 75.ms, duration: 280.ms),
            const SizedBox(height: 14),
            if (_canScanCamera)
              SoftBarcodeScannerCard(onDetect: _lookup)
                  .animate()
                  .fadeIn(delay: 90.ms, duration: 300.ms)
            else
              const SoftBarcodeNoCameraCard()
                  .animate()
                  .fadeIn(delay: 90.ms, duration: 280.ms),
            const SizedBox(height: 12),
            SoftBarcodeManualField(
              controller: _manual,
              onSearch: () => _lookup(_manual.text),
              loading: _loading,
            ).animate().fadeIn(delay: 105.ms, duration: 280.ms),
            if (_loading) ...[
              const SizedBox(height: 12),
              const SoftBarcodeLoadingCard()
                  .animate()
                  .fadeIn(duration: 240.ms),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              SoftBarcodeErrorCard(message: _error!)
                  .animate()
                  .fadeIn(duration: 280.ms),
            ],
            if (_product != null) ...[
              const SizedBox(height: 14),
              SoftBarcodeResultCard(
                product: _product!,
                stamp: stamp!,
                budget: budget,
              )
                  .animate(key: ValueKey(_product!.barcode))
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.04, curve: Curves.easeOutCubic),
            ],
            const SizedBox(height: 14),
            const SoftBarcodeFooterTip()
                .animate()
                .fadeIn(delay: 130.ms, duration: 280.ms),
          ],
        ),
      ),
    );
  }
}
