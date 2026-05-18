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

  String get shortClassMajor {
    final gradeMatch = RegExp(r'^(X{1,3}I{0,3})\s+').firstMatch(classMajor);
    if (gradeMatch == null) return classMajor;

    final grade = gradeMatch.group(1)!;                        
    final rest  = classMajor.substring(gradeMatch.end).trim(); 

    final numMatch  = RegExp(r'\s+(\d+)$').firstMatch(rest);
    final classNum  = numMatch?.group(1);                                  
    final majorName = numMatch != null ? rest.substring(0, numMatch.start) : rest;

    // Map to abbreviation (case-insensitive matching)
    final lc = majorName.toLowerCase();
    String abbr;
    if (lc.contains('rekayasa perangkat lunak')) {
      abbr = 'RPL';
    } else if (lc.contains('teknik komputer')) {
      abbr = 'TKJ';
    } else if (lc.contains('teknik kimia industri')) {
      abbr = 'TKI';
    } else if (lc.contains('manajemen perkantoran')) {
      abbr = 'MP';
    } else if (lc.contains('produksi') && lc.contains('televisi')) {
      abbr = 'PSPT';
    } else if (lc.contains('teknik grafika')) {
      abbr = 'TGR';
    } else if (lc.contains('akuntansi')) {
      abbr = 'AK';
    } else if (lc.contains('geomatika')) {
      abbr = 'GEO';
    } else if (lc.contains('multimedia')) {
      abbr = 'MM';
    } else if (lc.contains('desain pemodelan')) {
      abbr = 'DPIB';
    } else if (lc.contains('teknik audio video')) {
      abbr = 'TAV';
    } else if (lc.contains('sepeda motor')) {
      abbr = 'TBSM';
    } else if (lc.contains('kendaraan ringan')) {
      abbr = 'TKR';
    } else if (lc.contains('otomatisasi')) {
      abbr = 'OTKP';
    } else {
      abbr = majorName.split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty && !['dan', '&', 'dan', 'dan'].contains(w.toLowerCase()))
          .map((w) => w[0].toUpperCase())
          .join();
    }

    return classNum != null ? '$grade $abbr $classNum' : '$grade $abbr';
  }
}