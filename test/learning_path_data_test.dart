import 'package:flutter_test/flutter_test.dart';
import 'package:speaknation_app/data/learning_path_data.dart';
import 'package:speaknation_app/models/learning_path_step.dart';

void main() {
  test('A1 roadmap shares lesson IDs with skill paths', () {
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

    expect(roadLessons, hasLength(60));
    expect(roadLessons.every((step) => skillLessonIds.contains(step.id)), true);
    expect(roadLessons.any((step) => step.skillId == a1RoadmapSkillId), false);
    expect(roadLessons.first.id, 'listening_a1_lesson_1');
  });

  test('A1 roadmap uses 10 reviews and one final test', () {
    final roadSteps = getA1RoadmapSteps();
    final reviews = roadSteps
        .where((step) => step.type == LearningPathStepType.review)
        .toList();
    final finalTests = roadSteps
        .where((step) => step.type == LearningPathStepType.finalTest)
        .toList();

    expect(roadSteps, hasLength(71));
    expect(reviews, hasLength(10));
    expect(finalTests, hasLength(1));
    expect(reviews.first.title, 'A1 Review 1');
    expect(reviews.last.title, 'A1 Review 10');
    expect(finalTests.single.title, 'A1 Final Test');
  });
}
