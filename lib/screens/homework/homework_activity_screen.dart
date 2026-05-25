import 'package:flutter/material.dart';

import '../../models/homework_activity.dart';
import '../../services/student_progress_service.dart';

class HomeworkActivityScreen extends StatefulWidget {
  final HomeworkActivity activity;

  const HomeworkActivityScreen({
    super.key,
    required this.activity,
  });

  @override
  State<HomeworkActivityScreen> createState() => _HomeworkActivityScreenState();
}

class _HomeworkActivityScreenState extends State<HomeworkActivityScreen> {
  String? selectedAnswer;
  bool answered = false;

  bool lastCompleted = false;
  int? lastScore;

  @override
  void initState() {
    super.initState();
    loadLastResult();
  }

  Future<void> loadLastResult() async {
    final completed = await StudentProgressService.isActivityCompleted(
      activityId: widget.activity.id,
      category: 'homework',
    );

    final score = await StudentProgressService.getActivityScore(
      activityId: widget.activity.id,
      category: 'homework',
    );

    if (!mounted) return;

    setState(() {
      lastCompleted = completed;
      lastScore = score;
    });
  }
Future<void> checkAnswer() async {
  final bool isCorrect = selectedAnswer == widget.activity.correctAnswer;
  final int score = isCorrect ? 100 : 0;

  if (isCorrect) {
    await StudentProgressService.markActivityAsCompleted(
      activityId: widget.activity.id,
      category: 'homework',
    );
  }

  await StudentProgressService.saveActivityScore(
    activityId: widget.activity.id,
    category: 'homework',
    score: score,
  );

  if (!mounted) return;

  setState(() {
    answered = true;
    lastCompleted = isCorrect;
    lastScore = score;
  });
}
  void tryAgain() {
    setState(() {
      selectedAnswer = null;
      answered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isCorrect = selectedAnswer == widget.activity.correctAnswer;
    final bool lastCorrect = lastScore == 100;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(widget.activity.title),
        backgroundColor: const Color(0xFFB00020),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (lastCompleted && lastScore != null && !answered) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: lastCorrect ? Colors.greenAccent : Colors.orangeAccent,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    lastCorrect ? Icons.check_circle : Icons.info,
                    color:
                        lastCorrect ? Colors.greenAccent : Colors.orangeAccent,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      lastCorrect
                          ? 'Last result: Correct - $lastScore%'
                          : 'Last result: Review needed - $lastScore%',
                      style: TextStyle(
                        color: lastCorrect
                            ? Colors.greenAccent
                            : Colors.orangeAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          Text(
            widget.activity.description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white12),
            ),
            child: Text(
              widget.activity.instruction,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            widget.activity.question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 28),

          for (final option in widget.activity.options) answerOption(option),

          const SizedBox(height: 24),

          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: selectedAnswer == null || answered ? null : checkAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB00020),
                disabledBackgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Check Answer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          if (answered) ...[
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isCorrect ? Colors.greenAccent : Colors.orangeAccent,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isCorrect ? Icons.check_circle : Icons.info,
                        color:
                            isCorrect ? Colors.greenAccent : Colors.orangeAccent,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isCorrect
                              ? 'Completed: Correct'
                              : 'Completed: Review needed',
                          style: TextStyle(
                            color: isCorrect
                                ? Colors.greenAccent
                                : Colors.orangeAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    isCorrect
                        ? 'Great job. This activity is completed. Score: 100%'
                        : 'Correct answer: ${widget.activity.correctAnswer}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),

                  if (!isCorrect) ...[
                    const SizedBox(height: 6),
                    const Text(
                      'Review the example and try again later. Score: 0%',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: tryAgain,
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
                label: const Text(
                  'Try Again',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB00020),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                label: const Text(
                  'Back to Homework',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF333333),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget answerOption(String answer) {
    final bool isSelected = selectedAnswer == answer;
    final bool isCorrectAnswer = answer == widget.activity.correctAnswer;
    final bool isWrongSelected = answered && isSelected && !isCorrectAnswer;

    Color backgroundColor = const Color(0xFF1E1E1E);
    Color borderColor = Colors.white24;
    IconData? optionIcon;

    if (!answered && isSelected) {
      backgroundColor = const Color(0xFFB00020);
      borderColor = const Color(0xFFB00020);
    }

    if (answered && isCorrectAnswer) {
      backgroundColor = Colors.green.withValues(alpha: 0.25);
      borderColor = Colors.greenAccent;
      optionIcon = Icons.check_circle;
    }

    if (isWrongSelected) {
      backgroundColor = Colors.red.withValues(alpha: 0.25);
      borderColor = Colors.redAccent;
      optionIcon = Icons.cancel;
    }

    return GestureDetector(
      onTap: answered
          ? null
          : () {
              setState(() {
                selectedAnswer = answer;
              });
            },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                answer,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            if (optionIcon != null)
              Icon(
                optionIcon,
                color: borderColor,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}