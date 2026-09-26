import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/diyetsel_assets.dart';
import '../../../../core/utils/legal_links.dart';
import '../../../../core/models/app_modules.dart';
import '../../../../core/models/enums.dart';
import '../../domain/settings_visuals.dart';
import 'premium_home_widgets.dart' show SoftTap;
import 'soft_home_widgets.dart' show SoftModernIcon;
import '../../../../core/widgets/nav_back.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../core/l10n/ui_string.dart';


class SoftSettingsHeader extends StatelessWidget {
  const SoftSettingsHeader({super.key});

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
              Text(('Ayarlar').ui,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDeep,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 2),
              Text(('Tema, bildirimler ve hesap').ui,
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
          child: const SoftModernIcon(
            DiyetselAssets.modernIconAppsAll,
            size: 28,
            fallback: Icons.settings_rounded,
            fallbackColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class SoftSettingsProfileHero extends StatelessWidget {
  const SoftSettingsProfileHero({
    super.key,
    required this.name,
    required this.email,
    required this.roleLabel,
    required this.isAdmin,
    required this.tip,
    this.photoUrl,
    this.onAvatarTap,
  });

  final String name;
  final String email;
  final String roleLabel;
  final bool isAdmin;
  final String tip;
  final String? photoUrl;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isAdmin
              ? [SettingsVisuals.peach, SettingsVisuals.sky, SettingsVisuals.mint]
              : [SettingsVisuals.mint, const Color(0xFFFFF6E9), SettingsVisuals.sky],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(
                photoUrl: photoUrl,
                size: 54,
                onTap: onAvatarTap,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text((name).ui,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: AppColors.primaryDeep,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text((email).ui,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                        color: AppColors.primary.withValues(alpha: 0.58),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.modernLine),
                ),
                child: Text((roleLabel).ui,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5,
                    color: isAdmin ? SettingsVisuals.coral : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.modernLine.withValues(alpha: 0.7)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_rounded, size: 18, color: AppColors.primary.withValues(alpha: 0.75)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text((tip).ui,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      height: 1.35,
                      color: AppColors.primaryDeep.withValues(alpha: 0.88),
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

class SoftSettingsStatsRow extends StatelessWidget {
  const SoftSettingsStatsRow({
    super.key,
    required this.styleLabel,
    required this.reminderCount,
  });

  final String styleLabel;
  final int reminderCount;

  @override
  Widget build(BuildContext context) {
    Widget stat(String label, String value, IconData icon, Color accent, {String? asset}) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.modernLine),
            boxShadow: AppSpacing.soft,
          ),
          child: Column(
            children: [
              if (asset != null)
                SoftModernIcon(asset, size: 22, fallback: icon, fallbackColor: accent)
              else
                Icon(icon, size: 22, color: accent),
              const SizedBox(height: 6),
              Text((value).ui,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: accent),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text((label).ui,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        stat('Stil', styleLabel, Icons.palette_rounded, AppColors.primary,
            asset: DiyetselAssets.modernIconStory),
        const SizedBox(width: 8),
        stat('Bildirim', '$reminderCount', Icons.notifications_active_rounded, SettingsVisuals.coral,
            asset: DiyetselAssets.modernIconBell),
      ],
    );
  }
}

class SoftSettingsSectionTitle extends StatelessWidget {
  const SoftSettingsSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.asset,
    this.accent = AppColors.primary,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? asset;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null || asset != null) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: asset != null
                  ? SoftModernIcon(asset!, size: 20, fallback: icon ?? Icons.settings_rounded, fallbackColor: accent)
                  : Icon(icon, size: 20, color: accent),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text((title).ui,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: AppColors.primaryDeep,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text((subtitle!).ui,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                      height: 1.35,
                      color: AppColors.primary.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SoftSettingsCard extends StatelessWidget {
  const SoftSettingsCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: child,
    );
  }
}

class SoftSettingsStylePicker extends StatelessWidget {
  const SoftSettingsStylePicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final VisualStyle selected;
  final ValueChanged<VisualStyle> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget option({
      required VisualStyle style,
      required String title,
      required String subtitle,
      required String asset,
      required IconData icon,
      required Color accent,
      required Color tint,
    }) {
      final on = selected == style;
      return SoftTap(
        onTap: () => onChanged(style),
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: on
                ? LinearGradient(
                    colors: [tint, Colors.white],
                  )
                : null,
            color: on ? null : AppColors.modernWash,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: on ? accent.withValues(alpha: 0.45) : AppColors.modernLine,
              width: on ? 1.2 : 1,
            ),
            boxShadow: on ? AppSpacing.soft : null,
          ),
          child: Row(
            children: [
              SoftModernIcon(asset, size: 28, fallback: icon, fallbackColor: accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text((title).ui,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: on ? AppColors.primaryDeep : AppColors.primary.withValues(alpha: 0.75),
                      ),
                    ),
                    Text((subtitle).ui,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: AppColors.primary.withValues(alpha: 0.52),
                      ),
                    ),
                  ],
                ),
              ),
              if (on) Icon(Icons.check_circle_rounded, color: accent, size: 22),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        option(
          style: VisualStyle.modern,
          title: 'Modern',
          subtitle: 'Yumuşak wellness & sage',
          asset: DiyetselAssets.modernIconPlan,
          icon: Icons.dashboard_customize_rounded,
          accent: AppColors.primary,
          tint: SettingsVisuals.mint,
        ),
        const SizedBox(height: 10),
        option(
          style: VisualStyle.cartoon,
          title: 'Karikatür',
          subtitle: 'Krem & mercan yumuşak kawaii',
          asset: DiyetselAssets.modernIconStory,
          icon: Icons.sentiment_satisfied_alt_rounded,
          accent: SettingsVisuals.coral,
          tint: SettingsVisuals.peach,
        ),
      ],
    );
  }
}

class SoftSettingsLanguagePicker extends StatelessWidget {
  const SoftSettingsLanguagePicker({
    super.key,
    required this.languageCode,
    required this.onChanged,
  });

  final String languageCode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget chip(String code, String label, String flag) {
      final on = languageCode == code;
      return Expanded(
        child: SoftTap(
          onTap: () => onChanged(code),
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: on ? SettingsVisuals.sky : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: on ? SettingsVisuals.blue.withValues(alpha: 0.45) : AppColors.modernLine),
            ),
            child: Column(
              children: [
                Text((flag).ui, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 4),
                Text((label).ui,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: on ? SettingsVisuals.blueDeep : AppColors.primary.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        chip('tr', 'Türkçe', '🇹🇷'),
        const SizedBox(width: 10),
        chip('en', 'English', '🇬🇧'),
      ],
    );
  }
}

class SoftSettingsToggleRow extends StatelessWidget {
  const SoftSettingsToggleRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.icon = Icons.notifications_rounded,
    this.asset,
    this.accent = AppColors.primary,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData icon;
  final String? asset;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: asset != null
                ? SoftModernIcon(asset!, size: 22, fallback: icon, fallbackColor: accent)
                : Icon(icon, size: 20, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text((title).ui,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.primaryDeep,
                  ),
                ),
                Text((subtitle).ui,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: AppColors.primary.withValues(alpha: 0.52),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: accent.withValues(alpha: 0.4),
            activeThumbColor: accent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class SoftSettingsIntervalPicker extends StatelessWidget {
  const SoftSettingsIntervalPicker({
    super.key,
    required this.hours,
    required this.onChanged,
  });

  final int hours;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final h in [1, 2, 3, 4]) ...[
          if (h > 1) const SizedBox(width: 8),
          Expanded(
            child: SoftTap(
              onTap: () => onChanged(h),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: hours == h ? SettingsVisuals.sky : AppColors.modernWash,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: hours == h
                        ? SettingsVisuals.blue.withValues(alpha: 0.45)
                        : AppColors.modernLine,
                  ),
                ),
                child: Text(('$h sa').ui,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: hours == h ? SettingsVisuals.blueDeep : AppColors.primary.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class SoftSettingsAdminWaterCard extends StatelessWidget {
  const SoftSettingsAdminWaterCard({
    super.key,
    required this.liters,
    required this.ml,
    required this.onSlider,
    required this.onPreset,
    required this.onApplyAll,
  });

  final double liters;
  final int ml;
  final ValueChanged<double> onSlider;
  final ValueChanged<double> onPreset;
  final VoidCallback onApplyAll;

  @override
  Widget build(BuildContext context) {
    return SoftSettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SoftSettingsSectionTitle(
            title: 'Klinik su hedefi',
            subtitle: 'Yeni danışanlar bu litreyle başlar. Tek kişiyi Danışanlar’dan ayarlarsın.',
            icon: Icons.water_drop_rounded,
            asset: DiyetselAssets.modernIconWaterDrop,
            accent: SettingsVisuals.blue,
          ),
          Row(
            children: [
              const SoftModernIcon(
                DiyetselAssets.modernIconWaterBottle,
                size: 28,
                fallback: Icons.water_drop_rounded,
                fallbackColor: SettingsVisuals.blue,
              ),
              const SizedBox(width: 10),
              Text(('${liters.toStringAsFixed(2)} L  •  $ml ml').ui,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: AppColors.primaryDeep,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: SettingsVisuals.blue,
              thumbColor: SettingsVisuals.blue,
              inactiveTrackColor: SettingsVisuals.blue.withValues(alpha: 0.18),
            ),
            child: Slider(
              min: 1,
              max: 4,
              divisions: 12,
              value: liters.clamp(1, 4),
              label: '${liters.toStringAsFixed(2)} L',
              onChanged: onSlider,
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final preset in [1.5, 2.0, 2.5, 3.0, 3.5])
                ActionChip(
                  label: Text(('${preset.toStringAsFixed(1)} L').ui),
                  onPressed: () => onPreset(preset),
                ),
              ActionChip(
                avatar: const Icon(Icons.groups_rounded, size: 18),
                label: Text(('Tüm danışanlara uygula').ui),
                onPressed: onApplyAll,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SoftSettingsModuleRow extends StatelessWidget {
  const SoftSettingsModuleRow({
    super.key,
    required this.moduleId,
    required this.enabled,
    required this.onChanged,
  });

  final String moduleId;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SoftSettingsToggleRow(
      title: AppModule.label(moduleId),
      subtitle: AppModule.subtitle(moduleId),
      value: enabled,
      onChanged: onChanged,
      icon: AppModule.icon(moduleId),
      accent: AppColors.primary,
    );
  }
}

class SoftSettingsLegalLinks extends StatelessWidget {
  const SoftSettingsLegalLinks({super.key});

  @override
  Widget build(BuildContext context) {
    Widget row(IconData icon, String title, String subtitle, VoidCallback onTap) {
      return SoftTap(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: SettingsVisuals.mint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text((title).ui,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.primaryDeep,
                      ),
                    ),
                    Text((subtitle).ui,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.open_in_new_rounded, size: 16, color: AppColors.primary.withValues(alpha: 0.35)),
            ],
          ),
        ),
      );
    }

    return SoftSettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SoftSettingsSectionTitle(
            title: 'Yasal',
            subtitle: 'Gizlilik, destek ve kullanım şartları',
            icon: Icons.policy_rounded,
          ),
          row(Icons.privacy_tip_outlined, 'Gizlilik politikası', 'Verilerin nasıl işlendiği', LegalLinks.privacy),
          row(Icons.support_agent_rounded, 'Destek', AppConstants.supportEmail, LegalLinks.support),
          row(Icons.gavel_rounded, 'Kullanım şartları', 'Uygulama kullanım koşulları', LegalLinks.terms),
        ],
      ),
    );
  }
}

class SoftSettingsLogoutButton extends StatelessWidget {
  const SoftSettingsLogoutButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: SettingsVisuals.coral.withValues(alpha: 0.35)),
          boxShadow: AppSpacing.soft,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: SettingsVisuals.coral.withValues(alpha: 0.9)),
            const SizedBox(width: 8),
            Text(('Çıkış yap').ui,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: SettingsVisuals.coral.withValues(alpha: 0.95),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SoftSettingsDeleteAccountButton extends StatelessWidget {
  const SoftSettingsDeleteAccountButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftTap(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: SettingsVisuals.coral.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: SettingsVisuals.coral.withValues(alpha: 0.45)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_forever_rounded, color: SettingsVisuals.coral.withValues(alpha: 0.95)),
            const SizedBox(width: 8),
            Text(('Hesabı sil').ui,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: SettingsVisuals.coral.withValues(alpha: 0.98),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SoftSettingsFooterTip extends StatelessWidget {
  const SoftSettingsFooterTip({super.key, required this.admin});

  final bool admin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [SettingsVisuals.mint, SettingsVisuals.sky]),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.modernLine),
      ),
      child: Text((admin
            ? 'Klinik modül ve su hedefi değişiklikleri tüm danışan deneyimini etkiler — kaydetmeden önce kontrol et.'
            : 'Bildirim tercihlerin cihazında saklanır. Android’de izin vermediysen Ayarlar → Bildirimler’den aç.').ui,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
          height: 1.35,
          color: AppColors.primaryDeep.withValues(alpha: 0.82),
        ),
      ),
    );
  }
}
