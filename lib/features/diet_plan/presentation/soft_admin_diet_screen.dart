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


/// Soft premium admin diet plans hub.
class SoftAdminDietScreen extends ConsumerWidget {
  const SoftAdminDietScreen({super.key, required this.onOpenUpload});

  final VoidCallback onOpenUpload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(dietPlansProvider);
    final store = ref.watch(appStoreProvider);
    final plans = [...store.dietPlans()]
      ..sort((a, b) => b.weekStart.compareTo(a.weekStart));
    final desktop = context.isDesktopLayout;
    final pad = desktop
        ? EdgeInsets.fromLTRB(0, context.pagePadding.top, 0, 100)
        : const EdgeInsets.fromLTRB(18, 12, 18, 100);

    return Scaffold(
      backgroundColor: AppColors.modernWash,
      floatingActionButton: SoftTap(
        onTap: onOpenUpload,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.28),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.upload_file_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Word yükle',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
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
              title: 'Plan atama',
              body: plans.isEmpty
                  ? 'Word’den plan yükle veya oluştur; danışana ata ve haftalık takibi aç.'
                  : '${plans.length} plan hazır. Sessiz danışanlara yeni haftalık plan atamak bağlılığı güçlendirir.',
              icon: Icons.assignment_outlined,
              accent: AppColors.primary,
              tint: AppColors.modernMint,
            ),
            const SizedBox(height: 14),
            SoftTap(
              onTap: onOpenUpload,
              borderRadius: BorderRadius.circular(26),
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFE8F5F0), Color(0xFFFFF8E8), Color(0xFFE3F2F8)],
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
                              'Word ile plan ata',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 11.5,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Doküman yükle',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              color: AppColors.primaryDeep,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Kahvaltı, ara öğün, öğle… başlıklı .docx seç veya sürükle.',
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
                      DiyetselAssets.modernIconPlan,
                      size: 64,
                      fallback: Icons.description_rounded,
                      fallbackColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 40.ms, duration: 300.ms)
                .scale(
                  begin: const Offset(0.97, 0.97),
                  curve: Curves.easeOutCubic,
                  duration: 380.ms,
                ),
            const SizedBox(height: 18),
            Text(
              'Atanmış planlar',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 17,
                color: AppColors.primaryDeep,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Danışanlara yüklenen haftalık listeler',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 12),
            if (plans.isEmpty)
              _Empty()
            else if (desktop)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: plans.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: context.isExtraWide ? 3 : 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.8,
                ),
                itemBuilder: (_, i) => _PlanTile(plan: plans[i])
                    .animate()
                    .fadeIn(delay: (70 + 18 * i).ms, duration: 260.ms),
              )
            else
              for (var i = 0; i < plans.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _PlanTile(plan: plans[i])
                      .animate()
                      .fadeIn(delay: (70 + 18 * i).ms, duration: 260.ms)
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
                'Diyet planları',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryDeep,
                  letterSpacing: -0.4,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Word yükle ve danışana ata',
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
            DiyetselAssets.modernIconPlan,
            size: 28,
            fallback: Icons.restaurant_rounded,
            fallbackColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({required this.plan});
  final DietPlan plan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.modernLine),
        boxShadow: AppSpacing.soft,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5F0),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              plan.clientName.isNotEmpty ? plan.clientName[0].toUpperCase() : '?',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.clientName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15.5,
                    color: AppColors.primaryDeep,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  plan.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                    color: AppColors.primary.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateFormat('d MMM y', 'tr').format(plan.weekStart)} · ${plan.days.isEmpty ? 0 : plan.days.first.meals.length} öğün',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.primary.withValues(alpha: 0.62),
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
            DiyetselAssets.modernIconPlan,
            size: 48,
            fallback: Icons.folder_open_rounded,
            fallbackColor: AppColors.primary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          const Text(
            'Henüz plan yok',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: AppColors.primaryDeep,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'İlk Word belgeni yükleyerek başla.',
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
