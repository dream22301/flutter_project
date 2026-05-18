class Announcement {
  final int id;
  final String title;
  final String content;
  final String audience;
  final int prioritas;
  final String priorityLabel;
  final String? publishDate;

  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.audience,
    required this.prioritas,
    required this.priorityLabel,
    this.publishDate,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id:            json['id'] as int,
      title:         json['title'] as String? ?? '',
      content:       json['content'] as String? ?? '',
      audience:      json['audience'] as String? ?? '',
      prioritas:     json['prioritas'] as int? ?? 0,
      priorityLabel: json['priority_label'] as String? ?? 'normal',
      publishDate:   json['publish_date'] as String?,
    );
  }

  static const Map<int, int> priorityColors = {
    0: 0xFF8A93A6, // — normal
    1: 0xFF0EA5E9, // — info
    2: 0xFFF0A500, // — peringatan
    3: 0xFFEF4444, // — penting
  };

  int get color => priorityColors[prioritas] ?? priorityColors[0]!;
}
