import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../layout/responsive.dart';
import '../navigation/connect_routes.dart';
import '../theme/connect_theme.dart';
import '../widgets/scenario/continue_practice_button.dart';
import '../widgets/scenario/industry_chip.dart';
import '../widgets/scenario/scenario_card.dart';
import '../widgets/scenario/session_preview_card.dart';
import 'persona_editor_screen.dart';

class ScenarioSelectScreen extends StatefulWidget {
  const ScenarioSelectScreen({
    super.key,
    this.embedded = false,
    this.initialScenario,
  });

  final bool embedded;
  final String? initialScenario;

  @override
  State<ScenarioSelectScreen> createState() => _ScenarioSelectScreenState();
}

class _ScenarioSelectScreenState extends State<ScenarioSelectScreen> {
  String? _selectedTemplate;
  String? _difficulty;
  String? _style;
  String? _industry;

  static const _templates = [
    ('👔', 'Recruiter', 'Recruiter', 'Practice a first-round screening call.'),
    ('💼', 'Hiring Manager', 'Hiring Manager', 'Navigate role fit and team dynamics.'),
    ('🤝', 'Networking Event', 'Networking Event', 'Break the ice at a professional mixer.'),
  ];

  static const _customTitle = 'Custom Persona';

  bool get _canContinue =>
      _selectedTemplate != null &&
      _difficulty != null &&
      _style != null &&
      _industry != null;

  @override
  void initState() {
    super.initState();
    if (widget.initialScenario != null) {
      _selectedTemplate = widget.initialScenario;
    }
  }

  void _openEditor({required String title, required String role, bool custom = false}) {
    connectPush(
      context,
      PersonaEditorScreen(
        scenarioTitle: title,
        initialRole: role,
        custom: custom,
      ),
    );
  }

  void _onContinue() {
    if (!_canContinue) return;

    if (_selectedTemplate == _customTitle) {
      _openEditor(title: _customTitle, role: '', custom: true);
      return;
    }

    final match = _templates.where((t) => t.$2 == _selectedTemplate);
    if (match.isEmpty) return;
    final (_, title, role, _) = match.first;
    _openEditor(title: title, role: role);
  }

  Widget _body(BuildContext context) {
    return ConnectPage(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          Text('Practice session', style: connectTitle(context, size: 26)),
          const SizedBox(height: 8),
          Text(
            'Configure your scenario and session settings, then customize your AI partner.',
            style: connectMuted(14),
          ),
          const SizedBox(height: 32),
          Text(
            'CHOOSE A SCENARIO',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: ConnectColors.textMuted,
            ),
          ),
          const SizedBox(height: 14),
          ..._templates.map((t) {
            final (emoji, title, _, subtitle) = t;
            final selected = _selectedTemplate == title;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ScenarioCard(
                emoji: emoji,
                title: title,
                subtitle: subtitle,
                selected: selected,
                onTap: () => setState(() => _selectedTemplate = title),
              ),
            );
          }),
          ScenarioCard(
            emoji: '',
            title: 'Create custom',
            subtitle: 'Define your own role and prompt.',
            selected: _selectedTemplate == _customTitle,
            onTap: () => setState(() => _selectedTemplate = _customTitle),
            trailingIcon: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: ConnectColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add_rounded, color: ConnectColors.accent),
            ),
          ),
          const SizedBox(height: 36),
          _SessionSettingsGroup(
            difficulty: _difficulty,
            style: _style,
            industry: _industry,
            onDifficulty: (v) => setState(() => _difficulty = v),
            onStyle: (v) => setState(() => _style = v),
            onIndustry: (v) => setState(() => _industry = v),
          ),
          const SizedBox(height: 24),
          SessionPreviewCard(
            scenario: _selectedTemplate,
            difficulty: _difficulty,
            conversationStyle: _style,
            industry: _industry,
          ),
          const SizedBox(height: 28),
          ContinuePracticeButton(
            enabled: _canContinue,
            onPressed: _onContinue,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) return _body(context);

    return Scaffold(
      backgroundColor: ConnectColors.background,
      appBar: AppBar(
        backgroundColor: ConnectColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Practice'),
      ),
      body: _body(context),
    );
  }
}

class _SessionSettingsGroup extends StatelessWidget {
  const _SessionSettingsGroup({
    required this.difficulty,
    required this.style,
    required this.industry,
    required this.onDifficulty,
    required this.onStyle,
    required this.onIndustry,
  });

  final String? difficulty;
  final String? style;
  final String? industry;
  final ValueChanged<String> onDifficulty;
  final ValueChanged<String> onStyle;
  final ValueChanged<String> onIndustry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      decoration: BoxDecoration(
        color: ConnectColors.card.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(ConnectColors.radius),
        border: Border.all(color: ConnectColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SESSION SETTINGS',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: ConnectColors.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          _SettingChipRow(
            label: 'Difficulty',
            options: const ['Easy', 'Medium', 'Hard'],
            selected: difficulty,
            onSelected: onDifficulty,
          ),
          const SizedBox(height: 22),
          _SettingChipRow(
            label: 'Conversation style',
            options: const ['Conversational', 'Formal', 'Challenging'],
            selected: style,
            onSelected: onStyle,
          ),
          const SizedBox(height: 22),
          Text(
            'Industry',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ConnectColors.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          IndustryChipRow(selected: industry, onSelected: onIndustry),
        ],
      ),
    );
  }
}

class _SettingChipRow extends StatelessWidget {
  const _SettingChipRow({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: ConnectColors.textMuted,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((o) {
            final active = o == selected;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelected(o),
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: active ? ConnectColors.accent.withValues(alpha: 0.2) : ConnectColors.cardElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: active ? ConnectColors.accent : ConnectColors.border,
                    ),
                  ),
                  child: Text(
                    o,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      color: active ? ConnectColors.textPrimary : ConnectColors.textMuted,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
