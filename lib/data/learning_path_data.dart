import '../models/learning_path_step.dart';

const String a1RoadmapSkillId = 'a1_roadmap';

class LearningSkillDefinition {
  final String id;
  final String title;
  final String description;

  const LearningSkillDefinition({
    required this.id,
    required this.title,
    required this.description,
  });
}

const List<LearningSkillDefinition> learningSkillDefinitions = [
  LearningSkillDefinition(
    id: 'listening',
    title: 'Listening',
    description: 'Audio comprehension, dictation and listening confidence.',
  ),
  LearningSkillDefinition(
    id: 'speaking',
    title: 'Speaking',
    description: 'Guided prompts, pronunciation practice and oral fluency.',
  ),
  LearningSkillDefinition(
    id: 'reading',
    title: 'Reading',
    description: 'Short texts, key vocabulary and comprehension practice.',
  ),
  LearningSkillDefinition(
    id: 'vocabulary',
    title: 'Vocabulary',
    description: 'Themed words, usage in context and cumulative review.',
  ),
  LearningSkillDefinition(
    id: 'homework',
    title: 'Grammar & Practice',
    description: 'Grammar patterns, sentence building and written practice.',
  ),
];

final List<LearningPathStep> learningPathSteps = [
  for (final skill in learningSkillDefinitions) ..._buildSkillPath(skill),
  ...a1RoadmapMilestoneSteps,
];

final List<LearningPathStep> a1RoadmapMilestoneSteps =
    _buildA1RoadmapMilestoneSteps();

LearningSkillDefinition? getLearningSkillDefinition(String skillId) {
  for (final skill in learningSkillDefinitions) {
    if (skill.id == skillId) {
      return skill;
    }
  }

  return null;
}

List<LearningPathStep> getLearningPathStepsBySkill(String skillId) {
  return learningPathSteps.where((step) => step.skillId == skillId).toList()
    ..sort((a, b) => a.order.compareTo(b.order));
}

List<LearningPathStep> getA1RoadmapSteps() {
  const roadSkillOrder = [
    'listening',
    'vocabulary',
    'speaking',
    'reading',
    'homework',
  ];
  final steps = <LearningPathStep>[];
  var completedRoadLessons = 0;
  var reviewNumber = 1;

  for (int lessonNumber = 1; lessonNumber <= 12; lessonNumber++) {
    for (final skillId in roadSkillOrder) {
      steps.add(
        _findStep(
          skillId: skillId,
          type: LearningPathStepType.lesson,
          lessonNumber: lessonNumber,
        ),
      );
      completedRoadLessons++;

      if (completedRoadLessons % 6 == 0) {
        steps.add(
          _findStep(
            skillId: a1RoadmapSkillId,
            type: LearningPathStepType.review,
            reviewNumber: reviewNumber,
          ),
        );
        reviewNumber++;
      }
    }
  }

  steps.add(
    _findStep(skillId: a1RoadmapSkillId, type: LearningPathStepType.finalTest),
  );

  return steps;
}

LearningPathStep _findStep({
  required String skillId,
  required LearningPathStepType type,
  int? lessonNumber,
  int? reviewNumber,
}) {
  return learningPathSteps.firstWhere(
    (step) =>
        step.skillId == skillId &&
        step.type == type &&
        step.lessonNumber == lessonNumber &&
        step.reviewNumber == reviewNumber,
  );
}

List<LearningPathStep> _buildSkillPath(LearningSkillDefinition skill) {
  final steps = <LearningPathStep>[];
  int order = 1;

  for (int group = 1; group <= 4; group++) {
    for (int lessonInGroup = 1; lessonInGroup <= 3; lessonInGroup++) {
      final lessonNumber = ((group - 1) * 3) + lessonInGroup;

      steps.add(
        LearningPathStep(
          id: '${skill.id}_a1_lesson_$lessonNumber',
          level: 'A1',
          skillId: skill.id,
          skillTitle: skill.title,
          title: '${skill.title} Lesson $lessonNumber',
          description: _lessonDescription(skill.id, lessonNumber),
          type: LearningPathStepType.lesson,
          order: order,
          lessonNumber: lessonNumber,
        ),
      );

      order++;
    }

    steps.add(
      LearningPathStep(
        id: '${skill.id}_a1_review_$group',
        level: 'A1',
        skillId: skill.id,
        skillTitle: skill.title,
        title: '${skill.title} Review $group',
        description: 'Review lessons ${((group - 1) * 3) + 1} to ${group * 3}.',
        type: LearningPathStepType.review,
        order: order,
        reviewNumber: group,
      ),
    );

    order++;
  }

  steps.add(
    LearningPathStep(
      id: '${skill.id}_a1_final_test',
      level: 'A1',
      skillId: skill.id,
      skillTitle: skill.title,
      title: 'A1 ${skill.title} Final Test',
      description:
          'A stronger cumulative test for the full A1 ${skill.title} path.',
      type: LearningPathStepType.finalTest,
      order: order,
    ),
  );

  return steps;
}

List<LearningPathStep> _buildA1RoadmapMilestoneSteps() {
  final steps = <LearningPathStep>[];

  for (int reviewNumber = 1; reviewNumber <= 10; reviewNumber++) {
    final firstRoadActivity = ((reviewNumber - 1) * 6) + 1;
    final lastRoadActivity = reviewNumber * 6;

    steps.add(
      LearningPathStep(
        id: 'a1_roadmap_review_$reviewNumber',
        level: 'A1',
        skillId: a1RoadmapSkillId,
        skillTitle: 'A1 Road Map',
        title: 'A1 Review $reviewNumber',
        description:
            'Review road activities $firstRoadActivity to $lastRoadActivity.',
        type: LearningPathStepType.review,
        order: reviewNumber * 7,
        reviewNumber: reviewNumber,
      ),
    );
  }

  steps.add(
    const LearningPathStep(
      id: 'a1_roadmap_final_test',
      level: 'A1',
      skillId: a1RoadmapSkillId,
      skillTitle: 'A1 Road Map',
      title: 'A1 Final Test',
      description: 'A stronger test covering the complete A1 road map.',
      type: LearningPathStepType.finalTest,
      order: 71,
    ),
  );

  return steps;
}

String _lessonDescription(String skillId, int lessonNumber) {
  switch (skillId) {
    case 'listening':
      return 'Listen, understand the main idea and answer short questions.';
    case 'speaking':
      return 'Practice a guided speaking prompt and build oral confidence.';
    case 'reading':
      return 'Read a short text and answer comprehension questions.';
    case 'vocabulary':
      return 'Learn themed vocabulary and use it in short sentences.';
    case 'homework':
      return 'Practice grammar and sentence structure with guided tasks.';
    default:
      return 'Complete the practice activity and keep moving forward.';
  }
}
