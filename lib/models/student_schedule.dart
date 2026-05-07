/// Mirrors the Laravel StudentSchedule model.
/// period_start / period_end are period numbers (e.g. "1", "4").
/// start_time  / end_time   are HH:MM clock times from the teacher's schedule
/// (null when no teacher schedule is found for that subject).
class StudentSchedule {
  final int    id;
  final String day;
  final String subject;
  final String room;
  final String classMajor;
  final String periodStart; // period number as string e.g. "1"
  final String periodEnd;   // period number as string e.g. "4"
  final String? startTime;  // HH:MM e.g. "07:00" — from teacher's schedule
  final String? endTime;    // HH:MM e.g. "09:00" — from teacher's schedule

  const StudentSchedule({
    required this.id,
    required this.day,
    required this.subject,
    required this.room,
    required this.classMajor,
    required this.periodStart,
    required this.periodEnd,
    this.startTime,
    this.endTime,
  });

  factory StudentSchedule.fromJson(Map<String, dynamic> json) {
    return StudentSchedule(
      id:          json['id'] as int,
      day:         json['day']         as String? ?? '',
      subject:     json['subject']     as String? ?? '',
      room:        json['room']        as String? ?? '',
      classMajor:  json['class_major'] as String? ?? '',
      // Cast safely: DB stores ints, API now returns strings, handle both
      periodStart: (json['period_start'] ?? '').toString(),
      periodEnd:   (json['period_end']   ?? '').toString(),
      startTime:   json['start_time']  as String?,
      endTime:     json['end_time']    as String?,
    );
  }

  /// Human-readable time label. Uses actual clock time when available,
  /// otherwise falls back to "Jam ke-N".
  String get startDisplay => startTime ?? 'Jam ke-$periodStart';
  String get endDisplay   => endTime   ?? 'Jam ke-$periodEnd';

  /// Canonical Indonesian day order used for sorting.
  static const List<String> dayOrder = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', "Jum'at",
  ];

  int get dayIndex => dayOrder.indexOf(day);
}
