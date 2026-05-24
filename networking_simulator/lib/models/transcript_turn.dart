/// One turn in a conversation. Emitted by [GeminiLiveService.transcripts] as
/// the model dictates partial deltas; final turns are persisted to Firestore
/// at session end.
class TranscriptTurn {
  const TranscriptTurn({
    required this.id,
    required this.speaker,
    required this.text,
    required this.timestamp,
    this.isPartial = false,
  });

  final String id;
  final Speaker speaker;
  final String text;
  final DateTime timestamp;

  /// True while the model is still streaming words for this turn. The UI
  /// can render partials with a fade or cursor; when the same id arrives
  /// again with `isPartial: false`, replace the row.
  final bool isPartial;

  TranscriptTurn copyWith({
    String? id,
    Speaker? speaker,
    String? text,
    DateTime? timestamp,
    bool? isPartial,
  }) {
    return TranscriptTurn(
      id: id ?? this.id,
      speaker: speaker ?? this.speaker,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isPartial: isPartial ?? this.isPartial,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'speaker': speaker.name,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
        'isPartial': isPartial,
      };

  factory TranscriptTurn.fromJson(Map<String, dynamic> json) => TranscriptTurn(
        id: json['id'] as String,
        speaker: Speaker.values.firstWhere((s) => s.name == json['speaker']),
        text: json['text'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        isPartial: (json['isPartial'] as bool?) ?? false,
      );
}

enum Speaker { user, ai }
