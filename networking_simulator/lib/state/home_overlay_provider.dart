import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/scheduled_session.dart';

/// Drives the full-bleed ringing overlay on the home screen. The
/// notification scheduler writes to this provider when the T-0 tier
/// fires; the home screen reads it and renders [RingingOverlay] when
/// the value is [HomeOverlayRinging].
final homeOverlayProvider = StateProvider<HomeOverlay>((ref) {
  return const HomeOverlayNone();
});
