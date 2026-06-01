import 'package:flutter/material.dart';

import '../../models/assigned_activity.dart';
import '../../services/assignment_service.dart';
import '../../services/student_progress_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_ui.dart';

class TeacherAssignActivityScreen extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String studentLevel;

  const TeacherAssignActivityScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.studentLevel,
  });

  @override
  State<TeacherAssignActivityScreen> createState() =>
      _TeacherAssignActivityScreenState();
}

class _TeacherAssignActivityScreenState
    extends State<TeacherAssignActivityScreen> {
  String? selectedActivityId;
  String selectedCategory = 'All';
  bool isSaving = false;
  bool isLoadingStatuses = true;

  final Map<String, String> activityStatuses = {};

  final List<String> categories = const [
    'All',
    'Homework',
    'Listening',
    'Speaking',
    'Vocabulary',
    'Reading',
  ];

  final List<Map<String, String>> availableActivities = const [
    {
      'id': 'homework_001',
      'title': 'Basic Introductions',
      'type': 'Homework',
      'level': 'A1',
      'description': 'Practice simple introductions in English.',
    },
    {
      'id': 'listening_a1_morning_routine',
      'title': 'Morning Routine',
      'type': 'Listening',
      'level': 'A1',
      'description': 'Listen to a short audio about a daily routine.',
    },
    {
      'id': 'speaking_001',
      'title': 'Personal Introduction Practice',
      'type': 'Speaking',
      'level': 'A1',
      'description': 'Practice a short self-introduction for teacher review.',
    },
    {
      'id': 'vocabulary_a1_greetings',
      'title': 'Greetings and Introductions',
      'type': 'Vocabulary',
      'level': 'A1',
      'description': 'Practice basic greetings and personal introductions.',
    },
    {
      'id': 'homework_002',
      'title': 'Personal Information',
      'type': 'Homework',
      'level': 'A1',
      'description': 'Practice questions about age, city, and job.',
    },
    {
      'id': 'reading_001',
      'title': 'A Busy Morning',
      'type': 'Reading',
      'level': 'A1',
      'description': 'Read a short text about a morning routine.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadActivityStatuses();
  }

  String _progressCategory(String assignmentCategory) {
    switch (assignmentCategory) {
      case 'Listening':
        return 'listening';
      case 'Speaking':
        return 'speaking';
      case 'Vocabulary':
        return 'vocabulary';
      case 'Reading':
        return 'reading';
      case 'Homework':
        return 'homework';
      default:
        return assignmentCategory.toLowerCase();
    }
  }

  Future<void> _loadActivityStatuses() async {
    final Map<String, String> loadedStatuses = {};

    final List<AssignedActivity> assignments =
        await AssignmentService.getAssignedActivitiesForStudent(
          studentId: widget.studentId,
          studentName: widget.studentName,
        );

    for (final activity in availableActivities) {
      final id = activity['id'] ?? '';
      final title = activity['title'] ?? '';
      final type = activity['type'] ?? '';

      String status = 'Not Assigned';

      for (final assignment in assignments) {
        if (assignment.title == title &&
            assignment.category == type &&
            assignment.status != 'Reviewed') {
          status = assignment.status;
          break;
        }
      }

      final bool completedByStudent =
          await StudentProgressService.isActivityCompleted(
            activityId: id,
            category: _progressCategory(type),
          );

      final score = await StudentProgressService.getActivityScore(
        activityId: id,
        category: _progressCategory(type),
      );

      if (completedByStudent) {
        status = 'Completed';
      } else if (status == 'Not Assigned' && score != null && score < 85) {
        status = 'Review Needed';
      }

      loadedStatuses[id] = status;
    }

    if (!mounted) return;

    setState(() {
      activityStatuses.clear();
      activityStatuses.addAll(loadedStatuses);
      isLoadingStatuses = false;
    });
  }

  List<Map<String, String>> get filteredActivities {
    if (selectedCategory == 'All') {
      return availableActivities;
    }

    return availableActivities
        .where((activity) => activity['type'] == selectedCategory)
        .toList();
  }

  bool _canAssignActivity(String activityId) {
    final status = activityStatuses[activityId] ?? 'Not Assigned';
    return status == 'Not Assigned';
  }

  Future<void> _assignActivity() async {
    if (selectedActivityId == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an activity first.')),
      );
      return;
    }

    if (!_canAssignActivity(selectedActivityId!)) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This activity already has a status for this student.'),
        ),
      );
      return;
    }

    final selectedActivity = availableActivities.firstWhere(
      (activity) => activity['id'] == selectedActivityId,
    );

    final selectedId = selectedActivity['id'];

    setState(() {
      isSaving = true;
    });

    final wasAssigned = await AssignmentService.assignActivityToStudent(
      studentId: widget.studentId,
      studentName: widget.studentName,
      title: selectedActivity['title'] ?? '',
      category: selectedActivity['type'] ?? '',
      level: selectedActivity['level'] ?? '',
      dueDate: 'No due date',
      note: '',
    );

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });

    if (!wasAssigned) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${selectedActivity['title']} is already pending for ${widget.studentName}.',
          ),
        ),
      );

      await _loadActivityStatuses();
      return;
    }

    setState(() {
      if (selectedId != null) {
        activityStatuses[selectedId] = 'Pending';
      }

      selectedActivityId = null;
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${selectedActivity['title']} assigned to ${widget.studentName}.',
        ),
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'Listening':
        return Icons.headphones_outlined;
      case 'Speaking':
        return Icons.mic_none_outlined;
      case 'Vocabulary':
        return Icons.style_outlined;
      case 'Homework':
        return Icons.edit_note_outlined;
      case 'Reading':
        return Icons.menu_book_outlined;
      default:
        return Icons.task_alt_outlined;
    }
  }

  Color _getCategoryColor(String type) {
    switch (type) {
      case 'Listening':
        return AppTheme.info;
      case 'Speaking':
        return AppTheme.accentPurple;
      case 'Vocabulary':
        return AppTheme.brandRed;
      case 'Homework':
        return AppTheme.warning;
      case 'Reading':
        return const Color(0xFF00897B);
      default:
        return AppTheme.accentPurple;
    }
  }

  Color _getStatusColor(String status, String type) {
    switch (status) {
      case 'Completed':
        return AppTheme.success;
      case 'Pending':
        return AppTheme.warning;
      case 'Review Needed':
        return AppTheme.warning;
      default:
        return _getCategoryColor(type);
    }
  }

  IconData _getStatusIcon(String status, String type) {
    switch (status) {
      case 'Completed':
        return Icons.check_circle_outline;
      case 'Pending':
        return Icons.hourglass_empty_rounded;
      case 'Review Needed':
        return Icons.rate_review_outlined;
      default:
        return _getActivityIcon(type);
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'Completed':
        return 'Completed by student';
      case 'Pending':
        return 'Pending';
      case 'Review Needed':
        return 'Review Needed';
      default:
        return 'Available';
    }
  }

  Widget _buildStudentInfoBox() {
    final colors = Theme.of(context).colorScheme;
    final initial = widget.studentName.isEmpty ? '?' : widget.studentName[0];

    return AppPanel(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: AppTheme.brandRed.withValues(alpha: 0.14),
            child: Text(
              initial,
              style: const TextStyle(
                color: AppTheme.brandRed,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.studentName,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                AppStatusBadge(
                  label: 'Level ${widget.studentLevel}',
                  color: AppTheme.info,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Refresh statuses',
            onPressed: isSaving ? null : _loadActivityStatuses,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final bool isSelected = selectedCategory == category;

          return ChoiceChip(
            label: Text(category),
            selected: isSelected,
            onSelected: isSaving
                ? null
                : (_) {
                    setState(() {
                      selectedCategory = category;
                      selectedActivityId = null;
                    });
                  },
          );
        },
      ),
    );
  }

  Widget _buildActivityCard(Map<String, String> activity) {
    final colors = Theme.of(context).colorScheme;
    final activityId = activity['id'] ?? '';
    final isSelected = selectedActivityId == activityId;
    final activityType = activity['type'] ?? '';
    final status = activityStatuses[activityId] ?? 'Not Assigned';
    final canAssign = _canAssignActivity(activityId);
    final statusColor = _getStatusColor(status, activityType);
    final cardColor = !canAssign || isSelected
        ? statusColor.withValues(alpha: 0.08)
        : null;

    return AppPanel(
      margin: const EdgeInsets.only(bottom: 10),
      color: cardColor,
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          onTap: isSaving || !canAssign
              ? null
              : () {
                  setState(() {
                    selectedActivityId = activityId;
                  });
                },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                AppIconBox(
                  icon: _getStatusIcon(status, activityType),
                  color: statusColor,
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity['title'] ?? '',
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        activity['description'] ?? '',
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          AppStatusBadge(
                            label: activityType,
                            color: _getCategoryColor(activityType),
                          ),
                          AppStatusBadge(
                            label: 'Level ${activity['level']}',
                            color: AppTheme.info,
                          ),
                          AppStatusBadge(
                            label: _getStatusLabel(status),
                            color: status == 'Not Assigned'
                                ? colors.onSurfaceVariant
                                : statusColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  !canAssign
                      ? _getStatusIcon(status, activityType)
                      : isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: !canAssign
                      ? statusColor
                      : isSelected
                      ? statusColor
                      : colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCategoryCard() {
    final colors = Theme.of(context).colorScheme;

    return AppPanel(
      child: Text(
        'No $selectedCategory activities available yet.',
        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedActivity = selectedActivityId == null
        ? null
        : availableActivities.firstWhere(
            (activity) => activity['id'] == selectedActivityId,
          );

    final activitiesToShow = filteredActivities;

    return Scaffold(
      appBar: AppBar(title: const Text('Assign Activities')),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(top: BorderSide(color: appBorderColor(context))),
          ),
          child: ElevatedButton.icon(
            onPressed: isSaving || isLoadingStatuses ? null : _assignActivity,
            icon: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.add_task_outlined),
            label: Text(
              isLoadingStatuses
                  ? 'Loading...'
                  : isSaving
                  ? 'Assigning...'
                  : selectedActivity == null
                  ? 'Select an Activity'
                  : 'Assign ${selectedActivity['title']}',
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadActivityStatuses,
        color: AppTheme.brandRed,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const AppSectionHeader(
              title: 'Assign Activities',
              subtitle:
                  'Choose a category and assign an activity to this student.',
            ),
            const SizedBox(height: 20),
            _buildStudentInfoBox(),
            const SizedBox(height: 22),
            const AppSectionHeader(title: 'Category'),
            const SizedBox(height: 12),
            _buildCategoryFilter(),
            const SizedBox(height: 22),
            AppSectionHeader(
              title: selectedCategory == 'All'
                  ? 'Available Activities'
                  : '$selectedCategory Activities',
            ),
            const SizedBox(height: 12),
            if (isLoadingStatuses)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (activitiesToShow.isEmpty)
              _buildEmptyCategoryCard()
            else
              ...activitiesToShow.map(_buildActivityCard),
          ],
        ),
      ),
    );
  }
}
