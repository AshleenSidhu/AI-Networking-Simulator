import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'connect_state_provider.dart';
import 'user_stats_provider.dart';

/// One-way bridge: Riverpod-derived [UserStats] → [ConnectAppState].
///
/// The frontend's home dashboard widgets read `sessionsCompleted`,
/// `avgScore`, `dayStreak` off of [ConnectAppState] (via `ConnectScope.of`).
/// Those fields were hardcoded demo numbers. This provider listens to
/// [userStatsProvider] (which aggregates the real Firestore sessions
/// stream) and pushes updates into the [ConnectAppState] instance, which
/// fires `notifyListeners()` and wakes up any `ListenableBuilder` /
/// `InheritedNotifier` subscribers.
///
/// Activated once at app boot by `main.dart` via `ref.watch`. Stays alive
/// for the lifetime of the app (no `autoDispose`). Re-fires every time
/// the underlying recent-sessions stream emits — including the initial
/// emit and on sign-in / sign-out as `firestoreServiceProvider`
/// rebuilds against a new uid.
///
/// Failure mode: if [connectAppStateProvider] hasn't been overridden in
/// `ProviderScope`, reading it throws — surfacing the misconfiguration
/// loudly rather than syncing into a dead instance.
final connectStateSyncProvider = Provider<void>((ref) {
  final app = ref.read(connectAppStateProvider);

  ref.listen(
    userStatsProvider,
    (_, next) {
      // Defer to the microtask queue so `notifyListeners()` never runs
      // synchronously inside a `build()`. The combination of
      // `fireImmediately: true` + `ConnectAIApp` activating this provider
      // *during* its own build means the first emit would otherwise try
      // to dirty `ConnectScope` (an InheritedNotifier ancestor still
      // being built) → "setState() during build" assertion. A microtask
      // runs after the current frame's build phase completes, so the
      // notify lands cleanly in the next frame.
      Future.microtask(() {
        app.applyDerivedStats(
          sessionsCompleted: next.sessionsCompleted,
          avgScore: next.avgScore,
          dayStreak: next.dayStreak,
          growthPercent: next.growthPercent,
          skills: next.skills,
        );
      });
    },
    fireImmediately: true,
  );
});
