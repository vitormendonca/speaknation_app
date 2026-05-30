import 'package:flutter/material.dart';

import '../../data/learning_path_data.dart';
import '../../models/learning_path_step.dart';
import '../../services/learning_path_progress_service.dart';
import '../../theme/app_theme.dart';
import 'student_learning_step_screen.dart';

class StudentLearningPathScreen extends StatefulWidget {
  final String skillId;

  const StudentLearningPathScreen({
    super.key,
    required this.skillId,
  });

  @override
  State<StudentLearningPathScreen> createState() =>
      _StudentLearningPathScreenState();
}

class _StudentLearningPathScreenState extends State<StudentLearningPathScreen> {
  Set<String> completedStepIds = {};
  bool isLoading = true;

  LearningSkillDefinition? get skill {
    return getLearningSkillDefinition(widget.skillId);
  }

  List<LearningPathStep> get steps {
    return getLearningPathStepsBySkill(widget.skillId);
  }

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final completed = await LearningPathProgressService.getCompletedStepIds();

    if (!mounted) return;

    setState(() {
      completedStepIds = completed;
      isLoading = false;
    });
  }

  Future<void> _openStep(LearningPathStep step) async {
    final isCompleted = completedStepIds.contains(step.id);
    final isUnlocked = LearningPathProgressService.isStepUnlocked(
      step: step,
      completedStepIds: completedStepIds,
    );

    if (!isUnlocked) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complete the previous step to unlock this activity.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(milliseconds: 1400),
        ),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentLearningStepScreen(
          step: step,
          alreadyCompleted: isCompleted,
        ),
      ),
    );

    if (result == true) {
      await _loadProgress();
    }
  }

  @override
  Widget build(BuildContext context) {
    final skillDefinition = skill;
    final colors = Theme.of(context).colorScheme;

    if (skillDefinition == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Learning Path'),
        ),
        body: const Center(
          child: Text('Skill not found.'),
        ),
      );
    }

    final progress = LearningPathProgressService.getSkillProgressFromCompleted(
      skillId: widget.skillId,
      completedStepIds: completedStepIds,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${skillDefinition.title} Path'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadProgress,
        color: AppTheme.brandRed,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _header(context, skillDefinition, progress),
            const SizedBox(height: 20),
            Text(
              'A1 Roadmap',
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '12 lessons, 4 reviews and one stronger final test.',
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 14),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(28),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              for (final step in steps) _stepTile(context, step),
          ],
        ),
      ),
    );
  }

  Widget _header(
    BuildContext context,
    LearningSkillDefinition skillDefinition,
    LearningPathSkillProgress progress,
  ) {
    final colors = Theme.of(context).colorScheme;
    final skillColor = _skillColor(skillDefinition.id);

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
              color: skillColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _skillIcon(skillDefinition.id),
              color: skillColor,
              size: 30,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'A1 ${skillDefinition.title}',
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 27,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            skillDefinition.description,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress.lessonProgress.clamp(0.0, 1.0).toDouble(),
              minHeight: 9,
              color: skillColor,
              backgroundColor: colors.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _badge(
                context: context,
                label:
                    '${progress.completedLessons}/${progress.totalLessons} lessons',
                color: skillColor,
              ),
              _badge(
                context: context,
                label:
                    '${progress.completedReviews}/${progress.totalReviews} reviews',
                color: AppTheme.warning,
              ),
              _badge(
                context: context,
                label: progress.finalTestCompleted
                    ? 'Final test passed'
                    : 'Final test locked',
                color: progress.finalTestCompleted
                    ? AppTheme.success
                    : colors.onSurfaceVariant,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepTile(BuildContext context, LearningPathStep step) {
    final colors = Theme.of(context).colorScheme;
    final isCompleted = completedStepIds.contains(step.id);
    final isUnlocked = LearningPathProgressService.isStepUnlocked(
      step: step,
      completedStepIds: completedStepIds,
    );
    final stepColor = isCompleted
        ? AppTheme.success
        : isUnlocked
            ? _stepTypeColor(step.type)
            : colors.onSurfaceVariant;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _openStep(step),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: stepColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.check_circle_outline
                        : isUnlocked
                            ? _stepTypeIcon(step.type)
                            : Icons.lock_outline,
                    color: stepColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step.description,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _badge(
                  context: context,
                  label: isCompleted
                      ? 'Done'
                      : isUnlocked
                          ? step.type.label
                          : 'Locked',
                  color: stepColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge({
    required BuildContext context,
    required String label,
    required Color color,
  }) {
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

  Color _skillColor(String skillId) {
    switch (skillId) {
      case 'listening':
        return AppTheme.info;
      case 'speaking':
        return const Color(0xFF7B1FA2);
      case 'reading':
        return const Color(0xFF00897B);
      case 'vocabulary':
        return AppTheme.brandRed;
      case 'homework':
        return const Color(0xFF5E35B1);
      default:
        return AppTheme.info;
    }
  }

  IconData _skillIcon(String skillId) {
    switch (skillId) {
      case 'listening':
        return Icons.headphones_outlined;
      case 'speaking':
        return Icons.mic_none_outlined;
      case 'reading':
        return Icons.menu_book_outlined;
      case 'vocabulary':
        return Icons.style_outlined;
      case 'homework':
        return Icons.edit_note_outlined;
      default:
        return Icons.school_outlined;
    }
  }

  Color _stepTypeColor(LearningPathStepType type) {
    switch (type) {
      case LearningPathStepType.lesson:
        return AppTheme.info;
      case LearningPathStepType.review:
        return AppTheme.warning;
      case LearningPathStepType.finalTest:
        return AppTheme.brandRed;
    }
  }

  IconData _stepTypeIcon(LearningPathStepType type) {
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
