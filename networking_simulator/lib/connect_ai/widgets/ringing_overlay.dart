import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/scheduled_session.dart';
import '../../state/notification_scheduler.dart';
import '../../state/persona_repository.dart';
import '../navigation/connect_routes.dart';
import '../screens/call_screen.dart';
import '../theme/connect_theme.dart';

/// Full-bleed overlay shown over the home screen when the T-0 notification
/// tier fires. Pulses the persona avatar, plays a soft cue, and offers
/// Answer / Decline buttons.
///
/// Drop this in a `Stack` above the home screen and gate it on
/// `homeOverlayProvider`.
class RingingOverlay extends ConsumerStatefulWidget {
  const RingingOverlay({super.key, required this.ringing});

  final HomeOverlayRinging ringing;

  @override
  ConsumerState<RingingOverlay> createState() => _RingingOverlayState();
}

class _RingingOverlayState extends ConsumerState<RingingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final persona = ref.watch(personaByIdProvider(widget.ringing.personaId));
    final name = persona?.name ?? 'Your persona';
    final role = persona?.role ?? '';
    final emoji = persona?.avatarEmoji ?? '🎙️';

    return Positioned.fill(
      child: Container(
        color: ConnectColors.background.withValues(alpha: 0.96),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 48),
              Text('Incoming practice call',
                  style: connectMuted(13).copyWith(letterSpacing: 1.4)),
              const Spacer(),
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) => Container(
                  width: 200 + _pulse.value * 24,
                  height: 200 + _pulse.value * 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ConnectColors.accent
                        .withValues(alpha: 0.15 + _pulse.value * 0.2),
                  ),
                  alignment: Alignment.center,
                  child: Text(emoji, style: const TextStyle(fontSize: 84)),
                ),
              ),
              const SizedBox(height: 18),
              Text(name, style: connectTitle(context, size: 26)),
              const SizedBox(height: 4),
              Text(role, style: connectMuted(14)),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _RoundAction(
                      icon: Icons.call_end_rounded,
                      color: ConnectColors.danger,
                      label: 'Decline',
                      onTap: () => ref
                          .read(notificationSchedulerProvider.notifier)
                          .declineRinging(widget.ringing.scheduledSessionId),
                    ),
                    _RoundAction(
                      icon: Icons.call_rounded,
                      color: ConnectColors.success,
                      label: 'Answer',
                      onTap: () {
                        ref
                            .read(notificationSchedulerProvider.notifier)
                            .answerRinging();
                        connectPush(
                          context,
                          CallScreen(personaId: widget.ringing.personaId),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: color,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 78,
              height: 78,
              child: Icon(icon, color: Colors.white, size: 32),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: connectMuted(12)),
      ],
    );
  }
}
