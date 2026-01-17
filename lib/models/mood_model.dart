/// Mood tracking model for AI-powered recipe suggestions
class MoodModel {
  final String mood;
  final DateTime timestamp;
  final String? note;

  MoodModel({
    required this.mood,
    required this.timestamp,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'mood': mood,
    'timestamp': timestamp.toIso8601String(),
    'note': note,
  };

  factory MoodModel.fromJson(Map<String, dynamic> json) => MoodModel(
    mood: json['mood'],
    timestamp: DateTime.parse(json['timestamp']),
    note: json['note'],
  );
}

/// Available mood types
enum MoodType {
  excellent('Excellent', '😄', 5),
  great('Great', '😊', 4),
  good('Good', '🙂', 3),
  okay('Okay', '😐', 2),
  bad('Bad', '😔', 1);

  final String label;
  final String emoji;
  final int level;

  const MoodType(this.label, this.emoji, this.level);

  static MoodType fromString(String mood) {
    return MoodType.values.firstWhere(
      (e) => e.label.toLowerCase() == mood.toLowerCase(),
      orElse: () => MoodType.okay,
    );
  }
}

/// User achievement model
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final DateTime unlockedAt;
  final bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlockedAt,
    this.isUnlocked = false,
  });
}
