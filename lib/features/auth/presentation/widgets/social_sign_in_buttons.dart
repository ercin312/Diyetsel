import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/social_auth.dart';
import '../auth_controller.dart';

class SocialSignInButtons extends ConsumerWidget {
  const SocialSignInButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final google = SocialAuth.googleAvailable;
    final apple = SocialAuth.appleAvailable;
    if (!google && !apple) return const SizedBox.shrink();

    final loading = ref.watch(authControllerProvider).loading;
    final auth = ref.read(authControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'veya',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: AppColors.primary.withValues(alpha: 0.45),
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 14),
        if (google) ...[
          _SocialButton(
            label: 'Google ile devam et',
            background: Colors.white,
            foreground: const Color(0xFF1F1F1F),
            border: const Color(0xFFDADCE0),
            enabled: !loading,
            leading: const _GoogleMark(),
            onPressed: auth.loginWithGoogle,
          ),
          if (apple) const SizedBox(height: 10),
        ],
        if (apple)
          _SocialButton(
            label: 'Apple ile devam et',
            background: Colors.black,
            foreground: Colors.white,
            border: Colors.black,
            enabled: !loading,
            leading: const Icon(Icons.apple, size: 22, color: Colors.white),
            onPressed: auth.loginWithApple,
          ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.border,
    required this.enabled,
    required this.leading,
    required this.onPressed,
  });

  final String label;
  final Color background;
  final Color foreground;
  final Color border;
  final bool enabled;
  final Widget leading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: border),
      ),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(16),
        child: Opacity(
          opacity: enabled ? 1 : 0.55,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                leading,
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.18
      ..strokeCap = StrokeCap.butt;
    final rect = Rect.fromLTWH(size.width * 0.08, size.height * 0.08, size.width * 0.84, size.height * 0.84);
    stroke.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.2, 1.6, false, stroke);
    stroke.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 1.4, 1.1, false, stroke);
    stroke.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 2.5, 0.9, false, stroke);
    stroke.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, 3.4, 1.3, false, stroke);
    final bar = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.48, size.height * 0.42, size.width * 0.44, size.height * 0.16),
      bar,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
