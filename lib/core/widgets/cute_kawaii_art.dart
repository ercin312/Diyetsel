import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Cute kawaii illustration by config `imageKey` / `iconKey`, or remote URL.
class KawaiiArt extends StatelessWidget {
  const KawaiiArt({
    super.key,
    this.imageUrl = '',
    this.imageKey = 'bowl',
    this.size = 72,
  });

  final String imageUrl;
  final String imageKey;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('http')) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, _) => _fallback(),
          errorWidget: (_, _, _) => _fallback(),
        ),
      );
    }
    return SizedBox(width: size, height: size, child: _fallback());
  }

  Widget _fallback() {
    return CustomPaint(
      size: Size.square(size),
      painter: _KawaiiKeyPainter(imageKey),
    );
  }
}

class _KawaiiKeyPainter extends CustomPainter {
  _KawaiiKeyPainter(this.keyName);
  final String keyName;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.42;

    switch (keyName) {
      case 'star':
        _star(canvas, cx, cy, r, const Color(0xFFFFD54F));
      case 'fire':
        _blob(canvas, cx, cy, r, const Color(0xFFFF8A65), face: true);
      case 'water':
        _drop(canvas, cx, cy, r, const Color(0xFF81D4FA));
      case 'plan':
        _rect(canvas, cx, cy, r, const Color(0xFFFFF3E0), const Color(0xFFFFB74D));
      case 'more':
        _dots(canvas, cx, cy, r);
      case 'soup':
        _bowl(canvas, cx, cy, r, const Color(0xFFFFB74D), soup: true);
      case 'bowl':
        _bowl(canvas, cx, cy, r, const Color(0xFFAED581), soup: false);
      case 'avocado':
        _avocado(canvas, cx, cy, r);
      case 'carrot':
        _carrot(canvas, cx, cy, r);
      case 'clock':
        _clock(canvas, cx, cy, r);
      case 'clinic':
        _person(canvas, cx, cy, r, const Color(0xFF90CAF9));
      case 'lesson':
        _person(canvas, cx, cy, r, const Color(0xFFCE93D8));
      case 'streak':
        _person(canvas, cx, cy, r, const Color(0xFF81D4FA));
      case 'scale':
        _scale(canvas, cx, cy, r);
      case 'bottle':
        _bottle(canvas, cx, cy, r);
      case 'calendar':
        _rect(canvas, cx, cy, r, Colors.white, const Color(0xFFEF5350));
      case 'headset':
        _headset(canvas, cx, cy, r);
      case 'home':
        _home(canvas, cx, cy, r);
      case 'apple':
        _apple(canvas, cx, cy, r);
      case 'profile':
        _person(canvas, cx, cy, r, AppColors.kawaiiLeaf);
      case 'add':
        _plus(canvas, cx, cy, r);
      default:
        _blob(canvas, cx, cy, r, AppColors.kawaiiMint, face: true);
    }
  }

  void _face(Canvas canvas, double cx, double cy, double s) {
    final eye = Paint()..color = AppColors.kawaiiInk;
    canvas.drawCircle(Offset(cx - s * 0.18, cy - s * 0.05), s * 0.06, eye);
    canvas.drawCircle(Offset(cx + s * 0.18, cy - s * 0.05), s * 0.06, eye);
    final smile = Paint()
      ..color = AppColors.kawaiiInk
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.06
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy + s * 0.08), width: s * 0.45, height: s * 0.35),
      0.15,
      2.8,
      false,
      smile,
    );
  }

  void _blob(Canvas canvas, double cx, double cy, double r, Color c, {bool face = false}) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCircle(center: Offset(cx, cy), radius: r), Radius.circular(r * 0.55)),
      Paint()..color = c,
    );
    if (face) _face(canvas, cx, cy, r);
  }

  void _drop(Canvas canvas, double cx, double cy, double r, Color c) {
    final path = Path()
      ..moveTo(cx, cy - r)
      ..quadraticBezierTo(cx + r, cy, cx, cy + r * 0.85)
      ..quadraticBezierTo(cx - r, cy, cx, cy - r);
    canvas.drawPath(path, Paint()..color = c);
    _face(canvas, cx, cy + r * 0.1, r * 0.85);
  }

  void _star(Canvas canvas, double cx, double cy, double r, Color c) {
    canvas.drawCircle(Offset(cx, cy), r * 0.85, Paint()..color = c);
    _face(canvas, cx, cy, r * 0.7);
  }

  void _rect(Canvas canvas, double cx, double cy, double r, Color fill, Color accent) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: r * 1.6, height: r * 1.8),
        Radius.circular(r * 0.25),
      ),
      Paint()..color = fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - r * 0.8, cy - r * 0.9, r * 1.6, r * 0.35),
        Radius.circular(r * 0.12),
      ),
      Paint()..color = accent,
    );
  }

  void _bowl(Canvas canvas, double cx, double cy, double r, Color c, {required bool soup}) {
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + r * 0.15), width: r * 1.9, height: r * 1.2), Paint()..color = c);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy - r * 0.15), width: r * 1.7, height: r * 0.7), Paint()..color = Color.lerp(c, Colors.white, 0.35)!);
    if (soup) {
      canvas.drawCircle(Offset(cx - r * 0.25, cy - r * 0.35), r * 0.18, Paint()..color = const Color(0xFFFFF59D));
    } else {
      canvas.drawCircle(Offset(cx - r * 0.3, cy - r * 0.2), r * 0.2, Paint()..color = const Color(0xFF81C784));
      canvas.drawCircle(Offset(cx + r * 0.25, cy - r * 0.15), r * 0.16, Paint()..color = const Color(0xFFEF9A9A));
    }
    _face(canvas, cx, cy + r * 0.2, r * 0.7);
  }

  void _avocado(Canvas canvas, double cx, double cy, double r) {
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: r * 1.5, height: r * 1.9), Paint()..color = const Color(0xFFAED581));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + r * 0.1), width: r * 0.9, height: r * 1.1), Paint()..color = const Color(0xFFFFF59D));
    canvas.drawCircle(Offset(cx, cy + r * 0.15), r * 0.28, Paint()..color = const Color(0xFF8D6E63));
    _face(canvas, cx, cy - r * 0.15, r * 0.55);
  }

  void _carrot(Canvas canvas, double cx, double cy, double r) {
    final path = Path()
      ..moveTo(cx, cy + r)
      ..lineTo(cx - r * 0.45, cy - r * 0.4)
      ..lineTo(cx + r * 0.45, cy - r * 0.4)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFFF9800));
    canvas.drawCircle(Offset(cx, cy - r * 0.55), r * 0.28, Paint()..color = const Color(0xFF66BB6A));
    _face(canvas, cx, cy + r * 0.05, r * 0.55);
  }

  void _clock(Canvas canvas, double cx, double cy, double r) {
    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = const Color(0xFFFFCC80));
    canvas.drawCircle(Offset(cx, cy), r * 0.72, Paint()..color = Colors.white);
    _face(canvas, cx, cy + r * 0.05, r * 0.65);
  }

  void _person(Canvas canvas, double cx, double cy, double r, Color shirt) {
    canvas.drawCircle(Offset(cx, cy - r * 0.35), r * 0.42, Paint()..color = const Color(0xFFFFE0B2));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + r * 0.45), width: r * 1.4, height: r * 1.0),
        Radius.circular(r * 0.35),
      ),
      Paint()..color = shirt,
    );
    _face(canvas, cx, cy - r * 0.35, r * 0.5);
  }

  void _scale(Canvas canvas, double cx, double cy, double r) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy), width: r * 1.6, height: r * 1.2), Radius.circular(r * 0.3)),
      Paint()..color = const Color(0xFFE0E0E0),
    );
    canvas.drawCircle(Offset(cx, cy), r * 0.35, Paint()..color = AppColors.kawaiiLeaf);
  }

  void _bottle(Canvas canvas, double cx, double cy, double r) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy + r * 0.1), width: r * 0.9, height: r * 1.5), Radius.circular(r * 0.3)),
      Paint()..color = const Color(0xFF81D4FA),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy - r * 0.7), width: r * 0.45, height: r * 0.4), Radius.circular(r * 0.12)),
      Paint()..color = const Color(0xFF4FC3F7),
    );
  }

  void _headset(Canvas canvas, double cx, double cy, double r) {
    final p = Paint()
      ..color = AppColors.kawaiiLeaf
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.18;
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.7), 3.4, 2.5, false, p);
    canvas.drawCircle(Offset(cx - r * 0.65, cy + r * 0.15), r * 0.28, Paint()..color = AppColors.kawaiiLeaf);
    canvas.drawCircle(Offset(cx + r * 0.65, cy + r * 0.15), r * 0.28, Paint()..color = AppColors.kawaiiLeaf);
  }

  void _home(Canvas canvas, double cx, double cy, double r) {
    final path = Path()
      ..moveTo(cx, cy - r)
      ..lineTo(cx + r, cy)
      ..lineTo(cx + r * 0.7, cy)
      ..lineTo(cx + r * 0.7, cy + r)
      ..lineTo(cx - r * 0.7, cy + r)
      ..lineTo(cx - r * 0.7, cy)
      ..lineTo(cx - r, cy)
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.kawaiiLeaf);
  }

  void _apple(Canvas canvas, double cx, double cy, double r) {
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + r * 0.1), width: r * 1.5, height: r * 1.55), Paint()..color = const Color(0xFFEF5350));
    canvas.drawLine(Offset(cx, cy - r * 0.55), Offset(cx + r * 0.15, cy - r * 0.9), Paint()
      ..color = const Color(0xFF8D6E63)
      ..strokeWidth = r * 0.1
      ..strokeCap = StrokeCap.round);
  }

  void _plus(Canvas canvas, double cx, double cy, double r) {
    canvas.drawCircle(Offset(cx, cy), r, Paint()..color = AppColors.kawaiiLeaf);
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = r * 0.22
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - r * 0.35, cy), Offset(cx + r * 0.35, cy), p);
    canvas.drawLine(Offset(cx, cy - r * 0.35), Offset(cx, cy + r * 0.35), p);
  }

  void _dots(Canvas canvas, double cx, double cy, double r) {
    final p = Paint()..color = AppColors.kawaiiInk.withValues(alpha: 0.55);
    canvas.drawCircle(Offset(cx - r * 0.45, cy), r * 0.14, p);
    canvas.drawCircle(Offset(cx, cy), r * 0.14, p);
    canvas.drawCircle(Offset(cx + r * 0.45, cy), r * 0.14, p);
  }

  @override
  bool shouldRepaint(covariant _KawaiiKeyPainter oldDelegate) => oldDelegate.keyName != keyName;
}
