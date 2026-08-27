import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_theme.dart';

class WaterWave extends StatefulWidget {
  const WaterWave({
    super.key,
    required this.progress,
    required this.cartoon,
    this.size = 220,
  });

  final double progress;
  final bool cartoon;
  final double size;

  @override
  State<WaterWave> createState() => _WaterWaveState();
}

class _WaterWaveState extends State<WaterWave> with TickerProviderStateMixin {
  late final AnimationController _wave;
  late final AnimationController _fill;
  double _from = 0;
  double _to = 0;

  @override
  void initState() {
    super.initState();
    _from = widget.progress;
    _to = widget.progress;
    _wave = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _fill = AnimationController(vsync: this, duration: const Duration(milliseconds: 620))..value = 1;
  }

  @override
  void didUpdateWidget(covariant WaterWave oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _from = _currentProgress;
      _to = widget.progress;
      _fill.forward(from: 0);
    }
  }

  double get _currentProgress {
    final t = Curves.easeOutCubic.transform(_fill.value);
    return (_from + (_to - _from) * t).clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _wave.dispose();
    _fill.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reaction = widget.progress >= 1
        ? '🥳'
        : widget.progress > 0.7
            ? '😎'
            : widget.progress > 0.35
                ? '😊'
                : '😴';
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_wave, _fill]),
        builder: (context, _) {
          return CustomPaint(
            painter: _WavePainter(
              progress: _currentProgress,
              phase: _wave.value * math.pi * 2,
              cartoon: widget.cartoon,
            ),
            child: widget.cartoon
                ? Center(child: Text(reaction, style: TextStyle(fontSize: widget.size * 0.19)))
                : null,
          );
        },
      ),
    );
  }
}

class WaterSipGlass extends StatefulWidget {
  const WaterSipGlass({
    super.key,
    required this.progress,
    required this.onAdd,
    required this.cartoon,
    this.size = 220,
    this.sipLabel = '+250 ml',
    this.amountMl = 0,
  });

  final double progress;
  final VoidCallback onAdd;
  final bool cartoon;
  final double size;
  final String sipLabel;
  final int amountMl;

  @override
  State<WaterSipGlass> createState() => _WaterSipGlassState();
}

class _WaterSipGlassState extends State<WaterSipGlass> with TickerProviderStateMixin {
  late final AnimationController _burst;
  late final AnimationController _bounce;
  final _seeds = List<double>.generate(7, (i) => (i + 1) * 0.13);

  @override
  void initState() {
    super.initState();
    _burst = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _bounce = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
  }

  @override
  void dispose() {
    _burst.dispose();
    _bounce.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant WaterSipGlass oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.amountMl > oldWidget.amountMl || widget.progress > oldWidget.progress) {
      _play();
    }
  }

  Future<void> _play() async {
    HapticFeedback.lightImpact();
    _burst.forward(from: 0);
    await _bounce.forward(from: 0);
    if (mounted) await _bounce.reverse();
  }

  void _sip() => widget.onAdd();

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return SizedBox(
      width: size + 24,
      height: size + 72,
      child: AnimatedBuilder(
        animation: Listenable.merge([_burst, _bounce]),
        builder: (context, _) {
          final bounce = 1 + (math.sin(_bounce.value * math.pi) * 0.08);
          final burst = Curves.easeOut.transform(_burst.value);
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Transform.scale(
                scale: bounce,
                child: GestureDetector(
                  onTap: _sip,
                  child: WaterWave(progress: widget.progress, cartoon: widget.cartoon, size: size),
                ),
              ),
              for (var i = 0; i < _seeds.length; i++)
                if (_burst.value > 0 && _burst.value < 1)
                  _fallingDrop(
                    index: i,
                    size: size,
                    t: burst,
                    seed: _seeds[i],
                  ),
              if (burst > 0 && burst < 1)
                Opacity(
                  opacity: (1 - burst).clamp(0, 1),
                  child: Transform.translate(
                    offset: Offset(0, -size * 0.18 - burst * 36),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3C4),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 3))],
                      ),
                      child: Text(
                        widget.sipLabel,
                        style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF2A6F97)),
                      ),
                    ),
                  ),
                ),
              Positioned(
                bottom: 0,
                child: Material(
                  color: AppColors.accent,
                  shape: const CircleBorder(),
                  elevation: 4,
                  shadowColor: AppColors.accent.withValues(alpha: 0.45),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _sip,
                    child: const Padding(
                      padding: EdgeInsets.all(14),
                      child: Icon(Icons.add_rounded, color: Colors.white, size: 28),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _fallingDrop({required int index, required double size, required double t, required double seed}) {
    final dx = (seed - 0.5) * size * 0.7;
    final startY = -size * 0.55;
    final endY = size * 0.12;
    final y = startY + (endY - startY) * t;
    final opacity = (1 - t).clamp(0.0, 1.0);
    final scale = 0.7 + seed * 0.5;
    return Transform.translate(
      offset: Offset(dx, y),
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: scale * (1.1 - t * 0.3),
          child: const Text('💧', style: TextStyle(fontSize: 22, height: 1)),
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({required this.progress, required this.phase, required this.cartoon});

  final double progress;
  final double phase;
  final bool cartoon;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final radius = size.shortestSide / 2;
    final center = size.center(Offset.zero);
    final clip = Path()..addOval(Rect.fromCircle(center: center, radius: radius - 6));
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = cartoon ? 5 : 3
        ..color = AppColors.accent,
    );
    canvas.save();
    canvas.clipPath(clip);
    final waterTop = size.height * (1 - progress);
    final path = Path()..moveTo(0, waterTop);
    for (double x = 0; x <= size.width; x++) {
      final y = waterTop + math.sin((x / size.width * math.pi * 2) + phase) * 8;
      path.lineTo(x, y);
    }
    path
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, waterTop),
        Offset(0, size.height),
        [AppColors.accent.withValues(alpha: 0.75), const Color(0xFF0077B6)],
      );
    canvas.drawPath(path, paint);
    canvas.restore();
    canvas.drawRect(rect, Paint()..color = Colors.transparent);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.phase != phase;
}

class BeforeAfterSlider extends StatefulWidget {
  const BeforeAfterSlider({super.key, required this.before, required this.after});

  final ImageProvider? before;
  final ImageProvider? after;

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  double _value = 0.5;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.isCartoon ? 28 : 20),
        child: LayoutBuilder(
          builder: (context, c) {
            return Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(
                  color: AppColors.peach.withValues(alpha: 0.4),
                  child: widget.after == null
                      ? const Center(child: Text('Sonra'))
                      : Image(image: widget.after!, fit: BoxFit.cover),
                ),
                ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: _value,
                    child: SizedBox(
                      width: c.maxWidth,
                      child: widget.before == null
                          ? ColoredBox(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              child: const Center(child: Text('Önce')),
                            )
                          : Image(image: widget.before!, fit: BoxFit.cover),
                    ),
                  ),
                ),
                Positioned(
                  left: c.maxWidth * _value - 1,
                  top: 0,
                  bottom: 0,
                  child: Container(width: 3, color: Colors.white),
                ),
                Positioned.fill(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 0,
                      overlayShape: SliderComponentShape.noOverlay,
                      thumbColor: AppColors.primary,
                    ),
                    child: Slider(
                      value: _value,
                      onChanged: (v) => setState(() => _value = v),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
