import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/models.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/diyetsel_widgets.dart';
import '../../auth/presentation/auth_controller.dart';

class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key, this.admin = false});
  final bool admin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = ref.watch(servicesProvider).valueOrNull ?? [];
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    if (!admin) ref.watch(serviceRequestsProvider);
    return AppPage(
      title: 'Hizmetlerim',
      fab: admin
          ? FloatingActionButton(
              onPressed: () => _edit(context, store),
              child: const Icon(Icons.add),
            )
          : null,
      child: ListView(
        children: [
          for (final s in services.where((e) => e.active || admin))
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DiyetselCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(s.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))),
                        Text('₺${s.price.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900)),
                      ],
                    ),
                    Text(s.description),
                    const SizedBox(height: 8),
                    ...s.bullets.map((b) => Text('• $b')),
                    const SizedBox(height: 8),
                    Text('${s.durationMinutes} dk'),
                    const SizedBox(height: 8),
                    if (admin)
                      Row(
                        children: [
                          TextButton(onPressed: () => _edit(context, store, s), child: const Text('Düzenle')),
                          TextButton(onPressed: () => store.deleteService(s.id), child: const Text('Sil')),
                        ],
                      )
                    else
                      DiyetselButton(
                        label: 'Randevu / satın alma talebi',
                        onPressed: () async {
                          await store.saveServiceRequest(
                            ServiceRequest(
                              id: newId(),
                              clientId: user.id,
                              clientName: user.displayName,
                              serviceId: s.id,
                              serviceTitle: s.title,
                              status: 'pending',
                              createdAt: DateTime.now(),
                            ),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Talebiniz iletildi')));
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context, AppStore store, [ServicePackage? existing]) async {
    final title = TextEditingController(text: existing?.title ?? '');
    final desc = TextEditingController(text: existing?.description ?? '');
    final price = TextEditingController(text: existing?.price.toString() ?? '');
    final bullets = TextEditingController(text: existing?.bullets.join('\n') ?? '');
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Yeni hizmet' : 'Hizmeti düzenle'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: title, decoration: const InputDecoration(labelText: 'Başlık')),
              TextField(controller: desc, decoration: const InputDecoration(labelText: 'Açıklama')),
              TextField(controller: price, decoration: const InputDecoration(labelText: 'Fiyat')),
              TextField(controller: bullets, decoration: const InputDecoration(labelText: 'Madde (satır satır)'), maxLines: 4),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () async {
              await store.saveService(
                ServicePackage(
                  id: existing?.id ?? newId(),
                  title: title.text,
                  description: desc.text,
                  price: double.tryParse(price.text) ?? 0,
                  durationMinutes: existing?.durationMinutes ?? 45,
                  bullets: bullets.text.split('\n').where((e) => e.trim().isNotEmpty).toList(),
                ),
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}
