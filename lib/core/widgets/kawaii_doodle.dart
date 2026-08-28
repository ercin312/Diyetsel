import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

enum KawaiiKind {
  home,
  diet,
  water,
  calendar,
  shop,
  recipe,
  blog,
  cart,
  chat,
  people,
  settings,
  sparkle,
  gift,
  camera,
  folder,
  document,
  chart,
  search,
  orange,
  barcode,
  heart,
  fire,
  hourglass,
  plate,
}

extension KawaiiKindX on KawaiiKind {
  Color get tile {
    return switch (this) {
      KawaiiKind.home => AppColors.kawaiiLemon,
      KawaiiKind.diet => AppColors.kawaiiPeach,
      KawaiiKind.water => AppColors.kawaiiSky,
      KawaiiKind.calendar => AppColors.kawaiiMint,
      KawaiiKind.shop => AppColors.kawaiiLilac,
      KawaiiKind.recipe => AppColors.kawaiiPeach,
      KawaiiKind.blog => AppColors.kawaiiSky,
      KawaiiKind.cart => AppColors.kawaiiLemon,
      KawaiiKind.chat => AppColors.kawaiiMint,
      KawaiiKind.people => AppColors.kawaiiLilac,
      KawaiiKind.settings => const Color(0xFFE8E4DC),
      KawaiiKind.sparkle => AppColors.kawaiiLemon,
      KawaiiKind.gift => AppColors.kawaiiRose,
      KawaiiKind.camera => AppColors.kawaiiLilac,
      KawaiiKind.folder => AppColors.kawaiiLemon,
      KawaiiKind.document => AppColors.kawaiiSky,
      KawaiiKind.chart => AppColors.kawaiiMint,
      KawaiiKind.search => AppColors.kawaiiSky,
      KawaiiKind.orange => AppColors.kawaiiPeach,
      KawaiiKind.barcode => AppColors.kawaiiLilac,
      KawaiiKind.heart => AppColors.kawaiiRose,
      KawaiiKind.fire => const Color(0xFFFFE0C2),
      KawaiiKind.hourglass => AppColors.kawaiiLemon,
      KawaiiKind.plate => AppColors.kawaiiMint,
    };
  }

  IconData get materialIcon => switch (this) {
        KawaiiKind.home => Icons.home_rounded,
        KawaiiKind.diet => Icons.restaurant_rounded,
        KawaiiKind.water => Icons.water_drop_rounded,
        KawaiiKind.calendar => Icons.event_available_rounded,
        KawaiiKind.shop => Icons.storefront_rounded,
        KawaiiKind.recipe => Icons.menu_book_rounded,
        KawaiiKind.blog => Icons.article_rounded,
        KawaiiKind.cart => Icons.shopping_cart_rounded,
        KawaiiKind.chat => Icons.chat_rounded,
        KawaiiKind.people => Icons.groups_rounded,
        KawaiiKind.settings => Icons.settings_rounded,
        KawaiiKind.sparkle => Icons.auto_awesome_rounded,
        KawaiiKind.gift => Icons.card_giftcard_rounded,
        KawaiiKind.camera => Icons.photo_camera_rounded,
        KawaiiKind.folder => Icons.folder_rounded,
        KawaiiKind.document => Icons.picture_as_pdf_rounded,
        KawaiiKind.chart => Icons.space_dashboard_rounded,
        KawaiiKind.search => Icons.search_rounded,
        KawaiiKind.orange => Icons.eco_rounded,
        KawaiiKind.barcode => Icons.qr_code_scanner_rounded,
        KawaiiKind.heart => Icons.favorite_rounded,
        KawaiiKind.fire => Icons.local_fire_department_rounded,
        KawaiiKind.hourglass => Icons.hourglass_bottom_rounded,
        KawaiiKind.plate => Icons.restaurant_menu_rounded,
      };

  static KawaiiKind from({IconData? icon, String? emoji}) {
    final e = emoji ?? '';
    final i = icon;
    if (i == Icons.qr_code_scanner_rounded || i == Icons.qr_code_scanner) return KawaiiKind.barcode;
    if (i == Icons.favorite_rounded || i == Icons.favorite || e.contains('❤️') || e.contains('💖')) {
      return KawaiiKind.heart;
    }
    if (e.contains('🏠') || i == Icons.home_rounded || i == Icons.home) return KawaiiKind.home;
    if (e.contains('🥗') || e.contains('🥑') || e.contains('🥬') || e.contains('🫒') || i == Icons.restaurant_rounded || i == Icons.restaurant) {
      return KawaiiKind.diet;
    }
    if (e.contains('💧') || i == Icons.water_drop_rounded || i == Icons.water_drop) return KawaiiKind.water;
    if (e.contains('📅') || i == Icons.event_available_rounded || i == Icons.calendar_month_rounded || i == Icons.event) {
      return KawaiiKind.calendar;
    }
    if (e.contains('🎁') || i == Icons.storefront_rounded || i == Icons.storefront || i == Icons.medical_services) {
      return KawaiiKind.shop;
    }
    if (e.contains('🍲') || e.contains('🍜') || e.contains('🥙') || i == Icons.menu_book_rounded || i == Icons.menu_book) {
      return KawaiiKind.recipe;
    }
    if (e.contains('📰') || i == Icons.article_rounded || i == Icons.article || i == Icons.edit_note) {
      return KawaiiKind.blog;
    }
    if (e.contains('🛒') || e.contains('💰') || i == Icons.shopping_cart_rounded || i == Icons.shopping_cart) {
      return KawaiiKind.cart;
    }
    if (e.contains('💬') || i == Icons.chat_rounded || i == Icons.chat || i == Icons.chat_bubble_rounded) {
      return KawaiiKind.chat;
    }
    if (e.contains('👥') || e.contains('👤') || i == Icons.groups_rounded || i == Icons.groups || i == Icons.person) {
      return KawaiiKind.people;
    }
    if (e.contains('⚙️') || i == Icons.settings) return KawaiiKind.settings;
    if (e.contains('📷') || i == Icons.photo || i == Icons.camera_alt || i == Icons.photo_camera_rounded) {
      return KawaiiKind.camera;
    }
    if (e.contains('📁') || i == Icons.folder) return KawaiiKind.folder;
    if (e.contains('📄') || i == Icons.picture_as_pdf || i == Icons.picture_as_pdf_outlined) return KawaiiKind.document;
    if (e.contains('📊') || i == Icons.space_dashboard_rounded) return KawaiiKind.chart;
    if (e.contains('🔥') || e.contains('💪') || i == Icons.local_fire_department) return KawaiiKind.fire;
    if (e.contains('🍽️') || e.contains('🍳') || i == Icons.restaurant_menu_rounded || i == Icons.restaurant_menu) {
      return KawaiiKind.plate;
    }
    if (e.contains('⏳') || i == Icons.hourglass_bottom || i == Icons.timelapse) return KawaiiKind.hourglass;
    if (e.contains('🎨') ||
        e.contains('✨') ||
        i == Icons.auto_awesome ||
        i == Icons.auto_awesome_rounded ||
        i == Icons.grid_view_rounded ||
        i == Icons.share ||
        i == Icons.ios_share ||
        i == Icons.add_rounded ||
        i == Icons.add) {
      return KawaiiKind.sparkle;
    }
    if (e.contains('🍊') || e.contains('🍋') || e.contains('🍓')) return KawaiiKind.orange;
    if (i == Icons.search_rounded || i == Icons.search || e.contains('🔎')) return KawaiiKind.search;
    if (i == Icons.play_arrow || i == Icons.stop || i == Icons.login_rounded || i == Icons.send) {
      return KawaiiKind.hourglass;
    }
    if (i == Icons.mail_outline || i == Icons.mail_outline_rounded) return KawaiiKind.chat;
    if (i == Icons.lock_outline || i == Icons.lock_outline_rounded || i == Icons.lock_rounded) return KawaiiKind.settings;
    if (i == Icons.verified_user || i == Icons.verified_rounded) return KawaiiKind.people;
    if (i == Icons.view_week) return KawaiiKind.calendar;
    if (i == Icons.hourglass_bottom_rounded || i == Icons.hourglass_top_rounded) return KawaiiKind.hourglass;
    if (i == Icons.settings_rounded) return KawaiiKind.settings;
    if (i == Icons.notifications_active) return KawaiiKind.water;
    if (e.contains('🐟') || e.contains('🍖') || e.contains('🌯') || e.contains('☕')) return KawaiiKind.plate;
    if (e.contains('📝')) return KawaiiKind.heart;
    return KawaiiKind.sparkle;
  }

  static KawaiiKind forBlog(String category) {
    return switch (category) {
      'Keto' => KawaiiKind.diet,
      'Aralıklı Oruç' => KawaiiKind.hourglass,
      'Vegan' => KawaiiKind.diet,
      'Akdeniz' => KawaiiKind.orange,
      'Detoks' => KawaiiKind.water,
      'Spor' => KawaiiKind.fire,
      _ => KawaiiKind.blog,
    };
  }
}

class KawaiiDoodle extends StatelessWidget {
  const KawaiiDoodle({super.key, required this.kind, this.size = 32});

  final KawaiiKind kind;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _KawaiiPainter(kind)),
    );
  }
}

class KawaiiTile extends StatelessWidget {
  const KawaiiTile({
    super.key,
    required this.kind,
    this.size = 56,
    this.selected = false,
  });

  final KawaiiKind kind;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final radius = size * 0.36;
    final fill = dark ? Color.lerp(kind.tile, const Color(0xFF2A241F), 0.55)! : kind.tile;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutBack,
      width: size,
      height: size,
      alignment: Alignment.center,
      transform: selected
          ? (Matrix4.identity()..scaleByDouble(1.06, 1.06, 1.06, 1.0))
          : Matrix4.identity(),
      transformAlignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(fill, Colors.white, dark ? 0.1 : 0.42)!,
            fill,
            Color.lerp(fill, AppColors.kawaiiPeach, 0.12)!,
          ],
        ),
        border: Border.all(
          color: selected ? AppColors.kawaiiCoral.withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.9),
          width: selected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: selected ? AppColors.kawaiiGlow : AppColors.kawaiiShadow,
            blurRadius: selected ? 16 : 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: size * 0.1,
            left: size * 0.12,
            child: Container(
              width: size * 0.36,
              height: size * 0.2,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: dark ? 0.14 : 0.65),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          KawaiiDoodle(kind: kind, size: size * 0.7),
        ],
      ),
    );
  }
}

class _KawaiiPainter extends CustomPainter {
  _KawaiiPainter(this.kind);
  final KawaiiKind kind;

  static const ink = Color(0xFF3A3129);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(s / 32);
    switch (kind) {
      case KawaiiKind.home:
        _home(canvas);
      case KawaiiKind.diet:
        _diet(canvas);
      case KawaiiKind.water:
        _water(canvas);
      case KawaiiKind.calendar:
        _calendar(canvas);
      case KawaiiKind.shop:
        _shop(canvas);
      case KawaiiKind.recipe:
        _recipe(canvas);
      case KawaiiKind.blog:
        _blog(canvas);
      case KawaiiKind.cart:
        _cart(canvas);
      case KawaiiKind.chat:
        _chat(canvas);
      case KawaiiKind.people:
        _people(canvas);
      case KawaiiKind.settings:
        _settings(canvas);
      case KawaiiKind.sparkle:
        _sparkle(canvas);
      case KawaiiKind.gift:
        _shop(canvas);
      case KawaiiKind.camera:
        _camera(canvas);
      case KawaiiKind.folder:
        _folder(canvas);
      case KawaiiKind.document:
        _document(canvas);
      case KawaiiKind.chart:
        _chart(canvas);
      case KawaiiKind.search:
        _search(canvas);
      case KawaiiKind.orange:
        _orange(canvas);
      case KawaiiKind.barcode:
        _barcode(canvas);
      case KawaiiKind.heart:
        _heart(canvas);
      case KawaiiKind.fire:
        _fire(canvas);
      case KawaiiKind.hourglass:
        _hourglass(canvas);
      case KawaiiKind.plate:
        _plate(canvas);
    }
    canvas.restore();
  }

  Paint get _fill => Paint()..style = PaintingStyle.fill;
  Paint get _stroke => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.2
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = ink;

  void _home(Canvas c) {
    final p = Path()
      ..moveTo(-11, 2)
      ..lineTo(0, -11)
      ..lineTo(11, 2)
      ..lineTo(11, 12)
      ..lineTo(-11, 12)
      ..close();
    c.drawPath(p, _fill..color = const Color(0xFFFFC56D));
    c.drawPath(p, _stroke);
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-4, 4, 8, 8), const Radius.circular(1.5)), _fill..color = const Color(0xFFFF8A4C));
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-4, 4, 8, 8), const Radius.circular(1.5)), _stroke);
    c.drawCircle(const Offset(-6.2, 1.2), 1.15, _fill..color = ink);
    c.drawCircle(const Offset(6.2, 1.2), 1.15, _fill..color = ink);
    c.drawArc(const Rect.fromLTWH(-4.2, 2.2, 8.4, 5.2), 0.2, 2.7, false, _stroke..strokeWidth = 1.4);
  }

  void _diet(Canvas c) {
    const metal = Color(0xFFE9EEF2);
    const pink = Color(0xFFE7A4B4);
    const teal = Color(0xFF6AA3A8);
    for (final x in [-9.2, -7.5, -5.8, -4.1]) {
      final tine = RRect.fromRectAndRadius(Rect.fromLTWH(x, -13.5, 1.35, 10.5), const Radius.circular(0.7));
      c.drawRRect(tine, _fill..color = metal);
      c.drawRRect(tine, _stroke..strokeWidth = 1.15);
    }
    final neck = RRect.fromRectAndRadius(const Rect.fromLTWH(-8.1, -4.2, 5.6, 6.2), const Radius.circular(1.2));
    c.drawRRect(neck, _fill..color = metal);
    c.drawRRect(neck, _stroke..strokeWidth = 1.3);
    final forkH = RRect.fromRectAndRadius(const Rect.fromLTWH(-8.0, 1.6, 5.4, 12.2), const Radius.circular(2.2));
    c.drawRRect(forkH, _fill..color = pink);
    c.drawRRect(forkH, _stroke..strokeWidth = 1.6);
    final blade = Path()
      ..moveTo(4.6, -13.2)
      ..lineTo(8.6, -11.6)
      ..lineTo(7.2, 2.4)
      ..lineTo(4.2, 2.4)
      ..close();
    c.drawPath(blade, _fill..color = metal);
    c.drawPath(blade, _stroke..strokeWidth = 1.6);
    final knifeH = RRect.fromRectAndRadius(const Rect.fromLTWH(4.1, 2.1, 4.0, 11.6), const Radius.circular(1.9));
    c.drawRRect(knifeH, _fill..color = teal);
    c.drawRRect(knifeH, _stroke..strokeWidth = 1.6);
  }

  void _water(Canvas c) {
    final drop = Path()
      ..moveTo(0, -14.5)
      ..cubicTo(12.5, -1.5, 13.2, 9.2, 0, 14.2)
      ..cubicTo(-13.2, 9.2, -12.5, -1.5, 0, -14.5);
    c.drawPath(drop, _fill..color = const Color(0xFF7EC8EA));
    c.drawPath(drop, _stroke..strokeWidth = 2.05);
    c.drawOval(const Rect.fromLTWH(-6.8, -7.2, 5.2, 6.4), _fill..color = const Color(0xAAFFFFFF));
    c.drawCircle(const Offset(-3.5, 1.4), 1.55, _fill..color = ink);
    c.drawCircle(const Offset(3.5, 1.4), 1.55, _fill..color = ink);
    c.drawArc(const Rect.fromLTWH(-4.4, 3.4, 8.8, 6.2), 0.28, 2.58, false, _stroke..strokeWidth = 1.65);
  }

  void _calendar(Canvas c) {
    final body = RRect.fromRectAndRadius(const Rect.fromLTWH(-11.5, -7.2, 23, 20.4), const Radius.circular(3.6));
    c.drawRRect(body, _fill..color = const Color(0xFFFFFBF6));
    c.drawRRect(body, _stroke);
    c.drawRRect(
      RRect.fromRectAndCorners(
        const Rect.fromLTWH(-11.5, -7.2, 23, 6.6),
        topLeft: const Radius.circular(3.6),
        topRight: const Radius.circular(3.6),
      ),
      _fill..color = const Color(0xFFE85D4C),
    );
    c.drawLine(const Offset(-11.5, -0.6), const Offset(11.5, -0.6), _stroke..strokeWidth = 1.6);
    c.drawLine(const Offset(-5.2, -11.8), const Offset(-5.2, -5.2), _stroke..strokeWidth = 2.1);
    c.drawLine(const Offset(5.2, -11.8), const Offset(5.2, -5.2), _stroke..strokeWidth = 2.1);
    for (var y = 0; y < 3; y++) {
      for (var x = 0; x < 4; x++) {
        c.drawCircle(Offset(-7.2 + x * 3.7, 2.6 + y * 3.5), 0.72, _fill..color = const Color(0xFFC4B6A6));
      }
    }
    c.save();
    c.translate(6.4, 6.2);
    c.rotate(0.72);
    final pen = RRect.fromRectAndRadius(const Rect.fromLTWH(-1.25, -9.2, 2.5, 16.5), const Radius.circular(1.15));
    c.drawRRect(pen, _fill..color = const Color(0xFF5BA4D6));
    c.drawRRect(pen, _stroke..strokeWidth = 1.25);
    c.drawPath(
      Path()
        ..moveTo(-1.25, 7.1)
        ..lineTo(0, 10.2)
        ..lineTo(1.25, 7.1)
        ..close(),
      _fill..color = const Color(0xFFE9EEF2),
    );
    c.restore();
  }

  void _shop(Canvas c) {
    final body = RRect.fromRectAndRadius(const Rect.fromLTWH(-11.2, -0.4, 22.4, 13.8), const Radius.circular(2.2));
    c.drawRRect(body, _fill..color = const Color(0xFFFFE6C8));
    c.drawRRect(body, _stroke);
    final awning = Path()
      ..moveTo(-13.2, -0.4)
      ..lineTo(-10, -11.4)
      ..lineTo(10, -11.4)
      ..lineTo(13.2, -0.4)
      ..close();
    c.save();
    c.clipPath(awning);
    c.drawPath(awning, _fill..color = const Color(0xFFFFE066));
    for (var i = 0; i < 6; i++) {
      if (i.isOdd) {
        final x = -13.0 + i * 4.5;
        c.drawPath(
          Path()
            ..moveTo(x, -0.4)
            ..lineTo(x + 2.6, -11.4)
            ..lineTo(x + 6.8, -11.4)
            ..lineTo(x + 4.4, -0.4)
            ..close(),
          _fill..color = const Color(0xFF7EBF7A),
        );
      }
    }
    c.restore();
    c.drawPath(awning, _stroke);
    c.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-3.1, 3.1, 6.2, 10.2), const Radius.circular(1.1)),
      _fill..color = const Color(0xFF8B5E3C),
    );
    c.drawCircle(const Offset(1.6, 8.2), 0.7, _fill..color = const Color(0xFFFFE066));
    c.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(5.2, 3.6, 4.4, 4.2), const Radius.circular(0.8)),
      _fill..color = const Color(0xFFBFE4EA),
    );
  }

  void _recipe(Canvas c) {
    final book = RRect.fromRectAndRadius(const Rect.fromLTWH(-10.5, -12.2, 21, 24.4), const Radius.circular(2.6));
    c.drawRRect(book, _fill..color = const Color(0xFF8B5A3C));
    c.drawRRect(book, _stroke);
    c.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-7.2, -8.2, 14.6, 16.4), const Radius.circular(1.6)),
      _fill..color = const Color(0xFFA56B46),
    );
    c.drawOval(const Rect.fromLTWH(-4.6, -2.6, 9.2, 6.2), _fill..color = const Color(0xFFD8B08A));
    c.drawOval(const Rect.fromLTWH(-4.6, -2.6, 9.2, 6.2), _stroke..strokeWidth = 1.4);
    c.drawLine(const Offset(-6.6, -0.4), const Offset(-4.6, -0.4), _stroke..strokeWidth = 1.5);
    c.drawLine(const Offset(4.6, -0.4), const Offset(6.6, -0.4), _stroke..strokeWidth = 1.5);
    c.drawLine(const Offset(0, -2.6), const Offset(0, -6.4), _stroke..strokeWidth = 1.5);
    c.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-1.25, 8.2, 2.5, 6.2), const Radius.circular(0.7)),
      _fill..color = const Color(0xFFE85D4C),
    );
  }

  void _blog(Canvas c) {
    final pad = RRect.fromRectAndRadius(const Rect.fromLTWH(-11.4, -12.2, 18.4, 24.4), const Radius.circular(2.5));
    c.drawRRect(pad, _fill..color = const Color(0xFFF3D36A));
    c.drawRRect(pad, _stroke);
    for (final y in [-8.0, -2.6, 2.8, 8.2]) {
      c.drawCircle(Offset(-11.4, y), 1.7, _stroke..strokeWidth = 1.55);
    }
    for (final y in [-5.6, -0.4, 4.8]) {
      c.drawLine(Offset(-6.2, y), Offset(4.2, y), _stroke..strokeWidth = 1.25);
    }
    c.save();
    c.translate(8.4, 1.6);
    c.rotate(-0.52);
    final pen = RRect.fromRectAndRadius(const Rect.fromLTWH(-1.15, -10.2, 2.3, 18.6), const Radius.circular(1.05));
    c.drawRRect(pen, _fill..color = const Color(0xFF5BA4D6));
    c.drawRRect(pen, _stroke..strokeWidth = 1.2);
    c.drawPath(
      Path()
        ..moveTo(-1.15, 8.2)
        ..lineTo(0, 11)
        ..lineTo(1.15, 8.2)
        ..close(),
      _fill..color = const Color(0xFFE9EEF2),
    );
    c.restore();
  }

  void _cart(Canvas c) {
    final wire = _stroke
      ..strokeWidth = 2.15
      ..color = const Color(0xFFD0894B);
    c.drawLine(const Offset(-12.4, -8.2), const Offset(-8.2, -8.2), wire);
    c.drawLine(const Offset(-10.6, -8.2), const Offset(-7.2, -2.2), wire);
    final basket = Path()
      ..moveTo(-8.2, -2.2)
      ..lineTo(-5.2, 7.2)
      ..lineTo(9.4, 7.2)
      ..lineTo(11.4, -2.2)
      ..close();
    c.drawPath(basket, wire);
    c.drawLine(const Offset(-6.8, 2.4), const Offset(10.4, 2.4), wire..strokeWidth = 1.55);
    c.drawLine(const Offset(-2.2, -2.2), const Offset(-0.4, 7.2), wire..strokeWidth = 1.5);
    c.drawLine(const Offset(3.4, -2.2), const Offset(4.6, 7.2), wire..strokeWidth = 1.5);
    c.drawCircle(const Offset(-2.8, 11.1), 2.45, wire..strokeWidth = 2);
    c.drawCircle(const Offset(7.4, 11.1), 2.45, wire..strokeWidth = 2);
  }

  void _chat(Canvas c) {
    final back = RRect.fromRectAndRadius(const Rect.fromLTWH(-3.2, -11.4, 16.4, 12.2), const Radius.circular(6.2));
    c.drawRRect(back, _fill..color = const Color(0xFF7EC8C0));
    c.drawRRect(back, _stroke);
    final front = RRect.fromRectAndRadius(const Rect.fromLTWH(-13.2, -3.2, 16.6, 12.4), const Radius.circular(6.2));
    c.drawRRect(front, _fill..color = const Color(0xFFFFF6EA));
    c.drawRRect(front, _stroke);
    c.drawPath(
      Path()
        ..moveTo(-8.4, 8.4)
        ..lineTo(-11.6, 13.2)
        ..lineTo(-4.2, 9.2)
        ..close(),
      _fill..color = const Color(0xFFFFF6EA),
    );
    c.drawPath(
      Path()
        ..moveTo(-8.4, 8.4)
        ..lineTo(-11.6, 13.2)
        ..lineTo(-4.2, 9.2),
      _stroke..strokeWidth = 1.6,
    );
    for (final x in [-8.4, -5.2, -2.0]) {
      c.drawCircle(Offset(x, 3.1), 1.12, _fill..color = ink);
    }
  }

  void _people(Canvas c) {
    c.drawCircle(const Offset(-5, -6), 4.2, _fill..color = const Color(0xFFFFC56D));
    c.drawCircle(const Offset(-5, -6), 4.2, _stroke);
    c.drawCircle(const Offset(6, -5), 3.6, _fill..color = const Color(0xFFFFB0A0));
    c.drawCircle(const Offset(6, -5), 3.6, _stroke);
    c.drawOval(const Rect.fromLTWH(-12, 2, 14, 11), _fill..color = const Color(0xFF7DCEB8));
    c.drawOval(const Rect.fromLTWH(-12, 2, 14, 11), _stroke);
    c.drawOval(const Rect.fromLTWH(0, 3, 13, 10), _fill..color = const Color(0xFFFFC9A3));
    c.drawOval(const Rect.fromLTWH(0, 3, 13, 10), _stroke);
  }

  void _settings(Canvas c) {
    c.drawCircle(Offset.zero, 6.5, _fill..color = const Color(0xFFD9D3C8));
    c.drawCircle(Offset.zero, 6.5, _stroke);
    c.drawCircle(Offset.zero, 2.6, _fill..color = const Color(0xFFFFF8F0));
    for (var i = 0; i < 6; i++) {
      final a = i * math.pi / 3;
      c.drawCircle(Offset(math.cos(a) * 10, math.sin(a) * 10), 2.1, _fill..color = const Color(0xFFD9D3C8));
      c.drawCircle(Offset(math.cos(a) * 10, math.sin(a) * 10), 2.1, _stroke..strokeWidth = 1.8);
    }
  }

  void _sparkle(Canvas c) {
    void star(Offset o, double r, Color color) {
      final p = Path();
      for (var i = 0; i < 8; i++) {
        final ang = -math.pi / 2 + i * math.pi / 4;
        final rad = i.isEven ? r : r * 0.42;
        final pt = Offset(o.dx + math.cos(ang) * rad, o.dy + math.sin(ang) * rad);
        if (i == 0) {
          p.moveTo(pt.dx, pt.dy);
        } else {
          p.lineTo(pt.dx, pt.dy);
        }
      }
      p.close();
      c.drawPath(p, _fill..color = color);
      c.drawPath(p, _stroke..strokeWidth = 1.8);
    }

    star(const Offset(-3, -2), 10, const Color(0xFFFFC56D));
    star(const Offset(8, 7), 5, const Color(0xFFFF8A4C));
  }

  void _camera(Canvas c) {
    final body = RRect.fromRectAndRadius(const Rect.fromLTWH(-12, -6, 24, 16), const Radius.circular(4));
    c.drawRRect(body, _fill..color = const Color(0xFFE4D7FF));
    c.drawRRect(body, _stroke);
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-6, -11, 8, 5), const Radius.circular(1.5)), _fill..color = const Color(0xFFFFC56D));
    c.drawCircle(Offset.zero, 5, _fill..color = const Color(0xFF7DCEB8));
    c.drawCircle(Offset.zero, 5, _stroke);
    c.drawCircle(const Offset(-1.6, -1), 0.9, _fill..color = ink);
    c.drawCircle(const Offset(1.6, -1), 0.9, _fill..color = ink);
    c.drawArc(const Rect.fromLTWH(-2.4, 0.2, 4.8, 3.6), 0.2, 2.6, false, _stroke..strokeWidth = 1.2);
    c.drawCircle(const Offset(8, -3), 1.4, _fill..color = const Color(0xFFFF8A4C));
  }

  void _folder(Canvas c) {
    final tab = Path()
      ..moveTo(-12, -6)
      ..lineTo(-4, -6)
      ..lineTo(-1, -10)
      ..lineTo(6, -10)
      ..lineTo(6, -6);
    c.drawPath(tab, _fill..color = const Color(0xFFFFC56D));
    final body = RRect.fromRectAndRadius(const Rect.fromLTWH(-12, -6, 24, 18), const Radius.circular(3));
    c.drawRRect(body, _fill..color = const Color(0xFFFFE08A));
    c.drawRRect(body, _stroke);
  }

  void _document(Canvas c) {
    final page = Path()
      ..moveTo(-8, -12)
      ..lineTo(4, -12)
      ..lineTo(10, -6)
      ..lineTo(10, 12)
      ..lineTo(-8, 12)
      ..close();
    c.drawPath(page, _fill..color = const Color(0xFFF4FBFF));
    c.drawPath(page, _stroke);
    c.drawLine(const Offset(4, -12), const Offset(4, -6), _stroke);
    c.drawLine(const Offset(4, -6), const Offset(10, -6), _stroke);
  }

  void _chart(Canvas c) {
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-11, 2, 6, 10), const Radius.circular(2)), _fill..color = const Color(0xFF7DCEB8));
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-3, -6, 6, 18), const Radius.circular(2)), _fill..color = const Color(0xFFFFC56D));
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(5, -11, 6, 23), const Radius.circular(2)), _fill..color = const Color(0xFFFF8A4C));
    c.drawLine(const Offset(-13, 12), const Offset(13, 12), _stroke);
  }

  void _search(Canvas c) {
    c.drawCircle(const Offset(-3, -3), 8, _stroke..strokeWidth = 2.4);
    c.drawLine(const Offset(3, 3), const Offset(12, 12), _stroke..strokeWidth = 2.6);
  }

  void _orange(Canvas c) {
    c.drawCircle(Offset.zero, 12, _fill..color = const Color(0xFFFF9F43));
    c.drawCircle(Offset.zero, 12, _stroke);
    c.drawCircle(const Offset(-3.2, -1), 1.3, _fill..color = ink);
    c.drawCircle(const Offset(3.2, -1), 1.3, _fill..color = ink);
    c.drawArc(const Rect.fromLTWH(-4, 1, 8, 7), 0.3, 2.5, false, _stroke..strokeWidth = 1.7);
    c.drawOval(const Rect.fromLTWH(-2, -14, 4, 4), _fill..color = const Color(0xFF7DCEB8));
  }

  void _barcode(Canvas c) {
    final body = RRect.fromRectAndRadius(const Rect.fromLTWH(-12, -8, 24, 18), const Radius.circular(5));
    c.drawRRect(body, _fill..color = const Color(0xFFE8D9FF));
    c.drawRRect(body, _stroke);
    for (var i = 0; i < 7; i++) {
      final w = i.isEven ? 1.5 : 0.9;
      c.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(-8.5 + i * 2.5, -3.2, w, 10.4), const Radius.circular(0.4)),
        _fill..color = ink,
      );
    }
    c.drawCircle(const Offset(-5.2, -11.2), 2.1, _fill..color = const Color(0xFFFFC56D));
    c.drawCircle(const Offset(5.2, -11.2), 2.1, _fill..color = const Color(0xFFFFC56D));
  }

  void _heart(Canvas c) {
    final p = Path()
      ..moveTo(0, 11)
      ..cubicTo(-14, 2, -11, -10, 0, -4)
      ..cubicTo(11, -10, 14, 2, 0, 11);
    c.drawPath(p, _fill..color = const Color(0xFFFF8AA8));
    c.drawPath(p, _stroke);
    c.drawCircle(const Offset(-3.4, -1.2), 1.2, _fill..color = ink);
    c.drawCircle(const Offset(3.4, -1.2), 1.2, _fill..color = ink);
    c.drawArc(const Rect.fromLTWH(-3.6, 0.6, 7.2, 5), 0.25, 2.6, false, _stroke..strokeWidth = 1.4);
    c.drawOval(const Rect.fromLTWH(-7.2, -4.4, 3.4, 2.2), _fill..color = const Color(0x66FFFFFF));
  }

  void _fire(Canvas c) {
    final flame = Path()
      ..moveTo(0, 13)
      ..cubicTo(-11, 6, -9, -4, -4, -12)
      ..cubicTo(-2, -4, 1, -3, 0, -14)
      ..cubicTo(3, -5, 6, -6, 6, -10)
      ..cubicTo(12, -1, 10, 8, 0, 13);
    c.drawPath(flame, _fill..color = const Color(0xFFFF8A4C));
    c.drawPath(flame, _stroke);
    final inner = Path()
      ..moveTo(0, 9)
      ..cubicTo(-5, 4, -3, -2, 0, -6)
      ..cubicTo(3, -1, 5, 5, 0, 9);
    c.drawPath(inner, _fill..color = const Color(0xFFFFE08A));
    c.drawCircle(const Offset(-2.4, 2.2), 1.05, _fill..color = ink);
    c.drawCircle(const Offset(2.4, 2.2), 1.05, _fill..color = ink);
    c.drawArc(const Rect.fromLTWH(-2.6, 3.4, 5.2, 4), 0.3, 2.5, false, _stroke..strokeWidth = 1.3);
  }

  void _hourglass(Canvas c) {
    final glass = Path()
      ..moveTo(-8, -12)
      ..lineTo(8, -12)
      ..lineTo(3, 0)
      ..lineTo(8, 12)
      ..lineTo(-8, 12)
      ..lineTo(-3, 0)
      ..close();
    c.drawPath(glass, _fill..color = const Color(0xFFFFF3C4));
    c.drawPath(glass, _stroke);
    c.drawPath(
      Path()
        ..moveTo(-6.2, -10)
        ..lineTo(6.2, -10)
        ..lineTo(1.6, -2.2)
        ..lineTo(-1.6, -2.2)
        ..close(),
      _fill..color = const Color(0xFFFFC56D),
    );
    c.drawCircle(const Offset(-2.6, 4.4), 1.05, _fill..color = ink);
    c.drawCircle(const Offset(2.6, 4.4), 1.05, _fill..color = ink);
    c.drawArc(const Rect.fromLTWH(-2.8, 5.4, 5.6, 4), 0.2, 2.6, false, _stroke..strokeWidth = 1.25);
  }

  void _plate(Canvas c) {
    c.drawOval(const Rect.fromLTWH(-13, -6, 26, 18), _fill..color = const Color(0xFFF6FBFF));
    c.drawOval(const Rect.fromLTWH(-13, -6, 26, 18), _stroke);
    c.drawOval(const Rect.fromLTWH(-8.5, -2.2, 17, 10.4), _stroke..strokeWidth = 1.4);
    c.drawOval(const Rect.fromLTWH(-5, 0.4, 6.4, 4.4), _fill..color = const Color(0xFF7DCEB8));
    c.drawOval(const Rect.fromLTWH(1.2, 1.2, 5.2, 3.6), _fill..color = const Color(0xFFFF8A4C));
    c.drawCircle(const Offset(-3.2, -8.4), 1.4, _fill..color = const Color(0x66A8D8EA));
    c.drawCircle(const Offset(2.4, -9.2), 1.1, _fill..color = const Color(0x66A8D8EA));
  }

  @override
  bool shouldRepaint(covariant _KawaiiPainter oldDelegate) => oldDelegate.kind != kind;
}
