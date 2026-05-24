import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/scheduled_session.dart';
import '../../state/persona_repository.dart';
import '../../state/schedule_controller.dart';
import '../layout/responsive.dart';
import '../navigation/connect_routes.dart';
import '../theme/connect_theme.dart';
import '../widgets/connect_widgets.dart';
import 'call_screen.dart';
import 'scenario_select_screen.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(scheduledSessionsProvider);

    final content = async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Center(child: CircularProgressIndicator(color: ConnectColors.accent)),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Center(
          child: Text('Could not load schedule: $e', style: connectMuted()),
        ),
      ),
      data: (sessions) => sessions.isEmpty
          ? _EmptyState(embedded: embedded)
          : Column(
              children: sessions
                  .map((s) => _ScheduleRow(session: s))
                  .toList(growable: false),
            ),
    );

    final page = ConnectPage(
      fullWidth: embedded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!embedded) const SizedBox(height: 16),
          Text('Your schedule', style: connectTitle(context, size: 24)),
          const SizedBox(height: 4),
          Text('Reminders fire at T-2 min, T-30 sec, and T-0.',
              style: connectMuted()),
          const SizedBox(height: 20),
          content,
        ],
      ),
    );

    if (embedded) return SingleChildScrollView(child: page);
    return Scaffold(
      backgroundColor: ConnectColors.background,
      body: SafeArea(child: SingleChildScrollView(child: page)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.embedded});
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.calendar_today_rounded,
              size: 40, color: ConnectColors.textMuted),
          const SizedBox(height: 14),
          Text('No upcoming sessions',
              style: connectTitle(context, size: 16)),
          const SizedBox(height: 4),
          Text('Schedule one from any feedback screen, or kick off a free practice now.',
              textAlign: TextAlign.center, style: connectMuted(13)),
          const SizedBox(height: 18),
          ConnectPrimaryButton(
            label: 'Pick a scenario',
            onPressed: () => connectPush(
              context,
              const ScenarioSelectScreen(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleRow extends ConsumerWidget {
  const _ScheduleRow({required this.session});
  final ScheduledSession session;

  String _fmtDate(DateTime when) {
    final now = DateTime.now();
    final delta = when.difference(now);
    if (delta.inDays.abs() > 0) {
      final days = delta.inDays;
      return days > 0 ? 'in $days day${days == 1 ? '' : 's'}' : '${-days}d ago';
    }
    if (delta.inHours.abs() > 0) {
      final hrs = delta.inHours;
      return hrs > 0 ? 'in ${hrs}h' : '${-hrs}h ago';
    }
    if (delta.inMinutes.abs() > 0) {
      final m = delta.inMinutes;
      return m > 0 ? 'in ${m}m' : '${-m}m ago';
    }
    return 'now';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final persona = ref.watch(personaByIdProvider(session.personaId));
    final controller = ref.read(scheduleControllerProvider.notifier);
    // See _UpcomingCard for the rationale: Stack + Positioned stripe to
    // sidestep Flutter's "uniform colors" rule for rounded borders.
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ConnectColors.card,
        borderRadius: BorderRadius.circular(ConnectColors.radius),
        border: Border.all(color: ConnectColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 3,
            child: ColoredBox(color: ConnectColors.accent),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: ConnectColors.cardElevated,
                  child: Text(persona?.avatarEmoji ?? '🎙️',
                      style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(persona?.name ?? 'Persona',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(
                        _fmtDate(session.scheduledAt) +
                            (session.note == null ? '' : ' · ${session.note!}'),
                        style: connectMuted(12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Start now',
                  icon: const Icon(Icons.play_arrow_rounded, color: ConnectColors.accent),
                  onPressed: () => connectPush(
                    context,
                    CallScreen(personaId: session.personaId),
                  ),
                ),
                IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(Icons.close_rounded, color: ConnectColors.textMuted),
                  onPressed: () => controller.deleteSession(session.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
