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

  Widget _formCard(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    return DiyetselCard(
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!context.isDesktopLayout) ...[
              Center(
                child: context.isCartoon
                    ? const KawaiiTile(kind: KawaiiKind.orange, size: 84)
                    : Column(
                        children: [
                          const Icon(Icons.eco_rounded, size: 40, color: AppColors.primary),
                          const SizedBox(height: 8),
                          Text(
                            'Diyetsel',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                  letterSpacing: -0.8,
                                ),
                          ),
                        ],
                      ),
              ),
              if (context.isCartoon) ...[
                Text(
                  'Diyetsel',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                'auth.tagline'.tr(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
            ] else ...[
              Text(
                'auth.login'.tr(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'auth.tagline'.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
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
            const SizedBox(height: 12),
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
            const SizedBox(height: 20),
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
            const SizedBox(height: 10),
            DiyetselButton(
              label: 'auth.demoDietitian'.tr(),
              tonal: true,
              onPressed: () {
                _email.text = AppConstants.demoAdminEmail;
                _password.text = AppConstants.demoPassword;
                ref.read(authControllerProvider.notifier).login(_email.text, _password.text);
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go('/register'),
              child: Text('auth.noAccount'.tr()),
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
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFF8A3D),
                      Color(0xFFFF6B00),
                      Color(0xFF0F766E),
                    ],
                    stops: [0, 0.5, 1],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(48, 48, 40, 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.eco_rounded, color: Colors.white, size: 36),
                      const SizedBox(height: 16),
                      Text(
                        'Diyetsel',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        'Diyetisyen ve danışan yönetimi\niçin masaüstü deneyimi',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.95),
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Klinik paneli · Plan takibi · Raporlar',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
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

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Theme.of(context).brightness == Brightness.dark
                ? const [AppColors.dark, AppColors.darkCard]
                : context.isCartoon
                    ? const [AppColors.kawaiiMint, Colors.white, AppColors.kawaiiCream]
                    : const [
                        Color(0xFFFFE8D6),
                        AppColors.lightBg,
                        Color(0xFFE8E4DE),
                      ],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
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
