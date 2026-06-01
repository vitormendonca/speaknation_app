import 'package:flutter/material.dart';

import '../../data/learning_path_data.dart';
import '../../models/learning_path_step.dart';
import '../../services/learning_path_progress_service.dart';
import '../../theme/app_theme.dart';
import 'student_learning_step_screen.dart';

class StudentA1RoadmapScreen extends StatefulWidget {
  const StudentA1RoadmapScreen({super.key});

  @override
  State<StudentA1RoadmapScreen> createState() => _StudentA1RoadmapScreenState();
}

class _StudentA1RoadmapScreenState extends State<StudentA1RoadmapScreen> {
  Set<String> completedStepIds = {};
  bool isLoading = true;

  List<LearningPathStep> get roadSteps {
    return getA1RoadmapSteps();
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

  bool _isRoadStepUnlocked(int index) {
    if (index <= 0) {
      return true;
    }

    final step = roadSteps[index];

    if (completedStepIds.contains(step.id)) {
      return true;
    }

    return completedStepIds.contains(roadSteps[index - 1].id);
  }

  int? _nextRoadStepIndex(List<LearningPathStep> steps) {
    for (int index = 0; index < steps.length; index++) {
      final step = steps[index];

      if (!completedStepIds.contains(step.id) && _isRoadStepUnlocked(index)) {
        return index;
      }
    }

    return null;
  }

  Future<void> _openStep(int index, LearningPathStep step) async {
    final isCompleted = completedStepIds.contains(step.id);
    final isUnlocked = _isRoadStepUnlocked(index);

    if (!isUnlocked) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complete the previous road step to unlock this.'),
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
    final steps = roadSteps;

    return Scaffold(
      appBar: AppBar(title: const Text('A1 Road Map')),
      body: RefreshIndicator(
        onRefresh: _loadProgress,
        color: AppTheme.brandRed,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _header(context, steps),
            const SizedBox(height: 20),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(28),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              for (int index = 0; index < steps.length; index++)
                _roadStepTile(context, index, steps[index]),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, List<LearningPathStep> steps) {
    final colors = Theme.of(context).colorScheme;
    final completedRoadSteps = steps
        .where((step) => completedStepIds.contains(step.id))
        .length;
    final completedLessons = steps
        .where(
          (step) =>
              step.type == LearningPathStepType.lesson &&
              completedStepIds.contains(step.id),
        )
        .length;
    final completedReviews = steps
        .where(
          (step) =>
              step.type == LearningPathStepType.review &&
              completedStepIds.contains(step.id),
        )
        .length;
    final progress = steps.isEmpty ? 0.0 : completedRoadSteps / steps.length;
    final nextIndex = isLoading ? null : _nextRoadStepIndex(steps);
    VoidCallback? continueAction;

    if (nextIndex != null) {
      continueAction = () => _openStep(nextIndex, steps[nextIndex]);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
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
              Icons.route_outlined,
              color: AppTheme.brandRed,
              size: 30,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'A1 Road Map',
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 27,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A guided A1 path with integrated practice, one review every 6 activities and one final test.',
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
              value: progress.clamp(0.0, 1.0).toDouble(),
              minHeight: 9,
              color: AppTheme.brandRed,
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
                label: '$completedRoadSteps/${steps.length} road steps',
                color: AppTheme.brandRed,
              ),
              _badge(
                context: context,
                label:
                    '$completedLessons/${_totalByType(steps, LearningPathStepType.lesson)} lessons',
                color: AppTheme.info,
              ),
              _badge(
                context: context,
                label:
                    '$completedReviews/${_totalByType(steps, LearningPathStepType.review)} reviews',
                color: AppTheme.warning,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: continueAction,
              icon: Icon(
                nextIndex == null
                    ? Icons.check_circle_outline
                    : Icons.play_arrow_rounded,
              ),
              label: Text(
                nextIndex == null ? 'A1 Road Complete' : 'Continue Road',
              ),
            ),
          ),
          if (nextIndex != null) ...[
            const SizedBox(height: 8),
            Text(
              'Up next: ${steps[nextIndex].skillTitle} ${steps[nextIndex].type.label}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _roadStepTile(BuildContext context, int index, LearningPathStep step) {
    final colors = Theme.of(context).colorScheme;
    final isCompleted = completedStepIds.contains(step.id);
    final isUnlocked = _isRoadStepUnlocked(index);
    final isReview = step.type == LearningPathStepType.review;
    final isFinalTest = step.type == LearningPathStepType.finalTest;
    final isMilestone = isReview || isFinalTest;
    final typeColor = _stepTypeColor(step.type);
    final skillColor = _skillColor(step.skillId);
    final stepColor = isCompleted
        ? AppTheme.success
        : isMilestone
        ? typeColor
        : isUnlocked
        ? skillColor
        : colors.onSurfaceVariant;
    final borderColor = isMilestone
        ? stepColor.withValues(alpha: isUnlocked ? 0.72 : 0.45)
        : colors.outlineVariant.withValues(alpha: 0.5);
    final backgroundColor = isMilestone
        ? stepColor.withValues(alpha: isUnlocked ? 0.08 : 0.04)
        : Colors.transparent;
    final badgeLabel = isCompleted
        ? 'Done'
        : isUnlocked
        ? step.type.label
        : 'Locked';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _openStep(index, step),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: borderColor,
                width: isMilestone ? 1.4 : 1,
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
                        ? _stepTypeIcon(step.type, step.skillId)
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
                      Wrap(
                        spacing: 7,
                        runSpacing: 5,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _tinyBadge(
                            context: context,
                            label: 'Step ${index + 1}',
                            color: colors.onSurfaceVariant,
                          ),
                          _tinyBadge(
                            context: context,
                            label: step.skillTitle,
                            color: skillColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
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
                _badge(context: context, label: badgeLabel, color: stepColor),
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
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _tinyBadge({
    required BuildContext context,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 10,
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
      case a1RoadmapSkillId:
        return AppTheme.accentPurple;
      default:
        return AppTheme.info;
    }
  }

  int _totalByType(List<LearningPathStep> steps, LearningPathStepType type) {
    return steps.where((step) => step.type == type).length;
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

  IconData _stepTypeIcon(LearningPathStepType type, String skillId) {
    switch (type) {
      case LearningPathStepType.lesson:
        return _skillIcon(skillId);
      case LearningPathStepType.review:
        return Icons.rate_review_outlined;
      case LearningPathStepType.finalTest:
        return Icons.workspace_premium_outlined;
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
      case a1RoadmapSkillId:
        return Icons.route_outlined;
      default:
        return Icons.school_outlined;
    }
  }
}
