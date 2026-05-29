import 'package:flutter/material.dart';

import '../../data/reading_data.dart';
import '../../models/activity_question.dart';
import '../../models/reading_activity.dart';
import '../../services/student_progress_service.dart';

class ReadingScreen extends StatefulWidget {
  const ReadingScreen({super.key});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  Map<String, int> activityScores = {};
  Map<String, bool> completedActivities = {};

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  Future<void> loadProgress() async {
    final Map<String, int> loadedScores = {};
    final Map<String, bool> loadedCompleted = {};

    for (final activity in readingActivities) {
      final score = await StudentProgressService.getActivityScore(
        activityId: activity.id,
        category: 'reading',
      );

      final isCompleted = await StudentProgressService.isActivityCompleted(
        activityId: activity.id,
        category: 'reading',
      );

      loadedScores[activity.id] = score ?? -1;
      loadedCompleted[activity.id] = isCompleted;
    }

    if (!mounted) return;

    setState(() {
      activityScores = loadedScores;
      completedActivities = loadedCompleted;
    });
  }

  Future<void> openActivity(ReadingActivity activity) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReadingActivityScreen(
          activity: activity,
        ),
      ),
    );

    await loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Reading Practice'),
        backgroundColor: const Color(0xFFB00020),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Choose a reading practice',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Read short texts, answer questions, and check your comprehension.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          for (final activity in readingActivities)
            _readingActivityCard(
              activity: activity,
              onTap: () => openActivity(activity),
            ),
        ],
      ),
    );
  }

  Widget _readingActivityCard({
    required ReadingActivity activity,
    required VoidCallback onTap,
  }) {
    final int score = activityScores[activity.id] ?? -1;
    final bool isCompleted = completedActivities[activity.id] ?? false;
    final bool hasResult = score >= 0;

    String statusText = 'Not started';
    Color statusColor = Colors.white38;
    IconData statusIcon = Icons.radio_button_unchecked;

    if (hasResult) {
      if (isCompleted) {
        statusText = 'Completed • Best score: $score%';
        statusColor = Colors.greenAccent;
        statusIcon = Icons.check_circle;
      } else {
        statusText = 'Review Needed • Accuracy: $score%';
        statusColor = Colors.orangeAccent;
        statusIcon = Icons.info;
      }
    }

    return Card(
      color: const Color(0xFF1E1E1E),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Colors.white12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFB00020).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.menu_book,
                  color: Color(0xFFB00020),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      activity.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.35,
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
                  activity.level,
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

class ReadingActivityScreen extends StatefulWidget {
  final ReadingActivity activity;

  const ReadingActivityScreen({
    super.key,
    required this.activity,
  });

  @override
  State<ReadingActivityScreen> createState() => _ReadingActivityScreenState();
}

class _ReadingActivityScreenState extends State<ReadingActivityScreen> {
  final Map<String, String> selectedAnswers = {};
  final Map<String, TextEditingController> textControllers = {};

  bool showResult = false;

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
      activityId: widget.activity.id,
      category: 'reading',
    );

    final score = await StudentProgressService.getActivityScore(
      activityId: widget.activity.id,
      category: 'reading',
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

  bool _isCorrect(ActivityQuestion question, String userAnswer) {
    return userAnswer.trim().toLowerCase() ==
        question.correctAnswer.trim().toLowerCase();
  }

  bool _isQuestionAvailable(ActivityQuestion question) {
    return question.type != QuestionType.reorderSentence;
  }

  int _availableQuestionsTotal() {
    return widget.activity.questions
        .where((question) => _isQuestionAvailable(question))
        .length;
  }

  bool _allQuestionsAnswered() {
    for (final question in widget.activity.questions) {
      if (!_isQuestionAvailable(question)) {
        continue;
      }

      final answer = selectedAnswers[question.id];

      if (answer == null || answer.trim().isEmpty) {
        return false;
      }
    }

    return true;
  }

  int _calculateScore() {
    int score = 0;

    for (final question in widget.activity.questions) {
      if (!_isQuestionAvailable(question)) {
        continue;
      }

      final answer = selectedAnswers[question.id];

      if (answer != null && _isCorrect(question, answer)) {
        score++;
      }
    }

    return score;
  }

  int _calculatePercentageScore() {
    final int score = _calculateScore();
    final int total = _availableQuestionsTotal();

    if (total == 0) {
      return 0;
    }

    return ((score / total) * 100).round();
  }

  Future<void> _saveResult() async {
    final int percentageScore = _calculatePercentageScore();

    // If the activity is already completed, this is review/practice only.
    // Do not overwrite saved progress or saved score.
    if (reviewMode) {
      return;
    }

    if (percentageScore >= 85) {
      await StudentProgressService.markActivityAsCompleted(
        activityId: widget.activity.id,
        category: 'reading',
      );
    }

    await StudentProgressService.saveActivityScore(
      activityId: widget.activity.id,
      category: 'reading',
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

  Future<void> _finishReading() async {
    if (!_allQuestionsAnswered()) return;

    await _saveResult();

    if (!mounted) return;

    setState(() {
      showResult = true;
    });
  }

  void _restartActivity() {
    setState(() {
      showResult = false;
      selectedAnswers.clear();

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

    final activity = widget.activity;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(activity.title),
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
                      'Activity completed ✅\nYou can review it, but your saved score will not change.',
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
            activity.title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            activity.level,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white12),
            ),
            child: Text(
              activity.text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Questions',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          for (final question in activity.questions) _buildQuestion(question),
          const SizedBox(height: 24),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _allQuestionsAnswered() ? _finishReading : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB00020),
                disabledBackgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                reviewMode ? 'Check Review' : 'Finish Reading',
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

  Widget _buildQuestion(ActivityQuestion question) {
    switch (question.type) {
      case QuestionType.multipleChoice:
      case QuestionType.trueFalse:
        return _buildMultipleChoiceQuestion(question);

      case QuestionType.textInput:
      case QuestionType.dictation:
      case QuestionType.fillBlank:
        return _buildTextInputQuestion(question);

      case QuestionType.reorderSentence:
        return _buildComingSoonQuestion(question);
    }
  }

  Widget _buildMultipleChoiceQuestion(ActivityQuestion question) {
    final selectedAnswer = selectedAnswers[question.id];
    final bool hasAnswered = selectedAnswer != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
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
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          for (final option in question.options)
            _buildAnswerOption(
              question: question,
              option: option,
              selectedAnswer: selectedAnswer,
            ),
          if (hasAnswered) _buildInstantFeedback(question),
        ],
      ),
    );
  }

  Widget _buildAnswerOption({
    required ActivityQuestion question,
    required String option,
    required String? selectedAnswer,
  }) {
    final bool hasAnswered = selectedAnswer != null;
    final bool isCorrectAnswer = option == question.correctAnswer;
    final bool isSelected = option == selectedAnswer;
    final bool isWrongSelected = hasAnswered && isSelected && !isCorrectAnswer;

    Color backgroundColor = const Color(0xFF121212);
    Color borderColor = Colors.white24;
    IconData? optionIcon;

    if (hasAnswered && isCorrectAnswer) {
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
      onTap: hasAnswered
          ? null
          : () {
              setState(() {
                selectedAnswers[question.id] = option;
              });
            },
      child: Container(
        width: double.infinity,
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
                option,
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

  Widget _buildTextInputQuestion(ActivityQuestion question) {
    final submittedAnswer = selectedAnswers[question.id];
    final bool hasAnswered =
        submittedAnswer != null && submittedAnswer.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
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
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _getController(question.id),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
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
              filled: true,
              fillColor: const Color(0xFF121212),
              hintText: 'Type your answer here',
              hintStyle: const TextStyle(color: Colors.white38),
            ),
            onChanged: (value) {
              setState(() {
                selectedAnswers[question.id] = value;
              });
            },
          ),
          if (hasAnswered) ...[
            const SizedBox(height: 12),
            _buildInstantFeedback(question),
          ],
        ],
      ),
    );
  }

  Widget _buildInstantFeedback(ActivityQuestion question) {
    final answer = selectedAnswers[question.id];

    if (answer == null || answer.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final isCorrect = _isCorrect(question, answer);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
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

  Widget _buildComingSoonQuestion(ActivityQuestion question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
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
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This question type will be available soon.',
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    final int score = _calculateScore();
    final int total = _availableQuestionsTotal();
    final int percentageScore = _calculatePercentageScore();
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
      message = 'Excellent reading comprehension! This activity is completed.';
    } else if (percentageScore >= 85) {
      message = 'Great reading comprehension! This activity is completed.';
    } else if (percentageScore >= 70) {
      message = 'Good effort. Review the text and try again.';
    } else {
      message = 'Read the text again and pay attention to the details.';
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(reviewMode ? 'Reading Review' : 'Reading Result'),
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
                  isApproved ? Icons.check_circle : Icons.refresh,
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
          for (int i = 0; i < widget.activity.questions.length; i++)
            _buildReviewCard(
              index: i,
              question: widget.activity.questions[i],
            ),
          const SizedBox(height: 24),
          if (!isApproved) ...[
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _restartActivity,
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
                'Back to Reading',
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
    if (!_isQuestionAvailable(question)) {
      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${index + 1}',
              style: const TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              question.question,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This question type was not counted in this version.',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    final userAnswer = selectedAnswers[question.id] ?? '';
    final bool isCorrect = _isCorrect(question, userAnswer);

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