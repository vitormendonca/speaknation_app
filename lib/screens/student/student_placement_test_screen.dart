import 'package:flutter/material.dart';

import '../../data/placement_test_data.dart';
import '../../models/placement_question.dart';
import '../../services/learning_path_progress_service.dart';
import '../../theme/app_theme.dart';

class StudentPlacementTestScreen extends StatefulWidget {
  final String level;

  const StudentPlacementTestScreen({
    super.key,
    required this.level,
  });

  @override
  State<StudentPlacementTestScreen> createState() =>
      _StudentPlacementTestScreenState();
}

class _StudentPlacementTestScreenState
    extends State<StudentPlacementTestScreen> {
  final Map<String, String> selectedAnswers = {};

  bool isSubmitted = false;
  bool isSaving = false;
  int score = 0;

  List<PlacementQuestion> get questions {
    switch (widget.level) {
      case 'A1':
        return a1PlacementQuestions;
      default:
        return const [];
    }
  }

  int get correctCount {
    return questions.where((question) {
      return selectedAnswers[question.id] == question.correctAnswer;
    }).length;
  }

  bool get isComplete {
    return selectedAnswers.length == questions.length;
  }

  bool get passed {
    return score >= 85;
  }

  Future<void> _submitTest() async {
    if (!isComplete || isSaving) {
      return;
    }

    final calculatedScore = ((correctCount / questions.length) * 100).round();

    setState(() {
      score = calculatedScore;
      isSubmitted = true;
      isSaving = true;
    });

    if (calculatedScore >= 85) {
      await LearningPathProgressService.validateLevel(widget.level);
    }

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.level} Placement Check'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _header(context),
          const SizedBox(height: 18),
          for (final question in questions) _questionCard(context, question),
          const SizedBox(height: 10),
          if (isSubmitted) _resultCard(context),
          const SizedBox(height: 18),
          SizedBox(
            height: 50,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isComplete && !isSaving ? _submitTest : null,
              icon: Icon(
                isSubmitted
                    ? Icons.refresh_outlined
                    : Icons.workspace_premium_outlined,
              ),
              label: Text(
                isSubmitted ? 'Recalculate Score' : 'Submit Placement Check',
              ),
            ),
          ),
          if (!isComplete) ...[
            const SizedBox(height: 10),
            Text(
              'Answer all questions to submit.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
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
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppTheme.brandRed.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.workspace_premium_outlined,
              color: AppTheme.brandRed,
              size: 30,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '${widget.level} Placement Check',
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 27,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pass with 85% or higher to validate this level and continue from '
            'the next path. This is a development version with sample questions.',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 15,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _questionCard(BuildContext context, PlacementQuestion question) {
    final colors = Theme.of(context).colorScheme;
    final selectedAnswer = selectedAnswers[question.id];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
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
          _skillBadge(context, question.skill),
          const SizedBox(height: 12),
          Text(
            question.question,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          for (final option in question.options)
            _answerOption(
              context: context,
              question: question,
              option: option,
              isSelected: selectedAnswer == option,
            ),
        ],
      ),
    );
  }

  Widget _answerOption({
    required BuildContext context,
    required PlacementQuestion question,
    required String option,
    required bool isSelected,
  }) {
    final colors = Theme.of(context).colorScheme;
    final isCorrect = option == question.correctAnswer;
    final showCorrect = isSubmitted && isCorrect;
    final showWrong = isSubmitted && isSelected && !isCorrect;
    final borderColor = showCorrect
        ? AppTheme.success
        : showWrong
            ? AppTheme.brandRed
            : isSelected
                ? AppTheme.info
                : colors.outlineVariant.withValues(alpha: 0.5);
    final foregroundColor = showCorrect
        ? AppTheme.success
        : showWrong
            ? AppTheme.brandRed
            : colors.onSurface;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected
            ? borderColor.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: isSubmitted
              ? null
              : () {
                  setState(() {
                    selectedAnswers[question.id] = option;
                  });
                },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: foregroundColor,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: 14,
                      fontWeight: isSelected || showCorrect
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _resultCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final resultColor = passed ? AppTheme.success : AppTheme.warning;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: resultColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: resultColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            passed
                ? Icons.check_circle_outline
                : Icons.rate_review_outlined,
            color: resultColor,
            size: 30,
          ),
          const SizedBox(height: 12),
          Text(
            '$score%',
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            passed
                ? '${widget.level} validated. Your path was unlocked by test.'
                : 'Keep studying. You need 85% to validate this level.',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 14,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _skillBadge(BuildContext context, String label) {
    final color = _skillColor(label);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Color _skillColor(String skill) {
    switch (skill) {
      case 'Listening':
        return AppTheme.info;
      case 'Speaking':
        return const Color(0xFF7B1FA2);
      case 'Reading':
        return const Color(0xFF00897B);
      case 'Vocabulary':
        return AppTheme.brandRed;
      case 'Grammar':
        return const Color(0xFF5E35B1);
      default:
        return AppTheme.info;
    }
  }
}
