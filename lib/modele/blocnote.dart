class Note {
  int? id;
  String title;
  String content;
  DateTime createdAt;
  DateTime updatedAt;

  Note(
      {this.id,
      required this.title,
      required this.content,
      DateTime? createdAt,
      DateTime? updatedAt})
      : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Note.fromMap(Map<String, dynamic> m) => Note(
        id: m['id'] as int?,
        title: m['title'] as String? ?? '',
        content: m['content'] as String? ?? '',
        createdAt: DateTime.parse(m['created_at'] as String),
        updatedAt: DateTime.parse(m['updated_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'content': content,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
