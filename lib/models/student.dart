/// Mirrors the Laravel Student model fields returned by the API.
class Student {
  final String name;
  final String nis;
  final String classMajor;

  const Student({
    required this.name,
    required this.nis,
    required this.classMajor,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      name:       json['name'] as String? ?? '',
      nis:        json['nis'] as String? ?? '',
      classMajor: json['class_major'] as String? ?? '',
    );
  }

  Map<String, String> toMap() => {
    'name':        name,
    'nis':         nis,
    'class_major': classMajor,
  };

  static Student fromMap(Map<String, String?> map) => Student(
    name:       map['name'] ?? '',
    nis:        map['nis'] ?? '',
    classMajor: map['class_major'] ?? '',
  );
}