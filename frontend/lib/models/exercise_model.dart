enum ExerciseCategory {
  animal,
  bodyParts,
  food,
  verbs,
}

enum ExerciseType {
  writing, // Display image, type answer
  comprehension, // Audio + match picture to word
}

class ExerciseQuestion {
  final String id;
  final String? imageUrl;
  final String? audioUrl;
  final String? stimulusText; // For comprehension exercises - the text/description shown to user
  final String correctAnswer;
  final List<String>? options; // For comprehension exercises
  final List<String>? imageOptions; // For comprehension exercises
  final Map<String, String>? cueHierarchy; // Function, Rhyming, Written cues

  ExerciseQuestion({
    required this.id,
    this.imageUrl,
    this.audioUrl,
    this.stimulusText,
    required this.correctAnswer,
    this.options,
    this.imageOptions,
    this.cueHierarchy,
  });
}

class Exercise {
  final String id;
  final String title;
  final String description;
  final String type; // e.g., "writing", "comprehension"
  final ExerciseCategory category;
  final ExerciseType exerciseType;
  final List<String> options; // For multiple choice exercises (deprecated, use questions)
  final String? correctAnswer; // Deprecated, use questions
  final int difficulty; // 1-5 scale
  final String? imageUrl; // For displaying images (deprecated, use questions)
  final String? audioUrl; // For audio cues (deprecated, use questions)
  final Map<String, String>? cueHierarchy; // Function, Rhyming, Written cues (deprecated, use questions)
  final List<String>? imageOptions; // For comprehension exercises (deprecated, use questions)
  final List<ExerciseQuestion> questions; // List of questions for this exercise

  Exercise({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.exerciseType,
    required this.options,
    this.correctAnswer,
    this.difficulty = 1,
    this.imageUrl,
    this.audioUrl,
    this.cueHierarchy,
    this.imageOptions,
    required this.questions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'category': category.name,
      'exerciseType': exerciseType.name,
      'options': options,
      'correctAnswer': correctAnswer,
      'difficulty': difficulty,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'cueHierarchy': cueHierarchy,
      'imageOptions': imageOptions,
      'questions': questions.map((q) => {
        'id': q.id,
        'imageUrl': q.imageUrl,
        'audioUrl': q.audioUrl,        'stimulusText': q.stimulusText,        'correctAnswer': q.correctAnswer,
        'options': q.options,
        'imageOptions': q.imageOptions,
        'cueHierarchy': q.cueHierarchy,
      }).toList(),
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? '',
      category: ExerciseCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => ExerciseCategory.animal,
      ),
      exerciseType: ExerciseType.values.firstWhere(
        (e) => e.name == map['exerciseType'],
        orElse: () => ExerciseType.writing,
      ),
      options: List<String>.from(map['options'] ?? []),
      correctAnswer: map['correctAnswer'],
      difficulty: map['difficulty'] ?? 1,
      imageUrl: map['imageUrl'],
      audioUrl: map['audioUrl'],
      cueHierarchy: map['cueHierarchy'] != null
          ? Map<String, String>.from(map['cueHierarchy'])
          : null,
      imageOptions: map['imageOptions'] != null
          ? List<String>.from(map['imageOptions'])
          : null,
      questions: map['questions'] != null
          ? (map['questions'] as List).map((q) => ExerciseQuestion(
                id: q['id'] ?? '',
                imageUrl: q['imageUrl'],
                audioUrl: q['audioUrl'],
                stimulusText: q['stimulusText'],
            // Coerce to string to handle numeric values stored in Firestore
            correctAnswer: q['correctAnswer']?.toString() ?? '',
            options: q['options'] != null
              ? (q['options'] as List).map((e) => e.toString()).toList()
              : null,
            imageOptions: q['imageOptions'] != null
              ? (q['imageOptions'] as List).map((e) => e.toString()).toList()
              : null,
            cueHierarchy: q['cueHierarchy'] != null
              ? (q['cueHierarchy'] as Map).map((key, value) => MapEntry(key.toString(), value?.toString() ?? ''))
              : null,
              )).toList()
          : [],
    );
  }
}

