import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/diyetsel_assets.dart';
import '../../../../core/models/models.dart';
import '../../../../core/widgets/marketplace.dart';
import '../../../dashboard/presentation/widgets/premium_home_widgets.dart' show SoftTap;
import '../../../dashboard/presentation/widgets/soft_home_widgets.dart' show SoftModernIcon;
import '../../domain/service_visuals.dart';

class SoftServicesHeader extends StatelessWidget {
  const SoftServicesHeader({super.key, required this.admin});

  final bool admin;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SoftTap(
          onTap: () => Navigator.maybePop(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.modernLine),
              boxShadow: AppSpacing.soft,
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: AppColors.primary.withValues(alpha: 0.75),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                admin ? 'Hizmet yönetimi' : 'Hizmetler',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDeep,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                admin ? 'Paketleri düzenle ve yayınla' : 'Online, klinik ve programlar',
                style: const TextStyle(
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
            DiyetselAssets.modernIconService,
            size: 28,
            fallback: Icons.headset_mic_rounded,
            fallbackColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class SoftServicesHero extends StatelessWidget {
  const SoftServicesHero({super.key, required this.count, required this.fromPrice});

  final int count;
  final double? fromPrice;

  @override
  Widget build(BuildContext context) {
    final priceLabel = fromPrice == null
        ? 'kişiye özel paketler'
        : '₺${fromPrice!.toStringAsFixed(0)}’dan başlayan';

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F5F0), Color(0xFFFFF6E9), Color(0xFFE3F2F8)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
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
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Klinik & online',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Sana uygun paket',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    height: 1.15,
                    color: AppColors.primaryDeep,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$count hizmet · $priceLabel',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.35,
                    color: AppColors.primaryDeep.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          SoftModernIcon(
            DiyetselAssets.modernCardClinic,
            size: 78,
            fallback: Icons.medical_services_rounded,
            fallbackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class SoftServicesStatsRow extends StatelessWidget {
  const SoftServicesStatsRow({
    super.key,
    required this.packages,
    required this.categories,
    required this.fromPrice,
  });

  final int packages;
  final int categories;
  final double? fromPrice;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        'Paket',
        '$packages',
        DiyetselAssets.modernIconService,
        Icons.medical_services_rounded,
        AppColors.primary,
      ),
      (
        'Kategori',
        '$categories',
        DiyetselAssets.modernIconAppsAll,
        Icons.grid_view_rounded,
        const Color(0xFF5BA3C9),
      ),
      (
        'Başlangıç',
        fromPrice == null ? '—' : '₺${fromPrice!.toStringAsFixed(0)}',
        DiyetselAssets.modernIconCheck,
        Icons.payments_rounded,
        const Color(0xFFE07A5F),
      ),
    ];

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.modernLine),
                boxShadow: AppSpacing.soft,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SoftModernIcon(
                    items[i].$3,
                    size: 24,
                    fallback: items[i].$4,
                    fallbackColor: items[i].$5,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    items[i].$1,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11.5,
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    items[i].$2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: items[i].$5,
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

class SoftServiceCategoryChip extends StatelessWidget {
  const SoftServiceCategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.modernLine,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : AppSpacing.soft,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 12.5,
            color: selected ? Colors.white : AppColors.primaryDeep.withValues(alpha: 0.75),
          ),
        ),
      ),
    );
  }
}

class SoftServiceFeaturedCard extends StatelessWidget {
  const SoftServiceFeaturedCard({
    super.key,
    required this.service,
    required this.admin,
    required this.onOpen,
  });

  final ServicePackage service;
  final bool admin;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final tint = ServiceVisuals.softTintFor(service);
    final accent = ServiceVisuals.softAccentFor(service);

    return SoftTap(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppColors.modernLine),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.14),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 12, 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(tint, Colors.white, 0.1)!,
                    Color.lerp(tint, const Color(0xFFFFF6E9), 0.35)!,
                  ],
                ),
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
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Öne çıkan · ${service.category.isEmpty ? 'Paket' : service.category}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 11.5,
                              color: accent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          service.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            height: 1.2,
                            color: AppColors.primaryDeep,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          ServiceVisuals.displayTagline(service),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColors.primary.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  diyetselFoodPhoto(
                    url: ServiceVisuals.imageFor(service),
                    width: 96,
                    height: 96,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                      height: 1.35,
                      color: AppColors.primary.withValues(alpha: 0.65),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      SoftPricePill(
                        label: '₺${service.price.toStringAsFixed(0)}',
                        color: accent,
                      ),
                      const SizedBox(width: 8),
                      SoftPricePill(
                        label: '${service.durationMinutes} dk',
                        color: AppColors.primary,
                      ),
                      const Spacer(),
                      Text(
                        admin ? 'Detay' : 'İncele',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                          color: accent,
                        ),
                      ),
                      Icon(Icons.arrow_forward_rounded, size: 18, color: accent),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SoftServiceCard extends StatelessWidget {
  const SoftServiceCard({
    super.key,
    required this.service,
    required this.admin,
    required this.onOpen,
    this.onEdit,
    this.onDelete,
    this.index = 0,
  });

  final ServicePackage service;
  final bool admin;
  final VoidCallback onOpen;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final int index;

  @override
  Widget build(BuildContext context) {
    final tint = ServiceVisuals.softTintFor(service);
    final accent = ServiceVisuals.softAccentFor(service);

    return SoftTap(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(22),
      child: Container(
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
            Container(
              padding: const EdgeInsets.fromLTRB(14, 14, 10, 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(tint, Colors.white, 0.15)!,
                    Color.lerp(tint, const Color(0xFFFFF6E9), 0.4)!,
                  ],
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(ServiceVisuals.iconFor(service), size: 18, color: accent),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                service.category.isEmpty ? 'Paket' : service.category,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11.5,
                                  color: accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          service.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                            height: 1.2,
                            color: AppColors.primaryDeep,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ServiceVisuals.displayTagline(service),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12.5,
                            color: AppColors.primary.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  diyetselFoodPhoto(
                    url: ServiceVisuals.imageFor(service),
                    width: 84,
                    height: 84,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      height: 1.35,
                      color: AppColors.primaryDeep.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      SoftPricePill(
                        label: '₺${service.price.toStringAsFixed(0)}',
                        color: accent,
                      ),
                      SoftPricePill(
                        label: '${service.durationMinutes} dk',
                        color: AppColors.primary,
                      ),
                      for (final t in service.tags.take(2))
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.modernWash,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.modernLine),
                          ),
                          child: Text(
                            t,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              color: AppColors.primary.withValues(alpha: 0.75),
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (service.bullets.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      service.bullets.take(2).map((e) => '• $e').join('\n'),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                        height: 1.35,
                        color: AppColors.primary.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        admin ? 'Detay / düzenle' : 'İncele ve talep et',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: accent,
                          fontSize: 13.5,
                        ),
                      ),
                      Icon(Icons.arrow_forward_rounded, size: 18, color: accent),
                      const Spacer(),
                      if (onEdit != null)
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: onEdit,
                          icon: Icon(
                            Icons.edit_rounded,
                            size: 20,
                            color: AppColors.primary.withValues(alpha: 0.45),
                          ),
                        ),
                      if (onDelete != null)
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: onDelete,
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 20,
                            color: Color(0xFFE07A5F),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (40 * index).ms, duration: 280.ms).slideY(
          begin: 0.04,
          curve: Curves.easeOutCubic,
        );
  }
}

class SoftPricePill extends StatelessWidget {
  const SoftPricePill({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Color.lerp(color, Colors.white, 0.82),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5, color: color),
      ),
    );
  }
}

class SoftServicesEmpty extends StatelessWidget {
  const SoftServicesEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.modernLine),
      ),
      child: Column(
        children: [
          SoftModernIcon(
            DiyetselAssets.modernIconService,
            size: 48,
            fallback: Icons.medical_services_outlined,
            fallbackColor: AppColors.primary.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 12),
          const Text(
            'Bu kategoride hizmet yok',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: AppColors.primaryDeep,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Başka bir kategori seç veya tümünü görüntüle.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class SoftServicesFooterTip extends StatelessWidget {
  const SoftServicesFooterTip({super.key, required this.admin});

  final bool admin;

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
        children: [
          SoftModernIcon(
            DiyetselAssets.modernIconBell,
            size: 28,
            fallback: Icons.info_outline_rounded,
            fallbackColor: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              admin
                  ? 'Pasif paketler danışanlara görünmez. Yayın durumunu kart detayından yönet.'
                  : 'Talep gönderince diyetisyenin onaylar; randevu veya başlangıç tarihi mesajla netleşir.',
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

class SoftServicesFab extends StatelessWidget {
  const SoftServicesFab({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 2,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Yeni paket', style: TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}

class SoftServiceDetailSheet extends StatelessWidget {
  const SoftServiceDetailSheet({
    super.key,
    required this.service,
    required this.admin,
    this.onRequest,
    this.onEdit,
    this.onDelete,
  });

  final ServicePackage service;
  final bool admin;
  final VoidCallback? onRequest;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final tint = ServiceVisuals.softTintFor(service);
    final accent = ServiceVisuals.softAccentFor(service);

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      builder: (context, scroll) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.modernWash,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                    color: AppColors.modernLine,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.lerp(tint, Colors.white, 0.12)!,
                      const Color(0xFFFFF6E9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.modernLine),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
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
                              color: Colors.white.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              service.category.isEmpty ? 'Paket' : service.category,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                color: accent,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            service.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                              height: 1.2,
                              color: AppColors.primaryDeep,
                              letterSpacing: -0.3,
                            ),
                          ),
                          if (ServiceVisuals.displayTagline(service).isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              ServiceVisuals.displayTagline(service),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    diyetselFoodPhoto(
                      url: ServiceVisuals.imageFor(service),
                      width: 96,
                      height: 96,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 280.ms).scale(
                    begin: const Offset(0.96, 0.96),
                    curve: Curves.easeOutBack,
                  ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SoftPricePill(
                    label: '₺${service.price.toStringAsFixed(0)}',
                    color: accent,
                  ),
                  SoftPricePill(
                    label: '${service.durationMinutes} dk',
                    color: AppColors.primary,
                  ),
                  for (final t in service.tags)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.modernLine),
                      ),
                      child: Text(
                        t,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: AppColors.primary.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                service.description,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                  fontSize: 14.5,
                  color: AppColors.primaryDeep.withValues(alpha: 0.88),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Neler dahil?',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  color: AppColors.primaryDeep,
                ),
              ),
              const SizedBox(height: 10),
              for (var i = 0; i < service.bullets.length; i++)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.modernLine),
                    boxShadow: AppSpacing.soft,
                  ),
                  child: Row(
                    children: [
                      SoftModernIcon(
                        DiyetselAssets.modernIconCheck,
                        size: 20,
                        fallback: Icons.check_circle_rounded,
                        fallbackColor: accent,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          service.bullets[i],
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDeep,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: (45 * i).ms, duration: 260.ms)
                    .slideX(begin: 0.04, curve: Curves.easeOutCubic),
              const SizedBox(height: 16),
              if (onRequest != null)
                SoftTap(
                  onTap: onRequest,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.28),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Randevu / satın alma talebi',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              if (admin) ...[
                if (onEdit != null) ...[
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: onEdit,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.modernLine),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Düzenle', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ],
                if (onDelete != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: onDelete,
                    child: const Text(
                      'Sil',
                      style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFE07A5F)),
                    ),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}
