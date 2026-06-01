import 'package:flutter/material.dart';

import '../../data/learning_path_data.dart';
import '../../services/learning_path_progress_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_ui.dart';

class TeacherStudentProgressScreen extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String studentLevel;

  const TeacherStudentProgressScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.studentLevel,
  });

  @override
  State<TeacherStudentProgressScreen> createState() =>
      _TeacherStudentProgressScreenState();
}

class _TeacherStudentProgressScreenState
    extends State<TeacherStudentProgressScreen> {
  Map<String, LearningPathSkillProgress> progressBySkill = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final progress =
        await LearningPathProgressService.getAllSkillProgressForStudent(
          studentId: widget.studentId,
          studentName: widget.studentName,
        );

    if (!mounted) return;

    setState(() {
      progressBySkill = progress;
      isLoading = false;
    });
  }

  int get totalCompletedSteps {
    return progressBySkill.values.fold(
      0,
      (sum, progress) => sum + progress.completedSteps,
    );
  }

  int get totalSteps {
    return progressBySkill.values.fold(
      0,
      (sum, progress) => sum + progress.totalSteps,
    );
  }

  int get totalLessonsCompleted {
    return progressBySkill.values.fold(
      0,
      (sum, progress) => sum + progress.completedLessons,
    );
  }

  int get finalTestsPassed {
    return progressBySkill.values
        .where((progress) => progress.finalTestCompleted)
        .length;
  }

  int get overallPercent {
    if (totalSteps == 0) {
      return 0;
    }

    return ((totalCompletedSteps / totalSteps) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Progress'),
        actions: [
          IconButton(
            tooltip: 'Refresh progress',
            onPressed: _loadProgress,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProgress,
        color: AppTheme.brandRed,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _headerCard(context),
            const SizedBox(height: 18),
            if (isLoading)
              _loadingState()
            else ...[
              _overallCard(context),
              const SizedBox(height: 18),
              const AppSectionHeader(
                title: 'Learning Path',
                subtitle:
                    'Progress by skill across lessons, reviews and tests.',
              ),
              const SizedBox(height: 12),
              for (final skill in learningSkillDefinitions)
                _skillProgressCard(context, skill),
            ],
          ],
        ),
      ),
    );
  }

  Widget _headerCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final initial = widget.studentName.isEmpty ? '?' : widget.studentName[0];

    return AppPanel(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppTheme.brandRed.withValues(alpha: 0.14),
            child: Text(
              initial,
              style: const TextStyle(
                color: AppTheme.brandRed,
                fontSize: 23,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.studentName,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                AppStatusBadge(
                  label: 'Level ${widget.studentLevel}',
                  color: AppTheme.info,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _overallCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AppPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppIconBox(
                icon: Icons.query_stats_outlined,
                color: AppTheme.info,
                size: 50,
                iconSize: 28,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Progress',
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalCompletedSteps/$totalSteps path steps completed',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$overallPercent%',
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: totalSteps == 0 ? 0 : totalCompletedSteps / totalSteps,
              minHeight: 9,
              color: AppTheme.info,
              backgroundColor: colors.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppMetricCard(
                  icon: Icons.play_lesson_outlined,
                  title: 'Lessons',
                  value: totalLessonsCompleted.toString(),
                  color: AppTheme.success,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppMetricCard(
                  icon: Icons.workspace_premium_outlined,
                  title: 'Final Tests',
                  value: '$finalTestsPassed/5',
                  color: AppTheme.brandRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _skillProgressCard(
    BuildContext context,
    LearningSkillDefinition skill,
  ) {
    final colors = Theme.of(context).colorScheme;
    final progress =
        progressBySkill[skill.id] ??
        LearningPathSkillProgress(
          skillId: skill.id,
          completedLessons: 0,
          totalLessons: 12,
          completedReviews: 0,
          totalReviews: 4,
          finalTestCompleted: false,
        );

    final color = _skillColor(skill.id);
    final completedSteps = progress.completedSteps;
    final totalSkillSteps = progress.totalSteps;
    final percent = totalSkillSteps == 0
        ? 0
        : ((completedSteps / totalSkillSteps) * 100).round();

    return AppPanel(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIconBox(icon: _skillIcon(skill.id), color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skill.title,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      skill.description,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$percent%',
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: totalSkillSteps == 0
                  ? 0
                  : completedSteps / totalSkillSteps,
              minHeight: 8,
              color: color,
              backgroundColor: colors.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppStatusBadge(
                label:
                    '${progress.completedLessons}/${progress.totalLessons} lessons',
                color: color,
              ),
              AppStatusBadge(
                label:
                    '${progress.completedReviews}/${progress.totalReviews} reviews',
                color: AppTheme.warning,
              ),
              AppStatusBadge(
                label: progress.finalTestCompleted
                    ? 'Final passed'
                    : 'Final pending',
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

  Widget _loadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 80),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Color _skillColor(String skillId) {
    switch (skillId) {
      case 'listening':
        return AppTheme.info;
      case 'speaking':
        return AppTheme.accentPurple;
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
}
