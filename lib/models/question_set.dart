class QuestionSet {
  final int    id;
  final String title;
  final String keyCode;
  final int?   questionsCount;

  const QuestionSet({
    required this.id,
    required this.title,
    required this.keyCode,
    this.questionsCount,
  });

  factory QuestionSet.fromJson(Map<String, dynamic> json) {
    return QuestionSet(
      id:             json['id']              as int,
      title:          json['title']           as String? ?? '',
      keyCode:        json['key_code']        as String? ?? '',
      questionsCount: json['questions_count'] as int?,
    );
  }
}

class Question {
  final int    id;
  final String questionText;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAnswer;

  const Question({
    required this.id,
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id:            json['id']             as int,
      questionText:  json['question_text']  as String? ?? '',
      optionA:       json['option_a']       as String? ?? '',
      optionB:       json['option_b']       as String? ?? '',
      optionC:       json['option_c']       as String? ?? '',
      optionD:       json['option_d']       as String? ?? '',
      correctAnswer: json['correct_answer'] as String? ?? '',
    );
  }
}

class QuestionSetDetail {
  final int            id;
  final String         title;
  final String         keyCode;
  final List<Question> questions;

  const QuestionSetDetail({
    required this.id,
    required this.title,
    required this.keyCode,
    required this.questions,
  });

  factory QuestionSetDetail.fromJson(Map<String, dynamic> json) {
    final raw = json['questions'] as List<dynamic>? ?? [];
    return QuestionSetDetail(
      id:        json['id']       as int,
      title:     json['title']    as String? ?? '',
      keyCode:   json['key_code'] as String? ?? '',
      questions: raw.map((e) => Question.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
