import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/app_modules.dart';
import '../../../core/widgets/module_gate.dart';
import '../../../core/widgets/soft_ui_kit.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/story_visuals.dart';
import 'widgets/soft_story_widgets.dart';
import '../../../core/l10n/ui_string.dart';

/// Soft premium modern story card — şablon, önizleme, paylaşım.
class SoftStoryScreen extends ConsumerStatefulWidget {
  const SoftStoryScreen({super.key});

  @override
  ConsumerState<SoftStoryScreen> createState() => _SoftStoryScreenState();
}

class _SoftStoryScreenState extends ConsumerState<SoftStoryScreen> {
  final _boundary = GlobalKey();
  int _template = 0;
  int _captionIndex = 0;
  bool _sharing = false;

  Future<void> _share(String caption) async {
    setState(() => _sharing = true);
    try {
      final boundary = _boundary.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/diyetsel-hikaye.png');
      await file.writeAsBytes(bytes.buffer.asUint8List());
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: caption),
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
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
    ref.watch(checkInsProvider);
    ref.watch(dietPlansProvider);

    final templates = StoryVisuals.buildTemplates(store: store, user: user, cartoon: false);
    final t = templates[_template.clamp(0, templates.length - 1)];
    final captions = StoryVisuals.captionIdeas(t);
    final caption = captions[_captionIndex.clamp(0, captions.length - 1)];
    final dietitian = store.users().where((u) => u.isAdmin).firstOrNull?.displayName ?? 'Diyetisyen';

    final streak = store.streak(user.id).current;
    final waterPct = (store.waterLog(user.id, DateTime.now()).progress * 100).round();
    final badgeCount = store.userProgress(user.id).earnedBadgeIds.length;

    return Scaffold(
      backgroundColor: AppColors.modernWash,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          children: [
            SoftStoryHeader(
              sharing: _sharing,
              onShare: _sharing ? null : () => _share(caption),
            )
                .animate()
                .fadeIn(duration: 280.ms)
                .slideY(begin: -0.05, curve: Curves.easeOutCubic),
            const SizedBox(height: 14),
            SoftStoryHero(
              name: user.displayName,
              tip: StoryVisuals.tipOfDay(DateTime.now().day),
            )
                .animate()
                .fadeIn(delay: 40.ms, duration: 300.ms)
                .scale(
                  begin: const Offset(0.97, 0.97),
                  curve: Curves.easeOutCubic,
                  duration: 380.ms,
                ),
            const SizedBox(height: 12),
            SoftStoryStatsRow(
              templates: templates.length,
              streak: streak,
              waterPct: waterPct,
              badges: badgeCount,
            ).animate().fadeIn(delay: 60.ms, duration: 280.ms),
            const SizedBox(height: 12),
            SoftTipCard(
              title: 'Paylaşım etkisi',
              body: 'Hikaye kartını hikâyene eklemek sosyal hesap verebilirliği artırır — seriyi bozmamak için ekstra motivasyon.',
              icon: Icons.auto_awesome_rounded,
              accent: AppColors.primary,
              tint: AppColors.modernMint,
            ),
            const SizedBox(height: 14),
            const SoftStoryHowItWorksCard()
                .animate()
                .fadeIn(delay: 75.ms, duration: 280.ms),
            const SizedBox(height: 16),
            Text(('Şablon seç').ui,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: AppColors.primaryDeep,
              ),
            ),
            const SizedBox(height: 8),
            SoftStoryTemplateChips(
              templates: templates,
              selected: _template,
              onSelect: (i) => setState(() {
                _template = i;
                _captionIndex = 0;
              }),
            ).animate().fadeIn(delay: 90.ms, duration: 280.ms),
            const SizedBox(height: 12),
            SoftStorySnapshotStrip(
              templates: templates,
              selected: _template,
              onSelect: (i) => setState(() {
                _template = i;
                _captionIndex = 0;
              }),
            ).animate().fadeIn(delay: 105.ms, duration: 280.ms),
            const SizedBox(height: 18),
            Center(
              child: SoftStoryPreviewFrame(
                child: RepaintBoundary(
                  key: _boundary,
                  child: SoftShareableCard(
                    template: t,
                    userName: user.displayName,
                    dietitian: dietitian,
                  ),
                ),
              )
                  .animate(key: ValueKey(t.id))
                  .fadeIn(duration: 280.ms)
                  .scale(
                    begin: const Offset(0.94, 0.94),
                    curve: Curves.easeOutBack,
                    duration: 420.ms,
                  ),
            ),
            const SizedBox(height: 16),
            SoftStoryCaptionSection(
              captions: captions,
              selectedIndex: _captionIndex,
              caption: caption,
              onSelect: (i) => setState(() => _captionIndex = i),
            ).animate().fadeIn(delay: 120.ms, duration: 280.ms),
            const SizedBox(height: 14),
            SoftStoryShareButton(
              sharing: _sharing,
              onShare: _sharing ? null : () => _share(caption),
            ).animate().fadeIn(delay: 140.ms, duration: 280.ms),
            const SizedBox(height: 12),
            const SoftStoryPrivacyCard()
                .animate()
                .fadeIn(delay: 160.ms, duration: 280.ms),
          ],
        ),
      ),
    );
  }
}
