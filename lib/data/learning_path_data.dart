import '../models/learning_path_step.dart';

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
];

LearningSkillDefinition? getLearningSkillDefinition(String skillId) {
  for (final skill in learningSkillDefinitions) {
    if (skill.id == skillId) {
      return skill;
    }
  }

  return null;
}

List<LearningPathStep> getLearningPathStepsBySkill(String skillId) {
  return learningPathSteps
      .where((step) => step.skillId == skillId)
      .toList()
    ..sort((a, b) => a.order.compareTo(b.order));
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
      description: 'A stronger cumulative test for the full A1 ${skill.title} path.',
      type: LearningPathStepType.finalTest,
      order: order,
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
