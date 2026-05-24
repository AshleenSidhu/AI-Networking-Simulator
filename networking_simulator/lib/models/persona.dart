/// A networking-practice persona.
///
/// Templates ship as markdown files under `prompts/`. User-authored personas
/// live in Firestore under `users/{uid}/personas/{personaId}`. Both flow
/// through [PersonaRepository] and present identically to UI.
class Persona {
  const Persona({
    required this.id,
    required this.name,
    required this.role,
    required this.scenarioCategory,
    required this.avatarEmoji,
    required this.voice,
    required this.systemPromptTemplate,
    this.defaultDifficulty = 'Medium',
    this.isCustom = false,
    this.tagline,
  });

  final String id;

  /// Display name shown on cards and during the call (e.g. "Sarah", "Marcus").
  final String name;

  /// Job-title/role line shown under the name (e.g. "Senior Tech Recruiter").
  final String role;

  /// Which top-level home tile this persona is bucketed under. Must match
  /// the frontend's hardcoded scenarios on `home_screen.dart`.
  final ScenarioCategory scenarioCategory;

  /// Two-char emoji shown on cards and on the call screen as the avatar.
  final String avatarEmoji;

  /// The Gemini Live voice name (e.g. "Aoede", "Charon"). One voice per
  /// persona — we don't expose voice pickers to keep the demo deterministic.
  final String voice;

  /// Raw markdown system-instruction template with `{{placeholder}}`
  /// substitutions. Filled in by [SessionController] at session start with
  /// values pulled from `ConnectAppState` (industry, role, goal) and the
  /// cross-session summary, then sent as the Gemini Live `setup.system_instruction`.
  final String systemPromptTemplate;

  /// Default difficulty pill shown on the card. Overridable in the editor.
  final String defaultDifficulty;

  /// True for user-authored personas (saved via the persona editor).
  final bool isCustom;

  /// Optional one-line subtitle shown on cards under the role.
  final String? tagline;

  Persona copyWith({
    String? id,
    String? name,
    String? role,
    ScenarioCategory? scenarioCategory,
    String? avatarEmoji,
    String? voice,
    String? systemPromptTemplate,
    String? defaultDifficulty,
    bool? isCustom,
    String? tagline,
  }) {
    return Persona(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      scenarioCategory: scenarioCategory ?? this.scenarioCategory,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      voice: voice ?? this.voice,
      systemPromptTemplate: systemPromptTemplate ?? this.systemPromptTemplate,
      defaultDifficulty: defaultDifficulty ?? this.defaultDifficulty,
      isCustom: isCustom ?? this.isCustom,
      tagline: tagline ?? this.tagline,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role,
        'scenarioCategory': scenarioCategory.id,
        'avatarEmoji': avatarEmoji,
        'voice': voice,
        'systemPromptTemplate': systemPromptTemplate,
        'defaultDifficulty': defaultDifficulty,
        'isCustom': isCustom,
        'tagline': tagline,
      };

  factory Persona.fromJson(Map<String, dynamic> json) => Persona(
        id: json['id'] as String,
        name: json['name'] as String,
        role: json['role'] as String,
        scenarioCategory:
            ScenarioCategory.fromId(json['scenarioCategory'] as String),
        avatarEmoji: json['avatarEmoji'] as String,
        voice: json['voice'] as String,
        systemPromptTemplate: json['systemPromptTemplate'] as String,
        defaultDifficulty:
            (json['defaultDifficulty'] as String?) ?? 'Medium',
        isCustom: (json['isCustom'] as bool?) ?? false,
        tagline: json['tagline'] as String?,
      );
}

/// The five top-level scenario buckets surfaced on `home_screen.dart`.
/// Each persona belongs to exactly one. The frontend's emoji + label tuples
/// must match [emoji] and [label] below.
enum ScenarioCategory {
  recruiter('recruiter', '👔', 'Recruiter'),
  investor('investor', '💰', 'Investor'),
  networking('networking', '🤝', 'Networking'),
  founder('founder', '🚀', 'Founder'),
  mentor('mentor', '🎓', 'Mentor');

  const ScenarioCategory(this.id, this.emoji, this.label);

  final String id;
  final String emoji;
  final String label;

  static ScenarioCategory fromId(String id) =>
      ScenarioCategory.values.firstWhere((c) => c.id == id);
}
