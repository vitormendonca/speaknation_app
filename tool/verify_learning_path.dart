import 'dart:io';

import 'package:speaknation_app/data/learning_path_data.dart';
import 'package:speaknation_app/models/learning_path_step.dart';

void main() {
  final roadSteps = getA1RoadmapSteps();
  final roadLessons = roadSteps
      .where((step) => step.type == LearningPathStepType.lesson)
      .toList();
  final skillLessonIds = {
    for (final skill in learningSkillDefinitions)
      ...getLearningPathStepsBySkill(skill.id)
          .where((step) => step.type == LearningPathStepType.lesson)
          .map((step) => step.id),
  };
  final reviews = roadSteps
      .where((step) => step.type == LearningPathStepType.review)
      .toList();
  final finalTests = roadSteps
      .where((step) => step.type == LearningPathStepType.finalTest)
      .toList();

  _expect(roadSteps.length == 71, 'A1 Road Map should have 71 steps.');
  _expect(roadLessons.length == 60, 'A1 Road Map should have 60 lessons.');
  _expect(reviews.length == 10, 'A1 Road Map should have 10 reviews.');
  _expect(finalTests.length == 1, 'A1 Road Map should have one final test.');
  _expect(
    roadLessons.every((step) => skillLessonIds.contains(step.id)),
    'Road Map lessons should reuse the same IDs as skill paths.',
  );
  _expect(
    roadLessons.every((step) => step.skillId != a1RoadmapSkillId),
    'Road Map lessons should not be duplicated under the roadmap skill.',
  );
  _expect(reviews.first.title == 'A1 Review 1', 'Review title mismatch.');
  _expect(reviews.last.title == 'A1 Review 10', 'Review title mismatch.');
  _expect(
    finalTests.single.title == 'A1 Final Test',
    'Final test title mismatch.',
  );

  stdout.writeln('Learning path data verified.');
}

void _expect(bool condition, String message) {
  if (!condition) {
    throw StateError(message);
  }
}
