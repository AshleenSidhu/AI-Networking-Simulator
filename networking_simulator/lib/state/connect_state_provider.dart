import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../connect_ai/state/connect_app_state.dart';

/// Bridges the frontend's `InheritedNotifier`-backed [ConnectAppState]
/// into Riverpod so backend providers can read user demographics without
/// a `BuildContext`.
///
/// The single live instance is created in `main.dart` and registered via
/// `ProviderScope.overrides`. Reading this provider without that override
/// throws — catches mistakes early.
///
/// We don't subscribe to its `notifyListeners()` events here. The fields
/// it owns (name, role, industries, goal) are only read at session-start
/// time; mid-session edits don't affect a running call.
final connectAppStateProvider = Provider<ConnectAppState>((ref) {
  throw UnimplementedError(
    'connectAppStateProvider was read before ProviderScope.overrides '
    'wired it up. Pass the live ConnectAppState in via main.dart.',
  );
});
