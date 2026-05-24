import 'package:flutter/material.dart';

import '../layout/responsive.dart';
import '../navigation/connect_routes.dart';
import '../theme/connect_theme.dart';
import '../widgets/connect_widgets.dart';
import '../widgets/schedule_widgets.dart';
import '../widgets/session_form_widgets.dart';

class AddSessionScreen extends StatefulWidget {
  const AddSessionScreen({super.key});

  @override
  State<AddSessionScreen> createState() => _AddSessionScreenState();
}

class _AddSessionScreenState extends State<AddSessionScreen> {
  int _scenario = 0;
  int _dayIndex = 1;
  int _timeIndex = 6;
  String _difficulty = 'Medium';
  bool _reminder = true;
  int _reminderTiming = 1;

  static const _scenarios = [
    ('👔', 'Recruiter'),
    ('💰', 'Investor'),
    ('🤝', 'Networking'),
    ('💼', 'Hiring Manager'),
    ('🎓', 'Mentor'),
    ('🚀', 'Founder'),
  ];

  static const _times = [
    '8:00 AM', '9:00 AM', '10:00 AM', '12:00 PM',
    '2:00 PM', '4:00 PM', '6:30 PM', '8:00 PM',
  ];

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
    return Scaffold(
      backgroundColor: ConnectColors.background,
      body: SafeArea(
        child: ConnectPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const ConnectBackButton(),
                  Expanded(
                    child: Text(
                      'New Session',
                      textAlign: TextAlign.center,
                      style: connectTitle(context, size: 18),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 24),
                  children: [
                    sessionSectionTitle('Choose a scenario'),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 96,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _scenarios.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          final (emoji, label) = _scenarios[i];
                          return ScenarioChip(
                            emoji: emoji,
                            label: label,
                            selected: _scenario == i,
                            onTap: () => setState(() => _scenario = i),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 28),
                    sessionSectionTitle('Pick a date'),
                    const SizedBox(height: 12),
                    WeekStrip(
                      days: _weekDays,
                      selectedIndex: _dayIndex,
                      todayIndex: 1,
                      onDayTap: (i) => setState(() => _dayIndex = i),
                    ),
                    const SizedBox(height: 28),
                    sessionSectionTitle('Pick a time'),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _times.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, i) => TimeChip(
                          label: _times[i],
                          selected: _timeIndex == i,
                          onTap: () => setState(() => _timeIndex = i),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    sessionSectionTitle('Session settings'),
                    const SizedBox(height: 12),
                    SessionSettingsCard(
                      difficulty: _difficulty,
                      onDifficulty: (d) => setState(() => _difficulty = d),
                    ),
                    const SizedBox(height: 20),
                    sessionSectionTitle('Set a reminder'),
                    const SizedBox(height: 12),
                    SessionReminderCard(
                      enabled: _reminder,
                      timingIndex: _reminderTiming,
                      onToggle: (v) => setState(() => _reminder = v),
                      onTiming: (i) => setState(() => _reminderTiming = i),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              ConnectPrimaryButton(
                label: 'Schedule Session',
                onPressed: () => Navigator.pop(context),
              ),
              SizedBox(height: ConnectResponsive.isMobile(context) ? 8 : 16),
            ],
          ),
        ),
      ),
    );
  }
}
