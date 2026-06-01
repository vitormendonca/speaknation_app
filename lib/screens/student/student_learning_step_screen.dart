import 'package:flutter/material.dart';

import '../../data/learning_path_data.dart';
import '../../models/learning_path_step.dart';
import '../../services/learning_path_progress_service.dart';
import '../../theme/app_theme.dart';

class StudentLearningStepScreen extends StatefulWidget {
  final LearningPathStep step;
  final bool alreadyCompleted;

  const StudentLearningStepScreen({
    super.key,
    required this.step,
    required this.alreadyCompleted,
  });

  @override
  State<StudentLearningStepScreen> createState() =>
      _StudentLearningStepScreenState();
}

class _StudentLearningStepScreenState extends State<StudentLearningStepScreen> {
  bool isSaving = false;

  Future<void> _completeStep() async {
    if (widget.alreadyCompleted || isSaving) {
      Navigator.pop(context, false);
      return;
    }

    setState(() {
      isSaving = true;
    });

    await LearningPathProgressService.markStepCompleted(widget.step.id);

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final stepColor = _stepColor(widget.step.type);

    return Scaffold(
      appBar: AppBar(title: Text(widget.step.type.label)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: stepColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _stepIcon(widget.step.type),
                    color: stepColor,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  widget.step.title,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.step.level} ${widget.step.skillTitle}',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  widget.step.description,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 15,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _developmentExercise(context),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: isSaving ? null : _completeStep,
              icon: Icon(
                widget.alreadyCompleted
                    ? Icons.check_circle_outline
                    : Icons.done_rounded,
              ),
              label: Text(
                widget.alreadyCompleted
                    ? 'Already Completed'
                    : _completionLabel(widget.step.type),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _developmentExercise(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _exerciseTitle(widget.step.type),
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _exercisePrompt(widget.step),
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 15,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          _sampleQuestion(context),
        ],
      ),
    );
  }

  Widget _sampleQuestion(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Development activity placeholder. Real questions, audio, recording '
        'or reading content will be connected to this step later.',
        style: TextStyle(
          color: colors.onSurfaceVariant,
          fontSize: 13,
          height: 1.35,
        ),
      ),
    );
  }

  String _completionLabel(LearningPathStepType type) {
    switch (type) {
      case LearningPathStepType.lesson:
        return 'Complete Lesson';
      case LearningPathStepType.review:
        return 'Complete Review';
      case LearningPathStepType.finalTest:
        return 'Pass Final Test';
    }
  }

  String _exerciseTitle(LearningPathStepType type) {
    switch (type) {
      case LearningPathStepType.lesson:
        return 'Practice activity';
      case LearningPathStepType.review:
        return 'Cumulative review';
      case LearningPathStepType.finalTest:
        return 'Strong final test';
    }
  }

  String _exercisePrompt(LearningPathStep step) {
    if (step.skillId == a1RoadmapSkillId) {
      switch (step.type) {
        case LearningPathStepType.lesson:
          return 'This lesson represents one focused practice block inside the guided A1 road map.';
        case LearningPathStepType.review:
          return 'This review combines the previous six road activities before the student moves forward.';
        case LearningPathStepType.finalTest:
          return 'This final test covers the complete A1 road map and should feel stricter than normal practice.';
      }
    }

    switch (step.type) {
      case LearningPathStepType.lesson:
        return 'This lesson represents one focused practice block in the '
            '${step.skillTitle} A1 path.';
      case LearningPathStepType.review:
        return 'This review should mix the previous three lessons before the '
            'student moves forward.';
      case LearningPathStepType.finalTest:
        return 'This test should be stricter than normal lessons and count '
            'toward skill completion.';
    }
  }

  Color _stepColor(LearningPathStepType type) {
    switch (type) {
      case LearningPathStepType.lesson:
        return AppTheme.info;
      case LearningPathStepType.review:
        return AppTheme.warning;
      case LearningPathStepType.finalTest:
        return AppTheme.brandRed;
    }
  }

  IconData _stepIcon(LearningPathStepType type) {
    switch (type) {
      case LearningPathStepType.lesson:
        return Icons.play_lesson_outlined;
      case LearningPathStepType.review:
        return Icons.rate_review_outlined;
      case LearningPathStepType.finalTest:
        return Icons.workspace_premium_outlined;
    }
  }
}
