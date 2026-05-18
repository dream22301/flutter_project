/// Mirrors the Laravel next-subject API response payload.
class NextSubject {
  final String subject;
  final String room;
  final String startTime; 
  final String endTime;    
  final int periodStart;
  final int periodEnd;

  const NextSubject({
    required this.subject,
    required this.room,
    required this.startTime,
    required this.endTime,
    required this.periodStart,
    required this.periodEnd,
  });

  factory NextSubject.fromJson(Map<String, dynamic> json) {
    return NextSubject(
      subject:     json['subject']      as String? ?? '',
      room:        json['room']         as String? ?? '',
      startTime:   json['start_time']   as String? ?? '',
      endTime:     json['end_time']     as String? ?? '',
      periodStart: json['period_start'] as int?    ?? 0,
      periodEnd:   json['period_end']   as int?    ?? 0,
    );
  }

  String get timeRange {
    String fmt(String t) => t.length >= 5 ? t.substring(0, 5) : t;
    return '${fmt(startTime)} – ${fmt(endTime)}';
  }
}
