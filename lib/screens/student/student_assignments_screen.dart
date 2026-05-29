import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/homework_data.dart';
import '../../data/listening_data.dart';
import '../../data/reading_data.dart';
import '../../data/vocabulary_data.dart';
import '../../models/assigned_activity.dart';
import '../../models/homework_activity.dart';
import '../../models/listening_exercise.dart';
import '../../models/reading_activity.dart';
import '../../models/vocabulary_quiz.dart';
import '../../services/assignment_service.dart';
import '../homework/homework_activity_screen.dart';
import '../listening/listening_exercise_screen.dart';
import '../reading/reading_screen.dart';
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
        backgroundColor: Color(0xFFB00020),
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 1200),
      ),
    );
  }

  Future<void> _markAssignmentAsCompleted(AssignedActivity assignment) async {
    if (assignment.status == 'Completed') {
      return;
    }

    final wasUpdated =
        await AssignmentService.markStudentAssignmentAsCompleted(
      studentName: currentStudentName,
      title: assignment.title,
      category: assignment.category,
    );

    if (!mounted) return;

    if (wasUpdated) {
      ScaffoldMessenger.of(context).clearSnackBars();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Assignment marked as completed.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(milliseconds: 900),
        ),
      );
    }

    await _loadStudentAssignments();
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
            builder: (_) => ListeningExerciseScreen(
              exercise: exercise,
            ),
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
          MaterialPageRoute(
            builder: (_) => VocabularyQuizScreen(
              quiz: quiz,
            ),
          ),
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
            builder: (_) => ReadingActivityScreen(
              activity: readingActivity,
            ),
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

        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HomeworkActivityScreen(
              activity: homeworkActivity,
            ),
          ),
        );

        if (result == true) {
          await _markAssignmentAsCompleted(assignment);
        } else {
          await _loadStudentAssignments();
        }

        return;

      default:
        _showActivityNotFound(context);
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalAssignments = studentAssignments.length;

    final int pendingCount = studentAssignments
        .where((activity) => activity.status == 'Pending')
        .length;

    final int completedCount = studentAssignments
        .where((activity) => activity.status == 'Completed')
        .length;

    final int reviewNeededCount = studentAssignments
        .where((activity) => activity.status == 'Review Needed')
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('My Assignments'),
        backgroundColor: const Color(0xFFB00020),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadStudentAssignments,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStudentAssignments,
        color: const Color(0xFFB00020),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Assignments',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentStudentName.isEmpty
                        ? 'Check the activities your teacher assigned to you.'
                        : 'Activities assigned to $currentStudentName.',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  if (currentStudentLevel.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Level $currentStudentLevel',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    title: 'Total',
                    value: isLoading ? '...' : totalAssignments.toString(),
                    icon: Icons.assignment,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _summaryCard(
                    title: 'Pending',
                    value: isLoading ? '...' : pendingCount.toString(),
                    icon: Icons.hourglass_empty,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    title: 'Completed',
                    value: isLoading ? '...' : completedCount.toString(),
                    icon: Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _summaryCard(
                    title: 'Review',
                    value: isLoading ? '...' : reviewNeededCount.toString(),
                    icon: Icons.refresh,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'Assigned to You',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            if (isLoading)
              _loadingCard()
            else if (studentAssignments.isEmpty)
              _emptyCard()
            else
              for (final activity in studentAssignments)
                _assignmentCard(
                  context: context,
                  activity: activity,
                ),

            const SizedBox(height: 20),

            _infoCard(),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFFE53935),
            size: 30,
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _assignmentCard({
    required BuildContext context,
    required AssignedActivity activity,
  }) {
    final Color statusColor = _statusColor(activity.status);
    final IconData statusIcon = _statusIcon(activity.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFB00020).withValues(alpha: 0.2),
                child: Icon(
                  _categoryIcon(activity.category),
                  color: const Color(0xFFE53935),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${activity.category} • ${activity.level}',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                statusIcon,
                color: statusColor,
              ),
            ],
          ),

          const SizedBox(height: 14),

          _infoRow(
            icon: Icons.event,
            title: 'Due',
            value: activity.dueDate,
          ),

          _infoRow(
            icon: Icons.flag,
            title: 'Status',
            value: activity.status,
            valueColor: statusColor,
          ),

          if (activity.note.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              activity.note,
              style: const TextStyle(
                color: Colors.white70,
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
                _openAssignedActivity(
                  context: context,
                  assignment: activity,
                );
              },
              icon: Icon(
                activity.status == 'Completed'
                    ? Icons.visibility
                    : Icons.play_arrow,
              ),
              label: Text(
                activity.status == 'Completed'
                    ? 'Open Again'
                    : 'Open Activity',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE53935),
                side: const BorderSide(color: Color(0xFFE53935)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFE53935),
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            '$title: ',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: 14,
                fontWeight:
                    valueColor == null ? FontWeight.normal : FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFB00020),
        ),
      ),
    );
  }

  Widget _emptyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: const Text(
        'No assignments yet.',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MVP Note',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Opening an activity does not automatically complete it. The assignment is completed only after the activity returns a real completion confirmation.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Listening':
        return Icons.headphones;
      case 'Vocabulary':
        return Icons.quiz;
      case 'Reading':
        return Icons.menu_book;
      case 'Homework':
        return Icons.assignment;
      default:
        return Icons.school;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.greenAccent;
      case 'Review Needed':
        return Colors.orangeAccent;
      case 'Pending':
        return Colors.white54;
      default:
        return Colors.white54;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Completed':
        return Icons.check_circle;
      case 'Review Needed':
        return Icons.info;
      case 'Pending':
        return Icons.hourglass_empty;
      default:
        return Icons.assignment;
    }
  }
}