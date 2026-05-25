import 'package:flutter/material.dart';

import '../../services/student_progress_service.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  int listeningCompleted = 0;
  int vocabularyCompleted = 0;
  int readingCompleted = 0;
  int homeworkCompleted = 0;

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
    final progress = await StudentProgressService.getProgressByCategory();
    final reviews = await StudentProgressService.getReviewNeededByCategories();
    final averages = await StudentProgressService.getAverageScoresByCategory();

    if (!mounted) return;

    setState(() {
      listeningCompleted = progress['listening'] ?? 0;
      vocabularyCompleted = progress['vocabulary'] ?? 0;
      readingCompleted = progress['reading'] ?? 0;
      homeworkCompleted = progress['homework'] ?? 0;

      listeningReviewNeeded = reviews['listening'] ?? 0;
      vocabularyReviewNeeded = reviews['vocabulary'] ?? 0;
      readingReviewNeeded = reviews['reading'] ?? 0;
      homeworkReviewNeeded = reviews['homework'] ?? 0;

      listeningAverage = averages['listening'] ?? 0;
      vocabularyAverage = averages['vocabulary'] ?? 0;
      readingAverage = averages['reading'] ?? 0;
      homeworkAverage = averages['homework'] ?? 0;

      isLoadingProgress = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final int totalCompleted = listeningCompleted +
        vocabularyCompleted +
        readingCompleted +
        homeworkCompleted;

    final int totalReviewNeeded = listeningReviewNeeded +
        vocabularyReviewNeeded +
        readingReviewNeeded +
        homeworkReviewNeeded;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color(0xFFB00020),
        foregroundColor: Colors.white,
      ),
      body: ListView(
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
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Student Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Track your progress and learning journey.',
                        style: TextStyle(
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
                    border: Border.all(
                      color: const Color(0xFFB00020),
                    ),
                  ),
                  child: const Text(
                    'A1',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Complete A1 activities to unlock the next level in future versions.',
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
                const Text(
                  'A1 Progress',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  isLoadingProgress
                      ? 'Loading progress...'
                      : '$totalCompleted approved activities • $totalReviewNeeded review needed',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Completed means approved activities. Review Needed means activities attempted but not approved yet. Accuracy means your average score.',
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
                  completed: listeningCompleted,
                  reviewNeeded: listeningReviewNeeded,
                  averageScore: listeningAverage,
                ),
                progressRow(
                  icon: Icons.quiz,
                  title: 'Vocabulary',
                  completed: vocabularyCompleted,
                  reviewNeeded: vocabularyReviewNeeded,
                  averageScore: vocabularyAverage,
                ),
                progressRow(
                  icon: Icons.menu_book,
                  title: 'Reading',
                  completed: readingCompleted,
                  reviewNeeded: readingReviewNeeded,
                  averageScore: readingAverage,
                ),
                progressRow(
                  icon: Icons.assignment,
                  title: 'Homework',
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
        ],
      ),
    );
  }

  Widget progressRow({
    required IconData icon,
    required String title,
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
          Icon(
            icon,
            color: Colors.white70,
            size: 24,
          ),
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
                  'Completed: $completed',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                  ),
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