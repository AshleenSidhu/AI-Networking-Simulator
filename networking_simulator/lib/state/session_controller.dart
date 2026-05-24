import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../agents/persona_agent.dart';
import '../agents/summary_agent.dart';
import '../models/persona.dart';
import '../models/session.dart';
import '../models/transcript_turn.dart';
import '../services/firestore_service.dart';
import '../services/gemini_live_service.dart';
import 'connect_state_provider.dart';
import 'persona_repository.dart';

/// Owns the live-call lifecycle for one persona.
///
/// One SessionController instance is created per call (keyed by personaId).
/// It builds the system instruction (template + ConnectAppState vars +
/// previous summary), opens the Gemini Live connection, pipes transcript
/// turns and AI-speaking signals into [state], and on hang-up writes the
/// Session to Firestore + kicks off the summary agent.
///
/// The call screen reads `state` and calls [hangUp]/[toggleMute]/[pushToTalk].
class SessionController extends FamilyNotifier<SessionState, String> {
  final _uuid = const Uuid();
  late final String _sessionId;
  late final DateTime _startedAt;
  late final GeminiLiveService _live;
  StreamSubscription<TranscriptTurn>? _transcriptSub;
  StreamSubscription<bool>? _speakingSub;
  Timer? _ticker;
  bool _disposed = false;

  @override
  SessionState build(String personaId) {
    _sessionId = _uuid.v4();
    _startedAt = DateTime.now();

    ref.onDispose(_teardown);

    // Kick off the async connect side-effect on the next microtask so the
    // caller gets back a valid initial state immediately.
    Future.microtask(() => _connect(personaId));

    return SessionState(
      sessionId: _sessionId,
      personaId: personaId,
      transcript: const [],
      elapsed: Duration.zero,
      isMuted: false,
      isAiSpeaking: false,
      isPushToTalkDown: false,
      phase: SessionPhase.connecting,
    );
  }

  Future<void> _connect(String personaId) async {
    final persona = ref.read(personaByIdProvider(personaId));
    if (persona == null || persona.id.isEmpty) {
      state = state.copyWith(
        phase: SessionPhase.error,
        error: 'Persona not found: $personaId',
      );
      return;
    }

    try {
      _live = ref.read(geminiLiveServiceProvider);
      _transcriptSub = _live.transcripts.listen(_onTranscript);
      _speakingSub = _live.isAiSpeaking.listen(_onSpeakingChange);

      final firestore = ref.read(firestoreServiceProvider);
      final previousSummary = await firestore.readSummary(persona.id);

      // Pull personalization values from ConnectAppState (frontend's
      // existing onboarding state). Read once at connect-time — mid-call
      // edits don't affect a running persona.
      final connectState = ref.read(connectAppStateProvider);
      final systemInstruction = await PersonaAgent(persona: persona)
          .buildSystemInstruction(
        vars: {
          'industry': connectState.industries.isEmpty
              ? 'Technology'
              : connectState.industries.first,
          'goal': connectState.goal,
          'user_role': connectState.role,
          'difficulty': persona.defaultDifficulty,
        },
        previousSummary: previousSummary,
      );

      await _live.connect(
        systemInstruction: systemInstruction,
        voice: persona.voice,
      );

      if (_disposed) return;
      state = state.copyWith(phase: SessionPhase.live);

      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_disposed) return;
        state = state.copyWith(
          elapsed: DateTime.now().difference(_startedAt),
        );
      });
    } catch (e, st) {
      debugPrint('[SessionController] connect failed: $e\n$st');
      state = state.copyWith(
        phase: SessionPhase.error,
        error: e.toString(),
      );
    }
  }

  void _onTranscript(TranscriptTurn turn) {
    if (_disposed) return;
    final next = [...state.transcript];
    final idx = next.indexWhere((t) => t.id == turn.id);
    if (idx >= 0) {
      next[idx] = turn;
    } else {
      next.add(turn);
    }
    state = state.copyWith(transcript: next);
  }

  void _onSpeakingChange(bool speaking) {
    if (_disposed) return;
    state = state.copyWith(isAiSpeaking: speaking);
  }

  void toggleMute() {
    final muted = !state.isMuted;
    _live.setMuted(muted);
    state = state.copyWith(isMuted: muted);
  }

  void pushToTalk(bool isDown) {
    _live.setMuted(!isDown && state.isMuted);
    state = state.copyWith(isPushToTalkDown: isDown);
  }

  /// Hangs up, persists the session, kicks off the summary writer for the
  /// next call. The feedback judge is triggered separately by the feedback
  /// screen when the user navigates there.
  Future<void> hangUp() async {
    if (_disposed) return;
    _ticker?.cancel();
    await _live.disconnect();
    await _transcriptSub?.cancel();
    await _speakingSub?.cancel();

    final session = Session(
      id: _sessionId,
      personaId: state.personaId,
      startedAt: _startedAt,
      endedAt: DateTime.now(),
      transcript: state.transcript,
    );
    final firestore = ref.read(firestoreServiceProvider);
    await firestore.writeSession(session);

    // Fire-and-forget summary write. We don't block hangUp on it.
    final persona = ref.read(personaByIdProvider(state.personaId));
    if (persona != null && persona.id.isNotEmpty) {
      unawaited(_writeSummary(persona, session));
    }

    state = state.copyWith(phase: SessionPhase.ended);
  }

  Future<void> _writeSummary(Persona persona, Session session) async {
    final summaryAgent = ref.read(summaryAgentProvider);
    final firestore = ref.read(firestoreServiceProvider);
    try {
      final summary = await summaryAgent.writeSummary(
        personaName: persona.name,
        transcript: session.transcript,
      );
      if (summary.isNotEmpty) {
        await firestore.writeSummary(persona.id, summary);
      }
    } catch (e) {
      debugPrint('[SessionController] summary write failed: $e');
    }
  }

  void _teardown() {
    _disposed = true;
    _ticker?.cancel();
    _transcriptSub?.cancel();
    _speakingSub?.cancel();
    // Best-effort disconnect; ignore errors.
    try {
      _live.disconnect();
    } catch (_) {}
  }
}

final sessionControllerProvider =
    NotifierProvider.family<SessionController, SessionState, String>(
  SessionController.new,
);
