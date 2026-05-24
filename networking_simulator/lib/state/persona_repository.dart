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

  /// Mirror of the latest streamed custom personas plus any in-flight saves
  /// that haven't yet round-tripped through the Firestore snapshot listener.
  /// Used by [byId] for synchronous lookup so [SessionController._connect]
  /// (and the half-dozen widget watchers consuming `personaByIdProvider`)
  /// can resolve a freshly-saved persona during the brief window before
  /// `personasProvider` re-emits.
  ///
  /// Keyed by [Persona.id]. Templates live in [templates] and don't go here.
  final Map<String, Persona> _customCache = {};

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
    return firestore.watchUserPersonas().map((custom) {
      // Keep the sync-lookup cache aligned with the latest Firestore
      // snapshot. Replace rather than merge so deletes propagate.
      _customCache
        ..clear()
        ..addEntries(custom.map((p) => MapEntry(p.id, p)));
      return [...templates, ...custom];
    });
  }

  /// Synchronous lookup. Checks bundled templates first, then the cache of
  /// custom personas mirrored from Firestore (and pre-warmed by [savePersona]
  /// so an editor-to-call navigation never races the stream). Returns null
  /// when truly unknown — callers must handle null and surface an error.
  Persona? byId(String id) {
    for (final t in templates) {
      if (t.id == id) return t;
    }
    return _customCache[id];
  }

  /// Writes a custom persona to Firestore and synchronously updates the
  /// in-memory cache so [byId] / `personaByIdProvider` can resolve the new
  /// id immediately — before the Firestore snapshot stream re-emits.
  Future<String> savePersona(Persona p) async {
    final firestore = _ref.read(firestoreServiceProvider);
    final id = await firestore.writeUserPersona(p);
    _customCache[id] = p.copyWith(id: id, isCustom: true);
    return id;
  }

  Future<void> deletePersona(String id) async {
    final firestore = _ref.read(firestoreServiceProvider);
    _customCache.remove(id);
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
