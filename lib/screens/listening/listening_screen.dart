import 'package:flutter/material.dart';

import '../../data/listening_data.dart';
import '../../models/listening_exercise.dart';
import '../../services/student_progress_service.dart';
import 'listening_exercise_screen.dart';

class ListeningScreen extends StatefulWidget {
  const ListeningScreen({super.key});

  @override
  State<ListeningScreen> createState() => _ListeningScreenState();
}

class _ListeningScreenState extends State<ListeningScreen> {
  Map<String, int> exerciseScores = {};
  Map<String, bool> completedExercises = {};

  int completedNormalListeningExercises = 0;

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  Future<void> loadProgress() async {
    final Map<String, int> loadedScores = {};
    final Map<String, bool> loadedCompleted = {};

    int normalCompletedCount = 0;

    for (final exercise in listeningExercises) {
      final score = await StudentProgressService.getActivityScore(
        activityId: exercise.id,
        category: 'listening',
      );

      final isCompleted = await StudentProgressService.isActivityCompleted(
        activityId: exercise.id,
        category: 'listening',
      );

      loadedScores[exercise.id] = score ?? -1;
      loadedCompleted[exercise.id] = isCompleted;

      final bool reviewExercise = isReviewExercise(exercise);

      if (!reviewExercise && isCompleted) {
        normalCompletedCount++;
      }
    }

    if (!mounted) return;

    setState(() {
      exerciseScores = loadedScores;
      completedExercises = loadedCompleted;
      completedNormalListeningExercises = normalCompletedCount;
    });
  }

  Future<void> openExercise(ListeningExercise exercise) async {
    final bool reviewExercise = isReviewExercise(exercise);
    final bool locked = isReviewLocked(exercise);

    if (reviewExercise && locked) {
      showLockedReviewMessage();
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListeningExerciseScreen(
          exercise: exercise,
        ),
      ),
    );

    await loadProgress();
  }

  bool isReviewExercise(ListeningExercise exercise) {
    return exercise.id.contains('review') ||
        exercise.level.toLowerCase().contains('review');
  }

  bool isReviewLocked(ListeningExercise exercise) {
    final bool reviewExercise = isReviewExercise(exercise);

    if (!reviewExercise) {
      return false;
    }

    return completedNormalListeningExercises < 3;
  }

  void showLockedReviewMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Complete 3 listening activities to unlock this review.',
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
        title: const Text('Listening Practice'),
        backgroundColor: const Color(0xFFB00020),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Choose a listening practice',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Listen, answer questions, and unlock reviews as you progress.',
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
                    'Review unlock: $completedNormalListeningExercises/3 listening activities completed',
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

          for (final exercise in listeningExercises)
            listeningExerciseCard(
              exercise: exercise,
              onTap: () => openExercise(exercise),
            ),
        ],
      ),
    );
  }

  Widget listeningExerciseCard({
    required ListeningExercise exercise,
    required VoidCallback onTap,
  }) {
    final bool reviewExercise = isReviewExercise(exercise);
    final bool locked = isReviewLocked(exercise);

    final int score = exerciseScores[exercise.id] ?? -1;
    final bool isCompleted = completedExercises[exercise.id] ?? false;
    final bool hasResult = score >= 0;

    String statusText = 'Not started';
    Color statusColor = Colors.white38;
    IconData statusIcon = Icons.radio_button_unchecked;

    if (locked) {
      statusText = 'Locked • Complete 3 listening activities';
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
        color:
            reviewExercise ? const Color(0xFF241A10) : const Color(0xFF1E1E1E),
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: reviewExercise ? Colors.orangeAccent : Colors.white12,
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
                      : reviewExercise
                          ? Icons.workspace_premium
                          : Icons.headphones,
                  color: locked
                      ? Colors.white38
                      : reviewExercise
                          ? Colors.orangeAccent
                          : const Color(0xFFB00020),
                  size: 36,
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (reviewExercise) ...[
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
                        exercise.title,
                        style: TextStyle(
                          color: locked ? Colors.white54 : Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        reviewExercise
                            ? '${exercise.description} • ${exercise.questions.length} questions'
                            : exercise.description,
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
                        : reviewExercise
                            ? Colors.orangeAccent.withValues(alpha: 0.18)
                            : const Color(0xFFB00020),
                    borderRadius: BorderRadius.circular(20),
                    border: reviewExercise || locked
                        ? Border.all(
                            color:
                                locked ? Colors.white24 : Colors.orangeAccent,
                          )
                        : null,
                  ),
                  child: Text(
                    exercise.level,
                    style: TextStyle(
                      color: locked
                          ? Colors.white38
                          : reviewExercise
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