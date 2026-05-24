import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/feedback_report.dart';
import '../../models/scheduled_session.dart';
import '../../state/feedback_controller.dart';
import '../../state/persona_repository.dart';
import '../navigation/connect_routes.dart';
import '../theme/connect_theme.dart';
import '../widgets/connect_widgets.dart';
import 'call_screen.dart';
import 'home_shell.dart';

class FeedbackScreen extends ConsumerWidget {
  const FeedbackScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(feedbackProvider(sessionId));

    return Scaffold(
      backgroundColor: ConnectColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () =>
              connectReplace(context, const HomeShell(initialIndex: 0)),
        ),
        title: Text('Session feedback',
            style: connectTitle(context, size: 18)),
      ),
      body: SafeArea(
        child: report.when(
          loading: () => const _LoadingView(),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Could not score this session: $e',
                  style: connectMuted(), textAlign: TextAlign.center),
            ),
          ),
          data: (r) => r.isStreaming
              ? const _LoadingView()
              : _FilledView(report: r),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: ConnectColors.accent),
          const SizedBox(height: 24),
          Text('Scoring your session...',
              style: connectTitle(context, size: 18)),
          const SizedBox(height: 6),
          Text('This usually takes a few seconds.', style: connectMuted()),
        ],
      ),
    );
  }
}

class _FilledView extends ConsumerWidget {
  const _FilledView({required this.report});
  final FeedbackReport report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextPersona =
        ref.watch(personaByIdProvider(report.recommendedNextPersonaId));

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Center(child: _ScoreGauge(score: report.score)),
            const SizedBox(height: 28),
            _Metrics(report: report),
            const SizedBox(height: 24),
            _NarrativeCard(
              title: 'Strongest moment',
              icon: Icons.star_rounded,
              body: report.strongestMoment,
            ),
            const SizedBox(height: 12),
            _BulletsCard(
              title: 'Where to focus next',
              icon: Icons.flag_rounded,
              bullets: report.areasForImprovement,
            ),
            const SizedBox(height: 24),
            if (nextPersona != null && nextPersona.id.isNotEmpty) ...[
              Text('Recommended next session',
                  style: connectTitle(context, size: 16)),
              const SizedBox(height: 8),
              _RecommendedCard(
                emoji: nextPersona.avatarEmoji,
                name: nextPersona.name,
                role: nextPersona.role,
                rationale: report.recommendedNextRationale,
              ),
              const SizedBox(height: 16),
              ConnectPrimaryButton(
                label: 'Schedule Practice',
                onPressed: () async {
                  final scheduled = ScheduledSession(
                    id: '',
                    personaId: nextPersona.id,
                    scheduledAt:
                        DateTime.now().add(const Duration(days: 1, hours: 6)),
                    firedAt: const {
                      NotificationTier.twoMin: null,
                      NotificationTier.thirtySec: null,
                      NotificationTier.atTime: null,
                    },
                    note: report.recommendedNextRationale,
                  );
                  await ref
                      .read(feedbackControllerProvider.notifier)
                      .scheduleNext(scheduled);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: ConnectColors.cardElevated,
                      content: Text(
                        'Scheduled. Tip: long-press in the schedule tab to '
                        'compress to 60 seconds for demo.',
                        style: connectMuted(13).copyWith(
                            color: ConnectColors.textPrimary),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              ConnectPrimaryButton(
                label: 'Practice this again now',
                outlined: true,
                onPressed: () => connectReplace(
                  context,
                  CallScreen(personaId: nextPersona.id),
                ),
              ),
            ] else
              ConnectPrimaryButton(
                label: 'Back to home',
                onPressed: () => connectReplace(
                  context,
                  const HomeShell(initialIndex: 0),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ScoreGauge extends StatelessWidget {
  const _ScoreGauge({required this.score});
  final int score;

  Color get _ring {
    if (score >= 85) return ConnectColors.success;
    if (score >= 65) return ConnectColors.accent;
    if (score >= 45) return ConnectColors.warning;
    return ConnectColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 180,
            height: 180,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 10,
              backgroundColor: ConnectColors.cardElevated,
              color: _ring,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$score',
                  style: const TextStyle(
                      fontSize: 56, fontWeight: FontWeight.w800)),
              Text('out of 100', style: connectMuted(12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metrics extends StatelessWidget {
  const _Metrics({required this.report});
  final FeedbackReport report;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _Chip(label: 'Fillers', value: '${report.fillerCount}')),
        const SizedBox(width: 10),
        Expanded(
          child: _Chip(
            label: 'Comm.',
            value: '${((report.skillScores['Communication'] ?? 0) * 100).round()}%',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Chip(
            label: 'Follow-up',
            value: '${((report.skillScores['Follow-up'] ?? 0) * 100).round()}%',
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: ConnectColors.card,
        borderRadius: BorderRadius.circular(ConnectColors.radius),
        border: Border.all(color: ConnectColors.border),
      ),
      child: Column(
        children: [
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 2),
          Text(label, style: connectMuted(11)),
        ],
      ),
    );
  }
}

class _NarrativeCard extends StatelessWidget {
  const _NarrativeCard({
    required this.title,
    required this.icon,
    required this.body,
  });
  final String title;
  final IconData icon;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ConnectColors.card,
        borderRadius: BorderRadius.circular(ConnectColors.radius),
        border: Border.all(color: ConnectColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: ConnectColors.accent, size: 18),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          Text(body, style: connectMuted(14).copyWith(height: 1.5)),
        ],
      ),
    );
  }
}

class _BulletsCard extends StatelessWidget {
  const _BulletsCard({
    required this.title,
    required this.icon,
    required this.bullets,
  });
  final String title;
  final IconData icon;
  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ConnectColors.card,
        borderRadius: BorderRadius.circular(ConnectColors.radius),
        border: Border.all(color: ConnectColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: ConnectColors.accent, size: 18),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          ...bullets.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  '),
                  Expanded(child: Text(b, style: connectMuted(14))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendedCard extends StatelessWidget {
  const _RecommendedCard({
    required this.emoji,
    required this.name,
    required this.role,
    required this.rationale,
  });
  final String emoji;
  final String name;
  final String role;
  final String rationale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ConnectColors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(ConnectColors.radius),
        border: Border.all(color: ConnectColors.accent.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: ConnectColors.accent.withValues(alpha: 0.2),
            child: Text(emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style:
                        const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                Text(role, style: connectMuted(12)),
                const SizedBox(height: 6),
                Text(rationale, style: connectMuted(12).copyWith(height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
