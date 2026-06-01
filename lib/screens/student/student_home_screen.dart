import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/learning_path_data.dart';
import '../../models/assigned_activity.dart';
import '../../models/learning_path_step.dart';
import '../../services/assignment_service.dart';
import '../../services/learning_path_progress_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_controller.dart';
import 'student_a1_roadmap_screen.dart';
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
  int completedRoadReviews = 0;
  bool roadFinalTestCompleted = false;

  bool isLoadingProgress = true;
  bool isTeacherGuidanceExpanded = false;

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

    await LearningPathProgressService.syncCompletedAssignmentsToLearningPath(
      assignments,
    );

    final completedStepIds =
        await LearningPathProgressService.getCompletedStepIds();
    final pathProgress =
        LearningPathProgressService.getAllSkillProgressFromCompleted(
          completedStepIds,
        );
    final roadSteps = getA1RoadmapSteps();
    final roadReviewsCompleted = roadSteps
        .where(
          (step) =>
              step.type == LearningPathStepType.review &&
              completedStepIds.contains(step.id),
        )
        .length;
    LearningPathStep? roadFinalStep;

    for (final step in roadSteps) {
      if (step.type == LearningPathStepType.finalTest) {
        roadFinalStep = step;
        break;
      }
    }

    if (!mounted) return;

    final pending = assignments
        .where((assignment) => assignment.status == 'Pending')
        .length;
    final completed = assignments
        .where(
          (assignment) =>
              assignment.status == 'Completed' ||
              assignment.status == 'Reviewed',
        )
        .length;
    final reviewNeeded = assignments
        .where((assignment) => assignment.status == 'Review Needed')
        .length;

    setState(() {
      currentStudentName = savedStudentName;
      currentStudentLevel = savedStudentLevel;
      totalPending = pending;
      totalCompleted = completed;
      totalReviewNeeded = reviewNeeded;
      completedRoadReviews = roadReviewsCompleted;
      roadFinalTestCompleted =
          roadFinalStep != null && completedStepIds.contains(roadFinalStep.id);

      for (final skill in completedBySkill.keys) {
        final skillProgress = pathProgress[skill];

        completedBySkill[skill] = skillProgress?.completedLessons ?? 0;
        reviewBySkill[skill] = skillProgress?.completedReviews ?? 0;
        finalTestBySkill[skill] = skillProgress?.finalTestCompleted ?? false;
      }

      isTeacherGuidanceExpanded = reviewNeeded > 0;
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
      MaterialPageRoute(builder: (context) => screen),
    );

    await refreshProgress();
  }

  int get totalAssigned {
    return totalPending + totalCompleted + totalReviewNeeded;
  }

  int get pathCompleted {
    return completedBySkill.values.fold(0, (sum, value) => sum + value);
  }

  double get pathProgress {
    return (pathCompleted / 60).clamp(0.0, 1.0).toDouble();
  }

  int get totalRoadReviews {
    return getA1RoadmapSteps()
        .where((step) => step.type == LearningPathStepType.review)
        .length;
  }

  String get firstName {
    if (currentStudentName.trim().isEmpty) {
      return 'there';
    }

    return currentStudentName.trim().split(' ').first;
  }

  String get nextSkillId {
    const skillOrder = [
      'listening',
      'speaking',
      'reading',
      'vocabulary',
      'homework',
    ];

    for (final skill in skillOrder) {
      if ((completedBySkill[skill] ?? 0) < 12) {
        return skill;
      }
    }

    return 'listening';
  }

  String get nextSkillTitle {
    switch (nextSkillId) {
      case 'speaking':
        return 'Speaking';
      case 'reading':
        return 'Reading';
      case 'vocabulary':
        return 'Vocabulary';
      case 'homework':
        return 'Grammar';
      case 'listening':
      default:
        return 'Listening';
    }
  }

  bool get hasTeacherAttention {
    return totalPending > 0 || totalReviewNeeded > 0;
  }

  @override
  Widget build(BuildContext context) {
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
              openScreen(context, const StudentProfileScreen());
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
            _todayPanel(context),
            const SizedBox(height: 18),
            _skillProgressGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _todayPanel(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return _panel(
      context: context,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => openScreen(context, const StudentProfileScreen()),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.brandRed.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: AppTheme.brandRed,
                    size: 29,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () =>
                      openScreen(context, const StudentProfileScreen()),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, $firstName',
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        _levelBadge(context, currentStudentLevel),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Open profile',
                onPressed: () =>
                    openScreen(context, const StudentProfileScreen()),
                icon: Icon(
                  Icons.chevron_right_rounded,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.brandRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.route_outlined,
                  color: AppTheme.brandRed,
                  size: 21,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _smallBadge(
                context: context,
                label: '$pathCompleted/60 lessons',
                color: AppTheme.info,
              ),
              _smallBadge(
                context: context,
                label: '$completedRoadReviews/$totalRoadReviews reviews',
                color: AppTheme.warning,
              ),
              _smallBadge(
                context: context,
                label: roadFinalTestCompleted ? 'Final 1/1' : 'Final 0/1',
                color: roadFinalTestCompleted
                    ? AppTheme.success
                    : colors.onSurfaceVariant,
              ),
              _compactAction(
                context: context,
                icon: Icons.workspace_premium_outlined,
                label: 'Placement Test',
                onTap: () =>
                    openScreen(context, const StudentLevelTestsScreen()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _levelBadge(BuildContext context, String level) {
    final style = _levelStyle(level);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: style.borderColor.withValues(alpha: 0.75)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, color: style.color, size: 15),
          const SizedBox(width: 6),
          Text(
            'Level ${level.toUpperCase()}',
            style: TextStyle(
              color: style.textColor,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (style.accentIcon != null) ...[
            const SizedBox(width: 5),
            Icon(style.accentIcon, color: style.accentColor, size: 13),
          ],
        ],
      ),
    );
  }

  _LevelBadgeStyle _levelStyle(String level) {
    final normalized = level.toUpperCase();
    const silver = Color(0xFF9EA7B3);
    const silverDark = Color(0xFF6F7782);
    const gold = Color(0xFFC99722);
    const diamond = Color(0xFF00A6D6);

    if (normalized.startsWith('C')) {
      return const _LevelBadgeStyle(
        color: diamond,
        textColor: diamond,
        borderColor: Color(0xFF7DE3FF),
        icon: Icons.diamond_outlined,
        accentIcon: Icons.auto_awesome,
        accentColor: Color(0xFFE9FAFF),
      );
    }

    switch (normalized) {
      case 'A2':
        return const _LevelBadgeStyle(
          color: silver,
          textColor: silverDark,
          borderColor: gold,
          icon: Icons.workspace_premium_outlined,
          accentIcon: Icons.auto_awesome,
          accentColor: gold,
        );
      case 'B1':
        return const _LevelBadgeStyle(
          color: gold,
          textColor: gold,
          borderColor: gold,
          icon: Icons.workspace_premium_outlined,
        );
      case 'B2':
        return const _LevelBadgeStyle(
          color: gold,
          textColor: gold,
          borderColor: Color(0xFFFFD766),
          icon: Icons.workspace_premium_outlined,
          accentIcon: Icons.auto_awesome,
          accentColor: Color(0xFFFFD766),
        );
      case 'A1':
      default:
        return const _LevelBadgeStyle(
          color: silver,
          textColor: silverDark,
          borderColor: silver,
          icon: Icons.workspace_premium_outlined,
        );
    }
  }

  Widget _compactAction({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(99),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: _borderColor(context)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: colors.onSurfaceVariant, size: 14),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _teacherGuidancePanel(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final highlightColor = totalReviewNeeded > 0
        ? AppTheme.warning
        : totalPending > 0
        ? AppTheme.info
        : colors.onSurfaceVariant;

    return _panel(
      context: context,
      color: hasTeacherAttention
          ? highlightColor.withValues(alpha: 0.07)
          : Theme.of(context).cardColor,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                setState(() {
                  isTeacherGuidanceExpanded = !isTeacherGuidanceExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: highlightColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        totalReviewNeeded > 0
                            ? Icons.rate_review_outlined
                            : Icons.assignment_outlined,
                        color: highlightColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Teacher Guidance',
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            totalAssigned == 0
                                ? 'No teacher recommendations yet.'
                                : '$totalPending pending - $totalReviewNeeded review - $totalCompleted done',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                    Icon(
                      isTeacherGuidanceExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: colors.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: isTeacherGuidanceExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: Column(
                      children: [
                        Divider(color: _borderColor(context)),
                        const SizedBox(height: 8),
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
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: OutlinedButton.icon(
                              onPressed: () => openScreen(
                                context,
                                const StudentAssignmentsScreen(),
                              ),
                              icon: const Icon(Icons.open_in_new_rounded),
                              label: const Text('Open Assignments'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _skillProgressGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          context: context,
          title: 'A1 Progress',
          subtitle: 'Continue your road or focus on one skill.',
        ),
        const SizedBox(height: 12),
        _continueRoadCard(context),
        const SizedBox(height: 10),
        _teacherGuidancePanel(context),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 760 ? 5 : 2;
            final spacing = 10.0;
            final itemWidth =
                (constraints.maxWidth - spacing * (columns - 1)) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: _skillProgressCard(
                    context: context,
                    title: 'Listening',
                    skill: 'listening',
                    icon: Icons.headphones_outlined,
                    color: AppTheme.info,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _skillProgressCard(
                    context: context,
                    title: 'Speaking',
                    skill: 'speaking',
                    icon: Icons.mic_none_outlined,
                    color: const Color(0xFF7B1FA2),
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _skillProgressCard(
                    context: context,
                    title: 'Reading',
                    skill: 'reading',
                    icon: Icons.menu_book_outlined,
                    color: const Color(0xFF00897B),
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _skillProgressCard(
                    context: context,
                    title: 'Vocabulary',
                    skill: 'vocabulary',
                    icon: Icons.style_outlined,
                    color: AppTheme.brandRed,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _skillProgressCard(
                    context: context,
                    title: 'Grammar',
                    skill: 'homework',
                    icon: Icons.edit_note_outlined,
                    color: const Color(0xFF5E35B1),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _continueRoadCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => openScreen(context, const StudentA1RoadmapScreen()),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.brandRed.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.brandRed.withValues(alpha: 0.55),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.brandRed.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: AppTheme.brandRed,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Continue A1 Road',
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Next focus: $nextSkillTitle inside the guided road.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: colors.onSurfaceVariant,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _skillProgressCard({
    required BuildContext context,
    required String title,
    required String skill,
    required IconData icon,
    required Color color,
  }) {
    final colors = Theme.of(context).colorScheme;
    final completed = completedBySkill[skill] ?? 0;
    final completedReviews = reviewBySkill[skill] ?? 0;
    final finalTestDone = finalTestBySkill[skill] ?? false;
    final progress = (completed / 12).clamp(0.0, 1.0).toDouble();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () =>
            openScreen(context, StudentLearningPathScreen(skillId: skill)),
        child: Container(
          height: 136,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _borderColor(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 23),
                  const Spacer(),
                  Text(
                    '$completed/12',
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 9),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  color: color,
                  backgroundColor: colors.surfaceContainerHighest,
                ),
              ),
              const Spacer(),
              _smallBadge(
                context: context,
                label: finalTestDone
                    ? 'Test passed'
                    : '$completedReviews/4 reviews',
                color: finalTestDone ? AppTheme.success : color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader({
    required BuildContext context,
    required String title,
    required String subtitle,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 20,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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

  Widget _panel({
    required BuildContext context,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    Color? color,
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).cardColor,
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

class _LevelBadgeStyle {
  final Color color;
  final Color textColor;
  final Color borderColor;
  final IconData icon;
  final IconData? accentIcon;
  final Color? accentColor;

  const _LevelBadgeStyle({
    required this.color,
    required this.textColor,
    required this.borderColor,
    required this.icon,
    this.accentIcon,
    this.accentColor,
  });
}
