import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/constants/diyetsel_assets.dart';
import '../../../core/data/app_store.dart';
import '../../../core/data/providers.dart';
import '../../../core/models/models.dart';
import '../../../core/utils/desktop.dart';
import '../../../core/widgets/soft_desktop_frame.dart';
import '../../../core/widgets/soft_ui_kit.dart';
import '../../dashboard/presentation/widgets/premium_home_widgets.dart' show SoftTap;
import '../../dashboard/presentation/widgets/soft_home_widgets.dart' show SoftModernIcon;
import '../../../core/widgets/nav_back.dart';


/// Soft premium admin meal photo inbox.
class SoftAdminMealsScreen extends ConsumerWidget {
  const SoftAdminMealsScreen({super.key});

  static const _feedbacks = ['👏 Harika seçim', '⚠️ Porsiyon fazla', '💪 Devam'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(appStoreProvider);
    ref.watch(mealLogsProvider);
    final logs = [...store.mealLogs()]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final pending = logs.where((l) => l.feedbackNote == null).length;
    final desktop = context.isDesktopLayout;
    final pad = desktop
        ? EdgeInsets.fromLTRB(0, context.pagePadding.top, 0, context.pagePadding.bottom)
        : const EdgeInsets.fromLTRB(18, 12, 18, 28);

    return Scaffold(
      backgroundColor: AppColors.modernWash,
      body: SafeArea(
        child: SoftDesktopBody(
          child: ListView(
            padding: pad,
            children: [
              _Header()
                  .animate()
                  .fadeIn(duration: 280.ms)
                  .slideY(begin: -0.05, curve: Curves.easeOutCubic),
              const SizedBox(height: 12),
              SoftTipCard(
                title: pending > 0 ? 'Bekleyen geri bildirim' : 'Öğün kutusu',
                body: pending > 0
                    ? '$pending öğün yorum bekliyor — kısa ve net geri bildirim danışanı motive eder.'
                    : 'Gelen fotoğrafları buradan incele. Porsiyon ve dengeye odaklan.',
                icon: Icons.photo_camera_outlined,
                accent: const Color(0xFFE07A5F),
                tint: const Color(0xFFFFF0E8),
              ),
              const SizedBox(height: 14),
              _Hero(total: logs.length, pending: pending)
                  .animate()
                  .fadeIn(delay: 40.ms, duration: 300.ms)
                  .scale(
                    begin: const Offset(0.97, 0.97),
                    curve: Curves.easeOutCubic,
                    duration: 380.ms,
                  ),
              const SizedBox(height: 16),
              if (logs.isEmpty)
                _Empty()
              else if (desktop)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: logs.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: context.isExtraWide ? 3 : 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemBuilder: (_, i) => _MealCard(log: logs[i], store: store, index: i),
                )
              else
                for (var i = 0; i < logs.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _MealCard(log: logs[i], store: store, index: i)
                        .animate()
                        .fadeIn(delay: (70 + 16 * i).ms, duration: 260.ms)
                        .slideY(begin: 0.04, curve: Curves.easeOutCubic),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
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
                'Öğün günlüğü',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDeep,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Gelen fotoğraflara hızlı geri bildirim',
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
            DiyetselAssets.modernIconDietScale,
            size: 28,
            fallback: Icons.photo_camera_rounded,
            fallbackColor: Color(0xFF5BA3C9),
          ),
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.total, required this.pending});
  final int total;
  final int pending;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF8E8), Color(0xFFE8F5F0), Color(0xFFE3F2F8)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.modernLine),
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
                    color: const Color(0xFF5BA3C9).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Öğün inbox',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                      color: Color(0xFF3D7A96),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$total fotoğraf · $pending bekleyen not',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: AppColors.primaryDeep,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tek dokunuşla kısa geri bildirim gönder.',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.primaryDeep.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          const SoftModernIcon(
            DiyetselAssets.modernIconDietScale,
            size: 56,
            fallback: Icons.restaurant_rounded,
            fallbackColor: Color(0xFF5BA3C9),
          ),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({
    required this.log,
    required this.store,
    required this.index,
  });

  final MealPhotoLog log;
  final AppStore store;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFE8F5F0),
                child: Text(
                  log.clientName.isNotEmpty ? log.clientName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.clientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryDeep,
                      ),
                    ),
                    Text(
                      DateFormat('d MMM · HH:mm', 'tr').format(log.createdAt),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              if (log.stamp != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    log.stamp!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(log.photoPath),
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                height: 100,
                color: AppColors.modernWash,
                alignment: Alignment.center,
                child: Text(
                  'Görsel yüklenemedi',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary.withValues(alpha: 0.45),
                  ),
                ),
              ),
            ),
          ),
          if (log.caption?.isNotEmpty == true) ...[
            const SizedBox(height: 10),
            Text(
              log.caption!,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
                color: AppColors.primaryDeep,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final e in SoftAdminMealsScreen._feedbacks)
                SoftTap(
                  onTap: () async {
                    await store.saveMealLog(
                      log.copyWith(
                        feedbackEmoji: e.split(' ').first,
                        feedbackNote: e,
                      ),
                      countActivity: false,
                    );
                    await store.queueFeedbackNotification(
                      log.clientId,
                      'Diyetisyenin bugün senin için bir not bıraktı: $e',
                    );
                  },
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.modernWash,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.modernLine),
                    ),
                    child: Text(
                      e,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: AppColors.primaryDeep,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (log.feedbackNote != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Sen: ${log.feedbackNote}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
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
            DiyetselAssets.modernIconDietScale,
            size: 48,
            fallback: Icons.photo_outlined,
            fallbackColor: AppColors.primary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          const Text(
            'Henüz öğün fotoğrafı yok',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: AppColors.primaryDeep,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Danışanlar paylaşınca burada görünecek.',
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
