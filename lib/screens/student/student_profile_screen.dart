import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/assigned_activity.dart';
import '../../services/assignment_service.dart';
import '../../services/app_auth_service.dart';
import '../../services/student_progress_service.dart';
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
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('Logout', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Do you want to leave this account?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Color(0xFFE53935)),
              ),
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
    final int totalCompleted =
        listeningCompleted +
        vocabularyCompleted +
        readingCompleted +
        homeworkCompleted;

    final int totalPending =
        listeningPending + vocabularyPending + readingPending + homeworkPending;

    final int totalReviewNeeded =
        listeningReviewNeeded +
        vocabularyReviewNeeded +
        readingReviewNeeded +
        homeworkReviewNeeded;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFFB00020),
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: loadProgress, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadProgress,
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
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB00020).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFFB00020),
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Student Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$studentName • Level $studentLevel',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Level',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB00020).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFB00020)),
                    ),
                    child: Text(
                      studentLevel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Complete activities to unlock the next level in future versions.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$studentLevel Progress',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isLoadingProgress
                        ? 'Loading progress...'
                        : '$totalPending pending activities • $totalCompleted approved activities • $totalReviewNeeded review needed',
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pending means assigned activities that still need to be completed. Approved means completed and accepted activities. Review Needed means activities attempted but not approved yet.',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),

                  progressRow(
                    icon: Icons.headphones,
                    title: 'Listening',
                    pending: listeningPending,
                    completed: listeningCompleted,
                    reviewNeeded: listeningReviewNeeded,
                    averageScore: listeningAverage,
                  ),
                  progressRow(
                    icon: Icons.quiz,
                    title: 'Vocabulary',
                    pending: vocabularyPending,
                    completed: vocabularyCompleted,
                    reviewNeeded: vocabularyReviewNeeded,
                    averageScore: vocabularyAverage,
                  ),
                  progressRow(
                    icon: Icons.menu_book,
                    title: 'Reading',
                    pending: readingPending,
                    completed: readingCompleted,
                    reviewNeeded: readingReviewNeeded,
                    averageScore: readingAverage,
                  ),
                  progressRow(
                    icon: Icons.assignment,
                    title: 'Homework',
                    pending: homeworkPending,
                    completed: homeworkCompleted,
                    reviewNeeded: homeworkReviewNeeded,
                    averageScore: homeworkAverage,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            Container(
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
                    'Achievements',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Badges, level certificates, and skill achievements will appear here in future versions.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Use this option only when you want to leave this account or switch users.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: confirmLogout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE53935),
                        side: const BorderSide(color: Color(0xFFE53935)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget progressRow({
    required IconData icon,
    required String title,
    required int pending,
    required int completed,
    required int reviewNeeded,
    required int averageScore,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 24),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pending: $pending',
                  style: TextStyle(
                    color: pending > 0 ? Colors.amberAccent : Colors.white38,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Approved: $completed',
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
                const SizedBox(height: 3),
                Text(
                  'Review Needed: $reviewNeeded',
                  style: TextStyle(
                    color: reviewNeeded > 0
                        ? Colors.orangeAccent
                        : Colors.white38,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          Text(
            'Accuracy\n$averageScore%',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: averageScore >= 70
                  ? Colors.greenAccent
                  : averageScore > 0
                  ? Colors.orangeAccent
                  : Colors.white38,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
