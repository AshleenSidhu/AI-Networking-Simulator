import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/feedback_report.dart';
import '../models/persona.dart';
import '../models/scheduled_session.dart';
import '../models/session.dart';
import 'env.dart';

/// Persistent storage contract. The hot collections live under
/// `users/{uid}/{collection}`:
///
/// - `sessions/{id}` — completed practice sessions with transcripts
/// - `personas/{id}` — user-authored personas (templates are bundled assets)
/// - `summaries/{personaId}` — 2-3 sentence memory injected into next session
/// - `scheduledSessions/{id}` — upcoming sessions feeding the notification arc
/// - `feedbackReports/{id}` — judge output
///
/// All stream methods return broadcast streams that complete when the
/// service is disposed.
abstract class FirestoreService {
  // Sessions
  Stream<List<Session>> watchRecentSessions({int limit = 20});
  Future<void> writeSession(Session session);
  Future<Session?> readSession(String id);

  // Personas (user-authored only; templates are loaded from assets)
  Stream<List<Persona>> watchUserPersonas();
  Future<String> writeUserPersona(Persona persona);
  Future<void> deleteUserPersona(String id);

  // Per-persona cross-session memory
  Future<String?> readSummary(String personaId);
  Future<void> writeSummary(String personaId, String summary);

  // Scheduled sessions
  Stream<List<ScheduledSession>> watchScheduledSessions();
  Future<String> writeScheduledSession(ScheduledSession session);
  Future<void> markTierFired(String sessionId, NotificationTier tier);
  Future<void> dismissScheduledSession(String id);
  Future<void> deleteScheduledSession(String id);

  // Feedback reports
  Stream<List<FeedbackReport>> watchFeedbackReports();
  Future<void> writeFeedbackReport(FeedbackReport report);
  Future<FeedbackReport?> readFeedbackReport(String id);
}

/// In-memory mock backed by `Map`s. Keeps streams warm with broadcast
/// controllers so the UI sees updates. Survives across the same app
/// session but not across reloads — exactly the right behavior for
/// frontend dev work where you want stateful but disposable data.
class MockFirestoreService implements FirestoreService {
  final _uuid = const Uuid();

  final Map<String, Session> _sessions = {};
  final Map<String, Persona> _personas = {};
  final Map<String, String> _summaries = {};
  final Map<String, ScheduledSession> _scheduled = {};
  final Map<String, FeedbackReport> _feedback = {};

  // Broadcast controllers intentionally do NOT buffer events for late
  // subscribers. We rely on each watchXxx() method to yield the current
  // snapshot first via async*, then forward live updates from these.
  final _sessionsCtrl = StreamController<List<Session>>.broadcast();
  final _personasCtrl = StreamController<List<Persona>>.broadcast();
  final _scheduledCtrl = StreamController<List<ScheduledSession>>.broadcast();
  final _feedbackCtrl = StreamController<List<FeedbackReport>>.broadcast();

  MockFirestoreService() {
    // Seed two mock past sessions so the home + profile screens have
    // something to render on first paint.
    final now = DateTime.now();
    final s1 = Session(
      id: 's1',
      personaId: 'recruiter_sarah',
      startedAt: now.subtract(const Duration(days: 2, minutes: 12)),
      endedAt: now.subtract(const Duration(days: 2)),
      transcript: const [],
      score: 82,
      summary: 'Practiced phone screen with Sarah at Acme. Strong on '
          "'why us'; needs follow-up questions.",
    );
    final s2 = Session(
      id: 's2',
      personaId: 'networking_marcus',
      startedAt: now.subtract(const Duration(days: 5, minutes: 9)),
      endedAt: now.subtract(const Duration(days: 5)),
      transcript: const [],
      score: 71,
    );
    _sessions[s1.id] = s1;
    _sessions[s2.id] = s2;
  }

  void _emitSessions() => _sessionsCtrl.add(_sessions.values.toList());
  void _emitPersonas() => _personasCtrl.add(_personas.values.toList());
  void _emitScheduled() => _scheduledCtrl.add(_scheduled.values.toList());
  void _emitFeedback() => _feedbackCtrl.add(_feedback.values.toList());

  @override
  Stream<List<Session>> watchRecentSessions({int limit = 20}) async* {
    List<Session> sorted(Iterable<Session> input) {
      final list = input.toList()
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
      return list.take(limit).toList();
    }

    yield sorted(_sessions.values);
    await for (final list in _sessionsCtrl.stream) {
      yield sorted(list);
    }
  }

  @override
  Future<void> writeSession(Session session) async {
    _sessions[session.id] = session;
    _emitSessions();
  }

  @override
  Future<Session?> readSession(String id) async => _sessions[id];

  @override
  Stream<List<Persona>> watchUserPersonas() async* {
    yield _personas.values.toList();
    yield* _personasCtrl.stream;
  }

  @override
  Future<String> writeUserPersona(Persona persona) async {
    final id = persona.id.isEmpty ? _uuid.v4() : persona.id;
    _personas[id] = persona.copyWith(id: id, isCustom: true);
    _emitPersonas();
    return id;
  }

  @override
  Future<void> deleteUserPersona(String id) async {
    _personas.remove(id);
    _emitPersonas();
  }

  @override
  Future<String?> readSummary(String personaId) async => _summaries[personaId];

  @override
  Future<void> writeSummary(String personaId, String summary) async {
    _summaries[personaId] = summary;
  }

  @override
  Stream<List<ScheduledSession>> watchScheduledSessions() async* {
    yield _scheduled.values.toList();
    yield* _scheduledCtrl.stream;
  }

  @override
  Future<String> writeScheduledSession(ScheduledSession session) async {
    final id = session.id.isEmpty ? _uuid.v4() : session.id;
    _scheduled[id] = ScheduledSession(
      id: id,
      personaId: session.personaId,
      scheduledAt: session.scheduledAt,
      firedAt: session.firedAt,
      dismissed: session.dismissed,
      note: session.note,
    );
    _emitScheduled();
    return id;
  }

  @override
  Future<void> markTierFired(String sessionId, NotificationTier tier) async {
    final existing = _scheduled[sessionId];
    if (existing == null) return;
    _scheduled[sessionId] = existing.copyWith(
      firedAt: {...existing.firedAt, tier: DateTime.now()},
    );
    _emitScheduled();
  }

  @override
  Future<void> dismissScheduledSession(String id) async {
    final existing = _scheduled[id];
    if (existing == null) return;
    _scheduled[id] = existing.copyWith(dismissed: true);
    _emitScheduled();
  }

  @override
  Future<void> deleteScheduledSession(String id) async {
    _scheduled.remove(id);
    _emitScheduled();
  }

  @override
  Stream<List<FeedbackReport>> watchFeedbackReports() async* {
    yield _feedback.values.toList();
    yield* _feedbackCtrl.stream;
  }

  @override
  Future<void> writeFeedbackReport(FeedbackReport report) async {
    _feedback[report.sessionId] = report;
    _emitFeedback();
  }

  @override
  Future<FeedbackReport?> readFeedbackReport(String id) async => _feedback[id];
}

/// Real Firestore implementation. All paths are scoped under the active
/// user's uid to match the security rules in HUMAN_TODO.md step 3.
class RealFirestoreService implements FirestoreService {
  RealFirestoreService({required this.uid, FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final String uid;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _sessions =>
      _db.collection('users').doc(uid).collection('sessions');
  CollectionReference<Map<String, dynamic>> get _personas =>
      _db.collection('users').doc(uid).collection('personas');
  CollectionReference<Map<String, dynamic>> get _summaries =>
      _db.collection('users').doc(uid).collection('summaries');
  CollectionReference<Map<String, dynamic>> get _scheduled =>
      _db.collection('users').doc(uid).collection('scheduledSessions');
  CollectionReference<Map<String, dynamic>> get _feedback =>
      _db.collection('users').doc(uid).collection('feedbackReports');

  @override
  Stream<List<Session>> watchRecentSessions({int limit = 20}) {
    return _sessions
        .orderBy('startedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Session.fromJson(d.data())).toList());
  }

  @override
  Future<void> writeSession(Session session) =>
      _sessions.doc(session.id).set(session.toJson());

  @override
  Future<Session?> readSession(String id) async {
    final doc = await _sessions.doc(id).get();
    if (!doc.exists) return null;
    return Session.fromJson(doc.data()!);
  }

  @override
  Stream<List<Persona>> watchUserPersonas() {
    return _personas.snapshots().map(
          (snap) => snap.docs.map((d) => Persona.fromJson(d.data())).toList(),
        );
  }

  @override
  Future<String> writeUserPersona(Persona persona) async {
    final id = persona.id.isEmpty ? const Uuid().v4() : persona.id;
    final p = persona.copyWith(id: id, isCustom: true);
    await _personas.doc(id).set(p.toJson());
    return id;
  }

  @override
  Future<void> deleteUserPersona(String id) => _personas.doc(id).delete();

  @override
  Future<String?> readSummary(String personaId) async {
    final doc = await _summaries.doc(personaId).get();
    return doc.data()?['summary'] as String?;
  }

  @override
  Future<void> writeSummary(String personaId, String summary) =>
      _summaries.doc(personaId).set({
        'summary': summary,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  @override
  Stream<List<ScheduledSession>> watchScheduledSessions() {
    return _scheduled
        .orderBy('scheduledAt')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ScheduledSession.fromJson(d.data())).toList());
  }

  @override
  Future<String> writeScheduledSession(ScheduledSession session) async {
    final id = session.id.isEmpty ? const Uuid().v4() : session.id;
    await _scheduled.doc(id).set(ScheduledSession(
          id: id,
          personaId: session.personaId,
          scheduledAt: session.scheduledAt,
          firedAt: session.firedAt,
          dismissed: session.dismissed,
          note: session.note,
        ).toJson());
    return id;
  }

  @override
  Future<void> markTierFired(String sessionId, NotificationTier tier) {
    return _db.runTransaction((tx) async {
      final ref = _scheduled.doc(sessionId);
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final existing = ScheduledSession.fromJson(snap.data()!);
      if (existing.firedAt[tier] != null) return;
      final updated = existing.copyWith(
        firedAt: {...existing.firedAt, tier: DateTime.now()},
      );
      tx.set(ref, updated.toJson());
    });
  }

  @override
  Future<void> dismissScheduledSession(String id) =>
      _scheduled.doc(id).update({'dismissed': true});

  @override
  Future<void> deleteScheduledSession(String id) => _scheduled.doc(id).delete();

  @override
  Stream<List<FeedbackReport>> watchFeedbackReports() {
    return _feedback.snapshots().map(
          (snap) =>
              snap.docs.map((d) => FeedbackReport.fromJson(d.data())).toList(),
        );
  }

  @override
  Future<void> writeFeedbackReport(FeedbackReport report) =>
      _feedback.doc(report.sessionId).set(report.toJson());

  @override
  Future<FeedbackReport?> readFeedbackReport(String id) async {
    final doc = await _feedback.doc(id).get();
    if (!doc.exists) return null;
    return FeedbackReport.fromJson(doc.data()!);
  }
}

/// Provider switches to real impl only when Firebase is fully initialized
/// AND we have a signed-in user. The auth controller forwards its uid via
/// `currentUidProvider`.
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  if (useMocks || Firebase.apps.isEmpty) return MockFirestoreService();
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return MockFirestoreService();
  return RealFirestoreService(uid: uid);
});

/// Forward-declared here; populated by auth_controller.dart. Defined as a
/// Notifier so auth_controller can update it without circular deps.
class CurrentUidNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? uid) => state = uid;
}

final currentUidProvider =
    NotifierProvider<CurrentUidNotifier, String?>(CurrentUidNotifier.new);
