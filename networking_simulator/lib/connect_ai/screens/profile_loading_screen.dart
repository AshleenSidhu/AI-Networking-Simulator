import 'package:flutter/material.dart';

import '../layout/responsive.dart';
import '../navigation/connect_routes.dart';
import '../theme/connect_theme.dart';
import 'home_shell.dart';

class ProfileLoadingScreen extends StatefulWidget {
  const ProfileLoadingScreen({super.key});

  @override
  State<ProfileLoadingScreen> createState() => _ProfileLoadingScreenState();
}

class _ProfileLoadingScreenState extends State<ProfileLoadingScreen>
    with TickerProviderStateMixin {
  static const _items = [
    'Analyzing your background',
    'Identifying your strengths',
    'Finding your blind spots',
    'Matching you with personas',
  ];

  int _completed = 0;
  late final AnimationController _spin;
  late final AnimationController _glow;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
    _glow = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat(reverse: true);
    _runSequence();
  }

  Future<void> _runSequence() async {
    for (var i = 0; i < _items.length; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      setState(() => _completed = i + 1);
    }
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    connectReplace(context, const HomeShell());
  }

  @override
  void dispose() {
    _spin.dispose();
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConnectColors.background,
      body: ConnectPage(
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _glow,
              builder: (_, __) {
                return Container(
                  width: 260 + _glow.value * 40 + _completed * 12,
                  height: 260 + _glow.value * 40 + _completed * 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        ConnectColors.accent.withValues(alpha: 0.15 + _completed * 0.04),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: AnimatedBuilder(
                        animation: _spin,
                        builder: (_, __) {
                          return CustomPaint(
                            painter: _ArcPainter(_spin.value),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text('Building your profile...', style: connectTitle(context, size: 22)),
                    const SizedBox(height: 8),
                    Text('This only takes a moment', style: connectMuted()),
                    const SizedBox(height: 40),
                    ...List.generate(_items.length, (i) {
                      final done = i < _completed;
                      return TweenAnimationBuilder<double>(
                        key: ValueKey('item_$i'),
                        tween: Tween(begin: 0, end: done ? 1 : 0),
                        duration: const Duration(milliseconds: 400),
                        builder: (_, value, child) {
                          return Opacity(
                            opacity: value.clamp(0.3, 1),
                            child: Transform.translate(
                              offset: Offset(0, (1 - value) * 12),
                              child: child,
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              Icon(
                                done ? Icons.check_circle : Icons.circle_outlined,
                                color: done ? ConnectColors.accent : ConnectColors.textMuted,
                                size: 22,
                              ),
                              const SizedBox(width: 14),
                              Text(
                                _items[i],
                                style: TextStyle(
                                  color: done ? ConnectColors.textPrimary : ConnectColors.textMuted,
                                  fontWeight: done ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final bg = Paint()
      ..color = ConnectColors.cardElevated
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final fg = Paint()
      ..color = ConnectColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect.deflate(4), 0, 6.28, false, bg);
    canvas.drawArc(rect.deflate(4), -1.57 + progress * 6.28, 2.2, false, fg);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) => old.progress != progress;
}
