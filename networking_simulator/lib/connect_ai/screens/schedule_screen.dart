import 'package:flutter/material.dart';

import '../layout/responsive.dart';
import '../navigation/connect_routes.dart';
import '../theme/connect_theme.dart';
import '../widgets/connect_widgets.dart';
import '../widgets/schedule_widgets.dart';
import 'add_session_screen.dart';
import 'edit_session_screen.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key, this.embedded = true});

  final bool embedded;

  static const _weekDays = [
    WeekDay(label: 'MON', date: 10),
    WeekDay(label: 'TUE', date: 11, hasSession: true),
    WeekDay(label: 'WED', date: 12),
    WeekDay(label: 'THU', date: 13, hasSession: true),
    WeekDay(label: 'FRI', date: 14),
    WeekDay(label: 'SAT', date: 15),
    WeekDay(label: 'SUN', date: 16),
  ];

  @override
  Widget build(BuildContext context) {
    final content = ConnectPage(
      fullWidth: embedded && ConnectResponsive.useSideNavigation(context),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Your Schedule', style: connectTitle(context, size: 24)),
              IconButton(
                onPressed: () {},
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ConnectColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ConnectColors.border),
                  ),
                  child: const Icon(Icons.calendar_month_outlined, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _AiRecommendationsSection(),
          const SizedBox(height: 24),
          WeekStrip(
            days: _weekDays,
            selectedIndex: 1,
            todayIndex: 1,
            onDayTap: (_) {},
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Upcoming Sessions', style: connectTitle(context, size: 18)),
              TextButton(
                onPressed: () => connectSlideUp(context, const AddSessionScreen()),
                child: const Text(
                  '+ Add Session',
                  style: TextStyle(color: ConnectColors.accent, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _UpcomingSessionCard(
            dayLabel: 'TUE',
            date: 11,
            time: '6:30 PM',
            title: 'Recruiter Practice',
            subtitle: 'Tomorrow · 15 minutes',
            chips: const ['Medium 🟡', '👔 Recruiter'],
            blockColor: ConnectColors.accent,
            onEdit: () => connectSlideUp(context, const EditSessionScreen()),
          ),
          _UpcomingSessionCard(
            dayLabel: 'THU',
            date: 13,
            time: '4:00 PM',
            title: 'Networking Event Practice',
            subtitle: 'Thursday · 10 minutes',
            chips: const ['Easy 🟢', '🤝 Networking'],
            blockColor: ConnectColors.warning,
            onEdit: () => connectSlideUp(context, const EditSessionScreen()),
          ),
          _UpcomingSessionCard(
            dayLabel: 'SAT',
            date: 15,
            time: '11:00 AM',
            title: 'Investor Pitch Practice',
            subtitle: 'Saturday · 15 minutes',
            chips: const ['Hard 🔴', '💰 Investor'],
            blockColor: ConnectColors.cardElevated,
            mutedBlock: true,
            onEdit: () => connectSlideUp(context, const EditSessionScreen()),
          ),
          const SizedBox(height: 28),
          Text('Past Sessions', style: connectMuted(12)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('See 12 past sessions', style: connectMuted(14)),
                  Text('›', style: connectMuted(18)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );

    if (embedded) return content;

    return Scaffold(
      backgroundColor: ConnectColors.background,
      body: content,
    );
  }
}

class _AiRecommendationsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ConnectColors.card,
        borderRadius: BorderRadius.circular(ConnectColors.radius),
        border: Border(
          left: BorderSide(color: ConnectColors.accent, width: 3),
          top: BorderSide(color: ConnectColors.border),
          right: BorderSide(color: ConnectColors.border),
          bottom: BorderSide(color: ConnectColors.border),
        ),
        boxShadow: [
          BoxShadow(
            color: ConnectColors.accent.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: ConnectColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(ConnectColors.radius),
            ),
            child: const Text(
              '✦ AI Coach',
              style: TextStyle(color: ConnectColors.accent, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
          _RecommendationCard(
            borderColor: ConnectColors.accent,
            badge: '📈 Based on your last session',
            body:
                'You struggled with behavioral questions. We recommend a 15-minute recruiter practice tomorrow at 6:30 PM.',
            buttonLabel: '+ Add to Schedule',
            buttonColor: ConnectColors.accent,
          ),
          const SizedBox(height: 12),
          _RecommendationCard(
            borderColor: ConnectColors.warning,
            badge: '📅 Upcoming opportunity',
            body:
                'You have a networking event in 3 days. We recommend two additional practice sessions this week.',
            buttonLabel: '+ Add to Schedule',
            buttonColor: ConnectColors.warning,
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.borderColor,
    required this.badge,
    required this.body,
    required this.buttonLabel,
    required this.buttonColor,
  });

  final Color borderColor;
  final String badge;
  final String body;
  final String buttonLabel;
  final Color buttonColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ConnectColors.cardElevated,
        borderRadius: BorderRadius.circular(ConnectColors.radius),
        border: Border(left: BorderSide(color: borderColor, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(badge, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Text(body, style: connectMuted(13)),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => connectSlideUp(context, const AddSessionScreen()),
              style: TextButton.styleFrom(
                foregroundColor: buttonColor,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              child: Text(buttonLabel, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingSessionCard extends StatelessWidget {
  const _UpcomingSessionCard({
    required this.dayLabel,
    required this.date,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.chips,
    required this.blockColor,
    required this.onEdit,
    this.mutedBlock = false,
  });

  final String dayLabel;
  final int date;
  final String time;
  final String title;
  final String subtitle;
  final List<String> chips;
  final Color blockColor;
  final VoidCallback onEdit;
  final bool mutedBlock;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ConnectColors.card,
        borderRadius: BorderRadius.circular(ConnectColors.radius),
        border: Border.all(color: ConnectColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: mutedBlock ? ConnectColors.cardElevated : blockColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  dayLabel,
                  style: TextStyle(
                    fontSize: 10,
                    color: mutedBlock ? ConnectColors.textMuted : ConnectColors.textMuted,
                  ),
                ),
                Text(
                  '$date',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    color: mutedBlock ? ConnectColors.textMuted : ConnectColors.textPrimary,
                  ),
                ),
                Text(time, style: connectMuted(9)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(subtitle, style: connectMuted(12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: chips.map((c) => SessionMetaChip(label: c)).toList(),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: ConnectColors.textMuted, size: 20),
            color: ConnectColors.card,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: ConnectColors.danger))),
            ],
            onSelected: (v) {
              if (v == 'edit') onEdit();
            },
          ),
        ],
      ),
    );
  }
}
