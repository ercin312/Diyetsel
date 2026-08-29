import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/models.dart';
import '../../auth/presentation/auth_controller.dart';
import 'widgets/soft_service_widgets.dart';

/// Soft premium modern services hub.
class SoftServicesScreen extends ConsumerStatefulWidget {
  const SoftServicesScreen({super.key, this.admin = false});

  final bool admin;

  @override
  ConsumerState<SoftServicesScreen> createState() => _SoftServicesScreenState();
}

class _SoftServicesScreenState extends ConsumerState<SoftServicesScreen> {
  String _filter = 'Tümü';

  @override
  Widget build(BuildContext context) {
    final services = ref.watch(servicesProvider).valueOrNull ?? [];
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    if (!widget.admin) ref.watch(serviceRequestsProvider);

    final active = services.where((e) => e.active || widget.admin).toList();
    final categories = ['Tümü', ...{for (final s in active) s.category.isEmpty ? 'Paket' : s.category}];
    final shown = _filter == 'Tümü'
        ? active
        : active.where((s) => (s.category.isEmpty ? 'Paket' : s.category) == _filter).toList();

    final catCount = {for (final s in active) s.category.isEmpty ? 'Paket' : s.category}.length;
    double? fromPrice;
    if (active.isNotEmpty) {
      fromPrice = active.map((e) => e.price).reduce((a, b) => a < b ? a : b);
    }

    return Scaffold(
      backgroundColor: AppColors.modernWash,
      floatingActionButton: widget.admin
          ? SoftServicesFab(onPressed: () => _edit(context, store))
          : null,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
          children: [
            SoftServicesHeader(admin: widget.admin)
                .animate()
                .fadeIn(duration: 280.ms)
                .slideY(begin: -0.05, curve: Curves.easeOutCubic),
            const SizedBox(height: 14),
            SoftServicesHero(count: active.length, fromPrice: fromPrice)
                .animate()
                .fadeIn(delay: 40.ms, duration: 300.ms)
                .scale(
                  begin: const Offset(0.97, 0.97),
                  curve: Curves.easeOutCubic,
                  duration: 380.ms,
                ),
            const SizedBox(height: 14),
            SoftServicesStatsRow(
              packages: active.length,
              categories: catCount,
              fromPrice: fromPrice,
            ).animate().fadeIn(delay: 70.ms, duration: 280.ms),
            const SizedBox(height: 14),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final c = categories.elementAt(i);
                  return SoftServiceCategoryChip(
                    label: c,
                    selected: c == _filter,
                    onTap: () => setState(() => _filter = c),
                  );
                },
              ),
            ).animate().fadeIn(delay: 90.ms, duration: 280.ms),
            const SizedBox(height: 16),
            if (shown.isEmpty)
              const SoftServicesEmpty()
            else ...[
              SoftServiceFeaturedCard(
                service: shown.first,
                admin: widget.admin,
                onOpen: () => _openDetail(context, store, user, shown.first),
              )
                  .animate()
                  .fadeIn(delay: 110.ms, duration: 320.ms)
                  .scale(begin: const Offset(0.96, 0.96), curve: Curves.easeOutBack),
              if (shown.length > 1) ...[
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Text(
                      'Tüm paketler',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        color: AppColors.primaryDeep,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${shown.length - 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 11.5,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                for (var i = 1; i < shown.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SoftServiceCard(
                      service: shown[i],
                      index: i,
                      admin: widget.admin,
                      onOpen: () => _openDetail(context, store, user, shown[i]),
                      onEdit: widget.admin ? () => _edit(context, store, shown[i]) : null,
                      onDelete: widget.admin ? () => store.deleteService(shown[i].id) : null,
                    ),
                  ),
              ],
            ],
            const SizedBox(height: 8),
            SoftServicesFooterTip(admin: widget.admin)
                .animate()
                .fadeIn(delay: 160.ms, duration: 280.ms),
          ],
        ),
      ),
    );
  }

  void _openDetail(
    BuildContext context,
    AppStore store,
    UserProfile user,
    ServicePackage service,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SoftServiceDetailSheet(
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
                    const SnackBar(content: Text('Talebiniz iletildi')),
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

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.modernWash,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hizmet',
          style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryDeep),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: title, decoration: const InputDecoration(labelText: 'Başlık')),
              TextField(controller: tagline, decoration: const InputDecoration(labelText: 'Kısa slogan')),
              TextField(controller: category, decoration: const InputDecoration(labelText: 'Kategori')),
              TextField(controller: desc, decoration: const InputDecoration(labelText: 'Açıklama'), maxLines: 3),
              TextField(
                controller: price,
                decoration: const InputDecoration(labelText: 'Fiyat'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: bullets,
                decoration: const InputDecoration(labelText: 'Madde (satır satır)'),
                maxLines: 4,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Vazgeç',
              style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary.withValues(alpha: 0.55)),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
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
            child: const Text('Kaydet', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
