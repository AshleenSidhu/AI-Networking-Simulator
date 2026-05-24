import 'package:flutter/material.dart';

import '../layout/responsive.dart';
import '../navigation/connect_routes.dart';
import '../theme/connect_theme.dart';
import 'feedback_screen.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({
    super.key,
    required this.personaName,
    required this.personaRole,
  });

  final String personaName;
  final String personaRole;

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with SingleTickerProviderStateMixin {
  bool _muted = false;
  bool _whisperVisible = true;
  bool _goalsExpanded = false;
  late final AnimationController _pulse;

  static const _messages = [
    _Msg(false, "Hey! Good to finally connect — what's drawing you to this role specifically?"),
    _Msg(true, "Thanks for making the time. I've been following the team's ML infrastructure work and think my distributed systems background aligns well."),
    _Msg(false, "That's great — walk me through a project where you had to scale something under pressure."),
  ];

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _endCall() {
    connectPush(context, FeedbackScreen(personaName: widget.personaName));
  }

  bool get _aiSpeaking {
    if (_messages.isEmpty) return true;
    return !_messages.last.isUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConnectColors.background,
      body: SafeArea(
        child: ConnectPage(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(widget.personaName, style: connectTitle(context, size: 18)),
                        Text(widget.personaRole, style: connectMuted(13)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Column(
                  children: [
                    _AvatarPulse(pulse: _pulse, initials: _initials(widget.personaName), speaking: _aiSpeaking),
                    const SizedBox(height: 12),
                    Text('Live · 02:14', style: connectMuted(13)),
                    const SizedBox(height: 20),
                    if (_whisperVisible) _CoachWhisper(onDismiss: () => setState(() => _whisperVisible = false)),
                    const SizedBox(height: 16),
                    Expanded(child: _TranscriptPanel(messages: _messages)),
                    _GoalsPanel(expanded: _goalsExpanded, onToggle: () => setState(() => _goalsExpanded = !_goalsExpanded)),
                  ],
                ),
              ),
              _CallControls(
                muted: _muted,
                onMute: () => setState(() => _muted = !_muted),
                onEnd: _endCall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _Msg {
  const _Msg(this.isUser, this.text);
  final bool isUser;
  final String text;
}

class _AvatarPulse extends StatelessWidget {
  const _AvatarPulse({required this.pulse, required this.initials, required this.speaking});
  final Animation<double> pulse;
  final String initials;
  final bool speaking;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulse,
      builder: (_, __) {
        final scale = speaking ? 1 + pulse.value * 0.05 : 1.0;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  ConnectColors.accent.withValues(alpha: speaking ? 0.22 + pulse.value * 0.12 : 0.12),
                  ConnectColors.card,
                ],
              ),
              border: Border.all(
                color: ConnectColors.accent.withValues(alpha: speaking ? 0.55 : 0.25),
                width: speaking ? 2.5 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: ConnectColors.accent.withValues(alpha: speaking ? 0.28 : 0.12),
                  blurRadius: speaking ? 28 + pulse.value * 14 : 16,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(initials, style: connectTitle(context, size: 36)),
          ),
        );
      },
    );
  }
}

class _CoachWhisper extends StatelessWidget {
  const _CoachWhisper({required this.onDismiss});
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ConnectColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(ConnectColors.radius),
        border: Border.all(color: ConnectColors.accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.tips_and_updates_outlined, color: ConnectColors.accent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Lead with a specific outcome from your last project — numbers help.',
              style: connectMuted(13),
            ),
          ),
          GestureDetector(onTap: onDismiss, child: Icon(Icons.close, size: 18, color: ConnectColors.textMuted)),
        ],
      ),
    );
  }
}

class _TranscriptPanel extends StatelessWidget {
  const _TranscriptPanel({required this.messages});
  final List<_Msg> messages;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ConnectColors.card,
        borderRadius: BorderRadius.circular(ConnectColors.radius),
        border: Border.all(color: ConnectColors.border),
      ),
      child: ListView.separated(
        itemCount: messages.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final m = messages[i];
          return Align(
            alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: m.isUser ? ConnectColors.accent.withValues(alpha: 0.2) : ConnectColors.cardElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(m.text, style: TextStyle(fontSize: 13, height: 1.4, color: m.isUser ? ConnectColors.textPrimary : ConnectColors.textMuted)),
            ),
          );
        },
      ),
    );
  }
}

class _GoalsPanel extends StatelessWidget {
  const _GoalsPanel({required this.expanded, required this.onToggle});
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: ConnectColors.card,
        borderRadius: BorderRadius.circular(ConnectColors.radius),
        border: Border.all(color: ConnectColors.border),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(ConnectColors.radius),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Text('Session goals', style: connectTitle(context, size: 14)),
                  const Spacer(),
                  Icon(expanded ? Icons.expand_less : Icons.expand_more, color: ConnectColors.textMuted),
                ],
              ),
            ),
          ),
          if (expanded)
            const Padding(
              padding: EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GoalRow('Introduce yourself clearly'),
                  SizedBox(height: 8),
                  _GoalRow('Ask one thoughtful follow-up'),
                  SizedBox(height: 8),
                  _GoalRow('Close with a next step'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.radio_button_unchecked, size: 16, color: ConnectColors.accent),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: connectMuted(13))),
      ],
    );
  }
}

class _CallControls extends StatelessWidget {
  const _CallControls({
    required this.muted,
    required this.onMute,
    required this.onEnd,
  });

  final bool muted;
  final VoidCallback onMute;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ControlButton(
            icon: muted ? Icons.mic_off_rounded : Icons.mic_rounded,
            label: muted ? 'Unmute' : 'Mute',
            onTap: onMute,
          ),
          _ControlButton(
            icon: Icons.call_end_rounded,
            label: 'End',
            color: ConnectColors.danger,
            onTap: onEnd,
          ),
          _ControlButton(
            icon: Icons.graphic_eq_rounded,
            label: 'Hold',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final bg = color ?? ConnectColors.cardElevated;
    return Column(
      children: [
        Material(
          color: bg,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 56,
              height: 56,
              child: Icon(icon, color: ConnectColors.textPrimary),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: connectMuted(11)),
      ],
    );
  }
}