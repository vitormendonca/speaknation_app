import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/assigned_activity.dart';
import '../../services/app_auth_service.dart';
import '../../services/assignment_service.dart';
import '../../services/student_progress_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_ui.dart';
import '../login_screen.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  String studentName = 'Student';
  String studentLevel = 'A1';

  int listeningCompleted = 0;
  int vocabularyCompleted = 0;
  int readingCompleted = 0;
  int homeworkCompleted = 0;

  int listeningPending = 0;
  int vocabularyPending = 0;
  int readingPending = 0;
  int homeworkPending = 0;

  int listeningReviewNeeded = 0;
  int vocabularyReviewNeeded = 0;
  int readingReviewNeeded = 0;
  int homeworkReviewNeeded = 0;

  int listeningAverage = 0;
  int vocabularyAverage = 0;
  int readingAverage = 0;
  int homeworkAverage = 0;

  bool isLoadingProgress = true;

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();

    final currentStudentName =
        prefs.getString('currentStudentName') ?? 'Student';
    final currentStudentLevel = prefs.getString('currentStudentLevel') ?? 'A1';

    final List<AssignedActivity> assignedActivities =
        await AssignmentService.getAssignedActivitiesByStudentName(
          currentStudentName,
        );

    final averages = await StudentProgressService.getAverageScoresByCategory();

    int listeningPendingCount = 0;
    int vocabularyPendingCount = 0;
    int readingPendingCount = 0;
    int homeworkPendingCount = 0;

    int listeningCompletedCount = 0;
    int vocabularyCompletedCount = 0;
    int readingCompletedCount = 0;
    int homeworkCompletedCount = 0;

    int listeningReviewNeededCount = 0;
    int vocabularyReviewNeededCount = 0;
    int readingReviewNeededCount = 0;
    int homeworkReviewNeededCount = 0;

    for (final activity in assignedActivities) {
      final category = activity.category.toLowerCase();

      if (activity.status == 'Pending') {
        if (category == 'listening') {
          listeningPendingCount++;
        } else if (category == 'vocabulary') {
          vocabularyPendingCount++;
        } else if (category == 'reading') {
          readingPendingCount++;
        } else if (category == 'homework') {
          homeworkPendingCount++;
        }
      }

      if (activity.status == 'Completed' || activity.status == 'Reviewed') {
        if (category == 'listening') {
          listeningCompletedCount++;
        } else if (category == 'vocabulary') {
          vocabularyCompletedCount++;
        } else if (category == 'reading') {
          readingCompletedCount++;
        } else if (category == 'homework') {
          homeworkCompletedCount++;
        }
      }

      if (activity.status == 'Review Needed') {
        if (category == 'listening') {
          listeningReviewNeededCount++;
        } else if (category == 'vocabulary') {
          vocabularyReviewNeededCount++;
        } else if (category == 'reading') {
          readingReviewNeededCount++;
        } else if (category == 'homework') {
          homeworkReviewNeededCount++;
        }
      }
    }

    if (!mounted) return;

    setState(() {
      studentName = currentStudentName;
      studentLevel = currentStudentLevel;

      listeningPending = listeningPendingCount;
      vocabularyPending = vocabularyPendingCount;
      readingPending = readingPendingCount;
      homeworkPending = homeworkPendingCount;

      listeningCompleted = listeningCompletedCount;
      vocabularyCompleted = vocabularyCompletedCount;
      readingCompleted = readingCompletedCount;
      homeworkCompleted = homeworkCompletedCount;

      listeningReviewNeeded = listeningReviewNeededCount;
      vocabularyReviewNeeded = vocabularyReviewNeededCount;
      readingReviewNeeded = readingReviewNeededCount;
      homeworkReviewNeeded = homeworkReviewNeededCount;

      listeningAverage = averages['listening'] ?? 0;
      vocabularyAverage = averages['vocabulary'] ?? 0;
      readingAverage = averages['reading'] ?? 0;
      homeworkAverage = averages['homework'] ?? 0;

      isLoadingProgress = false;
    });
  }

  Future<void> logout() async {
    await AppAuthService.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Do you want to leave this account?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCompleted =
        listeningCompleted +
        vocabularyCompleted +
        readingCompleted +
        homeworkCompleted;

    final totalPending =
        listeningPending + vocabularyPending + readingPending + homeworkPending;

    final totalReviewNeeded =
        listeningReviewNeeded +
        vocabularyReviewNeeded +
        readingReviewNeeded +
        homeworkReviewNeeded;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            tooltip: 'Refresh profile',
            onPressed: loadProgress,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadProgress,
        color: AppTheme.brandRed,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _profileHeader(context),
            const SizedBox(height: 20),
            _summaryGrid(
              totalPending: totalPending,
              totalCompleted: totalCompleted,
              totalReviewNeeded: totalReviewNeeded,
            ),
            const SizedBox(height: 22),
            _currentLevelPanel(context),
            const SizedBox(height: 22),
            _progressPanel(
              context: context,
              totalPending: totalPending,
              totalCompleted: totalCompleted,
              totalReviewNeeded: totalReviewNeeded,
            ),
            const SizedBox(height: 22),
            _achievementsPanel(context),
            const SizedBox(height: 22),
            _accountPanel(context),
          ],
        ),
      ),
    );
  }

  Widget _profileHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AppPanel(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          const AppIconBox(
            icon: Icons.person_outline,
            color: AppTheme.brandRed,
            size: 56,
            iconSize: 31,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                AppStatusBadge(
                  label: 'Level $studentLevel',
                  color: AppTheme.brandRed,
                  icon: Icons.workspace_premium_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryGrid({
    required int totalPending,
    required int totalCompleted,
    required int totalReviewNeeded,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 700 ? 3 : 1;
        final spacing = 12.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: itemWidth,
              child: AppMetricCard(
                title: 'Pending',
                value: isLoadingProgress ? '...' : totalPending.toString(),
                icon: Icons.schedule_outlined,
                color: AppTheme.warning,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: AppMetricCard(
                title: 'Approved',
                value: isLoadingProgress ? '...' : totalCompleted.toString(),
                icon: Icons.check_circle_outline,
                color: AppTheme.success,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: AppMetricCard(
                title: 'Review',
                value: isLoadingProgress ? '...' : totalReviewNeeded.toString(),
                icon: Icons.rate_review_outlined,
                color: AppTheme.info,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _currentLevelPanel(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AppPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Level',
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          AppStatusBadge(
            label: studentLevel,
            color: AppTheme.brandRed,
            icon: Icons.workspace_premium_outlined,
          ),
          const SizedBox(height: 12),
          Text(
            'Complete activities and level checks to keep your progress clear.',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressPanel({
    required BuildContext context,
    required int totalPending,
    required int totalCompleted,
    required int totalReviewNeeded,
  }) {
    final colors = Theme.of(context).colorScheme;

    return AppPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$studentLevel Progress',
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isLoadingProgress
                ? 'Loading progress...'
                : '$totalPending pending activities - $totalCompleted approved activities - $totalReviewNeeded review needed',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 14,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          progressRow(
            context: context,
            icon: Icons.headphones_outlined,
            title: 'Listening',
            pending: listeningPending,
            completed: listeningCompleted,
            reviewNeeded: listeningReviewNeeded,
            averageScore: listeningAverage,
            color: AppTheme.info,
          ),
          progressRow(
            context: context,
            icon: Icons.style_outlined,
            title: 'Vocabulary',
            pending: vocabularyPending,
            completed: vocabularyCompleted,
            reviewNeeded: vocabularyReviewNeeded,
            averageScore: vocabularyAverage,
            color: AppTheme.brandRed,
          ),
          progressRow(
            context: context,
            icon: Icons.menu_book_outlined,
            title: 'Reading',
            pending: readingPending,
            completed: readingCompleted,
            reviewNeeded: readingReviewNeeded,
            averageScore: readingAverage,
            color: const Color(0xFF00897B),
          ),
          progressRow(
            context: context,
            icon: Icons.edit_note_outlined,
            title: 'Homework',
            pending: homeworkPending,
            completed: homeworkCompleted,
            reviewNeeded: homeworkReviewNeeded,
            averageScore: homeworkAverage,
            color: const Color(0xFF5E35B1),
          ),
        ],
      ),
    );
  }

  Widget _achievementsPanel(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AppPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Achievements',
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Badges, level certificates, and skill achievements will appear here in future versions.',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _accountPanel(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AppPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account',
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Use this option only when you want to leave this account or switch users.',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: confirmLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }

  Widget progressRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required int pending,
    required int completed,
    required int reviewNeeded,
    required int averageScore,
    required Color color,
  }) {
    final colors = Theme.of(context).colorScheme;
    final averageColor = averageScore >= 70
        ? AppTheme.success
        : averageScore > 0
        ? AppTheme.warning
        : colors.onSurfaceVariant;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: appBorderColor(context)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    AppStatusBadge(
                      label: 'Pending $pending',
                      color: pending > 0
                          ? AppTheme.warning
                          : colors.onSurfaceVariant,
                    ),
                    AppStatusBadge(
                      label: 'Approved $completed',
                      color: completed > 0
                          ? AppTheme.success
                          : colors.onSurfaceVariant,
                    ),
                    AppStatusBadge(
                      label: 'Review $reviewNeeded',
                      color: reviewNeeded > 0
                          ? AppTheme.warning
                          : colors.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Accuracy\n$averageScore%',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: averageColor,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
