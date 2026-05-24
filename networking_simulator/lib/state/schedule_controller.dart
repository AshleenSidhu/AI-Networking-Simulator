import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/scheduled_session.dart';
import '../services/firestore_service.dart';

/// All currently-pending (non-dismissed) scheduled sessions.
final scheduledSessionsProvider =
    StreamProvider<List<ScheduledSession>>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  return firestore.watchScheduledSessions().map(
        (list) => list.where((s) => !s.dismissed).toList()
          ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt)),
      );
});

/// The next upcoming session (or null). Drives the home `_UpcomingCard`.
final nextSessionProvider = Provider<ScheduledSession?>((ref) {
  final all = ref.watch(scheduledSessionsProvider).valueOrNull ?? const [];
  if (all.isEmpty) return null;
  final now = DateTime.now();
  return all.firstWhere(
    (s) => s.scheduledAt.isAfter(now),
    orElse: () => all.last,
  );
});

class ScheduleController extends Notifier<void> {
  @override
  void build() {}

  Future<void> deleteSession(String id) async {
    final firestore = ref.read(firestoreServiceProvider);
    await firestore.deleteScheduledSession(id);
  }

  Future<void> dismissSession(String id) async {
    final firestore = ref.read(firestoreServiceProvider);
    await firestore.dismissScheduledSession(id);
  }
}

final scheduleControllerProvider = NotifierProvider<ScheduleController, void>(
  ScheduleController.new,
);
