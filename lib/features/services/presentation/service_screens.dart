import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/models.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/cartoon_glyph.dart';
import '../../../core/widgets/marketplace.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/service_visuals.dart';
import 'soft_service_screen.dart';
import '../../../core/l10n/ui_string.dart';

class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key, this.admin = false});
  final bool admin;

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  String _filter = 'Tümü';

  @override
  Widget build(BuildContext context) {
    if (context.isModern) {
      return SoftServicesScreen(admin: widget.admin);
    }

    final services = ref.watch(servicesProvider).valueOrNull ?? [];
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    if (!widget.admin) ref.watch(serviceRequestsProvider);

    final active = services.where((e) => e.active || widget.admin).toList();
    final categories = ['Tümü', ...{for (final s in active) s.category.isEmpty ? 'Paket' : s.category}];
    final shown = _filter == 'Tümü'
        ? active
        : active.where((s) => (s.category.isEmpty ? 'Paket' : s.category) == _filter).toList();
    final cartoon = context.isCartoon;

    if (cartoon) {
      return AppPage(
        title: 'Hizmetler',
        padding: EdgeInsets.zero,
        fab: widget.admin
            ? FloatingActionButton(
                backgroundColor: AppColors.kawaiiLeaf,
                onPressed: () => _edit(context, store),
                child: const Icon(Icons.add_rounded, color: Colors.white),
              )
            : null,
        child: ColoredBox(
          color: AppColors.kawaiiSurfaceCream,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            children: [
              _ServicesHero(count: active.length)
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: -0.04, curve: Curves.easeOutCubic),
              if (!widget.admin) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.kawaiiMint.withValues(alpha: 0.85),
                        AppColors.kawaiiLemon.withValues(alpha: 0.55),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                    border: Border.all(color: AppColors.kawaiiOutline),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.inventory_2_outlined, color: AppColors.kawaiiLeafDeep, size: 22),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(('Paket seçerken süre ve içerikleri oku; talebin diyetisyene iletilir. Düzenli takip paketleri daha kalıcı sonuç verir.').ui,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                            color: AppColors.kawaiiInk,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 50.ms, duration: 280.ms),
              ],
              const SizedBox(height: 14),
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
              const SizedBox(height: 16),
              if (shown.isEmpty)
                Padding(
                  padding: EdgeInsets.all(28),
                  child: Text(('Bu kategoride hizmet yok.').ui,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.kawaiiMuted),
                  ),
                )
              else
                for (var i = 0; i < shown.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CartoonServiceCard(
                      service: shown[i],
                      admin: widget.admin,
                      onOpen: () => _openDetail(context, store, user, shown[i]),
                      onEdit: widget.admin ? () => _edit(context, store, shown[i]) : null,
                      onDelete: widget.admin ? () => store.deleteService(shown[i].id) : null,
                    )
                        .animate()
                        .fadeIn(delay: (50 * i).ms, duration: 300.ms)
                        .slideY(begin: 0.05, curve: Curves.easeOutCubic)
                        .scale(begin: const Offset(0.97, 0.97), curve: Curves.easeOutBack, duration: 400.ms),
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
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppColors.kawaiiLeafDeep),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(('Talep gönderince diyetisyenin onaylar; randevu veya başlangıç tarihi mesajla netleşir.').ui,
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 1.35, color: AppColors.kawaiiMuted),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 180.ms, duration: 300.ms),
            ],
          ),
        ),
      );
    }

    return SoftServicesScreen(admin: widget.admin);
  }

  void _openDetail(BuildContext context, AppStore store, UserProfile user, ServicePackage service) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ServiceDetailSheet(
        service: service,
        admin: widget.admin,
        onRequest: widget.admin
            ? null
            : () async {
                await store.saveServiceRequest(
                  ServiceRequest(
                    id: newId(),
                    clientId: user.id,
                    clientName: user.displayName,
                    serviceId: service.id,
                    serviceTitle: service.title,
                    status: 'pending',
                    createdAt: DateTime.now(),
                  ),
                );
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(('Talebiniz iletildi').ui)),
                  );
                }
              },
        onEdit: widget.admin
            ? () {
                Navigator.pop(ctx);
                _edit(context, store, service);
              }
            : null,
        onDelete: widget.admin
            ? () {
                Navigator.pop(ctx);
                store.deleteService(service.id);
              }
            : null,
      ),
    );
  }

  Future<void> _edit(BuildContext context, AppStore store, [ServicePackage? existing]) async {
    final title = TextEditingController(text: existing?.title ?? '');
    final desc = TextEditingController(text: existing?.description ?? '');
    final price = TextEditingController(text: existing?.price.toString() ?? '');
    final bullets = TextEditingController(text: existing?.bullets.join('\n') ?? '');
    final tagline = TextEditingController(text: existing?.tagline ?? '');
    final category = TextEditingController(text: existing?.category ?? 'Paket');
    final cartoon = context.isCartoon;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cartoon ? AppColors.kawaiiCream : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cartoon ? AppSpacing.radiusCard : 12),
        ),
        title: Text((existing == null ? 'Yeni hizmet' : 'Hizmeti düzenle').ui,
          style: TextStyle(fontWeight: FontWeight.w900, color: cartoon ? AppColors.kawaiiInk : null),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: title, decoration: InputDecoration(labelText: ('Başlık').ui)),
              TextField(controller: tagline, decoration: InputDecoration(labelText: ('Kısa slogan').ui)),
              TextField(controller: category, decoration: InputDecoration(labelText: ('Kategori').ui)),
              TextField(controller: desc, decoration: InputDecoration(labelText: ('Açıklama').ui), maxLines: 3),
              TextField(controller: price, decoration: InputDecoration(labelText: ('Fiyat').ui), keyboardType: TextInputType.number),
              TextField(controller: bullets, decoration: InputDecoration(labelText: ('Madde (satır satır)').ui), maxLines: 4),
            ],
          ),
        ),
        actions: [
          FilledButton(
            style: cartoon
                ? FilledButton.styleFrom(
                    backgroundColor: AppColors.kawaiiLeaf,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  )
                : null,
            onPressed: () async {
              await store.saveService(
                ServicePackage(
                  id: existing?.id ?? newId(),
                  title: title.text,
                  description: desc.text,
                  price: double.tryParse(price.text) ?? 0,
                  durationMinutes: existing?.durationMinutes ?? 45,
                  bullets: bullets.text.split('\n').where((e) => e.trim().isNotEmpty).toList(),
                  tagline: tagline.text.trim(),
                  category: category.text.trim().isEmpty ? 'Paket' : category.text.trim(),
                  tags: existing?.tags ?? const [],
                  imageUrl: existing?.imageUrl,
                  active: existing?.active ?? true,
                ),
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(('Kaydet').ui),
          ),
        ],
      ),
    );
  }
}

class _ServicesHero extends StatelessWidget {
  const _ServicesHero({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.kawaiiMint, AppColors.kawaiiSurfaceCream],
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
                Text(('Hizmetler').ui,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: AppColors.kawaiiInk,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(('$count paket · online, klinik ve program seçenekleri').ui,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 1.35, color: AppColors.kawaiiMuted),
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/images/mascot_avocado.png',
            width: 72,
            height: 72,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Icon(Icons.medical_services_rounded, size: 40, color: AppColors.kawaiiLeaf),
          ),
        ],
      ),
    );
  }
}

class _CartoonServiceCard extends StatelessWidget {
  const _CartoonServiceCard({
    required this.service,
    required this.admin,
    required this.onOpen,
    this.onEdit,
    this.onDelete,
  });

  final ServicePackage service;
  final bool admin;
  final VoidCallback onOpen;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final tint = ServiceVisuals.tintFor(service);
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
                padding: const EdgeInsets.fromLTRB(14, 14, 10, 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(tint, Colors.white, 0.2)!,
                      Color.lerp(tint, AppColors.kawaiiCream, 0.45)!,
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusHero - 1)),
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
                              CartoonGlyph(
                                icon: ServiceVisuals.iconFor(service),
                                accent: AppColors.kawaiiLeaf,
                                size: 36,
                                radius: 12,
                                iconSize: 18,
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text((service.category.isEmpty ? 'Paket' : service.category).ui,
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: AppColors.kawaiiInk),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text((service.title).ui,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 17,
                              height: 1.2,
                              color: AppColors.kawaiiInk,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text((ServiceVisuals.displayTagline(service)).ui,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: AppColors.kawaiiMuted),
                          ),
                        ],
                      ),
                    ),
                    diyetselFoodPhoto(
                      url: ServiceVisuals.imageFor(service),
                      width: 88,
                      height: 88,
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
                    Text((service.description).ui,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        height: 1.35,
                        color: AppColors.kawaiiInk.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _PricePill(label: '₺${service.price.toStringAsFixed(0)}', color: AppColors.kawaiiLeaf),
                        _PricePill(label: '${service.durationMinutes} dk', color: AppColors.kawaiiSkyBlue),
                        for (final t in service.tags.take(2))
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
                    if (service.bullets.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text((service.bullets.take(2).map((e) => '• $e').join('\n')).ui,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, height: 1.35, color: AppColors.kawaiiMuted),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text((admin ? 'Detay / düzenle' : 'İncele ve talep et').ui,
                          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.kawaiiLeafDeep, fontSize: 13.5),
                        ),
                        const Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.kawaiiLeafDeep),
                        const Spacer(),
                        if (onEdit != null)
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit_rounded, size: 20, color: AppColors.kawaiiMuted),
                          ),
                        if (onDelete != null)
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: onDelete,
                            icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.kawaiiCoral),
                          ),
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

class _PricePill extends StatelessWidget {
  const _PricePill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Color.lerp(color, Colors.white, 0.78),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text((label).ui, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5, color: color)),
    );
  }
}

class _ServiceDetailSheet extends StatelessWidget {
  const _ServiceDetailSheet({
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
    final cartoon = context.isCartoon;
    final bg = cartoon ? AppColors.kawaiiCream : Theme.of(context).colorScheme.surface;
    final tint = ServiceVisuals.tintFor(service);

    return DraggableScrollableSheet(
      initialChildSize: 0.86,
      minChildSize: 0.5,
      maxChildSize: 0.96,
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.lerp(tint, Colors.white, 0.2)!,
                      cartoon ? AppColors.kawaiiSurfaceCream : tint.withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
                  border: cartoon ? Border.all(color: AppColors.kawaiiOutline) : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text((service.category.isEmpty ? 'Paket' : service.category).ui,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: cartoon ? AppColors.kawaiiLeafDeep : context.brandPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text((service.title).ui,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                              height: 1.2,
                              color: cartoon ? AppColors.kawaiiInk : null,
                              letterSpacing: -0.3,
                            ),
                          ),
                          if (ServiceVisuals.displayTagline(service).isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text((ServiceVisuals.displayTagline(service)).ui,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: cartoon ? AppColors.kawaiiMuted : Theme.of(context).colorScheme.onSurfaceVariant,
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
              ).animate().fadeIn(duration: 280.ms).scale(begin: const Offset(0.96, 0.96), curve: Curves.easeOutBack),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _PricePill(
                    label: '₺${service.price.toStringAsFixed(0)}',
                    color: cartoon ? AppColors.kawaiiLeaf : context.brandPrimary,
                  ),
                  _PricePill(
                    label: '${service.durationMinutes} dk',
                    color: cartoon ? AppColors.kawaiiSkyBlue : context.brandDeep,
                  ),
                  for (final t in service.tags)
                    Chip(
                      label: Text((t).ui, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: cartoon ? AppColors.kawaiiInk : null)),
                      backgroundColor: cartoon ? AppColors.kawaiiMint : null,
                      side: cartoon ? const BorderSide(color: AppColors.kawaiiOutline) : null,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text((service.description).ui,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                  fontSize: 14.5,
                  color: cartoon ? AppColors.kawaiiInk.withValues(alpha: 0.88) : null,
                ),
              ),
              const SizedBox(height: 20),
              Text(('Neler dahil?').ui,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: cartoon ? AppColors.kawaiiInk : null),
              ),
              const SizedBox(height: 10),
              for (var i = 0; i < service.bullets.length; i++)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: cartoon ? Colors.white : Theme.of(context).colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    border: cartoon ? Border.all(color: AppColors.kawaiiOutline) : null,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded, size: 20, color: cartoon ? AppColors.kawaiiLeaf : context.brandPrimary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text((service.bullets[i]).ui,
                          style: TextStyle(fontWeight: FontWeight.w700, color: cartoon ? AppColors.kawaiiInk : null),
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
                Material(
                  color: cartoon ? AppColors.kawaiiLeaf : context.brandPrimary,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: InkWell(
                    onTap: onRequest,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Center(
                        child: Text(('Randevu / satın alma talebi').ui,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                ),
              if (admin) ...[
                if (onEdit != null)
                  TextButton.icon(onPressed: onEdit, icon: const Icon(Icons.edit_rounded), label: Text(('Düzenle').ui)),
                if (onDelete != null)
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.kawaiiCoral),
                    label: Text(('Sil').ui, style: TextStyle(color: AppColors.kawaiiCoral)),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}
