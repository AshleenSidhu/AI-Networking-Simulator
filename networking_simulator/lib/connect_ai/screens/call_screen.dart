import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/session.dart';
import '../../models/transcript_turn.dart';
import '../../state/persona_repository.dart';
import '../../state/session_controller.dart';
import '../layout/responsive.dart';
import '../navigation/connect_routes.dart';
import '../theme/connect_theme.dart';
import 'feedback_screen.dart';

/// Phone-call UI. Owns the live conversation lifecycle by reading
/// `sessionControllerProvider(personaId)` and rendering the four phases.
class CallScreen extends ConsumerWidget {
  const CallScreen({super.key, required this.personaId});

  final String personaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sessionControllerProvider(personaId));
    final persona = ref.watch(personaByIdProvider(personaId));

    Widget body;
    switch (state.phase) {
      case SessionPhase.connecting:
        body = _ConnectingView(personaName: persona?.name ?? 'your persona');
      case SessionPhase.live:
      case SessionPhase.ended:
        body = _LiveView(
          state: state,
          personaName: persona?.name ?? '',
          personaRole: persona?.role ?? '',
          personaEmoji: persona?.avatarEmoji ?? '🎙️',
          onEnd: () async {
            final notifier =
                ref.read(sessionControllerProvider(personaId).notifier);
            await notifier.hangUp();
            if (!context.mounted) return;
            connectReplace(
              context,
              FeedbackScreen(sessionId: state.sessionId),
            );
          },
          onMute: () =>
              ref.read(sessionControllerProvider(personaId).notifier).toggleMute(),
          onPushToTalk: (down) => ref
              .read(sessionControllerProvider(personaId).notifier)
              .pushToTalk(down),
        );
      case SessionPhase.error:
        body = _ErrorView(message: state.error ?? 'Unknown error');
    }

    return Scaffold(
      backgroundColor: ConnectColors.background,
      body: SafeArea(
        child: ConnectPage(child: body),
      ),
    );
  }
}

class _ConnectingView extends StatelessWidget {
  const _ConnectingView({required this.personaName});
  final String personaName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: ConnectColors.accent),
          const SizedBox(height: 24),
          Text('Connecting to $personaName...',
              style: connectTitle(context, size: 18)),
          const SizedBox(height: 8),
          Text('Hold tight — opening the line.', style: connectMuted()),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: ConnectColors.danger, size: 56),
          const SizedBox(height: 16),
          Text('Call failed', style: connectTitle(context, size: 22)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(message,
                textAlign: TextAlign.center, style: connectMuted()),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }
}

class _LiveView extends StatelessWidget {
  const _LiveView({
    required this.state,
    required this.personaName,
    required this.personaRole,
    required this.personaEmoji,
    required this.onEnd,
    required this.onMute,
    required this.onPushToTalk,
  });

  final SessionState state;
  final String personaName;
  final String personaRole;
  final String personaEmoji;
  final VoidCallback onEnd;
  final VoidCallback onMute;
  final void Function(bool isDown) onPushToTalk;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        _AvatarHeader(
          emoji: personaEmoji,
          name: personaName,
          role: personaRole,
          isAiSpeaking: state.isAiSpeaking,
          elapsed: state.elapsed,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: _TranscriptPanel(transcript: state.transcript),
        ),
        const SizedBox(height: 16),
        _CallControls(
          isMuted: state.isMuted,
          isPushToTalkDown: state.isPushToTalkDown,
          onMute: onMute,
          onPushToTalk: onPushToTalk,
          onEnd: onEnd,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _AvatarHeader extends StatelessWidget {
  const _AvatarHeader({
    required this.emoji,
    required this.name,
    required this.role,
    required this.isAiSpeaking,
    required this.elapsed,
  });

  final String emoji;
  final String name;
  final String role;
  final bool isAiSpeaking;
  final Duration elapsed;

  String _fmt(Duration d) {
    final mm = d.inMinutes.toString().padLeft(2, '0');
    final ss = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: isAiSpeaking ? 156 : 140,
          height: isAiSpeaking ? 156 : 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ConnectColors.accent.withValues(alpha: 0.18),
            boxShadow: isAiSpeaking
                ? [
                    BoxShadow(
                      color: ConnectColors.accent.withValues(alpha: 0.4),
                      blurRadius: 36,
                      spreadRadius: 4,
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(emoji, style: const TextStyle(fontSize: 64)),
        ),
        const SizedBox(height: 14),
        Text(name, style: connectTitle(context, size: 22)),
        Text(role, style: connectMuted(13)),
        const SizedBox(height: 6),
        Text(_fmt(elapsed),
            style: const TextStyle(
                color: ConnectColors.accent,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2)),
      ],
    );
  }
}

class _TranscriptPanel extends StatefulWidget {
  const _TranscriptPanel({required this.transcript});
  final List<TranscriptTurn> transcript;

  @override
  State<_TranscriptPanel> createState() => _TranscriptPanelState();
}

class _TranscriptPanelState extends State<_TranscriptPanel> {
  final _scroll = ScrollController();

  @override
  void didUpdateWidget(covariant _TranscriptPanel old) {
    super.didUpdateWidget(old);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.transcript.isEmpty) {
      return Center(
        child: Text('Waiting for the conversation to start...',
            style: connectMuted()),
      );
    }
    return ListView.separated(
      controller: _scroll,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      itemCount: widget.transcript.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final turn = widget.transcript[i];
        final isUser = turn.speaker == Speaker.user;
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.78,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isUser
                  ? ConnectColors.accent.withValues(alpha: 0.22)
                  : ConnectColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isUser
                    ? ConnectColors.accent.withValues(alpha: 0.4)
                    : ConnectColors.border,
              ),
            ),
            child: Text(
              turn.text + (turn.isPartial ? '...' : ''),
              style: TextStyle(
                color: ConnectColors.textPrimary,
                fontStyle:
                    turn.isPartial ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CallControls extends StatelessWidget {
  const _CallControls({
    required this.isMuted,
    required this.isPushToTalkDown,
    required this.onMute,
    required this.onPushToTalk,
    required this.onEnd,
  });

  final bool isMuted;
  final bool isPushToTalkDown;
  final VoidCallback onMute;
  final void Function(bool isDown) onPushToTalk;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _RoundButton(
          icon: isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
          color: isMuted ? ConnectColors.warning : ConnectColors.cardElevated,
          iconColor: isMuted
              ? ConnectColors.background
              : ConnectColors.textPrimary,
          label: isMuted ? 'Unmute' : 'Mute',
          onTap: onMute,
        ),
        _RoundButton(
          icon: Icons.call_end_rounded,
          color: ConnectColors.danger,
          iconColor: Colors.white,
          label: 'End',
          onTap: onEnd,
          large: true,
        ),
        GestureDetector(
          onTapDown: (_) => onPushToTalk(true),
          onTapUp: (_) => onPushToTalk(false),
          onTapCancel: () => onPushToTalk(false),
          child: _RoundButton(
            icon: Icons.spatial_audio_off_rounded,
            color: isPushToTalkDown
                ? ConnectColors.accent
                : ConnectColors.cardElevated,
            iconColor: ConnectColors.textPrimary,
            label: 'Hold',
            onTap: null,
          ),
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.large = false,
  });

  final IconData icon;
  final Color color;
  final Color iconColor;
  final String label;
  final VoidCallback? onTap;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final size = large ? 72.0 : 60.0;
    return Column(
      children: [
        Material(
          color: color,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(icon, color: iconColor, size: large ? 30 : 24),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: connectMuted(11)),
      ],
    );
  }
}
