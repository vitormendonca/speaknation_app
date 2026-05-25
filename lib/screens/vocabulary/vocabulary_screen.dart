import 'package:flutter/material.dart';

import '../../data/vocabulary_data.dart';
import '../../models/vocabulary_quiz.dart';
import '../../services/student_progress_service.dart';
import 'vocabulary_quiz_screen.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  Map<String, int> quizScores = {};
  Map<String, bool> completedQuizzes = {};

  int completedNormalVocabularyQuizzes = 0;

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  Future<void> loadProgress() async {
    final Map<String, int> loadedScores = {};
    final Map<String, bool> loadedCompleted = {};

    int normalCompletedCount = 0;

    for (final quiz in vocabularyQuizzes) {
      final score = await StudentProgressService.getActivityScore(
        activityId: quiz.id,
        category: 'vocabulary',
      );

      final isCompleted = await StudentProgressService.isActivityCompleted(
        activityId: quiz.id,
        category: 'vocabulary',
      );

      loadedScores[quiz.id] = score ?? -1;
      loadedCompleted[quiz.id] = isCompleted;

      final bool reviewQuiz = isReviewQuiz(quiz);

      if (!reviewQuiz && isCompleted) {
        normalCompletedCount++;
      }
    }

    if (!mounted) return;

    setState(() {
      quizScores = loadedScores;
      completedQuizzes = loadedCompleted;
      completedNormalVocabularyQuizzes = normalCompletedCount;
    });
  }

  Future<void> openQuiz(VocabularyQuiz quiz) async {
    final bool reviewQuiz = isReviewQuiz(quiz);
    final bool locked = isReviewLocked(quiz);

    if (reviewQuiz && locked) {
      showLockedReviewMessage();
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VocabularyQuizScreen(
          quiz: quiz,
        ),
      ),
    );

    await loadProgress();
  }

  bool isReviewQuiz(VocabularyQuiz quiz) {
    return quiz.id.contains('review') ||
        quiz.level.toLowerCase().contains('review');
  }

  bool isReviewLocked(VocabularyQuiz quiz) {
    final bool reviewQuiz = isReviewQuiz(quiz);

    if (!reviewQuiz) {
      return false;
    }

    return completedNormalVocabularyQuizzes < 3;
  }

  void showLockedReviewMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Complete 3 vocabulary activities to unlock this review.',
        ),
        backgroundColor: Color(0xFFB00020),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Vocabulary Quiz'),
        backgroundColor: const Color(0xFFB00020),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Choose a vocabulary practice',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Practice words by theme and unlock reviews as you progress.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lock_open,
                  color: Colors.orangeAccent,
                  size: 24,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    'Review unlock: $completedNormalVocabularyQuizzes/3 vocabulary activities completed',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          for (final quiz in vocabularyQuizzes)
            vocabularyCard(
              quiz: quiz,
              onTap: () => openQuiz(quiz),
            ),
        ],
      ),
    );
  }

  Widget vocabularyCard({
    required VocabularyQuiz quiz,
    required VoidCallback onTap,
  }) {
    final bool reviewQuiz = isReviewQuiz(quiz);
    final bool locked = isReviewLocked(quiz);

    final int score = quizScores[quiz.id] ?? -1;
    final bool isCompleted = completedQuizzes[quiz.id] ?? false;
    final bool hasResult = score >= 0;

    String statusText = 'Not started';
    Color statusColor = Colors.white38;
    IconData statusIcon = Icons.radio_button_unchecked;

    if (locked) {
      statusText = 'Locked • Complete 3 vocabulary activities';
      statusColor = Colors.white38;
      statusIcon = Icons.lock;
    } else if (hasResult) {
      if (isCompleted) {
        statusText = 'Completed • Accuracy: $score%';
        statusColor = Colors.greenAccent;
        statusIcon = Icons.check_circle;
      } else {
        statusText = 'Review Needed • Accuracy: $score%';
        statusColor = Colors.orangeAccent;
        statusIcon = Icons.info;
      }
    }

    return Opacity(
      opacity: locked ? 0.55 : 1,
      child: Card(
        color: reviewQuiz ? const Color(0xFF241A10) : const Color(0xFF1E1E1E),
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: reviewQuiz ? Colors.orangeAccent : Colors.white12,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Icon(
                  locked
                      ? Icons.lock
                      : reviewQuiz
                          ? Icons.workspace_premium
                          : Icons.quiz,
                  color: locked
                      ? Colors.white38
                      : reviewQuiz
                          ? Colors.orangeAccent
                          : const Color(0xFFB00020),
                  size: 36,
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (reviewQuiz) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: locked
                                ? Colors.white10
                                : Colors.orangeAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: locked
                                  ? Colors.white24
                                  : Colors.orangeAccent,
                            ),
                          ),
                          child: Text(
                            locked ? 'Locked review' : 'Review activity',
                            style: TextStyle(
                              color: locked
                                  ? Colors.white38
                                  : Colors.orangeAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),
                      ],

                      Text(
                        quiz.title,
                        style: TextStyle(
                          color: locked ? Colors.white54 : Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        reviewQuiz
                            ? '${quiz.description} • ${quiz.questions.length} questions'
                            : quiz.description,
                        style: TextStyle(
                          color: locked ? Colors.white38 : Colors.white70,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Icon(
                            statusIcon,
                            color: statusColor,
                            size: 16,
                          ),

                          const SizedBox(width: 6),

                          Expanded(
                            child: Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: locked
                        ? Colors.white10
                        : reviewQuiz
                            ? Colors.orangeAccent.withValues(alpha: 0.18)
                            : const Color(0xFFB00020),
                    borderRadius: BorderRadius.circular(20),
                    border: reviewQuiz || locked
                        ? Border.all(
                            color:
                                locked ? Colors.white24 : Colors.orangeAccent,
                          )
                        : null,
                  ),
                  child: Text(
                    quiz.level,
                    style: TextStyle(
                      color: locked
                          ? Colors.white38
                          : reviewQuiz
                              ? Colors.orangeAccent
                              : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}