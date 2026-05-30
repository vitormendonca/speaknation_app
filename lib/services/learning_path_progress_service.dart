import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/learning_path_data.dart';
import '../models/learning_path_step.dart';

class LearningPathSkillProgress {
  final String skillId;
  final int completedLessons;
  final int totalLessons;
  final int completedReviews;
  final int totalReviews;
  final bool finalTestCompleted;

  const LearningPathSkillProgress({
    required this.skillId,
    required this.completedLessons,
    required this.totalLessons,
    required this.completedReviews,
    required this.totalReviews,
    required this.finalTestCompleted,
  });

  int get completedSteps {
    return completedLessons + completedReviews + (finalTestCompleted ? 1 : 0);
  }

  int get totalSteps {
    return totalLessons + totalReviews + 1;
  }

  double get lessonProgress {
    if (totalLessons == 0) {
      return 0;
    }

    return completedLessons / totalLessons;
  }
}

class LearningPathProgressService {
  static const String _completedStepsPrefix = 'learning_path_completed_steps';

  static Future<Set<String>> getCompletedStepIds() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _completedStepsKey(prefs);
    final jsonString = prefs.getString(key);

    if (jsonString == null || jsonString.isEmpty) {
      return {};
    }

    final decoded = jsonDecode(jsonString);

    if (decoded is! List) {
      return {};
    }

    return decoded.map((item) => item.toString()).toSet();
  }

  static Future<void> markStepCompleted(String stepId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _completedStepsKey(prefs);
    final completed = await getCompletedStepIds();

    completed.add(stepId);

    await prefs.setString(key, jsonEncode(completed.toList()));
  }

  static Future<bool> isStepCompleted(String stepId) async {
    final completed = await getCompletedStepIds();
    return completed.contains(stepId);
  }

  static bool isStepUnlocked({
    required LearningPathStep step,
    required Set<String> completedStepIds,
  }) {
    final skillSteps = getLearningPathStepsBySkill(step.skillId);
    final stepIndex = skillSteps.indexWhere((item) => item.id == step.id);

    if (stepIndex <= 0) {
      return true;
    }

    final previousStep = skillSteps[stepIndex - 1];
    return completedStepIds.contains(previousStep.id);
  }

  static Future<LearningPathSkillProgress> getSkillProgress(
    String skillId,
  ) async {
    final completed = await getCompletedStepIds();
    return getSkillProgressFromCompleted(
      skillId: skillId,
      completedStepIds: completed,
    );
  }

  static Future<Map<String, LearningPathSkillProgress>>
      getAllSkillProgress() async {
    final completed = await getCompletedStepIds();

    return {
      for (final skill in learningSkillDefinitions)
        skill.id: getSkillProgressFromCompleted(
          skillId: skill.id,
          completedStepIds: completed,
        ),
    };
  }

  static LearningPathSkillProgress getSkillProgressFromCompleted({
    required String skillId,
    required Set<String> completedStepIds,
  }) {
    final skillSteps = getLearningPathStepsBySkill(skillId);
    final lessonSteps = skillSteps
        .where((step) => step.type == LearningPathStepType.lesson)
        .toList();
    final reviewSteps = skillSteps
        .where((step) => step.type == LearningPathStepType.review)
        .toList();
    LearningPathStep? finalTestStep;

    for (final step in skillSteps) {
      if (step.type == LearningPathStepType.finalTest) {
        finalTestStep = step;
        break;
      }
    }

    final completedLessons = lessonSteps
        .where((step) => completedStepIds.contains(step.id))
        .length;
    final completedReviews = reviewSteps
        .where((step) => completedStepIds.contains(step.id))
        .length;

    return LearningPathSkillProgress(
      skillId: skillId,
      completedLessons: completedLessons,
      totalLessons: lessonSteps.length,
      completedReviews: completedReviews,
      totalReviews: reviewSteps.length,
      finalTestCompleted:
          finalTestStep != null && completedStepIds.contains(finalTestStep.id),
    );
  }

  static Future<String> _completedStepsKey(SharedPreferences prefs) async {
    final studentId = prefs.getString('currentStudentId');
    final studentName = prefs.getString('currentStudentName');
    final studentKey = (studentId?.isNotEmpty ?? false)
        ? studentId!
        : (studentName?.isNotEmpty ?? false)
            ? studentName!
            : 'guest';

    return '${_completedStepsPrefix}_${_normalizeKey(studentKey)}';
  }

  static String _normalizeKey(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_]+'), '_');
  }
}
