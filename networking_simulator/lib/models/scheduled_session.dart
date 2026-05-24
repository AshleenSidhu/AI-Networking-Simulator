/// A future session the user has scheduled. Drives the "Schedule" tab,
/// the home `_UpcomingCard`, and the tiered notification timers.
///
/// Stored at `users/{uid}/scheduledSessions/{id}`.
class ScheduledSession {
  const ScheduledSession({
    required this.id,
    required this.personaId,
    required this.scheduledAt,
    required this.firedAt,
    this.dismissed = false,
    this.note,
  });

  final String id;
  final String personaId;
  final DateTime scheduledAt;

  /// Per-tier dedupe map. Null means the tier hasn't fired yet. Updated
  /// transactionally by both the in-tab scheduler and (in the FCM stretch)
  /// the Cloud Function so neither fires twice.
  final Map<NotificationTier, DateTime?> firedAt;

  /// True if the user declined the T-0 ringing overlay. Hides further
  /// notifications for this row.
  final bool dismissed;

  /// Optional free-form focus from the feedback recommendation
  /// ("Tonight: ask three follow-up questions").
  final String? note;

  ScheduledSession copyWith({
    Map<NotificationTier, DateTime?>? firedAt,
    bool? dismissed,
    String? note,
  }) {
    return ScheduledSession(
      id: id,
      personaId: personaId,
      scheduledAt: scheduledAt,
      firedAt: firedAt ?? this.firedAt,
      dismissed: dismissed ?? this.dismissed,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'personaId': personaId,
        'scheduledAt': scheduledAt.toIso8601String(),
        'firedAt': firedAt.map((k, v) => MapEntry(k.name, v?.toIso8601String())),
        'dismissed': dismissed,
        'note': note,
      };

  factory ScheduledSession.fromJson(Map<String, dynamic> json) {
    final rawFired = (json['firedAt'] as Map<String, dynamic>? ?? {});
    return ScheduledSession(
      id: json['id'] as String,
      personaId: json['personaId'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      firedAt: {
        for (final tier in NotificationTier.values)
          tier: rawFired[tier.name] == null
              ? null
              : DateTime.parse(rawFired[tier.name] as String),
      },
      dismissed: (json['dismissed'] as bool?) ?? false,
      note: json['note'] as String?,
    );
  }
}

/// The three-tier reminder schedule (compressed to T-60s/T-15s/T-0 for demos).
enum NotificationTier {
  twoMin,
  thirtySec,
  atTime;

  /// How long before [ScheduledSession.scheduledAt] this tier fires under
  /// the real (production) schedule.
  Duration get realLeadTime {
    switch (this) {
      case NotificationTier.twoMin:
        return const Duration(minutes: 2);
      case NotificationTier.thirtySec:
        return const Duration(seconds: 30);
      case NotificationTier.atTime:
        return Duration.zero;
    }
  }

  /// Compressed schedule used during demo dry-runs (long-press the
  /// Schedule Practice button to schedule 60s out).
  Duration get demoLeadTime {
    switch (this) {
      case NotificationTier.twoMin:
        return const Duration(seconds: 60);
      case NotificationTier.thirtySec:
        return const Duration(seconds: 15);
      case NotificationTier.atTime:
        return Duration.zero;
    }
  }
}

/// Sealed state for the home-screen overlay. Frontend's home_screen reads
/// `homeOverlayProvider` and switches on this.
sealed class HomeOverlay {
  const HomeOverlay();
}

class HomeOverlayNone extends HomeOverlay {
  const HomeOverlayNone();
}

class HomeOverlayRinging extends HomeOverlay {
  const HomeOverlayRinging({
    required this.scheduledSessionId,
    required this.personaId,
  });
  final String scheduledSessionId;
  final String personaId;
}
