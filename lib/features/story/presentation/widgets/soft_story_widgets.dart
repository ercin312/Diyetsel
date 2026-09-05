import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/diyetsel_assets.dart';
import '../../../dashboard/presentation/widgets/premium_home_widgets.dart' show SoftTap;
import '../../../dashboard/presentation/widgets/soft_home_widgets.dart' show SoftModernIcon;
import '../../domain/story_visuals.dart';
import '../../../../core/widgets/nav_back.dart';


class SoftStoryHeader extends StatelessWidget {
  const SoftStoryHeader({super.key, required this.onShare, required this.sharing});

  final VoidCallback? onShare;
  final bool sharing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SoftNavBackButton(),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hikaye kartı',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDeep,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Paylaşılabilir PNG kart',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0x991A4F45),
                ),
              ),
            ],
          ),
        ),
        SoftTap(
          onTap: onShare,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: sharing ? AppColors.primary.withValues(alpha: 0.5) : AppColors.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: sharing
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.28),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Icon(
              sharing ? Icons.hourglass_top_rounded : Icons.ios_share_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}

class SoftStoryHero extends StatelessWidget {
  const SoftStoryHero({super.key, required this.name, required this.tip});

  final String name;
  final String tip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF8E8), Color(0xFFFFF6E9), Color(0xFFE3F2F8)],
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    'Paylaşılabilir hikaye',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Merhaba $name',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    height: 1.15,
                    color: AppColors.primaryDeep,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tip,
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
            DiyetselAssets.modernIconStory,
            size: 64,
            fallback: Icons.auto_awesome_rounded,
            fallbackColor: const Color(0xFFD4A017),
          ),
        ],
      ),
    );
  }
}

class SoftStoryStatsRow extends StatelessWidget {
  const SoftStoryStatsRow({
    super.key,
    required this.templates,
    required this.streak,
    required this.waterPct,
    required this.badges,
  });

  final int templates;
  final int streak;
  final int waterPct;
  final int badges;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.dashboard_customize_rounded, DiyetselAssets.modernIconStory, const Color(0xFFD4A017), 'Şablon', '$templates'),
      (Icons.local_fire_department_rounded, DiyetselAssets.modernIconStreak, const Color(0xFFE07A5F), 'Seri', '$streak'),
      (Icons.water_drop_rounded, DiyetselAssets.modernIconWaterDrop, const Color(0xFF5BA3C9), 'Su', '%$waterPct'),
      (Icons.emoji_events_rounded, DiyetselAssets.modernIconCheck, AppColors.primary, 'Rozet', '$badges'),
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
                  Text(
                    items[i].$5,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: items[i].$3,
                    ),
                  ),
                  Text(
                    items[i].$4,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

class SoftStoryHowItWorksCard extends StatelessWidget {
  const SoftStoryHowItWorksCard({super.key});

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
          const Text(
            'Nasıl çalışır?',
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
                  child: Text(
                    '$i',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    StoryVisuals.howItWorks(i),
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

class SoftStoryTemplateChips extends StatelessWidget {
  const SoftStoryTemplateChips({
    super.key,
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
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: templates.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final t = templates[i];
          final on = i == selected;
          final accent = StoryVisuals.softAccentFor(t.id);
          return SoftTap(
            onTap: () => onSelect(i),
            borderRadius: BorderRadius.circular(999),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: on ? accent : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: on ? accent : AppColors.modernLine),
                boxShadow: on
                    ? [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.28),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : AppSpacing.soft,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    t.icon,
                    size: 16,
                    color: on ? Colors.white : accent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    t.chip,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                      color: on ? Colors.white : AppColors.primaryDeep,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class SoftStorySnapshotStrip extends StatelessWidget {
  const SoftStorySnapshotStrip({
    super.key,
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
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: templates.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final t = templates[i];
          final on = i == selected;
          final accent = StoryVisuals.softAccentFor(t.id);
          final tint = StoryVisuals.softTintFor(t.id);
          return SoftTap(
            onTap: () => onSelect(i),
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 112,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: on ? tint : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: on ? accent.withValues(alpha: 0.45) : AppColors.modernLine,
                  width: on ? 1.5 : 1,
                ),
                boxShadow: AppSpacing.soft,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SoftModernIcon(
                    StoryVisuals.softAssetFor(t.id),
                    size: 20,
                    fallback: t.icon,
                    fallbackColor: accent,
                  ),
                  const Spacer(),
                  Text(
                    t.statLabel ?? t.chip,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    t.statValue ?? '—',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: accent,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class SoftShareableCard extends StatelessWidget {
  const SoftShareableCard({
    super.key,
    required this.template,
    required this.userName,
    required this.dietitian,
  });

  final StoryTemplate template;
  final String userName;
  final String dietitian;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('d MMM y', 'tr').format(DateTime.now());
    final accent = StoryVisuals.softAccentFor(template.id);

    return Container(
      width: 320,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: template.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.22),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
                ),
                padding: const EdgeInsets.all(10),
                child: SoftModernIcon(
                  StoryVisuals.softAssetFor(template.id),
                  size: 28,
                  fallback: template.icon,
                  fallbackColor: Colors.white,
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'DİYETSEL',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    date,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              template.chip,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 11.5,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            userName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          Text(
            'Diyetisyen: $dietitian',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            template.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              height: 1.15,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            template.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  template.foot,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ),
              SoftModernIcon(
                DiyetselAssets.modernIconStory,
                size: 36,
                fallback: Icons.auto_awesome_rounded,
                fallbackColor: Colors.white.withValues(alpha: 0.9),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SoftStoryCaptionSection extends StatelessWidget {
  const SoftStoryCaptionSection({
    super.key,
    required this.captions,
    required this.selectedIndex,
    required this.caption,
    required this.onSelect,
  });

  final List<String> captions;
  final int selectedIndex;
  final String caption;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Paylaşım metni',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 15,
            color: AppColors.primaryDeep,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < captions.length; i++)
              SoftTap(
                onTap: () => onSelect(i),
                borderRadius: BorderRadius.circular(999),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: selectedIndex == i ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: selectedIndex == i ? AppColors.primary : AppColors.modernLine,
                    ),
                  ),
                  child: Text(
                    captions[i].length > 36 ? '${captions[i].substring(0, 34)}…' : captions[i],
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: selectedIndex == i ? Colors.white : AppColors.primaryDeep,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.modernLine),
            boxShadow: AppSpacing.soft,
          ),
          child: Text(
            caption,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              height: 1.35,
              color: AppColors.primary.withValues(alpha: 0.65),
            ),
          ),
        ),
      ],
    );
  }
}

class SoftStoryShareButton extends StatelessWidget {
  const SoftStoryShareButton({super.key, required this.sharing, required this.onShare});

  final bool sharing;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: onShare,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: sharing ? AppColors.primary.withValues(alpha: 0.5) : AppColors.primary,
          borderRadius: BorderRadius.circular(18),
          boxShadow: sharing
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              sharing ? Icons.hourglass_top_rounded : Icons.ios_share_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              sharing ? 'Hazırlanıyor…' : 'PNG paylaş',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SoftStoryPrivacyCard extends StatelessWidget {
  const SoftStoryPrivacyCard({super.key});

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
            fallback: Icons.lock_outline_rounded,
            fallbackColor: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Kartta yalnızca ismin, diyetisyen adı ve seçtiğin özet görünür. Sohbet, lab PDF’leri veya detaylı kilo grafiği paylaşılmaz.',
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

class SoftStoryPreviewFrame extends StatelessWidget {
  const SoftStoryPreviewFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Önizleme',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: AppColors.primaryDeep,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '1080×1920 uyumlu',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 10.5,
                    color: AppColors.primary.withValues(alpha: 0.65),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
