import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/diyetsel_assets.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/app_modules.dart';
import '../../../core/widgets/app_page.dart';
import '../../../core/widgets/kawaii_doodle.dart';
import '../../../core/widgets/module_gate.dart';
import '../../../core/widgets/style_icon.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../dashboard/presentation/widgets/premium_home_widgets.dart';
import '../domain/story_visuals.dart';
import 'soft_story_screen.dart';
import '../../../core/l10n/ui_string.dart';

class StoryCardScreen extends ConsumerStatefulWidget {
  const StoryCardScreen({super.key});

  @override
  ConsumerState<StoryCardScreen> createState() => _StoryCardScreenState();
}

class _StoryCardScreenState extends ConsumerState<StoryCardScreen> {
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
        ShareParams(files: [XFile(file.path)], text: caption));
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (context.isModern) {
      return const SoftStoryScreen();
    }

    final locked = lockedIfOff(ref, module: AppModule.story, title: 'Hikaye kartı');
    if (locked != null) return locked;

    final user = ref.watch(authControllerProvider).user!;
    final store = ref.watch(appStoreProvider);
    ref.watch(streaksProvider);
    ref.watch(waterLogsProvider);
    ref.watch(measurementsProvider);
    ref.watch(checkInsProvider);
    ref.watch(dietPlansProvider);

    final templates = StoryVisuals.buildTemplates(
      store: store,
      user: user,
      cartoon: true,
    );
    final t = templates[_template.clamp(0, templates.length - 1)];
    final captions = StoryVisuals.captionIdeas(t);
    final caption = captions[_captionIndex.clamp(0, captions.length - 1)];
    final dietitian = store.users().where((u) => u.isAdmin).firstOrNull?.displayName ?? 'Diyetisyen';

    return AppPage(
        title: 'Hikaye kartı',
        padding: EdgeInsets.zero,
        actions: [
          IconButton(
            tooltip: ('Paylaş').ui,
            onPressed: _sharing ? null : () => _share(caption),
            icon: const Icon(Icons.ios_share_rounded, color: AppColors.kawaiiLeafDeep)),
        ],
        child: ColoredBox(
          color: AppColors.kawaiiSurfaceCream,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            children: [
              _StoryHero(name: user.displayName)
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: -0.04, curve: Curves.easeOutCubic),
              const SizedBox(height: 14),
              _HowItWorksCard().animate().fadeIn(delay: 40.ms, duration: 280.ms),
              const SizedBox(height: 14),
              Text(('Şablon seç').ui,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5, color: AppColors.kawaiiInk)),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: templates.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final selected = i == _template;
                    return FilterChip(
                      selected: selected,
                      showCheckmark: false,
                      avatar: Icon(
                        templates[i].icon,
                        size: 16,
                        color: selected ? Colors.white : AppColors.kawaiiLeafDeep),
                      label: Text((templates[i].chip).ui,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                          color: selected ? Colors.white : AppColors.kawaiiInk)),
                      selectedColor: AppColors.kawaiiLeaf,
                      backgroundColor: Colors.white,
                      side: BorderSide(color: selected ? AppColors.kawaiiLeaf : AppColors.kawaiiOutline),
                      onSelected: (_) => setState(() {
                        _template = i;
                        _captionIndex = 0;
                      }));
                  })).animate().fadeIn(delay: 60.ms, duration: 280.ms),
              const SizedBox(height: 12),
              _SnapshotStrip(
                templates: templates,
                selected: _template,
                onSelect: (i) => setState(() {
                  _template = i;
                  _captionIndex = 0;
                }))
                  .animate()
                  .fadeIn(delay: 80.ms, duration: 280.ms),
              const SizedBox(height: 18),
              Center(
                child: RepaintBoundary(
                  key: _boundary,
                  child: _ShareableCard(
                    template: t,
                    userName: user.displayName,
                    dietitian: dietitian,
                    cartoon: true
                  )
                      .animate(key: ValueKey(t.id))
                      .fadeIn(duration: 280.ms)
                      .scale(begin: const Offset(0.94, 0.94), curve: Curves.easeOutBack, duration: 420.ms))),
              const SizedBox(height: 16),
              Text(('Paylaşım metni').ui,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.kawaiiInk)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < captions.length; i++)
                    ChoiceChip(
                      selected: _captionIndex == i,
                      label: Text((captions[i].length > 36 ? '${captions[i].substring(0, 34)}…' : captions[i]).ui,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: _captionIndex == i ? Colors.white : AppColors.kawaiiInk)),
                      selectedColor: AppColors.kawaiiLeaf,
                      backgroundColor: Colors.white,
                      side: BorderSide(color: _captionIndex == i ? AppColors.kawaiiLeaf : AppColors.kawaiiOutline),
                      onSelected: (_) => setState(() => _captionIndex = i)),
                ]),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.kawaiiOutline)),
                child: Text((caption).ui,
                  style: const TextStyle(fontWeight: FontWeight.w600, height: 1.35, color: AppColors.kawaiiMuted))),
              const SizedBox(height: 14),
              SoftTap(
                onTap: _sharing ? null : () => _share(caption),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: _sharing ? AppColors.kawaiiLeaf.withValues(alpha: 0.6) : AppColors.kawaiiLeaf,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: AppSpacing.soft),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_sharing ? Icons.hourglass_top_rounded : Icons.ios_share_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text((_sharing ? 'Hazırlanıyor…' : 'PNG paylaş').ui,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                    ]))),
              const SizedBox(height: 12),
              _PrivacyCard().animate().fadeIn(delay: 140.ms, duration: 280.ms),
            ],
          ),
        ),
      );
  }
}

class _StoryHero extends StatelessWidget {
  const _StoryHero({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 10, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.kawaiiLemon, AppColors.kawaiiSurfaceCream, AppColors.kawaiiLilac]),
        borderRadius: BorderRadius.circular(AppSpacing.radiusHero),
        border: Border.all(color: AppColors.kawaiiOutline),
        boxShadow: AppSpacing.soft),
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
                    borderRadius: BorderRadius.circular(20)),
                  child: Text(('Paylaşılabilir hikaye').ui,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: AppColors.kawaiiLeafDeep))),
                const SizedBox(height: 10),
                Text(('Merhaba $name').ui,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, height: 1.15, color: AppColors.kawaiiInk)),
                const SizedBox(height: 6),
                Text(('Canlı verinden kart üret — Instagram story, WhatsApp veya galeri için PNG.').ui,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 1.35, color: AppColors.kawaiiMuted)),
              ])),
          Image.asset(DiyetselAssets.mascotCarrot, height: 84, fit: BoxFit.contain),
        ]));
  }
}

class _HowItWorksCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.kawaiiOutline),
        boxShadow: AppSpacing.soft),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(('Nasıl çalışır?').ui, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.kawaiiInk)),
          const SizedBox(height: 10),
          for (var i = 1; i <= 3; i++) ...[
            if (i > 1) const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.kawaiiMint,
                    borderRadius: BorderRadius.circular(9)),
                  child: Text(('$i').ui, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppColors.kawaiiLeafDeep))),
                const SizedBox(width: 10),
                Expanded(
                  child: Text((StoryVisuals.howItWorks(i)).ui,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 1.35, color: AppColors.kawaiiInk))),
              ]),
          ],
        ]));
  }
}

class _SnapshotStrip extends StatelessWidget {
  const _SnapshotStrip({
    required this.templates,
    required this.selected,
    required this.onSelect,
  });

  final List<StoryTemplate> templates;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: templates.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final t = templates[i];
          final on = i == selected;
          return SoftTap(
            onTap: () => onSelect(i),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 108,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: on ? AppColors.kawaiiMint : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: on ? AppColors.kawaiiLeaf : AppColors.kawaiiOutline, width: on ? 1.5 : 1)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text((t.statLabel ?? t.chip).ui, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: AppColors.kawaiiMuted)),
                  const Spacer(),
                  Text((t.statValue ?? '—').ui,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.kawaiiInk)),
                ])));
        }));
  }
}

class _ShareableCard extends StatelessWidget {
  const _ShareableCard({
    required this.template,
    required this.userName,
    required this.dietitian,
    required this.cartoon,
  });

  final StoryTemplate template;
  final String userName;
  final String dietitian;
  final bool cartoon;

  @override
  Widget build(BuildContext context) {
    final onCard = cartoon ? AppColors.kawaiiInk : Colors.white;
    final onCardMuted = cartoon ? AppColors.kawaiiInk.withValues(alpha: 0.72) : Colors.white70;
    final date = DateFormat('d MMM y', 'tr').format(DateTime.now());

    return Container(
      width: 320,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: template.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(cartoon ? 30 : (22)),
        border: cartoon
            ? Border.all(color: Colors.white.withValues(alpha: 0.55), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: cartoon
                    ? AppColors.kawaiiGlow
                    : AppColors.modernSoftShadow,
            blurRadius: 24,
            offset: const Offset(0, 12)),
        ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (cartoon)
                KawaiiTile(kind: template.kind, size: 54)
              else
                ModernIconTile(kind: template.kind, color: Colors.white, size: 48, inverted: true),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(('DİYETSEL').ui,
                    style: TextStyle(
                      color: onCardMuted,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      fontSize: 12)),
                  Text((date).ui, style: TextStyle(color: onCardMuted, fontWeight: FontWeight.w600, fontSize: 11)),
                ]),
            ]),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: cartoon ? Colors.white.withValues(alpha: 0.75) : Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20)),
            child: Text((template.chip).ui,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: onCard))),
          const SizedBox(height: 12),
          Text((userName).ui,
            style: TextStyle(
              color: onCard,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3)),
          Text(('Diyetisyen: $dietitian').ui, style: TextStyle(color: onCardMuted, fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 18),
          Text((template.title).ui,
            style: TextStyle(
              color: onCard,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              height: 1.15,
              letterSpacing: -0.4)),
          const SizedBox(height: 6),
          Text((template.subtitle).ui,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: onCardMuted,
              fontWeight: FontWeight.w700,
              height: 1.35)),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text((template.foot).ui, style: TextStyle(color: onCardMuted, fontWeight: FontWeight.w600, fontSize: 12.5))),
              if (cartoon)
                Image.asset(DiyetselAssets.mascotAvocado, height: 44, fit: BoxFit.contain),
            ]),
        ]));
  }
}

class _PrivacyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.kawaiiOutline),
        boxShadow: AppSpacing.soft),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline_rounded, color: AppColors.kawaiiLeafDeep),
          SizedBox(width: 10),
          Expanded(
            child: Text(('Kartta yalnızca ismin, diyetisyen adı ve seçtiğin özet görünür. Sohbet, lab PDF’leri veya detaylı kilo grafiği paylaşılmaz.').ui,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, height: 1.35, color: AppColors.kawaiiMuted))),
        ]));
  }
}
