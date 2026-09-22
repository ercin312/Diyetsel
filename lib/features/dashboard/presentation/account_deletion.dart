import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../auth/presentation/auth_controller.dart';

/// Confirms and runs in-app account deletion (App Store Guideline 5.1.1(v)).
Future<void> confirmAndDeleteAccount(BuildContext context, WidgetRef ref) async {
  final passwordController = TextEditingController();
  final needsPassword = _emailPasswordProviderSignedIn();

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Hesabı kalıcı olarak sil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hesabınız ve uygulamada saklanan kişisel verileriniz silinir. '
                'Bu işlem geri alınamaz.',
              ),
              if (needsPassword) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Şifrenizi girin',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => Navigator.of(ctx).pop(true),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.kawaiiCoralDeep),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hesabı sil'),
          ),
        ],
      );
    },
  );

  if (confirmed != true || !context.mounted) {
    passwordController.dispose();
    return;
  }

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Hesap siliniyor…'),
            ],
          ),
        ),
      ),
    ),
  );

  try {
    await ref.read(authControllerProvider.notifier).deleteAccount(
          password: needsPassword ? passwordController.text : null,
        );
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop(); // loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hesabınız silindi.')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop(); // loading
      final message = e.toString().replaceAll('Bad state: ', '').replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  } finally {
    passwordController.dispose();
  }
}

bool _emailPasswordProviderSignedIn() {
  if (Firebase.apps.isEmpty) return true;
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return true;
  return user.providerData.any((p) => p.providerId == 'password');
}
