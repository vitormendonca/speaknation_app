import 'package:flutter/material.dart';

import '../../models/activity_question.dart';
import '../../models/vocabulary_quiz.dart';
import '../../services/student_progress_service.dart';

class VocabularyQuizScreen extends StatefulWidget {
  final VocabularyQuiz quiz;

  const VocabularyQuizScreen({
    super.key,
    required this.quiz,
  });

  @override
  State<VocabularyQuizScreen> createState() => _VocabularyQuizScreenState();
}

class _VocabularyQuizScreenState extends State<VocabularyQuizScreen> {
  int currentQuestionIndex = 0;
  bool showResult = false;

  final Map<String, String> answers = {};
  final Map<String, TextEditingController> textControllers = {};

  bool lastCompleted = false;
  int? lastScore;
  bool reviewMode = false;

  @override
  void initState() {
    super.initState();
    _loadLastResult();
  }

  Future<void> _loadLastResult() async {
    final completed = await StudentProgressService.isActivityCompleted(
      activityId: widget.quiz.id,
      category: 'vocabulary',
    );

    final score = await StudentProgressService.getActivityScore(
      activityId: widget.quiz.id,
      category: 'vocabulary',
    );

    if (!mounted) return;

    setState(() {
      lastCompleted = completed;
      lastScore = score;
      reviewMode = completed;
    });
  }

  @override
  void dispose() {
    for (final controller in textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _getController(String questionId) {
    if (!textControllers.containsKey(questionId)) {
      textControllers[questionId] = TextEditingController();
    }

    return textControllers[questionId]!;
  }

  ActivityQuestion get currentQuestion {
    return widget.quiz.questions[currentQuestionIndex];
  }

  bool _isCurrentQuestionAnswered() {
    final answer = answers[currentQuestion.id];
    return answer != null && answer.trim().isNotEmpty;
  }

  bool _isCorrect(ActivityQuestion question, String answer) {
    return answer.trim().toLowerCase() ==
        question.correctAnswer.trim().toLowerCase();
  }

  int _calculateScore() {
    int score = 0;

    for (final question in widget.quiz.questions) {
      final userAnswer = answers[question.id];

      if (userAnswer != null && _isCorrect(question, userAnswer)) {
        score++;
      }
    }

    return score;
  }

  int _calculatePercentageScore() {
    final score = _calculateScore();
    final total = widget.quiz.questions.length;

    if (total == 0) {
      return 0;
    }

    return ((score / total) * 100).round();
  }

  Future<void> _saveResult() async {
    final percentageScore = _calculatePercentageScore();

    // If the quiz is already completed, this is review/practice only.
    // Do not overwrite saved progress or saved score.
    if (reviewMode) {
      return;
    }

    if (percentageScore >= 85) {
      await StudentProgressService.markActivityAsCompleted(
        activityId: widget.quiz.id,
        category: 'vocabulary',
      );
    }

    await StudentProgressService.saveActivityScore(
      activityId: widget.quiz.id,
      category: 'vocabulary',
      score: percentageScore,
    );

    if (!mounted) return;

    setState(() {
      lastScore = percentageScore;

      if (percentageScore >= 85) {
        lastCompleted = true;
        reviewMode = true;
      }
    });
  }

  Future<void> _nextQuestion() async {
    if (!_isCurrentQuestionAnswered()) return;

    final bool isLastQuestion =
        currentQuestionIndex == widget.quiz.questions.length - 1;

    if (isLastQuestion) {
      await _saveResult();

      if (!mounted) return;

      setState(() {
        showResult = true;
      });
    } else {
      setState(() {
        currentQuestionIndex++;
      });
    }
  }

  void _restartQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      showResult = false;
      answers.clear();

      for (final controller in textControllers.values) {
        controller.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showResult) {
      return _buildResultScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(widget.quiz.title),
        backgroundColor: const Color(0xFFB00020),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (reviewMode && lastScore != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.greenAccent),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.greenAccent,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Quiz completed ✅\nYou can review it, but your saved score will not change.',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                'Best score: $lastScore%',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          Text(
            widget.quiz.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            widget.quiz.description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            widget.quiz.level,
            style: const TextStyle(
              color: Colors.white54,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 24),

          LinearProgressIndicator(
            value: (currentQuestionIndex + 1) / widget.quiz.questions.length,
            backgroundColor: Colors.white24,
            color: const Color(0xFFB00020),
          ),

          const SizedBox(height: 12),

          Text(
            'Question ${currentQuestionIndex + 1} of ${widget.quiz.questions.length}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 24),

          _buildQuestionCard(currentQuestion),

          const SizedBox(height: 24),

          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _isCurrentQuestionAnswered() ? _nextQuestion : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB00020),
                disabledBackgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                currentQuestionIndex == widget.quiz.questions.length - 1
                    ? reviewMode
                        ? 'Finish Review'
                        : 'Finish Quiz'
                    : 'Next',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(ActivityQuestion question) {
    return Container(
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
            question.question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          if (question.type == QuestionType.multipleChoice ||
              question.type == QuestionType.trueFalse)
            _buildOptions(question)
          else
            _buildTextInput(question),

          if (_isCurrentQuestionAnswered()) ...[
            const SizedBox(height: 14),
            _buildInstantFeedback(question),
          ],
        ],
      ),
    );
  }

  Widget _buildOptions(ActivityQuestion question) {
    final selectedAnswer = answers[question.id];
    final hasAnswered = selectedAnswer != null;

    return Column(
      children: [
        for (final option in question.options)
          GestureDetector(
            onTap: hasAnswered
                ? null
                : () {
                    setState(() {
                      answers[question.id] = option;
                    });
                  },
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getOptionBackgroundColor(
                  option: option,
                  selectedAnswer: selectedAnswer,
                  correctAnswer: question.correctAnswer,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _getOptionBorderColor(
                    option: option,
                    selectedAnswer: selectedAnswer,
                    correctAnswer: question.correctAnswer,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  if (hasAnswered && option == question.correctAnswer)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.greenAccent,
                    ),

                  if (hasAnswered &&
                      option == selectedAnswer &&
                      option != question.correctAnswer)
                    const Icon(
                      Icons.cancel,
                      color: Colors.redAccent,
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Color _getOptionBackgroundColor({
    required String option,
    required String? selectedAnswer,
    required String correctAnswer,
  }) {
    if (selectedAnswer == null) {
      return const Color(0xFF121212);
    }

    if (option == correctAnswer) {
      return Colors.green.withValues(alpha: 0.25);
    }

    if (option == selectedAnswer && option != correctAnswer) {
      return Colors.red.withValues(alpha: 0.25);
    }

    return const Color(0xFF121212);
  }

  Color _getOptionBorderColor({
    required String option,
    required String? selectedAnswer,
    required String correctAnswer,
  }) {
    if (selectedAnswer == null) {
      return Colors.white24;
    }

    if (option == correctAnswer) {
      return Colors.greenAccent;
    }

    if (option == selectedAnswer && option != correctAnswer) {
      return Colors.redAccent;
    }

    return Colors.white24;
  }

  Widget _buildTextInput(ActivityQuestion question) {
    return TextField(
      controller: _getController(question.id),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: question.type == QuestionType.fillBlank
            ? 'Complete the sentence'
            : 'Type your answer here',
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF121212),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFB00020)),
        ),
      ),
      onChanged: (value) {
        setState(() {
          answers[question.id] = value;
        });
      },
    );
  }

  Widget _buildInstantFeedback(ActivityQuestion question) {
    final answer = answers[question.id];

    if (answer == null || answer.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final isCorrect = _isCorrect(question, answer);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCorrect
            ? Colors.green.withValues(alpha: 0.15)
            : Colors.orange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? Colors.greenAccent : Colors.orangeAccent,
        ),
      ),
      child: Text(
        isCorrect ? 'Correct!' : 'Correct answer: ${question.correctAnswer}',
        style: TextStyle(
          color: isCorrect ? Colors.greenAccent : Colors.orangeAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    final score = _calculateScore();
    final total = widget.quiz.questions.length;
    final percentageScore = _calculatePercentageScore();
    final bool isApproved = percentageScore >= 85;

    String message;

    if (reviewMode) {
      if (isApproved) {
        message =
            'Good review. Your saved score is still ${lastScore ?? percentageScore}%.';
      } else {
        message =
            'This was practice only. Your saved progress did not change.';
      }
    } else if (percentageScore >= 90) {
      message = 'Excellent! This quiz is completed.';
    } else if (percentageScore >= 85) {
      message = 'Great job! This quiz is completed.';
    } else if (percentageScore >= 70) {
      message = 'Good effort. Review and try again.';
    } else {
      message = 'Review the vocabulary and try again.';
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(reviewMode ? 'Quiz Review' : 'Quiz Result'),
        backgroundColor: const Color(0xFFB00020),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isApproved ? Colors.greenAccent : Colors.orangeAccent,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  isApproved ? Icons.emoji_events : Icons.refresh,
                  color: isApproved ? Colors.greenAccent : Colors.orangeAccent,
                  size: 72,
                ),

                const SizedBox(height: 16),

                Text(
                  reviewMode
                      ? isApproved
                          ? 'Review Completed'
                          : 'Review Practice'
                      : isApproved
                          ? 'Completed'
                          : 'Review Needed',
                  style: TextStyle(
                    color: isApproved ? Colors.greenAccent : Colors.orangeAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  reviewMode ? 'Your review score' : 'Your score',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '$score/$total',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  reviewMode
                      ? 'Review accuracy: $percentageScore%'
                      : 'Accuracy: $percentageScore%',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (reviewMode && lastScore != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Saved score: $lastScore%',
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Review your answers',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          for (int i = 0; i < widget.quiz.questions.length; i++)
            _buildReviewCard(
              index: i,
              question: widget.quiz.questions[i],
            ),

          const SizedBox(height: 24),

          if (!isApproved) ...[
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _restartQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB00020),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
          ],

          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Back to Vocabulary',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard({
    required int index,
    required ActivityQuestion question,
  }) {
    final userAnswer = answers[question.id] ?? '';
    final isCorrect = _isCorrect(question, userAnswer);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrect ? Colors.greenAccent : Colors.redAccent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.greenAccent : Colors.redAccent,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  'Question ${index + 1}',
                  style: TextStyle(
                    color: isCorrect ? Colors.greenAccent : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            question.question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Your answer: ${userAnswer.isEmpty ? 'No answer' : userAnswer}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Correct answer: ${question.correctAnswer}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}