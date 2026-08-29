import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/diyetsel_assets.dart';
import '../../../core/models/models.dart';

class ServiceVisuals {
  ServiceVisuals._();

  static String imageFor(ServicePackage s) {
    if (s.imageUrl != null && s.imageUrl!.trim().isNotEmpty) return s.imageUrl!.trim();
    switch (s.id) {
      case 'svc-online':
        return DiyetselAssets.characterWoman;
      case 'svc-clinic':
        return DiyetselAssets.characterBoy;
      case 'svc-detox':
        return DiyetselAssets.foodGreenSmoothie;
      case 'svc-sport':
        return DiyetselAssets.characterActiveBoy;
      default:
        return DiyetselAssets.mascotAvocado;
    }
  }

  static Color tintFor(ServicePackage s) {
    switch (s.category) {
      case 'Online':
        return AppColors.kawaiiSky;
      case 'Klinik':
        return AppColors.kawaiiLilac;
      case 'Program':
        return AppColors.kawaiiMint;
      case 'Spor':
        return AppColors.kawaiiPeach;
      default:
        return AppColors.kawaiiSurfaceCream;
    }
  }

  /// Soft modern wash tint (cream / teal family).
  static Color softTintFor(ServicePackage s) {
    switch (s.category) {
      case 'Online':
        return const Color(0xFFE3F2F8);
      case 'Klinik':
        return const Color(0xFFE8F5F0);
      case 'Program':
        return const Color(0xFFFFF8E8);
      case 'Spor':
        return const Color(0xFFFFF0E8);
      default:
        return const Color(0xFFE8F5F0);
    }
  }

  static Color softAccentFor(ServicePackage s) {
    switch (s.category) {
      case 'Online':
        return const Color(0xFF5BA3C9);
      case 'Klinik':
        return AppColors.primary;
      case 'Program':
        return const Color(0xFFD4A017);
      case 'Spor':
        return const Color(0xFFE07A5F);
      default:
        return AppColors.primary;
    }
  }

  static IconData iconFor(ServicePackage s) {
    switch (s.category) {
      case 'Online':
        return Icons.videocam_rounded;
      case 'Klinik':
        return Icons.local_hospital_rounded;
      case 'Program':
        return Icons.auto_awesome_rounded;
      case 'Spor':
        return Icons.fitness_center_rounded;
      default:
        return Icons.medical_services_rounded;
    }
  }

  static String displayTagline(ServicePackage s) {
    if (s.tagline.trim().isNotEmpty) return s.tagline;
    return '${s.durationMinutes} dk · ${s.bullets.length} madde';
  }
}
