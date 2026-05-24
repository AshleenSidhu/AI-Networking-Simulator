import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/persona.dart';
import '../../state/persona_repository.dart';
import '../layout/responsive.dart';
import '../navigation/connect_routes.dart';
import '../theme/connect_theme.dart';
import '../widgets/connect_widgets.dart';
import 'call_screen.dart';
import 'persona_editor_screen.dart';

class ScenarioSelectScreen extends ConsumerWidget {
  const ScenarioSelectScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPersonas = ref.watch(personasProvider);

    final body = asyncPersonas.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 80),
          child: CircularProgressIndicator(color: ConnectColors.accent),
        ),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Center(
          child: Text(
            'Could not load personas: $e',
            style: connectMuted(),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (personas) => _Grid(personas: personas),
    );

    final content = ConnectPage(
      fullWidth: embedded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!embedded) const SizedBox(height: 16),
          Text('Pick a scenario',
              style: connectTitle(context, size: 24)),
          const SizedBox(height: 4),
          Text('Each persona is a different practice flow.',
              style: connectMuted()),
          const SizedBox(height: 24),
          body,
        ],
      ),
    );

    if (embedded) return SingleChildScrollView(child: content);
    return Scaffold(
      backgroundColor: ConnectColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(child: content),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.personas});
  final List<Persona> personas;

  @override
  Widget build(BuildContext context) {
    final cols = ConnectResponsive.isDesktop(context)
        ? 3
        : ConnectResponsive.isTablet(context)
            ? 2
            : 1;

    final tiles = <Widget>[
      ...personas.map((p) => _PersonaTile(persona: p)),
      const _CustomTile(),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tiles.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (_, i) => tiles[i],
    );
  }
}

class _PersonaTile extends StatelessWidget {
  const _PersonaTile({required this.persona});
  final Persona persona;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => connectPush(
        context,
        CallScreen(personaId: persona.id),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: ConnectColors.card,
          borderRadius: BorderRadius.circular(ConnectColors.radius),
          border: Border.all(color: ConnectColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(persona.avatarEmoji, style: const TextStyle(fontSize: 32)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ConnectColors.cardElevated,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(persona.defaultDifficulty, style: connectMuted(10)),
                ),
              ],
            ),
            const Spacer(),
            Text(persona.name,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 2),
            Text(persona.role,
                style: connectMuted(12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            if (persona.tagline != null) ...[
              const SizedBox(height: 6),
              Text(persona.tagline!, style: connectMuted(11)),
            ],
          ],
        ),
      ),
    );
  }
}

class _CustomTile extends StatelessWidget {
  const _CustomTile();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          connectPush(context, const PersonaEditorScreen()),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: ConnectColors.accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(ConnectColors.radius),
          border: Border.all(
            color: ConnectColors.accent.withValues(alpha: 0.6),
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: ConnectColors.accent, size: 36),
            const SizedBox(height: 8),
            const Text('Create Custom',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 4),
            Text('Design your own persona',
                textAlign: TextAlign.center, style: connectMuted(11)),
          ],
        ),
      ),
    );
  }
}
