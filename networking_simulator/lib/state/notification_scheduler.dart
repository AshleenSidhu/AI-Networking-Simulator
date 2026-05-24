import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/scheduled_session.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../state/persona_repository.dart';
import 'home_overlay_provider.dart';
import 'schedule_controller.dart';

/// Watches the scheduled-sessions Firestore stream and arms one [Timer]
/// per tier per session. On fire:
///
/// - T-2min / T-30s: show a browser notification (or in-app SnackBar if
///   the tab is focused — the SnackBar half lives on the home screen).
/// - T-0: write `homeOverlayProvider` to [HomeOverlayRinging] so the
///   home screen renders the full-bleed ringing UI.
///
/// Dedupes via [ScheduledSession.firedAt] — both this and the (stretch)
/// Cloud Function transactionally compare-and-set tier timestamps.
class NotificationScheduler extends Notifier<void> {
  final _timers = HashMap<String, Timer>();

  @override
  void build() {
    ref.onDispose(() {
      for (final t in _timers.values) {
        t.cancel();
      }
      _timers.clear();
    });

    ref.listen<AsyncValue<List<ScheduledSession>>>(
      scheduledSessionsProvider,
      (prev, next) {
        final list = next.valueOrNull;
        if (list != null) _resyncTimers(list);
      },
      fireImmediately: true,
    );
  }

  void _resyncTimers(List<ScheduledSession> sessions) {
    final liveKeys = <String>{};
    for (final session in sessions) {
      if (session.dismissed) continue;
      for (final tier in NotificationTier.values) {
        final key = '${session.id}/${tier.name}';
        liveKeys.add(key);
        if (_timers.containsKey(key)) continue;
        if (session.firedAt[tier] != null) continue;

        final fireAt = session.scheduledAt.subtract(tier.realLeadTime);
        final delay = fireAt.difference(DateTime.now());
        if (delay.isNegative) {
          _fire(session, tier);
        } else {
          _timers[key] = Timer(delay, () => _fire(session, tier));
        }
      }
    }
    // Cancel timers for sessions that have been deleted or dismissed.
    final stale = _timers.keys.where((k) => !liveKeys.contains(k)).toList();
    for (final k in stale) {
      _timers.remove(k)?.cancel();
    }
  }

  Future<void> _fire(ScheduledSession session, NotificationTier tier) async {
    final firestore = ref.read(firestoreServiceProvider);
    // Compare-and-set: re-read and bail if someone else already fired this tier.
    final fresh = ref.read(scheduledSessionsProvider).valueOrNull?.firstWhere(
          (s) => s.id == session.id,
          orElse: () => session,
        );
    if (fresh?.firedAt[tier] != null) return;

    await firestore.markTierFired(session.id, tier);

    final persona = ref.read(personaByIdProvider(session.personaId));
    final personaName = persona?.name ?? 'your scheduled persona';

    switch (tier) {
      case NotificationTier.twoMin:
        await ref.read(notificationServiceProvider).show(
              title: 'Your call with $personaName is in 2 minutes',
              body: 'Take a breath. You\'ve got this.',
              tag: '${session.id}/twoMin',
            );
      case NotificationTier.thirtySec:
        await ref.read(notificationServiceProvider).show(
              title: '30 seconds — $personaName is about to call',
              body: 'Find a quiet spot.',
              tag: '${session.id}/thirtySec',
            );
      case NotificationTier.atTime:
        ref.read(homeOverlayProvider.notifier).state = HomeOverlayRinging(
          scheduledSessionId: session.id,
          personaId: session.personaId,
        );
        debugPrint('[NotificationScheduler] T-0 fired for ${session.id}');
    }
  }

  /// Called by the home screen's ringing overlay when the user taps
  /// Decline. Clears the overlay and marks the session dismissed.
  Future<void> declineRinging(String scheduledSessionId) async {
    ref.read(homeOverlayProvider.notifier).state = const HomeOverlayNone();
    await ref.read(scheduleControllerProvider.notifier)
        .dismissSession(scheduledSessionId);
  }

  /// Called when the user taps Answer; just clears the overlay (the home
  /// screen then routes to /call).
  void answerRinging() {
    ref.read(homeOverlayProvider.notifier).state = const HomeOverlayNone();
  }
}

final notificationSchedulerProvider =
    NotifierProvider<NotificationScheduler, void>(
  NotificationScheduler.new,
);
