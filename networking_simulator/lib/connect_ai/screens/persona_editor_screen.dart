import 'package:flutter/material.dart';

import '../layout/responsive.dart';
import '../navigation/connect_routes.dart';
import '../theme/connect_theme.dart';
import '../widgets/connect_widgets.dart';
import 'call_screen.dart';

class PersonaEditorScreen extends StatefulWidget {
  const PersonaEditorScreen({
    super.key,
    required this.scenarioTitle,
    this.initialRole = '',
    this.custom = false,
  });

  final String scenarioTitle;
  final String initialRole;
  final bool custom;

  @override
  State<PersonaEditorScreen> createState() => _PersonaEditorScreenState();
}

class _PersonaEditorScreenState extends State<PersonaEditorScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _roleCtrl;
  late final TextEditingController _promptCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(
      text: widget.custom ? '' : _defaultName(widget.scenarioTitle),
    );
    _roleCtrl = TextEditingController(text: widget.initialRole);
    _promptCtrl = TextEditingController(text: _defaultPrompt(widget.scenarioTitle));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roleCtrl.dispose();
    _promptCtrl.dispose();
    super.dispose();
  }

  String _defaultName(String title) {
    return switch (title) {
      'Recruiter' => 'Alex Chen',
      'Hiring Manager' => 'Jordan Lee',
      'Networking Event' => 'Sam Rivera',
      _ => 'Custom Persona',
    };
  }

  String _defaultPrompt(String title) {
    return switch (title) {
      'Recruiter' =>
        'You are a friendly tech recruiter screening candidates for a senior software role. Ask about experience, motivation, and culture fit.',
      'Hiring Manager' =>
        'You are a hiring manager evaluating technical depth and collaboration style. Probe past projects and decision-making.',
      'Networking Event' =>
        'You are a professional at a networking mixer. Start casual, then steer toward mutual interests and follow-ups.',
      _ =>
        'Describe how this persona should behave, their tone, and what they want to learn about the candidate.',
    };
  }

  void _startCall() {
    connectPush(
      context,
      CallScreen(
        personaName: _nameCtrl.text.trim().isEmpty ? 'Practice Partner' : _nameCtrl.text.trim(),
        personaRole: _roleCtrl.text.trim().isEmpty ? widget.scenarioTitle : _roleCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConnectColors.background,
      appBar: AppBar(
        backgroundColor: ConnectColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.scenarioTitle),
      ),
      body: ConnectPage(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            Text('Edit persona', style: connectTitle(context, size: 24)),
            const SizedBox(height: 8),
            Text('Tune the name, role, and system prompt before your call.', style: connectMuted()),
            const SizedBox(height: 24),
            _FieldLabel('Name'),
            const SizedBox(height: 8),
            _TextField(controller: _nameCtrl, hint: 'e.g. Alex Chen'),
            const SizedBox(height: 20),
            _FieldLabel('Role'),
            const SizedBox(height: 8),
            _TextField(controller: _roleCtrl, hint: 'e.g. Senior Recruiter at Google'),
            const SizedBox(height: 20),
            _FieldLabel('System prompt'),
            const SizedBox(height: 8),
            _TextField(
              controller: _promptCtrl,
              hint: 'How should the AI behave during the call?',
              maxLines: 8,
            ),
            const SizedBox(height: 28),
            ConnectPrimaryButton(label: 'Save & Start Call', onPressed: _startCall),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14));
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: ConnectColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: connectMuted(14),
        filled: true,
        fillColor: ConnectColors.card,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ConnectColors.radius),
          borderSide: const BorderSide(color: ConnectColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ConnectColors.radius),
          borderSide: const BorderSide(color: ConnectColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ConnectColors.radius),
          borderSide: const BorderSide(color: ConnectColors.accent),
        ),
      ),
    );
  }
}
