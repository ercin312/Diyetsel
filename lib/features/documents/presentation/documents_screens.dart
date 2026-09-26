import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/diyetsel_assets.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/models.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/diyetsel_widgets.dart';
import '../../../core/widgets/soft_ui_kit.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../dashboard/presentation/widgets/premium_home_widgets.dart';
import '../domain/vault_io.dart';
import '../../../core/l10n/ui_string.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  String _filter = 'Tümü';

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(documentsProvider);

    final files = user.isAdmin
        ? store.users().where((u) => !u.isAdmin).expand((u) {
            return store.documents(u.id).map(
                  (f) => f.ownerName.isEmpty ? f.copyWith(ownerName: u.displayName) : f,
                );
          }).toList()
        : store.documents(user.id);
    files.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));

    final categories = [
      'Tümü',
      ...VaultVisuals.categories.where((c) => files.any((f) => f.category == c)),
    ];
    final shown = _filter == 'Tümü' ? files : files.where((f) => f.category == _filter).toList();
    final cartoon = context.isCartoon;

    if (cartoon) {
      return AppPage(
        title: 'Belge kasası',
        padding: EdgeInsets.zero,
        fab: FloatingActionButton(
          backgroundColor: AppColors.kawaiiLeaf,
          onPressed: () => _upload(context, store, user),
          child: const Icon(Icons.upload_file_rounded, color: Colors.white),
        ),
        child: ColoredBox(
          color: AppColors.kawaiiSurfaceCream,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 88),
            children: [
              _VaultHero(count: files.length, admin: user.isAdmin)
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: -0.04, curve: Curves.easeOutCubic),
              const SizedBox(height: 14),
              _PurposeCard().animate().fadeIn(delay: 40.ms, duration: 280.ms),
              const SizedBox(height: 14),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final c = categories[i];
                    final selected = c == _filter;
                    final label = c == 'Tümü' ? 'Tümü' : VaultVisuals.label(c);
                    return FilterChip(
                      selected: selected,
                      showCheckmark: false,
                      avatar: c == 'Tümü'
                          ? null
                          : Icon(
                              VaultVisuals.iconFor(c),
                              size: 16,
                              color: selected ? Colors.white : VaultVisuals.accentFor(c),
                            ),
                      label: Text((label).ui,
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
              if (files.isEmpty)
                _EmptyVault(onUpload: () => _upload(context, store, user))
                    .animate()
                    .fadeIn(duration: 320.ms)
                    .scale(begin: const Offset(0.96, 0.96))
              else if (shown.isEmpty)
                Padding(
                  padding: EdgeInsets.all(28),
                  child: Text(('Bu kategoride belge yok.').ui,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.kawaiiMuted),
                  ),
                )
              else
                for (var i = 0; i < shown.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _CartoonDocCard(
                      file: shown[i],
                      showOwner: user.isAdmin,
                      onOpen: () => VaultIO.open(context, shown[i]),
                      onMore: () => _openDetail(context, store, user, shown[i]),
                    )
                        .animate()
                        .fadeIn(delay: (40 * i).ms, duration: 280.ms)
                        .slideY(begin: 0.04, curve: Curves.easeOutCubic),
                  ),
              const SizedBox(height: 8),
              _TipsFooter().animate().fadeIn(delay: 160.ms, duration: 280.ms),
            ],
          ),
        ),
      );
    }

    return AppPage(
      title: 'Belge kasası',
      padding: context.isModern ? EdgeInsets.zero : null,
      fab: FloatingActionButton.extended(
        onPressed: () => _upload(context, store, user),
        icon: const Icon(Icons.upload_file_rounded),
        label: Text(('Yükle').ui, style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      child: context.isModern
          ? SoftWashBackground(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
                children: [
                  SoftSurfaceCard(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                    color: AppColors.modernMint,
                    child: Row(
                      children: [
                        SoftProgressRing(
                          progress: files.isEmpty ? 0 : 1,
                          color: AppColors.primary,
                          child: Text(('${files.length}').ui,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: AppColors.primaryDeep,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text((user.isAdmin ? 'Klinik belge kasası' : 'Güvenli belge kasası').ui,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: AppColors.primaryDeep,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(('Lab, plan PDF ve formlar — tek yerde sakla, aç, paylaş.').ui,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.5,
                                  color: AppColors.primary.withValues(alpha: 0.55),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 280.ms),
                  const SizedBox(height: 12),
                  SoftTipCard(
                    title: 'Dosya ipucu',
                    body: 'PDF ve net fotoğraflar en iyi sonucu verir. Kategori etiketi eklemek aramayı kolaylaştırır.',
                    icon: Icons.folder_special_outlined,
                    accent: AppColors.primary,
                    tint: Colors.white,
                  ),
                  const SizedBox(height: 14),
                  SoftChipRail(
                    labels: [
                      for (final c in categories) c == 'Tümü' ? 'Tümü' : VaultVisuals.label(c),
                    ],
                    selectedIndex: categories.indexOf(_filter).clamp(0, categories.length - 1),
                    onSelected: (i) => setState(() => _filter = categories[i]),
                  ),
                  const SizedBox(height: 16),
                  if (files.isEmpty)
                    SoftEmptyRich(
                      title: 'Henüz belge yok',
                      body: 'Lab sonucu veya diyet planı PDF’ini yükleyerek başla.',
                      icon: Icons.folder_open_rounded,
                      actionLabel: 'Belge yükle',
                      onAction: () => _upload(context, store, user),
                    )
                  else if (shown.isEmpty)
                    SoftEmptyRich(
                      title: 'Bu kategoride yok',
                      body: 'Başka bir filtre dene veya yeni belge yükle.',
                      icon: Icons.filter_alt_outlined,
                    )
                  else
                    for (var i = 0; i < shown.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SoftSurfaceCard(
                          onTap: () => VaultIO.open(context, shown[i]),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.modernMint,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  VaultVisuals.iconForFile(shown[i]),
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text((shown[i].name).ui,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primaryDeep,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(([
                                        VaultVisuals.label(shown[i].category),
                                        DateFormat('d MMM y', 'tr').format(shown[i].uploadedAt),
                                        if (user.isAdmin && shown[i].ownerName.isNotEmpty) shown[i].ownerName,
                                      ].join(' · ')).ui,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        color: AppColors.primary.withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => _openDetail(context, store, user, shown[i]),
                                icon: const Icon(Icons.more_horiz_rounded),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: (30 * i).ms, duration: 260.ms),
                      ),
                ],
              ),
            )
          : ListView(
              children: [
                FeatureBanner(
                  icon: Icons.folder_special_rounded,
                  emoji: '📁',
                  title: 'Güvenli belge kasası',
                  subtitle:
                      'Lab sonuçları, diyet planı PDF’leri ve formları burada sakla; dokunarak aç veya paylaş.',
                ),
                const SizedBox(height: 12),
                if (files.isEmpty)
                  EmptyState(
                    icon: Icons.folder_open_rounded,
                    title: 'Henüz belge yok',
                    subtitle: 'Yükle butonuyla PDF, fotoğraf veya Word ekle.',
                  )
                else
                  for (final f in shown.isEmpty ? files : shown)
                    DiyetselCard(
                      onTap: () => VaultIO.open(context, f),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(VaultVisuals.iconForFile(f), color: context.brandPrimary),
                        title: Text((f.name).ui, style: const TextStyle(fontWeight: FontWeight.w800)),
                        subtitle: Text(([
                            VaultVisuals.label(f.category),
                            DateFormat('d MMM y HH:mm', 'tr').format(f.uploadedAt),
                            if (user.isAdmin && f.ownerName.isNotEmpty) f.ownerName,
                          ].join(' · ')).ui,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.more_horiz_rounded),
                          onPressed: () => _openDetail(context, store, user, f),
                        ),
                      ),
                    ),
              ],
            ),
    );
  }

  Future<void> _upload(BuildContext context, AppStore store, UserProfile user) async {
    final meta = await showModalBottomSheet<_UploadMeta>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _UploadSheet(),
    );
    if (meta == null || !context.mounted) return;

    final picked = await FilePicker.pickFiles();
    if (picked.isEmpty || picked.first.path == null) return;
    final file = picked.first;
    final id = newId();
    try {
      final persisted = await VaultIO.persistPickedFile(
        sourcePath: file.path!,
        id: id,
        originalName: file.name,
      );
      final mime = file.name.contains('.') ? file.name.split('.').last.toLowerCase() : 'file';
      final category = meta.category == 'auto' ? VaultVisuals.guessCategory(file.name, mime) : meta.category;
      await store.saveDocument(
        VaultFile(
          id: id,
          userId: user.id,
          name: file.name,
          path: persisted.path,
          mime: mime,
          uploadedAt: DateTime.now(),
          category: category,
          note: meta.note,
          sizeBytes: await persisted.length(),
          ownerName: user.displayName,
        ),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(('Belge kasaya eklendi').ui)),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(('Dosya kaydedilemedi').ui)),
        );
      }
    }
  }

  void _openDetail(BuildContext context, AppStore store, UserProfile user, VaultFile file) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DocDetailSheet(
        file: file,
        onOpen: () async {
          Navigator.pop(ctx);
          await VaultIO.open(context, file);
        },
        onShare: () async {
          await VaultIO.share(file);
        },
        onDelete: () async {
          await VaultIO.deleteLocal(file);
          await store.deleteDocument(file.id);
          if (ctx.mounted) Navigator.pop(ctx);
        },
      ),
    );
  }
}

class _UploadMeta {
  const _UploadMeta({required this.category, required this.note});
  final String category;
  final String note;
}

class _VaultHero extends StatelessWidget {
  const _VaultHero({required this.count, required this.admin});

  final int count;
  final bool admin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 10, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.kawaiiLilac, AppColors.kawaiiSurfaceCream, AppColors.kawaiiSky],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
        border: Border.all(color: AppColors.kawaiiOutline),
        boxShadow: AppSpacing.soft,
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
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text((admin ? 'Danışan belgeleri' : 'Kişisel kasa').ui,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: AppColors.kawaiiLeafDeep),
                  ),
                ),
                const SizedBox(height: 10),
                Text((count == 0 ? 'Kasayı doldurmaya başla' : '$count belge hazır').ui,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, height: 1.15, color: AppColors.kawaiiInk),
                ),
                const SizedBox(height: 6),
                Text(('Lab sonuçları, plan PDF’leri ve formlar — tek yerde, dokununca açılır.').ui,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 1.35, color: AppColors.kawaiiMuted),
                ),
              ],
            ),
          ),
          Image.asset(DiyetselAssets.mascotAvocado, height: 84, fit: BoxFit.contain),
        ],
      ),
    );
  }
}

class _PurposeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = VaultVisuals.categories;
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
          Text(('Ne için kullanılır?').ui,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.kawaiiInk),
          ),
          const SizedBox(height: 4),
          Text(('Diyetisyeninle paylaşacağın veya saklamak istediğin dosyalar için güvenli klasör.').ui,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, height: 1.35, color: AppColors.kawaiiMuted),
          ),
          const SizedBox(height: 12),
          for (final c in items) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: VaultVisuals.tintFor(c),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(VaultVisuals.iconFor(c), size: 18, color: VaultVisuals.accentFor(c)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text((VaultVisuals.label(c)).ui, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                        Text((VaultVisuals.hint(c)).ui, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11.5, color: AppColors.kawaiiMuted)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CartoonDocCard extends StatelessWidget {
  const _CartoonDocCard({
    required this.file,
    required this.showOwner,
    required this.onOpen,
    required this.onMore,
  });

  final VaultFile file;
  final bool showOwner;
  final VoidCallback onOpen;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final tint = VaultVisuals.tintFor(file.category);
    final accent = VaultVisuals.accentFor(file.category);
    final size = VaultVisuals.formatSize(file.sizeBytes);

    return SoftTap(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(color: AppColors.kawaiiOutline),
          boxShadow: AppSpacing.soft,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(16)),
              child: Icon(VaultVisuals.iconForFile(file), color: accent, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text((file.name).ui,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.kawaiiInk),
                  ),
                  const SizedBox(height: 3),
                  Text(([
                      VaultVisuals.label(file.category),
                      DateFormat('d MMM y', 'tr').format(file.uploadedAt),
                      if (size.isNotEmpty) size,
                      if (showOwner && file.ownerName.isNotEmpty) file.ownerName,
                    ].join(' · ')).ui,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.kawaiiMuted),
                  ),
                  if (file.note.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text((file.note).ui,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.kawaiiLeafDeep),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              onPressed: onMore,
              icon: const Icon(Icons.more_horiz_rounded, color: AppColors.kawaiiMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyVault extends StatelessWidget {
  const _EmptyVault({required this.onUpload});

  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.kawaiiOutline),
        boxShadow: AppSpacing.soft,
      ),
      child: Column(
        children: [
          Image.asset(DiyetselAssets.mascotCarrot, height: 88),
          const SizedBox(height: 12),
          Text(('Kasa henüz boş').ui,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.kawaiiInk),
          ),
          const SizedBox(height: 6),
          Text(('İlk lab sonucunu veya plan PDF’ini yükle. Dosyalar uygulamada saklanır; dokunarak açabilir veya paylaşabilirsin.').ui,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, height: 1.4, color: AppColors.kawaiiMuted),
          ),
          const SizedBox(height: 16),
          SoftTap(
            onTap: onUpload,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.kawaiiLeaf,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(('Belge yükle').ui,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipsFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.kawaiiOutline),
        boxShadow: AppSpacing.soft,
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline_rounded, color: AppColors.kawaiiLeafDeep),
          SizedBox(width: 10),
          Expanded(
            child: Text(('Dosyalar cihazındaki uygulama klasöründe tutulur. PDF ve görseller dokununca açılır; diğerleri paylaşım menüsüyle açılır.').ui,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 1.35, color: AppColors.kawaiiMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocDetailSheet extends StatelessWidget {
  const _DocDetailSheet({
    required this.file,
    required this.onOpen,
    required this.onShare,
    required this.onDelete,
  });

  final VaultFile file;
  final VoidCallback onOpen;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cartoon = context.isCartoon;
    final tint = VaultVisuals.tintFor(file.category);
    final accent = VaultVisuals.accentFor(file.category);
    final size = VaultVisuals.formatSize(file.sizeBytes);

    return Container(
      decoration: BoxDecoration(
        color: cartoon ? AppColors.kawaiiCream : Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(color: AppColors.kawaiiOutline, borderRadius: BorderRadius.circular(99)),
            ),
          ),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(16)),
                child: Icon(VaultVisuals.iconForFile(file), color: accent, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text((file.name).ui,
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: cartoon ? AppColors.kawaiiInk : null),
                    ),
                    const SizedBox(height: 4),
                    Text(([
                        VaultVisuals.label(file.category),
                        DateFormat('d MMM y HH:mm', 'tr').format(file.uploadedAt),
                        if (size.isNotEmpty) size,
                      ].join(' · ')).ui,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                        color: cartoon ? AppColors.kawaiiMuted : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (file.note.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text((file.note).ui, style: const TextStyle(fontWeight: FontWeight.w600, height: 1.4)),
          ],
          const SizedBox(height: 18),
          SoftTap(
            onTap: onOpen,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: cartoon ? AppColors.kawaiiLeaf : context.brandPrimary,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(('Belgeyi aç').ui,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onShare,
                  icon: const Icon(Icons.ios_share_rounded),
                  label: Text(('Paylaş').ui),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UploadSheet extends StatefulWidget {
  const _UploadSheet();

  @override
  State<_UploadSheet> createState() => _UploadSheetState();
}

class _UploadSheetState extends State<_UploadSheet> {
  String _category = 'auto';
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartoon = context.isCartoon;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: BoxDecoration(
          color: cartoon ? AppColors.kawaiiCream : Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(color: AppColors.kawaiiOutline, borderRadius: BorderRadius.circular(99)),
                ),
              ),
              Text(('Belge yükle').ui,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: cartoon ? AppColors.kawaiiInk : null),
              ),
              const SizedBox(height: 6),
              Text(('Kategori seç, isteğe bağlı not ekle; sonra dosyayı seç.').ui,
                style: TextStyle(fontWeight: FontWeight.w600, color: cartoon ? AppColors.kawaiiMuted : null),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    selected: _category == 'auto',
                    label: Text(('Otomatik').ui),
                    onSelected: (_) => setState(() => _category = 'auto'),
                  ),
                  for (final c in VaultVisuals.categories)
                    ChoiceChip(
                      selected: _category == c,
                      label: Text((VaultVisuals.label(c)).ui),
                      onSelected: (_) => setState(() => _category = c),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _note,
                decoration: InputDecoration(
                  labelText: ('Not (opsiyonel)').ui,
                  hintText: ('Örn. Mart 2026 kan tahlili').ui,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => Navigator.pop(
                  context,
                  _UploadMeta(category: _category, note: _note.text.trim()),
                ),
                icon: const Icon(Icons.folder_open_rounded),
                label: Text(('Dosya seç').ui),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
