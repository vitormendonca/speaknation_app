import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/homework_data.dart';
import '../../data/listening_data.dart';
import '../../data/reading_data.dart';
import '../../data/speaking_data.dart';
import '../../data/vocabulary_data.dart';
import '../../models/assigned_activity.dart';
import '../../models/homework_activity.dart';
import '../../models/listening_exercise.dart';
import '../../models/reading_activity.dart';
import '../../models/speaking_activity.dart';
import '../../models/vocabulary_quiz.dart';
import '../../services/assignment_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_ui.dart';
import '../homework/homework_activity_screen.dart';
import '../listening/listening_exercise_screen.dart';
import '../reading/reading_screen.dart';
import '../speaking/speaking_activity_screen.dart';
import '../vocabulary/vocabulary_quiz_screen.dart';

class StudentAssignmentsScreen extends StatefulWidget {
  const StudentAssignmentsScreen({super.key});

  @override
  State<StudentAssignmentsScreen> createState() =>
      _StudentAssignmentsScreenState();
}

class _StudentAssignmentsScreenState extends State<StudentAssignmentsScreen> {
  String currentStudentName = '';
  String currentStudentLevel = '';

  List<AssignedActivity> studentAssignments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudentAssignments();
  }

  Future<void> _loadStudentAssignments() async {
    final prefs = await SharedPreferences.getInstance();

    final savedStudentName = prefs.getString('currentStudentName') ?? '';
    final savedStudentLevel = prefs.getString('currentStudentLevel') ?? '';

    final assignments =
        await AssignmentService.getAssignedActivitiesByStudentName(
          savedStudentName,
        );

    if (!mounted) return;

    setState(() {
      currentStudentName = savedStudentName;
      currentStudentLevel = savedStudentLevel;
      studentAssignments = assignments.reversed.toList();
      isLoading = false;
    });
  }

  ListeningExercise? _findListeningExercise(String title) {
    for (final exercise in listeningExercises) {
      if (exercise.title == title) {
        return exercise;
      }
    }

    return null;
  }

  VocabularyQuiz? _findVocabularyQuiz(String title) {
    for (final quiz in vocabularyQuizzes) {
      if (quiz.title == title) {
        return quiz;
      }
    }

    return null;
  }

  ReadingActivity? _findReadingActivity(String title) {
    for (final activity in readingActivities) {
      if (activity.title == title) {
        return activity;
      }
    }

    return null;
  }

  SpeakingActivity? _findSpeakingActivity(String title) {
    for (final activity in speakingActivities) {
      if (activity.title == title) {
        return activity;
      }
    }

    return null;
  }

  HomeworkActivity? _findHomeworkActivity(String title) {
    for (final activity in homeworkActivities) {
      if (activity.title == title) {
        return activity;
      }
    }

    return null;
  }

  void _showActivityNotFound(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Activity not found. Check if the assigned activity title matches the real activity title.',
        ),
        duration: Duration(milliseconds: 1200),
      ),
    );
  }

  Future<void> _openAssignedActivity({
    required BuildContext context,
    required AssignedActivity assignment,
  }) async {
    switch (assignment.category) {
      case 'Listening':
        final exercise = _findListeningExercise(assignment.title);

        if (exercise == null) {
          _showActivityNotFound(context);
          return;
        }

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ListeningExerciseScreen(exercise: exercise),
          ),
        );

        await _loadStudentAssignments();
        return;

      case 'Vocabulary':
        final quiz = _findVocabularyQuiz(assignment.title);

        if (quiz == null) {
          _showActivityNotFound(context);
          return;
        }

        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => VocabularyQuizScreen(quiz: quiz)),
        );

        await _loadStudentAssignments();
        return;

      case 'Reading':
        final readingActivity = _findReadingActivity(assignment.title);

        if (readingActivity == null) {
          _showActivityNotFound(context);
          return;
        }

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReadingActivityScreen(activity: readingActivity),
          ),
        );

        await _loadStudentAssignments();
        return;

      case 'Speaking':
        final speakingActivity = _findSpeakingActivity(assignment.title);

        if (speakingActivity == null) {
          _showActivityNotFound(context);
          return;
        }

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SpeakingActivityScreen(activity: speakingActivity),
          ),
        );

        await _loadStudentAssignments();
        return;

      case 'Homework':
        final homeworkActivity = _findHomeworkActivity(assignment.title);

        if (homeworkActivity == null) {
          _showActivityNotFound(context);
          return;
        }

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HomeworkActivityScreen(activity: homeworkActivity),
          ),
        );

        await _loadStudentAssignments();
        return;

      default:
        _showActivityNotFound(context);
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalAssignments = studentAssignments.length;
    final pendingCount = studentAssignments
        .where((activity) => activity.status == 'Pending')
        .length;
    final completedCount = studentAssignments
        .where(
          (activity) =>
              activity.status == 'Completed' || activity.status == 'Reviewed',
        )
        .length;
    final reviewNeededCount = studentAssignments
        .where((activity) => activity.status == 'Review Needed')
        .length;

    final studentLabel = currentStudentName.isEmpty
        ? 'Check the activities your teacher assigned to you.'
        : 'Activities assigned to $currentStudentName.';
    final levelLabel = currentStudentLevel.isEmpty
        ? studentLabel
        : '$studentLabel Level $currentStudentLevel.';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Assignments'),
        actions: [
          IconButton(
            tooltip: 'Refresh assignments',
            onPressed: _loadStudentAssignments,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStudentAssignments,
        color: AppTheme.brandRed,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppSectionHeader(title: 'My Assignments', subtitle: levelLabel),
            const SizedBox(height: 20),
            _summaryGrid(
              totalAssignments: totalAssignments,
              pendingCount: pendingCount,
              completedCount: completedCount,
              reviewNeededCount: reviewNeededCount,
            ),
            const SizedBox(height: 24),
            const AppSectionHeader(
              title: 'Assigned to You',
              subtitle:
                  'Open teacher recommendations and keep your path moving.',
            ),
            const SizedBox(height: 14),
            if (isLoading)
              _loadingCard()
            else if (studentAssignments.isEmpty)
              _emptyCard(context)
            else
              for (final activity in studentAssignments)
                _assignmentCard(context: context, activity: activity),
            const SizedBox(height: 20),
            _infoCard(context),
          ],
        ),
      ),
    );
  }

  Widget _summaryGrid({
    required int totalAssignments,
    required int pendingCount,
    required int completedCount,
    required int reviewNeededCount,
  }) {
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
              child: AppMetricCard(
                title: 'Total',
                value: isLoading ? '...' : totalAssignments.toString(),
                icon: Icons.assignment_outlined,
                color: AppTheme.info,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: AppMetricCard(
                title: 'Pending',
                value: isLoading ? '...' : pendingCount.toString(),
                icon: Icons.schedule_outlined,
                color: AppTheme.warning,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: AppMetricCard(
                title: 'Completed',
                value: isLoading ? '...' : completedCount.toString(),
                icon: Icons.check_circle_outline,
                color: AppTheme.success,
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: AppMetricCard(
                title: 'Review',
                value: isLoading ? '...' : reviewNeededCount.toString(),
                icon: Icons.rate_review_outlined,
                color: AppTheme.warning,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _assignmentCard({
    required BuildContext context,
    required AssignedActivity activity,
  }) {
    final colors = Theme.of(context).colorScheme;
    final statusColor = _statusColor(activity.status);
    final statusIcon = _statusIcon(activity.status);

    return AppPanel(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIconBox(
                icon: _categoryIcon(activity.category),
                color: statusColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${activity.category} - ${activity.level}',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              AppStatusBadge(
                label: activity.status,
                color: statusColor,
                icon: statusIcon,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _infoRow(
            context: context,
            icon: Icons.event_outlined,
            title: 'Due',
            value: activity.dueDate,
          ),
          _infoRow(
            context: context,
            icon: Icons.flag_outlined,
            title: 'Status',
            value: activity.status,
            valueColor: statusColor,
          ),
          if (activity.note.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              activity.note,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _openAssignedActivity(context: context, assignment: activity);
              },
              icon: Icon(
                _isCompletedStatus(activity.status)
                    ? Icons.visibility_outlined
                    : Icons.play_arrow_rounded,
              ),
              label: Text(
                _isCompletedStatus(activity.status)
                    ? 'Open Again'
                    : 'Open Activity',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.brandRed, size: 20),
          const SizedBox(width: 10),
          Text(
            '$title: ',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? colors.onSurface,
                fontSize: 14,
                fontWeight: valueColor == null
                    ? FontWeight.normal
                    : FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingCard() {
    return const AppPanel(
      padding: EdgeInsets.all(24),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _emptyCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AppPanel(
      padding: const EdgeInsets.all(18),
      child: Text(
        'No assignments yet.',
        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 15),
      ),
    );
  }

  Widget _infoCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AppPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MVP Note',
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Opening an activity does not automatically complete it. The assignment is completed only after the activity returns a real completion confirmation.',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Listening':
        return Icons.headphones_outlined;
      case 'Speaking':
        return Icons.mic_none_outlined;
      case 'Vocabulary':
        return Icons.style_outlined;
      case 'Reading':
        return Icons.menu_book_outlined;
      case 'Homework':
        return Icons.edit_note_outlined;
      default:
        return Icons.school_outlined;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Completed':
      case 'Reviewed':
        return AppTheme.success;
      case 'Review Needed':
        return AppTheme.warning;
      case 'Pending':
      default:
        return AppTheme.info;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Completed':
      case 'Reviewed':
        return Icons.check_circle_outline;
      case 'Review Needed':
        return Icons.rate_review_outlined;
      case 'Pending':
        return Icons.schedule_outlined;
      default:
        return Icons.assignment_outlined;
    }
  }

  bool _isCompletedStatus(String status) {
    return status == 'Completed' || status == 'Reviewed';
  }
}
