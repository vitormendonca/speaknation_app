import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/assigned_activity.dart';
import '../../services/assignment_service.dart';
import '../../services/learning_path_progress_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_controller.dart';
import 'student_assignments_screen.dart';
import 'student_learning_path_screen.dart';
import 'student_level_tests_screen.dart';
import 'student_profile_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  String currentStudentName = '';
  String currentStudentLevel = 'A1';

  int totalPending = 0;
  int totalCompleted = 0;
  int totalReviewNeeded = 0;

  final Map<String, int> completedBySkill = {
    'listening': 0,
    'speaking': 0,
    'reading': 0,
    'vocabulary': 0,
    'homework': 0,
  };

  final Map<String, int> reviewBySkill = {
    'listening': 0,
    'speaking': 0,
    'reading': 0,
    'vocabulary': 0,
    'homework': 0,
  };

  final Map<String, bool> finalTestBySkill = {
    'listening': false,
    'speaking': false,
    'reading': false,
    'vocabulary': false,
    'homework': false,
  };

  bool isLoadingProgress = true;

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStudentName = prefs.getString('currentStudentName') ?? '';
    final savedStudentLevel = prefs.getString('currentStudentLevel') ?? 'A1';

    final List<AssignedActivity> assignments =
        await AssignmentService.getAssignedActivitiesByStudentName(
      savedStudentName,
    );

    final pathProgress =
        await LearningPathProgressService.getAllSkillProgress();

    if (!mounted) return;

    setState(() {
      currentStudentName = savedStudentName;
      currentStudentLevel = savedStudentLevel;

      totalPending = assignments
          .where((assignment) => assignment.status == 'Pending')
          .length;

      totalCompleted = assignments
          .where(
            (assignment) =>
                assignment.status == 'Completed' ||
                assignment.status == 'Reviewed',
          )
          .length;

      totalReviewNeeded = assignments
          .where((assignment) => assignment.status == 'Review Needed')
          .length;

      for (final skill in completedBySkill.keys) {
        final skillProgress = pathProgress[skill];

        completedBySkill[skill] = skillProgress?.completedLessons ?? 0;
        reviewBySkill[skill] = skillProgress?.completedReviews ?? 0;
        finalTestBySkill[skill] = skillProgress?.finalTestCompleted ?? false;
      }

      isLoadingProgress = false;
    });
  }

  Future<void> refreshProgress() async {
    setState(() {
      isLoadingProgress = true;
    });

    await loadProgress();
  }

  Future<void> openScreen(BuildContext context, Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => screen,
      ),
    );

    await refreshProgress();
  }

  int get totalAssigned {
    return totalPending + totalCompleted + totalReviewNeeded;
  }

  int get pathCompleted {
    return completedBySkill.values.fold(0, (sum, value) => sum + value);
  }

  String get firstName {
    if (currentStudentName.trim().isEmpty) {
      return 'there';
    }

    return currentStudentName.trim().split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SpeakNation'),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            icon: Icon(ThemeController.iconFor(context)),
            onPressed: () => ThemeController.toggle(context),
          ),
          IconButton(
            tooltip: 'My Profile',
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              openScreen(
                context,
                const StudentProfileScreen(),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: refreshProgress,
        color: AppTheme.brandRed,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _heroPanel(context),
            const SizedBox(height: 18),
            _metricGrid(context),
            const SizedBox(height: 22),
            _levelCheckPanel(context),
            const SizedBox(height: 22),
            _assignedWorkPanel(context),
            const SizedBox(height: 22),
            _learningPathPanel(context),
            const SizedBox(height: 10),
            Text(
              'Your teacher guides the same learning path you can study on your own.',
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroPanel(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasReview = totalReviewNeeded > 0;
    final hasPending = totalPending > 0;

    final String actionTitle;
    final String actionLabel;
    final IconData actionIcon;
    final VoidCallback action;

    if (hasReview) {
      actionTitle = 'Review needs attention';
      actionLabel = 'Open Review';
      actionIcon = Icons.rate_review_outlined;
      action = () => openScreen(context, const StudentAssignmentsScreen());
    } else if (hasPending) {
      actionTitle = 'Keep today moving';
      actionLabel = 'Open Assignments';
      actionIcon = Icons.assignment_outlined;
      action = () => openScreen(context, const StudentAssignmentsScreen());
    } else {
      actionTitle = 'Continue your A1 path';
      actionLabel = 'Continue Learning';
      actionIcon = Icons.play_arrow_rounded;
      action = () => openScreen(
            context,
            const StudentLearningPathScreen(skillId: 'listening'),
          );
    }

    return _panel(
      context: context,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.brandRed.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.school_outlined,
                  color: AppTheme.brandRed,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, $firstName',
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Level $currentStudentLevel path',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            actionTitle,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Build real progress across Listening, Speaking, Reading, '
            'Vocabulary and Grammar.',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: action,
              icon: Icon(actionIcon),
              label: Text(actionLabel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 700 ? 4 : 2;
        final spacing = 12.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: itemWidth,
              child: _metricCard(
                context: context,
                icon: Icons.route_outlined,
                label: 'Path',
                value: '$pathCompleted/60',
                color: AppTheme.info,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _metricCard(
                context: context,
                icon: Icons.assignment_outlined,
                label: 'Guided',
                value: totalAssigned.toString(),
                color: AppTheme.brandRed,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _metricCard(
                context: context,
                icon: Icons.check_circle_outline,
                label: 'Lessons Done',
                value: pathCompleted.toString(),
                color: AppTheme.success,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: _metricCard(
                context: context,
                icon: Icons.rate_review_outlined,
                label: 'To Review',
                value: totalReviewNeeded.toString(),
                color: AppTheme.warning,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _metricCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final colors = Theme.of(context).colorScheme;

    return _panel(
      context: context,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _levelCheckPanel(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return _panel(
      context: context,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.brandRed.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.workspace_premium_outlined,
              color: AppTheme.brandRed,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Already know some English?',
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Take a level check to validate what you know and start '
                  'from the right point.',
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
          IconButton(
            tooltip: 'Open level checks',
            onPressed: () => openScreen(
              context,
              const StudentLevelTestsScreen(),
            ),
            icon: const Icon(Icons.arrow_forward_ios_rounded),
          ),
        ],
      ),
    );
  }

  Widget _assignedWorkPanel(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return _panel(
      context: context,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            context: context,
            title: 'Teacher Guidance',
            subtitle: 'Recommendations from your teacher for this same path.',
            actionLabel: 'Open',
            onAction: () => openScreen(
              context,
              const StudentAssignmentsScreen(),
            ),
          ),
          const SizedBox(height: 16),
          if (isLoadingProgress)
            LinearProgressIndicator(
              color: AppTheme.brandRed,
              backgroundColor: colors.surfaceContainerHighest,
            )
          else ...[
            _statusLine(
              context: context,
              icon: Icons.schedule_outlined,
              label: 'Recommended',
              value: totalPending,
              color: AppTheme.warning,
            ),
            _statusLine(
              context: context,
              icon: Icons.check_circle_outline,
              label: 'Completed with guidance',
              value: totalCompleted,
              color: AppTheme.success,
            ),
            _statusLine(
              context: context,
              icon: Icons.rate_review_outlined,
              label: 'Needs teacher review',
              value: totalReviewNeeded,
              color: AppTheme.warning,
            ),
          ],
        ],
      ),
    );
  }

  Widget _learningPathPanel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          context: context,
          title: 'A1 Learning Path',
          subtitle: '12 lessons, review every 3, then a final test.',
        ),
        const SizedBox(height: 12),
        _skillPathTile(
          context: context,
          title: 'Listening',
          subtitle: 'Audio, dictation and comprehension.',
          skill: 'listening',
          icon: Icons.headphones_outlined,
          color: AppTheme.info,
          onTap: () => openScreen(
            context,
            const StudentLearningPathScreen(skillId: 'listening'),
          ),
        ),
        _skillPathTile(
          context: context,
          title: 'Speaking',
          subtitle: 'Guided recording and teacher review.',
          skill: 'speaking',
          icon: Icons.mic_none_outlined,
          color: const Color(0xFF7B1FA2),
          onTap: () => openScreen(
            context,
            const StudentLearningPathScreen(skillId: 'speaking'),
          ),
        ),
        _skillPathTile(
          context: context,
          title: 'Reading',
          subtitle: 'Short texts and guided comprehension.',
          skill: 'reading',
          icon: Icons.menu_book_outlined,
          color: const Color(0xFF00897B),
          onTap: () => openScreen(
            context,
            const StudentLearningPathScreen(skillId: 'reading'),
          ),
        ),
        _skillPathTile(
          context: context,
          title: 'Vocabulary',
          subtitle: 'Themes, review sets and final checks.',
          skill: 'vocabulary',
          icon: Icons.style_outlined,
          color: AppTheme.brandRed,
          onTap: () => openScreen(
            context,
            const StudentLearningPathScreen(skillId: 'vocabulary'),
          ),
        ),
        _skillPathTile(
          context: context,
          title: 'Grammar & Practice',
          subtitle: 'Homework, grammar and written practice.',
          skill: 'homework',
          icon: Icons.edit_note_outlined,
          color: const Color(0xFF5E35B1),
          onTap: () => openScreen(
            context,
            const StudentLearningPathScreen(skillId: 'homework'),
          ),
        ),
      ],
    );
  }

  Widget _skillPathTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String skill,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;
    final completed = completedBySkill[skill] ?? 0;
    final completedReviews = reviewBySkill[skill] ?? 0;
    final finalTestDone = finalTestBySkill[skill] ?? false;
    final double progress = (completed / 12).clamp(0.0, 1.0).toDouble();
    final reviewLabel = finalTestDone
        ? 'Test passed'
        : '$completedReviews/4 reviews';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _borderColor(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 13,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: colors.onSurfaceVariant,
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    color: color,
                    backgroundColor: colors.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '$completed/12 lessons',
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    _smallBadge(
                      context: context,
                      label: reviewLabel,
                      color: finalTestDone ? AppTheme.success : color,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader({
    required BuildContext context,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(width: 10),
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel),
          ),
        ],
      ],
    );
  }

  Widget _statusLine({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int value,
    required Color color,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _smallBadge(
            context: context,
            label: value.toString(),
            color: value > 0 ? color : colors.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _smallBadge({
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

  Widget _panel({
    required BuildContext context,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _borderColor(context)),
      ),
      child: child,
    );
  }

  Color _borderColor(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return colors.outlineVariant.withValues(alpha: isDark ? 0.35 : 0.8);
  }

}
