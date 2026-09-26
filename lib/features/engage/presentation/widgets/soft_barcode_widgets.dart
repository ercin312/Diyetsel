import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/diyetsel_assets.dart';
import '../../../../core/utils/engage_logic.dart';
import '../../../dashboard/presentation/widgets/premium_home_widgets.dart' show SoftTap;
import '../../../dashboard/presentation/widgets/soft_home_widgets.dart' show SoftModernIcon;
import '../../domain/barcode_visuals.dart';
import '../../../../core/widgets/nav_back.dart';
import '../../../../core/l10n/ui_string.dart';


class SoftBarcodeHeader extends StatelessWidget {
  const SoftBarcodeHeader({super.key});

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
              Text(('Barkod').ui,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDeep,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 2),
              Text(('Yiyebilir miyim?').ui,
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
            DiyetselAssets.modernIconSearch,
            size: 28,
            fallback: Icons.qr_code_scanner_rounded,
            fallbackColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class SoftBarcodeHero extends StatelessWidget {
  const SoftBarcodeHero({
    super.key,
    required this.remaining,
    required this.budget,
    required this.tip,
    required this.hasProduct,
    this.stamp,
  });

  final int remaining;
  final int budget;
  final String tip;
  final bool hasProduct;
  final String? stamp;

  @override
  Widget build(BuildContext context) {
    final accent = hasProduct ? BarcodeVisuals.stampAccent(stamp) : AppColors.primary;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            BarcodeVisuals.stampTint(stamp),
            const Color(0xFFFFF6E9),
            const Color(0xFFE3F2F8),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text((hasProduct ? BarcodeVisuals.stampLabel(stamp) : 'Rafa bakmadan karar').ui,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                      color: accent,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text((hasProduct ? 'Ürün analizi hazır' : '$budget kcal tavan').ui,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    height: 1.15,
                    color: AppColors.primaryDeep,
                  ),
                ),
                const SizedBox(height: 6),
                Text((tip).ui,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.35,
                    color: AppColors.primary.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          SoftModernIcon(
            DiyetselAssets.modernIconPlan,
            size: 64,
            fallback: Icons.qr_code_scanner_rounded,
            fallbackColor: accent,
          ),
        ],
      ),
    );
  }
}

class SoftBarcodeStatsRow extends StatelessWidget {
  const SoftBarcodeStatsRow({
    super.key,
    required this.remaining,
    required this.budget,
    required this.canScan,
    required this.stamp,
  });

  final int remaining;
  final int budget;
  final bool canScan;
  final String? stamp;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.local_fire_department_rounded, DiyetselAssets.modernIconStreak, const Color(0xFFE07A5F), 'Kalan', '$remaining'),
      (Icons.cookie_rounded, DiyetselAssets.modernIconPlan, AppColors.primary, 'Tavan', '$budget'),
      (Icons.qr_code_scanner_rounded, DiyetselAssets.modernIconSearch, const Color(0xFF5BA3C9), 'Kamera', canScan ? 'Açık' : 'Kapalı'),
      (Icons.verified_rounded, DiyetselAssets.modernIconCheck, BarcodeVisuals.stampAccent(stamp), 'Damga', BarcodeVisuals.stampLabel(stamp)),
    ];

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.modernLine),
                boxShadow: AppSpacing.soft,
              ),
              child: Column(
                children: [
                  SoftModernIcon(
                    items[i].$2,
                    size: 22,
                    fallback: items[i].$1,
                    fallbackColor: items[i].$3,
                  ),
                  const SizedBox(height: 6),
                  Text((items[i].$5).ui,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: items[i].$3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text((items[i].$4).ui,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 10.5,
                      color: AppColors.primary.withValues(alpha: 0.5),
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

class SoftBarcodeHowItWorksCard extends StatelessWidget {
  const SoftBarcodeHowItWorksCard({super.key});

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
          Text(('Nasıl kullanılır?').ui,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15,
              color: AppColors.primaryDeep,
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 1; i <= 3; i++) ...[
            if (i > 1) const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(('$i').ui,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text((BarcodeVisuals.howItWorks(i)).ui,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      height: 1.35,
                      color: AppColors.primaryDeep.withValues(alpha: 0.88),
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

class SoftBarcodeScannerCard extends StatelessWidget {
  const SoftBarcodeScannerCard({super.key, required this.onDetect});

  final void Function(String code) onDetect;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                SoftModernIcon(
                  DiyetselAssets.modernIconSearch,
                  size: 22,
                  fallback: Icons.qr_code_scanner_rounded,
                  fallbackColor: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(('Kamera taraması').ui,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: AppColors.primaryDeep,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(('Canlı').ui,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 10.5,
                      color: AppColors.primary.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 220,
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  onDetect: (capture) {
                    final code = capture.barcodes.firstOrNull?.rawValue;
                    if (code != null) onDetect(code);
                  },
                ),
                Center(
                  child: Container(
                    width: 200,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.75), width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 12,
                  child: Text(('Barkodu çerçeveye hizala').ui,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.95),
                      shadows: const [Shadow(blurRadius: 8, color: Colors.black54)],
                    ),
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

class SoftBarcodeNoCameraCard extends StatelessWidget {
  const SoftBarcodeNoCameraCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: Row(
        children: [
          SoftModernIcon(
            DiyetselAssets.modernIconPlan,
            size: 40,
            fallback: Icons.desktop_windows_rounded,
            fallbackColor: const Color(0xFF5BA3C9),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(('Kamera bu cihazda yok').ui,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: AppColors.primaryDeep,
                  ),
                ),
                const SizedBox(height: 4),
                Text(('Windows’ta tarama kapalı. Paketin altındaki 8–13 haneli barkodu kutuya yazıp ara.').ui,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                    height: 1.35,
                    color: AppColors.primary.withValues(alpha: 0.55),
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

class SoftBarcodeManualField extends StatelessWidget {
  const SoftBarcodeManualField({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.loading,
  });

  final TextEditingController controller;
  final VoidCallback onSearch;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(('Manuel barkod').ui,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              color: AppColors.primaryDeep,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryDeep),
            decoration: InputDecoration(
              hintText: ('Örn. 8690504…').ui,
              hintStyle: TextStyle(color: AppColors.primary.withValues(alpha: 0.35)),
              filled: true,
              fillColor: AppColors.modernWash,
              prefixIcon: Icon(Icons.qr_code_rounded, color: AppColors.primary.withValues(alpha: 0.55)),
              suffixIcon: IconButton(
                icon: loading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary.withValues(alpha: 0.7),
                        ),
                      )
                    : Icon(Icons.search_rounded, color: AppColors.primary.withValues(alpha: 0.75)),
                onPressed: loading ? null : onSearch,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.modernLine),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.modernLine),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
            onSubmitted: (_) => onSearch(),
          ),
        ],
      ),
    );
  }
}

class SoftBarcodeErrorCard extends StatelessWidget {
  const SoftBarcodeErrorCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0E8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE07A5F).withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFE07A5F)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(('Bulunamadı').ui,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: AppColors.primaryDeep,
                  ),
                ),
                const SizedBox(height: 4),
                Text((message).ui,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.35,
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

class SoftBarcodeResultCard extends StatelessWidget {
  const SoftBarcodeResultCard({
    super.key,
    required this.product,
    required this.stamp,
    required this.budget,
  });

  final OffProduct product;
  final String stamp;
  final int budget;

  @override
  Widget build(BuildContext context) {
    final accent = BarcodeVisuals.stampAccent(stamp);
    final tint = BarcodeVisuals.stampTint(stamp);
    final ratio = budget <= 0 ? 1.0 : (product.kcal / budget).clamp(0.0, 1.5);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [tint, Colors.white],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.4), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.16),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(BarcodeVisuals.stampIcon(stamp), color: accent, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text((product.name).ui,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: AppColors.primaryDeep,
                      ),
                    ),
                    if (product.brand != null) ...[
                      const SizedBox(height: 2),
                      Text((product.brand!).ui,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                          color: AppColors.primary.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text((BarcodeVisuals.stampLabel(stamp)).ui,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _StatPill(label: 'Kalori', value: '${product.kcal}', unit: product.per, accent: accent),
              const SizedBox(width: 8),
              _StatPill(label: 'Tavan', value: '$budget', unit: 'kcal', accent: AppColors.primary),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(('Bütçe kullanımı').ui,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.primary.withValues(alpha: 0.55),
                  ),
                ),
              ),
              Text(('${product.kcal} / $budget kcal').ui,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  color: accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 9,
              backgroundColor: Colors.white.withValues(alpha: 0.85),
              color: accent,
            ),
          ),
          const SizedBox(height: 12),
          Text((BarcodeVisuals.stampMessage(stamp)).ui,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              height: 1.35,
              color: AppColors.primary.withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(height: 10),
          Text(('Barkod: ${product.barcode}').ui,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: AppColors.primary.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.unit,
    required this.accent,
  });

  final String label;
  final String value;
  final String unit;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.modernLine),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text((label).ui,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            Text((value).ui,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: accent,
              ),
            ),
            Text((unit).ui,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: AppColors.primary.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SoftBarcodeLoadingCard extends StatelessWidget {
  const SoftBarcodeLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.primary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(width: 12),
          Text(('Open Food Facts aranıyor…').ui,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primary.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}

class SoftBarcodeFooterTip extends StatelessWidget {
  const SoftBarcodeFooterTip({super.key});

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
            fallback: Icons.lightbulb_outline_rounded,
            fallbackColor: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(('Open Food Facts çoğu ürünü 100 g olarak verir. Paket 30 g ise kaloriyi üçe böl; damga değişebilir.').ui,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                height: 1.35,
                color: AppColors.primary.withValues(alpha: 0.65),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
