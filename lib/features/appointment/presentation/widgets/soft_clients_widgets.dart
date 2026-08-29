import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/diyetsel_assets.dart';
import '../../../../core/models/models.dart';
import '../../../dashboard/presentation/widgets/premium_home_widgets.dart' show SoftTap;
import '../../../dashboard/presentation/widgets/soft_home_widgets.dart' show SoftModernIcon;

class SoftClientsHeader extends StatelessWidget {
  const SoftClientsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Danışanlar',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDeep,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'CRM · su hedefi, aktiflik ve modüller',
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
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: AppColors.modernLine),
            boxShadow: AppSpacing.soft,
          ),
          padding: const EdgeInsets.all(10),
          child: const SoftModernIcon(
            DiyetselAssets.modernIconCheck,
            size: 32,
            fallback: Icons.groups_rounded,
            fallbackColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class SoftClientsHero extends StatelessWidget {
  const SoftClientsHero({
    super.key,
    required this.active,
    required this.total,
  });

  final int active;
  final int total;

  @override
  Widget build(BuildContext context) {
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
                    'Danışan listesi',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$active aktif · $total kayıt',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    height: 1.2,
                    color: AppColors.primaryDeep,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Bir danışana dokun: su, aktiflik ve bölümleri yönet.',
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
          const SoftModernIcon(
            DiyetselAssets.modernCardClinic,
            size: 64,
            fallback: Icons.person_rounded,
            fallbackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class SoftClientsSearchField extends StatelessWidget {
  const SoftClientsSearchField({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.primaryDeep,
        ),
        decoration: InputDecoration(
          hintText: 'İsim veya e-posta ara',
          hintStyle: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.primary.withValues(alpha: 0.4),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 4),
            child: SoftModernIcon(
              DiyetselAssets.modernIconSearch,
              size: 22,
              fallback: Icons.search_rounded,
              fallbackColor: AppColors.primary.withValues(alpha: 0.55),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }
}

class SoftClientTile extends StatelessWidget {
  const SoftClientTile({
    super.key,
    required this.client,
    required this.onTap,
  });

  final UserProfile client;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final liters = (client.waterGoalMl / 1000).toStringAsFixed(1);
    final initial = client.displayName.isNotEmpty ? client.displayName[0].toUpperCase() : '?';

    return SoftTap(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.modernLine),
          boxShadow: AppSpacing.soft,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: client.isActive
                  ? const Color(0xFFE8F5F0)
                  : const Color(0xFFFFF0E8),
              child: Text(
                initial,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: client.isActive ? AppColors.primary : const Color(0xFFE07A5F),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15.5,
                      color: AppColors.primaryDeep,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    client.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Su $liters L · hedef ${client.targetWeightKg ?? '-'} kg',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: AppColors.primary.withValues(alpha: 0.62),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: client.isActive
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : const Color(0xFFE07A5F).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    client.isActive ? 'aktif' : 'pasif',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      color: client.isActive ? AppColors.primary : const Color(0xFFC45A3C),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primary.withValues(alpha: 0.35),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SoftClientsEmpty extends StatelessWidget {
  const SoftClientsEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.modernLine),
      ),
      child: Column(
        children: [
          SoftModernIcon(
            DiyetselAssets.modernIconSearch,
            size: 48,
            fallback: Icons.search_off_rounded,
            fallbackColor: AppColors.primary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          const Text(
            'Danışan bulunamadı',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: AppColors.primaryDeep,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Aramayı değiştir veya listeyi yenile.',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primary.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class SoftClientsQuickLinks extends StatelessWidget {
  const SoftClientsQuickLinks({super.key});

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, String route, Color tint, IconData icon, String asset) {
      return Expanded(
        child: SoftTap(
          onTap: () => context.push(route),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.modernLine),
              boxShadow: AppSpacing.soft,
            ),
            child: Column(
              children: [
                SoftModernIcon(asset, size: 24, fallback: icon, fallbackColor: AppColors.primary),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: AppColors.primaryDeep,
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
        chip(
          'Bildirim',
          '/admin/notifications',
          const Color(0xFFFFF0E8),
          Icons.notifications_active_rounded,
          DiyetselAssets.modernIconBell,
        ),
        const SizedBox(width: 8),
        chip(
          'Öğün',
          '/admin/meals',
          const Color(0xFFE3F2F8),
          Icons.photo_camera_rounded,
          DiyetselAssets.modernIconDietScale,
        ),
        const SizedBox(width: 8),
        chip(
          'Diyet',
          '/admin/diet-plans',
          const Color(0xFFE8F5F0),
          Icons.restaurant_rounded,
          DiyetselAssets.modernIconPlan,
        ),
      ],
    ).animate().fadeIn(duration: 280.ms);
  }
}
