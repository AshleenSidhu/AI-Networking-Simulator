import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/connect_theme.dart';

class ContinuePracticeButton extends StatefulWidget {
  const ContinuePracticeButton({
    super.key,
    required this.enabled,
    required this.onPressed,
  });

  final bool enabled;
  final VoidCallback? onPressed;

  @override
  State<ContinuePracticeButton> createState() => _ContinuePracticeButtonState();
}

class _ContinuePracticeButtonState extends State<ContinuePracticeButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: enabled ? 1 : 0.45,
          child: GestureDetector(
            onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
            onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
            onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
            onTap: enabled ? widget.onPressed : null,
            child: AnimatedScale(
              scale: _pressed && enabled ? 0.98 : 1,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOutCubic,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ConnectColors.radius),
                  color: enabled ? ConnectColors.accent : ConnectColors.cardElevated,
                  border: Border.all(
                    color: enabled ? Colors.transparent : ConnectColors.border,
                  ),
                  boxShadow: enabled ? ConnectColors.cardShadow : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      enabled ? Icons.arrow_forward_rounded : Icons.lock_outline_rounded,
                      size: 20,
                      color: enabled ? Colors.white : ConnectColors.textMuted,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      enabled ? 'Continue' : 'Complete selections',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: enabled ? Colors.white : ConnectColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 220),
          crossFadeState:
              enabled ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              'Customize your AI partner before the call',
              textAlign: TextAlign.center,
              style: connectMuted(12),
            ),
          ),
          secondChild: const SizedBox(height: 4),
        ),
      ],
    );
  }
}
