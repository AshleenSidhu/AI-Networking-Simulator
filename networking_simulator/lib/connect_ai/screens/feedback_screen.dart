import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../layout/responsive.dart';
import '../navigation/connect_routes.dart';
import '../state/connect_app_state.dart';
import '../theme/connect_theme.dart';
import '../widgets/connect_widgets.dart';
import 'home_screen.dart';
import 'scenario_select_screen.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key, required this.personaName});

  final String personaName;

  static const _metrics = [
    ('Clarity', 82),
    ('Confidence', 76),
    ('Engagement', 88),
    ('Structure', 71),
  ];

  @override
  Widget build(BuildContext context) {
    const score = 79;

    return Scaffold(
      backgroundColor: ConnectColors.background,
      appBar: AppBar(
        backgroundColor: ConnectColors.background,
        automaticallyImplyLeading: false,
        title: const Text('Session complete'),
      ),
      body: ConnectPage(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            Text(
              'Great work, ${ConnectScope.of(context).displayName.split(' ').first}!',
              style: connectTitle(context, size: 24),
            ),
            const SizedBox(height: 8),
            Text('Your practice call with $personaName is ready for review.', style: connectMuted()),
            const SizedBox(height: 28),
            const Center(child: _ScoreArc(score: score)),
            const SizedBox(height: 28),
            Text('Metrics', style: connectTitle(context, size: 18)),
            const SizedBox(height: 12),
            ..._metrics.map((m) => _MetricBar(label: m.$1, value: m.$2)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: ConnectColors.card,
                borderRadius: BorderRadius.circular(ConnectColors.radius),
                border: Border.all(color: ConnectColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Coach narrative', style: connectTitle(context, size: 16)),
                  const SizedBox(height: 10),
                  Text(
                    'You opened with a strong hook and tied your background to the role. '
                    'Try tightening your project story — lead with impact, then explain how. '
                    'Your follow-up question showed genuine curiosity; add one more to deepen rapport.',
                    style: connectMuted(14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const _NextSessionCard(),
            const SizedBox(height: 24),
            ConnectPrimaryButton(
              label: 'Practice again',
              onPressed: () => connectPush(context, const ScenarioSelectScreen()),
            ),
            const SizedBox(height: 12),
            ConnectPrimaryButton(
              label: 'Back to home',
              outlined: true,
              onPressed: () => connectReplace(context, const HomeShell()),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreArc extends StatelessWidget {
  const _ScoreArc({required this.score});
  final int score;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: CustomPaint(
        painter: _ArcPainter(score / 100),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$score', style: connectTitle(context, size: 42)),
              Text('Overall', style: connectMuted(12)),
            ],
          ),
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
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final bg = Paint()
      ..color = ConnectColors.cardElevated
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    final fg = Paint()
      ..color = ConnectColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi * 0.75, math.pi * 1.5, false, bg);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi * 0.75, math.pi * 1.5 * progress, false, fg);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) => oldDelegate.progress != progress;
}

class _MetricBar extends StatelessWidget {
  const _MetricBar({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Text('$value%', style: connectMuted(12)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 8,
              backgroundColor: ConnectColors.cardElevated,
              color: ConnectColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _NextSessionCard extends StatelessWidget {
  const _NextSessionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ConnectColors.card,
        borderRadius: BorderRadius.circular(ConnectColors.radius),
        border: Border(
          left: const BorderSide(color: ConnectColors.accent, width: 3),
          top: BorderSide(color: ConnectColors.border),
          right: BorderSide(color: ConnectColors.border),
          bottom: BorderSide(color: ConnectColors.border),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_available_rounded, color: ConnectColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Next session', style: connectTitle(context, size: 15)),
                const SizedBox(height: 4),
                Text('Schedule a follow-up to keep momentum.', style: connectMuted(12)),
              ],
            ),
          ),
          TextButton(onPressed: () {}, child: const Text('Schedule')),
        ],
      ),
    );
  }
}
