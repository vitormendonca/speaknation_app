import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/listening_data.dart';
import '../../models/listening_exercise.dart';
import 'listening_exercise_screen.dart';

class ListeningScreen extends StatefulWidget {
  const ListeningScreen({super.key});

  @override
  State<ListeningScreen> createState() => _ListeningScreenState();
}

class _ListeningScreenState extends State<ListeningScreen> {
  Map<String, int> lastScores = {};
  Map<String, int> lastTotals = {};

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();

    final Map<String, int> loadedScores = {};
    final Map<String, int> loadedTotals = {};

    for (final exercise in listeningExercises) {
      loadedScores[exercise.id] =
          prefs.getInt('${exercise.id}_last_score') ?? -1;

      loadedTotals[exercise.id] =
          prefs.getInt('${exercise.id}_last_total') ?? 0;
    }

    setState(() {
      lastScores = loadedScores;
      lastTotals = loadedTotals;
    });
  }

  Future<void> openExercise(ListeningExercise exercise) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            'Listen, answer questions, and track your comprehension progress.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
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
    final int lastScore = lastScores[exercise.id] ?? -1;
    final int lastTotal = lastTotals[exercise.id] ?? 0;
    final bool hasResult = lastScore >= 0 && lastTotal > 0;

    String statusText = 'Not started';
    Color statusColor = Colors.white38;
    IconData statusIcon = Icons.radio_button_unchecked;

    if (hasResult) {
      final double percentage = lastScore / lastTotal;

      statusText = 'Last score: $lastScore/$lastTotal';

      if (percentage >= 0.8) {
        statusColor = Colors.greenAccent;
        statusIcon = Icons.check_circle;
      } else if (percentage >= 0.6) {
        statusColor = Colors.orangeAccent;
        statusIcon = Icons.info;
      } else {
        statusColor = Colors.redAccent;
        statusIcon = Icons.warning;
      }
    }

    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              const Icon(
                Icons.headphones,
                color: Color(0xFFB00020),
                size: 36,
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      exercise.description,
                      style: const TextStyle(
                        color: Colors.white70,
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
                  color: const Color(0xFFB00020),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  exercise.level,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}