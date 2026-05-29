import 'package:flutter/material.dart';

import '../../models/assigned_activity.dart';
import '../../services/assignment_service.dart';
import '../../services/student_progress_service.dart';

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
    'Vocabulary',
    'Reading',
  ];

  final List<Map<String, String>> availableActivities = const [
    {
      'id': 'homework_001',
      'title': 'Basic Greetings',
      'type': 'Homework',
      'level': 'A1',
      'description': 'Practice simple greetings and introductions.',
    },
    {
      'id': 'listening_001',
      'title': 'Morning Routine',
      'type': 'Listening',
      'level': 'A1',
      'description': 'Listen to a short audio about a daily routine.',
    },
    {
      'id': 'vocabulary_001',
      'title': 'Daily Vocabulary',
      'type': 'Vocabulary',
      'level': 'A1',
      'description': 'Review common daily vocabulary words.',
    },
    {
      'id': 'homework_002',
      'title': 'Simple Present Practice',
      'type': 'Homework',
      'level': 'A2',
      'description':
          'Practice affirmative and negative simple present sentences.',
    },
    {
      'id': 'reading_001',
      'title': 'A Short Introduction',
      'type': 'Reading',
      'level': 'A1',
      'description': 'Read a short text and answer comprehension questions.',
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
        await AssignmentService.getAssignedActivitiesByStudentName(
      widget.studentName,
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
        const SnackBar(
          content: Text('Please select an activity first.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          duration: Duration(milliseconds: 1200),
        ),
      );
      return;
    }

    if (!_canAssignActivity(selectedActivityId!)) {
      ScaffoldMessenger.of(context).clearSnackBars();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This activity already has a status for this student.'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          duration: Duration(milliseconds: 1200),
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
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1200),
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
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1200),
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'Listening':
        return Icons.headphones;
      case 'Vocabulary':
        return Icons.menu_book;
      case 'Homework':
        return Icons.assignment;
      case 'Reading':
        return Icons.article;
      default:
        return Icons.task_alt;
    }
  }

  Color _getCategoryColor(String type) {
    switch (type) {
      case 'Listening':
        return Colors.blueAccent;
      case 'Vocabulary':
        return Colors.purpleAccent;
      case 'Homework':
        return Colors.orangeAccent;
      case 'Reading':
        return Colors.greenAccent;
      default:
        return const Color(0xFFD3E4FD);
    }
  }

  Color _getStatusColor(String status, String type) {
    switch (status) {
      case 'Completed':
        return Colors.greenAccent;
      case 'Pending':
        return Colors.amberAccent;
      case 'Review Needed':
        return Colors.orangeAccent;
      default:
        return _getCategoryColor(type);
    }
  }

  IconData _getStatusIcon(String status, String type) {
    switch (status) {
      case 'Completed':
        return Icons.check_circle;
      case 'Pending':
        return Icons.hourglass_empty;
      case 'Review Needed':
        return Icons.info;
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFF6E59A5),
            child: Text(
              widget.studentName[0],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Level ${widget.studentLevel}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: isSaving ? null : _loadActivityStatuses,
            icon: const Icon(
              Icons.refresh,
              color: Colors.white70,
            ),
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
        separatorBuilder: (context, index) => const SizedBox(width: 10),
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
            selectedColor: const Color(0xFF6E59A5),
            backgroundColor: const Color(0xFF1E1E1E),
            side: BorderSide(
              color: isSelected ? const Color(0xFFD3E4FD) : Colors.white24,
            ),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivityCard(Map<String, String> activity) {
    final activityId = activity['id'] ?? '';
    final isSelected = selectedActivityId == activityId;
    final activityType = activity['type'] ?? '';
    final status = activityStatuses[activityId] ?? 'Not Assigned';
    final canAssign = _canAssignActivity(activityId);
    final statusColor = _getStatusColor(status, activityType);

    return Card(
      color: !canAssign
          ? statusColor.withValues(alpha: 0.12)
          : isSelected
              ? const Color(0xFF6E59A5).withValues(alpha: 0.28)
              : const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: !canAssign
              ? statusColor
              : isSelected
                  ? const Color(0xFFD3E4FD)
                  : Colors.white10,
          width: isSelected || !canAssign ? 1.4 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: isSaving || !canAssign
            ? null
            : () {
                setState(() {
                  selectedActivityId = activityId;
                });
              },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _getStatusIcon(status, activityType),
                  color: statusColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['title'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      activity['description'] ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _smallTag(
                          text: activityType,
                          color: _getCategoryColor(activityType),
                        ),
                        _smallTag(
                          text: 'Level ${activity['level']}',
                          color: const Color(0xFFD3E4FD),
                        ),
                        _smallTag(
                          text: _getStatusLabel(status),
                          color: status == 'Not Assigned'
                              ? Colors.white54
                              : statusColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                !canAssign
                    ? _getStatusIcon(status, activityType)
                    : isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                color: !canAssign
                    ? statusColor
                    : isSelected
                        ? const Color(0xFFD3E4FD)
                        : Colors.white38,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _smallTag({
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: 0.45),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyCategoryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        'No $selectedCategory activities available yet.',
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 15,
        ),
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
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: const Text('Assign Activities'),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFF121212),
            border: Border(
              top: BorderSide(
                color: Colors.white10,
              ),
            ),
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
                : const Icon(Icons.add_task),
            label: Text(
              isLoadingStatuses
                  ? 'Loading...'
                  : isSaving
                      ? 'Assigning...'
                      : selectedActivity == null
                          ? 'Select an Activity'
                          : 'Assign ${selectedActivity['title']}',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6E59A5),
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  const Color(0xFF6E59A5).withValues(alpha: 0.45),
              disabledForegroundColor: Colors.white70,
              padding: const EdgeInsets.symmetric(
                vertical: 15,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadActivityStatuses,
        color: const Color(0xFF6E59A5),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Assign Activities',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose a category and assign one or more activities to this student.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            _buildStudentInfoBox(),
            const SizedBox(height: 24),
            const Text(
              'Category',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildCategoryFilter(),
            const SizedBox(height: 24),
            Text(
              selectedCategory == 'All'
                  ? 'Available Activities'
                  : '$selectedCategory Activities',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (isLoadingStatuses)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(
                    color: Color(0xFF6E59A5),
                  ),
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