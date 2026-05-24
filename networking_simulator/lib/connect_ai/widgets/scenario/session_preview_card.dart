import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/connect_theme.dart';
import 'scenario_data.dart';

class SessionPreviewCard extends StatelessWidget {
  const SessionPreviewCard({
    super.key,
    required this.scenario,
    required this.difficulty,
    required this.conversationStyle,
    required this.industry,
    this.estimatedLength = '~10–15 min',
  });

  final String? scenario;
  final String? difficulty;
  final String? conversationStyle;
  final String? industry;
  final String estimatedLength;

  @override
  Widget build(BuildContext context) {
    final hasSelections =
        scenario != null && difficulty != null && conversationStyle != null && industry != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ConnectColors.card,
        borderRadius: BorderRadius.circular(ConnectColors.radius),
        border: Border.all(color: ConnectColors.border),
        boxShadow: ConnectColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Session Preview',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: ConnectColors.textPrimary,
                ),
              ),
              const Spacer(),
              Icon(Icons.schedule_rounded, size: 16, color: ConnectColors.textMuted.withValues(alpha: 0.9)),
              const SizedBox(width: 6),
              Text(estimatedLength, style: connectMuted(12)),
            ],
          ),
          const SizedBox(height: 14),
          if (!hasSelections)
            Text(
              'Complete your selections above to preview your session.',
              style: connectMuted(13),
            )
          else ...[
            _PreviewLine(
              icon: Icons.person_outline_rounded,
              text: scenario!,
            ),
            const SizedBox(height: 8),
            _PreviewLine(
              icon: Icons.speed_rounded,
              text: difficultyPreviewLabel(difficulty!),
            ),
            const SizedBox(height: 8),
            _PreviewLine(
              icon: Icons.chat_bubble_outline_rounded,
              text: conversationStylePreviewLabel(conversationStyle!),
            ),
            const SizedBox(height: 8),
            _PreviewLine(
              icon: Icons.business_center_outlined,
              text: industryPreviewLabel(industry!),
            ),
          ],
        ],
      ),
    );
  }
}

class _PreviewLine extends StatelessWidget {
  const _PreviewLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: ConnectColors.accent.withValues(alpha: 0.85)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.4,
              color: ConnectColors.textPrimary.withValues(alpha: 0.92),
            ),
          ),
        ),
      ],
    );
  }
}
