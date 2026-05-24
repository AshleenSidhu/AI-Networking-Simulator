import 'package:flutter/material.dart';

import '../layout/responsive.dart';
import '../navigation/connect_routes.dart';
import '../theme/connect_theme.dart';
import '../widgets/connect_widgets.dart';
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
  String _difficulty = 'Medium';
  String _style = 'Conversational';
  String _industry = 'Tech';

  static const _templates = [
    ('👔', 'Recruiter', 'Recruiter', 'Practice a first-round screening call.'),
    ('💼', 'Hiring Manager', 'Hiring Manager', 'Navigate role fit and team dynamics.'),
    ('🤝', 'Networking Event', 'Networking Event', 'Break the ice at a professional mixer.'),
  ];

  @override
  void initState() {
    super.initState();
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

  Widget _body(BuildContext context) {
    return ConnectPage(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          Text('Choose a scenario', style: connectTitle(context, size: 24)),
          const SizedBox(height: 8),
          Text('Pick a template or build your own persona.', style: connectMuted()),
          const SizedBox(height: 24),
          ..._templates.map((t) {
            final (emoji, title, role, subtitle) = t;
            final selected = _selectedTemplate == title;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SelectableOptionCard(
                emoji: emoji,
                title: title,
                subtitle: subtitle,
                selected: selected,
                onTap: () {
                  setState(() => _selectedTemplate = title);
                  _openEditor(title: title, role: role);
                },
              ),
            );
          }),
          GestureDetector(
            onTap: () => _openEditor(title: 'Custom Persona', role: '', custom: true),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: ConnectColors.card,
                borderRadius: BorderRadius.circular(ConnectColors.radius),
                border: Border.all(color: ConnectColors.accent.withValues(alpha: 0.45)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: ConnectColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add_rounded, color: ConnectColors.accent),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Create custom', style: connectTitle(context, size: 16)),
                        const SizedBox(height: 4),
                        Text('Define your own role and prompt.', style: connectMuted(13)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: ConnectColors.textMuted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text('Session settings', style: connectTitle(context, size: 18)),
          const SizedBox(height: 12),
          _ChipRow(
            label: 'Difficulty',
            options: const ['Easy', 'Medium', 'Hard'],
            selected: _difficulty,
            onSelected: (v) => setState(() => _difficulty = v),
          ),
          const SizedBox(height: 12),
          _ChipRow(
            label: 'Style',
            options: const ['Conversational', 'Formal', 'Challenging'],
            selected: _style,
            onSelected: (v) => setState(() => _style = v),
          ),
          const SizedBox(height: 12),
          _ChipRow(
            label: 'Industry',
            options: const ['Tech', 'Finance', 'Healthcare'],
            selected: _industry,
            onSelected: (v) => setState(() => _industry = v),
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
        title: const Text('Scenarios'),
      ),
      body: _body(context),
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: connectMuted(12)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((o) {
            final active = o == selected;
            return ChoiceChip(
              label: Text(o),
              selected: active,
              onSelected: (_) => onSelected(o),
              selectedColor: ConnectColors.accent.withValues(alpha: 0.25),
              backgroundColor: ConnectColors.card,
              labelStyle: TextStyle(
                color: active ? ConnectColors.textPrimary : ConnectColors.textMuted,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
              side: BorderSide(color: active ? ConnectColors.accent : ConnectColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            );
          }).toList(),
        ),
      ],
    );
  }
}
