import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/connect_theme.dart';

/// Animated sound bars when the AI persona is "speaking" (UI mock only).
class AIWaveAnimation extends StatefulWidget {
  const AIWaveAnimation({
    super.key,
    required this.active,
    this.barCount = 7,
    this.color,
  });

  final bool active;
  final int barCount;
  final Color? color;

  @override
  State<AIWaveAnimation> createState() => _AIWaveAnimationState();
}

class _AIWaveAnimationState extends State<AIWaveAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant AIWaveAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) _syncAnimation();
  }

  void _syncAnimation() {
    if (widget.active) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? ConnectColors.accent;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      opacity: widget.active ? 1 : 0,
      child: SizedBox(
        height: 32,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.barCount, (i) {
                final phase = (_controller.value * 2 * math.pi) + (i * 0.65);
                final height = widget.active ? 6 + (20 * math.sin(phase).abs()) : 4.0;
                return Container(
                  width: 4,
                  height: height,
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.45 + (i % 3) * 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
