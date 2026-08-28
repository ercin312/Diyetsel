import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/data/app_store.dart';
import '../../../core/utils/desktop.dart';
import '../../../core/widgets/diyetsel_widgets.dart';
import '../../../core/widgets/kawaii_doodle.dart';
import '../../../core/widgets/luxury_glyph.dart';
import '../../../core/widgets/style_icon.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController(text: AppConstants.demoClientEmail);
  final _password = TextEditingController(text: AppConstants.demoPassword);
  final _form = GlobalKey<FormState>();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Widget _brandMark(BuildContext context) {
    final brand = context.brandPrimary;
    if (context.isLuxury) {
      return Column(
        children: [
          const LuxuryIconTile(kind: KawaiiKind.orange, size: 56),
          const SizedBox(height: 12),
          Text(
            'Diyetsel',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: brand,
                  letterSpacing: 1.4,
                ),
          ),
        ],
      );
    }
    return Column(
      children: [
        Icon(Icons.eco_rounded, size: 42, color: brand),
        const SizedBox(height: 10),
        Text(
          'Diyetsel',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: brand,
                letterSpacing: -0.8,
              ),
        ),
      ],
    );
  }

  Widget _formCard(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final modern = context.isModern;
    return DiyetselCard(
      color: modern
          ? AppColors.lightSurface
          : (context.isCartoon ? AppColors.kawaiiBubble : null),
      padding: modern
          ? const EdgeInsets.fromLTRB(24, 28, 24, 22)
          : (context.isCartoon ? const EdgeInsets.fromLTRB(22, 26, 22, 22) : const EdgeInsets.all(18)),
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!context.isDesktopLayout) ...[
              Center(
                child: context.isCartoon
                    ? Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.kawaiiCream,
                          borderRadius: BorderRadius.circular(36),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.kawaiiGlow,
                              blurRadius: 22,
                              offset: Offset(0, 8),
                            ),
                            BoxShadow(
                              color: AppColors.kawaiiShadow,
                              blurRadius: 18,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const KawaiiTile(kind: KawaiiKind.orange, size: 96),
                      )
                    : _brandMark(context),
              ),
              if (context.isCartoon) ...[
                const SizedBox(height: 16),
                Text(
                  'Diyetsel',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.kawaiiInk,
                      ),
                ),
              ],
              SizedBox(height: context.isCartoon ? 12 : (modern ? 8 : 4)),
              Text(
                'auth.tagline'.tr(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.isCartoon
                          ? AppColors.kawaiiInk.withValues(alpha: 0.65)
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      letterSpacing: context.isLuxury ? 0.2 : null,
                      fontWeight: context.isCartoon ? FontWeight.w600 : null,
                    ),
              ),
              SizedBox(height: context.isCartoon ? 32 : (modern ? 28 : 24)),
            ] else ...[
              Text(
                'auth.login'.tr(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: context.isLuxury ? FontWeight.w600 : FontWeight.w700,
                      letterSpacing: context.isLuxury ? 0.6 : null,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'auth.tagline'.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              SizedBox(height: modern ? 28 : 24),
            ],
            TextFormField(
              controller: _email,
              decoration: InputDecoration(
                labelText: 'auth.email'.tr(),
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(10),
                  child: StyleIcon(icon: Icons.mail_outline_rounded, emoji: '👤', size: 18, sticker: false),
                ),
              ),
              validator: (v) => v != null && v.contains('@') ? null : 'auth.emailInvalid'.tr(),
            ),
            SizedBox(height: modern ? 14 : 12),
            TextFormField(
              controller: _password,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'auth.password'.tr(),
                prefixIcon: const Padding(
                  padding: EdgeInsets.all(10),
                  child: StyleIcon(icon: Icons.lock_outline_rounded, emoji: '🔒', size: 18, sticker: false),
                ),
              ),
              validator: (v) => v != null && v.length >= 6 ? null : 'auth.passwordShort'.tr(),
            ),
            if (auth.error != null) ...[
              const SizedBox(height: 12),
              Text(auth.error!, style: const TextStyle(color: AppColors.danger)),
            ],
            SizedBox(height: modern ? 24 : 20),
            DiyetselButton(
              label: auth.loading ? '...' : 'auth.login'.tr(),
              icon: Icons.login_rounded,
              onPressed: auth.loading
                  ? null
                  : () async {
                      if (_form.currentState!.validate()) {
                        await ref.read(authControllerProvider.notifier).login(_email.text, _password.text);
                      }
                    },
            ),
            SizedBox(height: modern ? 12 : 10),
            DiyetselButton(
              label: 'auth.demoDietitian'.tr(),
              tonal: true,
              onPressed: () {
                _email.text = AppConstants.demoAdminEmail;
                _password.text = AppConstants.demoPassword;
                ref.read(authControllerProvider.notifier).login(_email.text, _password.text);
              },
            ),
            SizedBox(height: modern ? 18 : 16),
            TextButton(
              onPressed: () => context.go('/register'),
              child: Text('auth.noAccount'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _mobileGradient(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return context.isLuxury
          ? const [AppColors.luxuryDarkCanvas, AppColors.luxuryDarkSurface, Color(0xFF2A1C14)]
          : const [AppColors.dark, AppColors.darkCard];
    }
    if (context.isCartoon) {
      return const [AppColors.kawaiiCream, AppColors.kawaiiBubble, AppColors.kawaiiMint];
    }
    if (context.isLuxury) {
      return const [
        Color(0xFF0A0807),
        AppColors.luxuryCanvas,
        AppColors.luxuryCopperDeep,
        Color(0xFF2A1C14),
      ];
    }
    return const [
      AppColors.modernWash,
      AppColors.lightBg,
      AppColors.modernSageSoft,
    ];
  }

  Widget _desktopHero(BuildContext context) {
    final luxury = context.isLuxury;
    final colors = luxury
        ? const [
            Color(0xFF1A120E),
            AppColors.luxuryCopperDeep,
            Color(0xFF3D2416),
            AppColors.luxuryBronze,
          ]
        : const [
            AppColors.primaryBright,
            AppColors.primary,
            AppColors.modernSageDeep,
          ];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
          stops: luxury ? const [0, 0.35, 0.7, 1] : const [0, 0.55, 1],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(48, 48, 40, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (luxury)
              const LuxuryIconTile(kind: KawaiiKind.orange, size: 44, inverted: true)
            else
              const Icon(Icons.eco_rounded, color: Colors.white, size: 36),
            const SizedBox(height: 16),
            Text(
              'Diyetsel',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: luxury ? AppColors.luxuryGoldSoft : Colors.white,
                    fontWeight: luxury ? FontWeight.w600 : FontWeight.w700,
                    letterSpacing: luxury ? 1.6 : -1,
                  ),
            ),
            const Spacer(),
            Text(
              'Diyetisyen ve danışan yönetimi\niçin masaüstü deneyimi',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white.withValues(alpha: luxury ? 0.92 : 0.95),
                    height: 1.35,
                    fontWeight: luxury ? FontWeight.w500 : FontWeight.w600,
                    letterSpacing: luxury ? 0.3 : null,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Klinik paneli · Plan takibi · Raporlar',
              style: TextStyle(
                color: luxury ? AppColors.luxuryChampagne.withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.8),
                letterSpacing: luxury ? 0.6 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (context.isDesktopLayout) {
      return Scaffold(
        body: Row(
          children: [
            Expanded(
              flex: 5,
              child: _desktopHero(context),
            ),
            Expanded(
              flex: 4,
              child: ColoredBox(
                color: context.isLuxury
                    ? (Theme.of(context).brightness == Brightness.dark
                        ? AppColors.luxuryDarkCanvas
                        : AppColors.luxuryCanvas)
                    : context.isModern
                        ? AppColors.lightBg
                        : Theme.of(context).colorScheme.surfaceContainerLowest,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(context.isModern ? 40 : 32),
                      child: _formCard(context).animate().fadeIn(duration: 280.ms),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final luxury = context.isLuxury;
    final modern = context.isModern;
    final cartoon = context.isCartoon;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _mobileGradient(context),
            stops: luxury && !dark
                ? const [0, 0.4, 0.72, 1]
                : (cartoon && !dark
                    ? const [0, 0.45, 1]
                    : (modern && !dark ? const [0, 0.5, 1] : null)),
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(cartoon ? 28 : (modern ? 28 : 24)),
              child: _formCard(context).animate().fadeIn().slideY(begin: 0.05, duration: 400.ms),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _asAdmin = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final canAdmin = !ref.watch(appStoreProvider).hasAdmin;
    return Scaffold(
      appBar: AppBar(title: Text('auth.register'.tr())),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: DiyetselCard(
              child: Column(
                children: [
                  TextField(controller: _name, decoration: InputDecoration(labelText: 'auth.name'.tr())),
                  const SizedBox(height: 12),
                  TextField(controller: _email, decoration: InputDecoration(labelText: 'auth.email'.tr())),
                  const SizedBox(height: 12),
                  TextField(controller: _password, obscureText: true, decoration: InputDecoration(labelText: 'auth.password'.tr())),
                  if (canAdmin)
                    SwitchListTile(
                      value: _asAdmin,
                      onChanged: (v) => setState(() => _asAdmin = v),
                      title: Text('auth.dietitianSetup'.tr()),
                      subtitle: Text('auth.dietitianSetupHint'.tr()),
                    ),
                  if (auth.error != null) Text(auth.error!, style: const TextStyle(color: AppColors.danger)),
                  const SizedBox(height: 16),
                  DiyetselButton(
                    label: 'auth.register'.tr(),
                    onPressed: () => ref.read(authControllerProvider.notifier).register(
                          name: _name.text,
                          email: _email.text,
                          password: _password.text,
                          asAdmin: _asAdmin,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
