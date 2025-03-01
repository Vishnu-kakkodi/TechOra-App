class Option {
  final String id;
  final String text;
  final bool isCorrect;

  Option({
    required this.id,
    required this.text,
    required this.isCorrect,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['_id'] ?? '',
      text: json['text'] ?? '',
      isCorrect: json['isCorrect'] ?? false,
    );
  }
}



class Question {
  final String id;
  final String text;
  final String type;
  final int points;
  final String explanation;
  final String status;
  final List<Option> options;

  Question({
    required this.id,
    required this.text,
    required this.type,
    required this.points,
    required this.explanation,
    required this.status,
    required this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['_id'] ?? '',
      text: json['question'] ?? '',
      type: json['type'] ?? 'multiple-choice',
      points: json['points'] ?? 0,
      explanation: json['explanation'] ?? '',
      status: json['status'] ?? 'published',
      options: (json['options'] as List<dynamic>?)
              ?.map((option) => Option.fromJson(option))
              .toList() ??
          [],
    );
  }

    int get correctOptionIndex {
    return options.indexWhere((option) => option.isCorrect);
  }
}



class Quiz {
  final String id;
  final String title;
  final String description;
  final String department;
  final String difficultyLevel;
  final int passingScore;
  final int positiveScore;
  final int negativeScore;
  final String stack;
  final String collegeName;
  final String startDate;
  final int duration;
  final int maxAttempts;
  final int totalQuestions;
  final String status;
  final List<Question> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.department,
    required this.difficultyLevel,
    required this.passingScore,
    required this.positiveScore,
    required this.negativeScore,
    required this.stack,
    required this.collegeName,
    required this.startDate,
    required this.duration,
    required this.maxAttempts,
    required this.totalQuestions,
    required this.status,
    required this.questions,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      department: json['department'] ?? '',
      difficultyLevel: json['difficultyLevel'] ?? '',
      passingScore: json['passingScore'] ?? 0,
      positiveScore: json['positiveScore'] ?? 0,
      negativeScore: json['negativeScore'] ?? 0,
      stack: json['stack'] ?? '',
      collegeName: json['institutionId']?['collegeName'] ?? '',
      startDate: json['startDate'] ?? '',
      duration: json['duration'] ?? 0,
      maxAttempts: json['maxAttempts'] ?? 1,
      totalQuestions: json['totalQuestions'] ?? 0,
      status: json['status'] ?? '',
      questions: (json['questions'] as List<dynamic>?)
              ?.map((question) => Question.fromJson(question))
              .toList() ??
          [],
    );
  }
}
