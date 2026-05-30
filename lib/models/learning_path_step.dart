enum LearningPathStepType {
  lesson,
  review,
  finalTest,
}

class LearningPathStep {
  final String id;
  final String level;
  final String skillId;
  final String skillTitle;
  final String title;
  final String description;
  final LearningPathStepType type;
  final int order;
  final int? lessonNumber;
  final int? reviewNumber;

  const LearningPathStep({
    required this.id,
    required this.level,
    required this.skillId,
    required this.skillTitle,
    required this.title,
    required this.description,
    required this.type,
    required this.order,
    this.lessonNumber,
    this.reviewNumber,
  });
}

extension LearningPathStepTypeLabel on LearningPathStepType {
  String get label {
    switch (this) {
      case LearningPathStepType.lesson:
        return 'Lesson';
      case LearningPathStepType.review:
        return 'Review';
      case LearningPathStepType.finalTest:
        return 'Final Test';
    }
  }
}
