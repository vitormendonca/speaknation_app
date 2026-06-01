import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/speaking_activity.dart';
import '../../services/assignment_service.dart';
import '../../services/student_progress_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_ui.dart';

class SpeakingActivityScreen extends StatefulWidget {
  final SpeakingActivity activity;

  const SpeakingActivityScreen({super.key, required this.activity});

  @override
  State<SpeakingActivityScreen> createState() => _SpeakingActivityScreenState();
}

class _SpeakingActivityScreenState extends State<SpeakingActivityScreen> {
  final Set<int> checkedItems = {};
  bool submitted = false;
  int? lastScore;

  @override
  void initState() {
    super.initState();
    _loadLastResult();
  }

  Future<void> _loadLastResult() async {
    final score = await StudentProgressService.getActivityScore(
      activityId: widget.activity.id,
      category: 'speaking',
    );

    if (!mounted) return;

    setState(() {
      lastScore = score;

      if (score != null) {
        submitted = true;
        checkedItems.addAll(
          List<int>.generate(
            widget.activity.checklist.length,
            (index) => index,
          ),
        );
      }
    });
  }

  bool get isReadyToSubmit {
    return checkedItems.length == widget.activity.checklist.length;
  }

  Future<void> _submitForReview() async {
    if (!isReadyToSubmit || submitted) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final currentStudentName = prefs.getString('currentStudentName') ?? '';

    await StudentProgressService.saveActivityScore(
      activityId: widget.activity.id,
      category: 'speaking',
      score: 100,
    );

    if (currentStudentName.isNotEmpty) {
      await AssignmentService.markStudentAssignmentAsReviewNeeded(
        studentName: currentStudentName,
        title: widget.activity.title,
        category: 'Speaking',
      );
    }

    if (!mounted) return;

    setState(() {
      submitted = true;
      lastScore = 100;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.activity.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AppPanel(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppIconBox(
                  icon: Icons.mic_none_outlined,
                  color: AppTheme.accentPurple,
                  size: 54,
                  iconSize: 30,
                ),
                const SizedBox(height: 18),
                Text(
                  widget.activity.title,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.activity.description,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppStatusBadge(
                      label: widget.activity.level,
                      color: AppTheme.info,
                    ),
                    AppStatusBadge(
                      label: submitted ? 'Submitted' : 'Teacher review',
                      color: submitted
                          ? AppTheme.warning
                          : AppTheme.accentPurple,
                      icon: submitted
                          ? Icons.rate_review_outlined
                          : Icons.mic_none_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _textPanel(
            context: context,
            title: 'Speaking Prompt',
            body: widget.activity.prompt,
            icon: Icons.record_voice_over_outlined,
            color: AppTheme.accentPurple,
          ),
          const SizedBox(height: 12),
          _textPanel(
            context: context,
            title: 'Target Language',
            body: widget.activity.targetLanguage,
            icon: Icons.chat_bubble_outline,
            color: AppTheme.info,
          ),
          const SizedBox(height: 12),
          _textPanel(
            context: context,
            title: 'Preparation',
            body: widget.activity.preparationTip,
            icon: Icons.tips_and_updates_outlined,
            color: AppTheme.warning,
          ),
          const SizedBox(height: 16),
          AppSectionHeader(
            title: 'Self Check',
            subtitle: lastScore == null
                ? 'Confirm each item after practicing aloud.'
                : 'Your practice was submitted for review.',
          ),
          const SizedBox(height: 12),
          AppPanel(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                for (
                  int index = 0;
                  index < widget.activity.checklist.length;
                  index++
                )
                  CheckboxListTile(
                    value: checkedItems.contains(index),
                    onChanged: submitted
                        ? null
                        : (value) {
                            setState(() {
                              if (value == true) {
                                checkedItems.add(index);
                              } else {
                                checkedItems.remove(index);
                              }
                            });
                          },
                    title: Text(widget.activity.checklist[index]),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: isReadyToSubmit && !submitted
                  ? _submitForReview
                  : null,
              icon: Icon(
                submitted
                    ? Icons.rate_review_outlined
                    : Icons.upload_file_outlined,
              ),
              label: Text(
                submitted ? 'Submitted for Review' : 'Submit Speaking Practice',
              ),
            ),
          ),
          if (submitted) ...[
            const SizedBox(height: 14),
            AppPanel(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.rate_review_outlined,
                    color: AppTheme.warning,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your speaking practice is ready for teacher review.',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _textPanel({
    required BuildContext context,
    required String title,
    required String body,
    required IconData icon,
    required Color color,
  }) {
    final colors = Theme.of(context).colorScheme;

    return AppPanel(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIconBox(icon: icon, color: color, size: 42, iconSize: 23),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 14,
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
}
