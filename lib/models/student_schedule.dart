/// Mirrors the Laravel StudentSchedule model fields.
class StudentSchedule {
  final int id;
  final String day;
  final String subject;
  final String room;
  final String classMajor;
  final String periodStart; // e.g. "07:30"
  final String periodEnd;   // e.g. "09:00"

  const StudentSchedule({
    required this.id,
    required this.day,
    required this.subject,
    required this.room,
    required this.classMajor,
    required this.periodStart,
    required this.periodEnd,
  });

  factory StudentSchedule.fromJson(Map<String, dynamic> json) {
    return StudentSchedule(
      id:          json['id'] as int,
      day:         json['day'] as String? ?? '',
      subject:     json['subject'] as String? ?? '',
      room:        json['room'] as String? ?? '',
      classMajor:  json['class_major'] as String? ?? '',
      periodStart: json['period_start'] as String? ?? '',
      periodEnd:   json['period_end'] as String? ?? '',
    );
  }

  /// Canonical Indonesian day order used for sorting.
  static const List<String> dayOrder = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', "Jum'at",
  ];

  int get dayIndex => dayOrder.indexOf(day);
}
