import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/models/models.dart';
import '../../../dashboard/presentation/widgets/premium_home_widgets.dart' show SoftTap;
import '../../domain/shopping_delivery.dart';
import '../../domain/shopping_platforms.dart';

Future<void> showShoppingDeliverySheet({
  required BuildContext context,
  required List<ShoppingItem> items,
  required bool cartoon,
  ShoppingDeliveryPlatform? initialPlatform,
  ValueChanged<ShoppingDeliveryPlatform>? onPlatformSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => ShoppingDeliverySheet(
      items: items,
      cartoon: cartoon,
      initialPlatform: initialPlatform ?? ShoppingDeliveryPlatform.trendyolGo,
      onPlatformSelected: onPlatformSelected,
    ),
  );
}

class ShoppingDeliverySheet extends StatefulWidget {
  const ShoppingDeliverySheet({
    super.key,
    required this.items,
    required this.cartoon,
    required this.initialPlatform,
    this.onPlatformSelected,
  });

  final List<ShoppingItem> items;
  final bool cartoon;
  final ShoppingDeliveryPlatform initialPlatform;
  final ValueChanged<ShoppingDeliveryPlatform>? onPlatformSelected;

  @override
  State<ShoppingDeliverySheet> createState() => _ShoppingDeliverySheetState();
}

class _ShoppingDeliverySheetState extends State<ShoppingDeliverySheet> {
  late ShoppingDeliveryPlatform _platform;
  int _seqIndex = 0;
  bool _busy = false;

  List<ShoppingItem> get _needed => ShoppingDelivery.neededProducts(widget.items);

  Color get _accent =>
      widget.cartoon ? AppColors.kawaiiLeaf : AppColors.primary;

  Color get _surface =>
      widget.cartoon ? AppColors.kawaiiSurfaceCream : AppColors.modernWash;

  @override
  void initState() {
    super.initState();
    _platform = widget.initialPlatform;
  }

  Future<void> _toast(String msg) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _copy() async {
    if (_needed.isEmpty) {
      await _toast('Alınacak ürün yok — elinde olanları işaretle.');
      return;
    }
    await ShoppingDelivery.copyList(_needed, platform: _platform);
    await _toast('Liste panoya kopyalandı');
  }

  Future<void> _share() async {
    if (_needed.isEmpty) {
      await _toast('Alınacak ürün yok');
      return;
    }
    await ShoppingDelivery.shareList(_needed, platform: _platform);
  }

  Future<void> _openCurrent() async {
    if (_needed.isEmpty) return;
    setState(() => _busy = true);
    try {
      final item = _needed[_seqIndex.clamp(0, _needed.length - 1)];
      final ok = await ShoppingDelivery.openSearch(_platform, item);
      if (!ok) await _toast('Bağlantı açılamadı');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openNext() async {
    if (_needed.isEmpty) return;
    await _openCurrent();
    if (!mounted) return;
    if (_seqIndex < _needed.length - 1) {
      setState(() => _seqIndex++);
    } else {
      await _toast('Liste bitti — sepete eklediklerini uygulamada işaretle ✓');
    }
  }

  Future<void> _openHome() async {
    setState(() => _busy = true);
    try {
      await ShoppingDelivery.openPlatformHome(_platform);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _selectPlatform(ShoppingDeliveryPlatform p) {
    setState(() {
      _platform = p;
      _seqIndex = 0;
    });
    widget.onPlatformSelected?.call(p);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final needed = _needed;
    final current = needed.isEmpty
        ? null
        : needed[_seqIndex.clamp(0, needed.length - 1)];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          Flexible(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottom),
              shrinkWrap: true,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _platform.accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(_platform.icon, color: _platform.accent, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Platforma gönder',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Elindekileri işaretle ✓ — alınacaklar sırayla aranır',
                            style: TextStyle(fontSize: 12.5, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '1. Platform seç',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: _accent,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final p in ShoppingDeliveryPlatform.values)
                      SoftTap(
                        onTap: () => _selectPlatform(p),
                        borderRadius: BorderRadius.circular(999),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: _platform == p
                                ? p.accent
                                : Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: _platform == p
                                  ? p.accent
                                  : (widget.cartoon
                                      ? AppColors.kawaiiOutline
                                      : AppColors.modernLine),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                p.icon,
                                size: 16,
                                color: _platform == p
                                    ? Colors.white
                                    : p.accent,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                p.label,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                  color: _platform == p
                                      ? Colors.white
                                      : (widget.cartoon
                                          ? AppColors.kawaiiInk
                                          : AppColors.lightInk),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  '2. Alınacaklar (${needed.length})',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: _accent,
                  ),
                ),
                const SizedBox(height: 8),
                if (needed.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: widget.cartoon
                            ? AppColors.kawaiiOutline
                            : AppColors.modernLine,
                      ),
                    ),
                    child: const Text(
                      'Alınacak ürün yok. Elinde olmayanları listede bırak '
                      '(işaretsiz); elindekilerin tikini koy.',
                      style: TextStyle(height: 1.35),
                    ),
                  )
                else ...[
                  ...needed.asMap().entries.map((e) {
                    final i = e.key;
                    final item = e.value;
                    final active = i == _seqIndex;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: active
                              ? _platform.accent.withValues(alpha: 0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: active
                                ? _platform.accent.withValues(alpha: 0.45)
                                : (widget.cartoon
                                    ? AppColors.kawaiiOutline
                                    : AppColors.modernLine),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '${i + 1}.',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: active ? _platform.accent : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                ShoppingDelivery.lineFor(item),
                                style: TextStyle(
                                  fontWeight:
                                      active ? FontWeight.w800 : FontWeight.w600,
                                ),
                              ),
                            ),
                            SoftTap(
                              onTap: _busy
                                  ? null
                                  : () async {
                                      setState(() => _seqIndex = i);
                                      setState(() => _busy = true);
                                      try {
                                        await ShoppingDelivery.openSearch(
                                          _platform,
                                          item,
                                        );
                                      } finally {
                                        if (mounted) {
                                          setState(() => _busy = false);
                                        }
                                      }
                                    },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _platform.accent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Ara',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    color: _platform.accent,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  if (current != null)
                    SoftTap(
                      onTap: _busy ? null : _openNext,
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _platform.accent,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: _platform.accent.withValues(alpha: 0.28),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          _busy
                              ? 'Açılıyor…'
                              : 'Sıradaki: ${ShoppingDelivery.searchQueryFor(current)}  ·  Ara',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _SheetBtn(
                        label: 'Kopyala',
                        icon: Icons.copy_rounded,
                        onTap: _copy,
                        outline: true,
                        cartoon: widget.cartoon,
                        accent: _accent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SheetBtn(
                        label: 'Paylaş',
                        icon: Icons.ios_share_rounded,
                        onTap: _share,
                        outline: true,
                        cartoon: widget.cartoon,
                        accent: _accent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SheetBtn(
                        label: 'Uygulama',
                        icon: Icons.open_in_new_rounded,
                        onTap: _busy ? null : _openHome,
                        outline: false,
                        cartoon: widget.cartoon,
                        accent: _platform.accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetBtn extends StatelessWidget {
  const _SheetBtn({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.outline,
    required this.cartoon,
    required this.accent,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool outline;
  final bool cartoon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: outline ? Colors.white : accent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: outline
                ? (cartoon ? AppColors.kawaiiOutline : AppColors.modernLine)
                : accent,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: outline ? accent : Colors.white),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 11.5,
                color: outline
                    ? (cartoon ? AppColors.kawaiiInk : AppColors.lightInk)
                    : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
