import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/persona.dart';
import '../../state/persona_repository.dart';
import '../navigation/connect_routes.dart';
import '../theme/connect_theme.dart';
import '../widgets/connect_widgets.dart';
import 'call_screen.dart';

class PersonaEditorScreen extends ConsumerStatefulWidget {
  const PersonaEditorScreen({super.key});

  @override
  ConsumerState<PersonaEditorScreen> createState() => _PersonaEditorScreenState();
}

class _PersonaEditorScreenState extends ConsumerState<PersonaEditorScreen> {
  final _nameCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  final _taglineCtrl = TextEditingController();
  final _promptCtrl = TextEditingController(text: _defaultTemplate);
  ScenarioCategory _category = ScenarioCategory.networking;
  String _voice = 'Aoede';
  String _difficulty = 'Medium';
  String _emoji = '🧑‍💼';
  bool _saving = false;

  static const _defaultTemplate = '''
# You are <Name> — <Role>

You are roleplaying <a short situational frame>. Be warm, direct, and stay in character.

## How you behave
- <Behavioral instruction 1>
- <Behavioral instruction 2>
- <Behavioral instruction 3>

## Tone
- <Tone notes>

## Hard rules
- Stay in character at all times.
- Never give the user feedback during the call.
- Keep turns short (1-3 sentences).

{{previous_summary_block}}
''';

  static const _voiceOptions = ['Aoede', 'Charon', 'Fenrir', 'Kore', 'Puck'];
  static const _difficultyOptions = ['Easy', 'Medium', 'Hard'];
  static const _emojiOptions = [
    '🧑‍💼', '👩‍💻', '🧑‍🔬', '🧑‍🎨', '🧑‍🚀', '🧑‍🍳', '🎤', '📚',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roleCtrl.dispose();
    _taglineCtrl.dispose();
    _promptCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty || _roleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and role are required.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final persona = Persona(
        id: '',
        name: _nameCtrl.text.trim(),
        role: _roleCtrl.text.trim(),
        scenarioCategory: _category,
        avatarEmoji: _emoji,
        voice: _voice,
        systemPromptTemplate: _promptCtrl.text,
        defaultDifficulty: _difficulty,
        isCustom: true,
        tagline: _taglineCtrl.text.trim().isEmpty
            ? null
            : _taglineCtrl.text.trim(),
      );
      final id = await ref
          .read(personaRepositoryProvider)
          .savePersona(persona);
      if (!mounted) return;
      connectReplace(context, CallScreen(personaId: id));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save persona: $e')),
      );
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConnectColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Create custom persona'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _emojiPicker(),
              const SizedBox(height: 16),
              _field(_nameCtrl, label: 'Name', hint: 'Sarah Chen'),
              const SizedBox(height: 12),
              _field(_roleCtrl,
                  label: 'Role',
                  hint: 'Senior Tech Recruiter at Acme Corp'),
              const SizedBox(height: 12),
              _field(_taglineCtrl,
                  label: 'Tagline (optional)',
                  hint: '15-min phone screen at a startup'),
              const SizedBox(height: 16),
              _dropdownRow(),
              const SizedBox(height: 16),
              Text('System prompt',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 6),
              Text(
                  'Markdown template. Use {{industry}}, {{goal}}, {{user_role}}, {{difficulty}} for personalization. {{previous_summary_block}} is auto-injected from the last session.',
                  style: connectMuted(11)),
              const SizedBox(height: 8),
              TextField(
                controller: _promptCtrl,
                maxLines: 14,
                style: const TextStyle(
                    fontFamily: 'monospace', fontSize: 12, height: 1.4),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: ConnectColors.card,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ConnectColors.radius),
                    borderSide: BorderSide(color: ConnectColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ConnectColors.radius),
                    borderSide: const BorderSide(
                        color: ConnectColors.accent, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ConnectPrimaryButton(
                label: _saving ? 'Saving...' : 'Save & Start Practice',
                onPressed: _saving ? () {} : _save,
              ),
              const SizedBox(height: 12),
              ConnectPrimaryButton(
                label: 'Cancel',
                outlined: true,
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emojiPicker() {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _emojiOptions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final e = _emojiOptions[i];
          final selected = e == _emoji;
          return GestureDetector(
            onTap: () => setState(() => _emoji = e),
            child: Container(
              width: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? ConnectColors.accent.withValues(alpha: 0.2)
                    : ConnectColors.card,
                borderRadius: BorderRadius.circular(ConnectColors.radius),
                border: Border.all(
                  color:
                      selected ? ConnectColors.accent : ConnectColors.border,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Text(e, style: const TextStyle(fontSize: 28)),
            ),
          );
        },
      ),
    );
  }

  Widget _field(TextEditingController c,
      {required String label, required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 6),
        TextField(
          controller: c,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: connectMuted(14),
            filled: true,
            fillColor: ConnectColors.card,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ConnectColors.radius),
              borderSide: BorderSide(color: ConnectColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ConnectColors.radius),
              borderSide: const BorderSide(
                  color: ConnectColors.accent, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _dropdownRow() {
    return Row(
      children: [
        Expanded(
          child: _dropdown<ScenarioCategory>(
            label: 'Category',
            value: _category,
            items: ScenarioCategory.values
                .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text('${c.emoji}  ${c.label}'),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _category = v ?? _category),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _dropdown<String>(
            label: 'Voice',
            value: _voice,
            items: _voiceOptions
                .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                .toList(),
            onChanged: (v) => setState(() => _voice = v ?? _voice),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _dropdown<String>(
            label: 'Difficulty',
            value: _difficulty,
            items: _difficultyOptions
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (v) => setState(() => _difficulty = v ?? _difficulty),
          ),
        ),
      ],
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: ConnectColors.card,
            borderRadius: BorderRadius.circular(ConnectColors.radius),
            border: Border.all(color: ConnectColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: ConnectColors.card,
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
