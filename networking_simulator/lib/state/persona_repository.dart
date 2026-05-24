import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/persona.dart';
import '../services/firestore_service.dart';

/// Merges the 5 bundled persona templates with user-authored personas from
/// Firestore. The frontend's scenario grid is driven by [personasProvider]
/// and never differentiates between template and custom personas — they
/// both have the same shape.
class PersonaRepository {
  PersonaRepository(this._ref);

  final Ref _ref;

  /// The hardcoded set of bundled templates. Each entry's [Persona.id]
  /// must match a `prompts/<id>.md` file — PersonaAgent loads from there.
  ///
  /// IDs and scenario categories also match the frontend's 5 emoji
  /// scenarios on home_screen.dart. If you change one, change the other.
  static const List<Persona> templates = [
    Persona(
      id: 'recruiter_sarah',
      name: 'Sarah Chen',
      role: 'Senior Tech Recruiter',
      scenarioCategory: ScenarioCategory.recruiter,
      avatarEmoji: '👔',
      voice: 'Aoede',
      systemPromptTemplate: '', // loaded from prompts/recruiter_sarah.md
      defaultDifficulty: 'Medium',
      tagline: '15-min phone screen at a startup',
    ),
    Persona(
      id: 'investor_julia',
      name: 'Julia Reyes',
      role: 'Series A Partner, Atlas Ventures',
      scenarioCategory: ScenarioCategory.investor,
      avatarEmoji: '💰',
      voice: 'Kore',
      systemPromptTemplate: '',
      defaultDifficulty: 'Hard',
      tagline: '20-min pitch call',
    ),
    Persona(
      id: 'networking_marcus',
      name: 'Marcus Okafor',
      role: 'Director, Platform Engineering',
      scenarioCategory: ScenarioCategory.networking,
      avatarEmoji: '🤝',
      voice: 'Charon',
      systemPromptTemplate: '',
      defaultDifficulty: 'Medium',
      tagline: 'Conference bar conversation',
    ),
    Persona(
      id: 'founder_elena',
      name: 'Elena Park',
      role: 'Co-founder & CEO, Threadline',
      scenarioCategory: ScenarioCategory.founder,
      avatarEmoji: '🚀',
      voice: 'Puck',
      systemPromptTemplate: '',
      defaultDifficulty: 'Medium',
      tagline: 'Peer founder compare-notes call',
    ),
    Persona(
      id: 'mentor_david',
      name: 'David Whitfield',
      role: 'Retired CTO, pro-bono mentor',
      scenarioCategory: ScenarioCategory.mentor,
      avatarEmoji: '🎓',
      voice: 'Fenrir',
      systemPromptTemplate: '',
      defaultDifficulty: 'Easy',
      tagline: 'Socratic mentoring session',
    ),
  ];

  Stream<List<Persona>> watch() {
    final firestore = _ref.watch(firestoreServiceProvider);
    return firestore.watchUserPersonas().map((custom) => [
          ...templates,
          ...custom,
        ]);
  }

  Persona? byId(String id) {
    return templates.firstWhere(
      (p) => p.id == id,
      orElse: () => const Persona(
        id: '',
        name: '',
        role: '',
        scenarioCategory: ScenarioCategory.networking,
        avatarEmoji: '?',
        voice: 'Aoede',
        systemPromptTemplate: '',
      ),
    );
  }

  Future<String> savePersona(Persona p) async {
    final firestore = _ref.read(firestoreServiceProvider);
    return firestore.writeUserPersona(p);
  }

  Future<void> deletePersona(String id) async {
    final firestore = _ref.read(firestoreServiceProvider);
    return firestore.deleteUserPersona(id);
  }
}

final personaRepositoryProvider = Provider<PersonaRepository>((ref) {
  return PersonaRepository(ref);
});

/// The provider screens consume to render the scenario grid. Async to
/// reflect Firestore latency for user personas.
final personasProvider = StreamProvider<List<Persona>>((ref) {
  return ref.watch(personaRepositoryProvider).watch();
});

/// Look up a single persona by id. Combines templates + cached custom.
final personaByIdProvider = Provider.family<Persona?, String>((ref, id) {
  final all = ref.watch(personasProvider).value;
  if (all == null) {
    return ref.watch(personaRepositoryProvider).byId(id);
  }
  for (final p in all) {
    if (p.id == id) return p;
  }
  return null;
});
