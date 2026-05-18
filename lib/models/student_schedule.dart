class StudentSchedule {
  final int    id;
  final String day;
  final String subject;
  final String room;
  final String classMajor;
  final String periodStart; 
  final String periodEnd;   
  final String? startTime;  
  final String? endTime;    

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
      periodStart: (json['period_start'] ?? '').toString(),
      periodEnd:   (json['period_end']   ?? '').toString(),
      startTime:   json['start_time']  as String?,
      endTime:     json['end_time']    as String?,
    );
  }


  String? get calculatedStartTime {
    final p = int.tryParse(periodStart) ?? 0;
    final time = _getHardcodedTime(p, true);
    return time.isNotEmpty ? time : startTime; 
  }

  String? get calculatedEndTime {
    final p = int.tryParse(periodEnd) ?? 0;
    final time = _getHardcodedTime(p, false);
    return time.isNotEmpty ? time : endTime;
  }

  String get startDisplay => calculatedStartTime ?? 'Jam ke-$periodStart';
  String get endDisplay   => calculatedEndTime   ?? 'Jam ke-$periodEnd';


  static const List<String> dayOrder = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', "Jum'at",
  ];

  int get dayIndex => dayOrder.indexOf(day);

  String _getHardcodedTime(int period, bool isStart) {
    final d = day.toLowerCase();
    if (d == 'senin') {
      switch (period) {
        case 1: return isStart ? "08:00" : "08:40";
        case 2: return isStart ? "08:40" : "09:20";
        case 3: return isStart ? "09:20" : "10:00";
        case 4: return isStart ? "10:15" : "10:55";
        case 5: return isStart ? "10:55" : "11:35";
        case 6: return isStart ? "11:35" : "12:15";
        case 7: return isStart ? "13:00" : "13:55";
        case 8: return isStart ? "13:55" : "14:35";
        case 9: return isStart ? "14:35" : "15:15";
        default: return "";
      }
    } else if (d == "jum'at" || d == "jumat") {
      switch (period) {
        case 1: return isStart ? "08:00" : "08:40";
        case 2: return isStart ? "08:40" : "09:20";
        case 3: return isStart ? "09:20" : "10:00";
        case 4: return isStart ? "10:00" : "10:40";
        case 5: return isStart ? "12:20" : "13:15";
        case 6: return isStart ? "13:15" : "13:55";
        case 7: return isStart ? "13:55" : "14:35";
        case 8: return isStart ? "14:35" : "15:15";
        default: return "";
      }
    } else {
      // Selasa, Rabu, Kamis
      switch (period) {
        case 1:  return isStart ? "07:00" : "07:40";
        case 2:  return isStart ? "07:40" : "08:20";
        case 3:  return isStart ? "08:20" : "09:00";
        case 4:  return isStart ? "09:00" : "09:40";
        case 5:  return isStart ? "09:55" : "10:35";
        case 6:  return isStart ? "10:35" : "11:15";
        case 7:  return isStart ? "11:15" : "11:55";
        case 8:  return isStart ? "12:35" : "13:30";
        case 9:  return isStart ? "13:30" : "14:10";
        case 10: return isStart ? "14:10" : "14:50";
        case 11: return isStart ? "14:50" : "15:30";
        default: return "";
      }
    }
  }
}


