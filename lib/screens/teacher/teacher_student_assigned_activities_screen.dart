import 'package:flutter/material.dart';

import '../../models/assigned_activity.dart';
import '../../services/assignment_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_ui.dart';
import 'teacher_assign_activity_screen.dart';

class TeacherStudentAssignedActivitiesScreen extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String studentLevel;

  const TeacherStudentAssignedActivitiesScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.studentLevel,
  });

  @override
  State<TeacherStudentAssignedActivitiesScreen> createState() =>
      _TeacherStudentAssignedActivitiesScreenState();
}

class _TeacherStudentAssignedActivitiesScreenState
    extends State<TeacherStudentAssignedActivitiesScreen> {
  List<AssignedActivity> assignedActivities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssignedActivities();
  }

  Future<void> _loadAssignedActivities() async {
    final activities = await AssignmentService.getAssignedActivitiesForStudent(
      studentId: widget.studentId,
      studentName: widget.studentName,
    );

    if (!mounted) return;

    setState(() {
      assignedActivities = activities.reversed.toList();
      isLoading = false;
    });
  }

  Future<void> _openAssignActivityScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeacherAssignActivityScreen(
          studentId: widget.studentId,
          studentName: widget.studentName,
          studentLevel: widget.studentLevel,
        ),
      ),
    );

    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    await _loadAssignedActivities();
  }

  Future<void> _confirmDeleteAssignment(AssignedActivity activity) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;

        return AlertDialog(
          title: const Text('Remove assignment?'),
          content: Text(
            'Remove "${activity.title}" from ${widget.studentName}?',
            style: TextStyle(color: colors.onSurfaceVariant, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await AssignmentService.deleteAssignment(activity.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Assigned activity removed.')));

    await _loadAssignedActivities();
  }

  Future<void> _confirmMarkAsReviewed(AssignedActivity activity) async {
    final shouldReview = await showDialog<bool>(
      context: context,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;

        return AlertDialog(
          title: const Text('Mark as reviewed?'),
          content: Text(
            'Mark "${activity.title}" as reviewed for ${widget.studentName}?',
            style: TextStyle(color: colors.onSurfaceVariant, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Mark as Reviewed'),
            ),
          ],
        );
      },
    );

    if (shouldReview != true) {
      return;
    }

    await AssignmentService.markAssignmentAsReviewed(activity.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Assignment marked as reviewed.')),
    );

    await _loadAssignedActivities();
  }

  IconData _getActivityIcon(String category) {
    switch (category) {
      case 'Listening':
        return Icons.headphones_outlined;
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return AppTheme.success;
      case 'Reviewed':
        return AppTheme.info;
      case 'Review Needed':
        return AppTheme.warning;
      case 'Pending':
      default:
        return AppTheme.warning;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Completed':
        return Icons.check_circle_outline;
      case 'Reviewed':
        return Icons.verified_outlined;
      case 'Review Needed':
        return Icons.rate_review_outlined;
      case 'Pending':
      default:
        return Icons.hourglass_empty_rounded;
    }
  }

  Widget _buildActionIcon(AssignedActivity activity) {
    final colors = Theme.of(context).colorScheme;

    if (activity.status == 'Pending') {
      return IconButton(
        tooltip: 'Remove assignment',
        onPressed: () => _confirmDeleteAssignment(activity),
        icon: Icon(Icons.delete_outline, color: colors.onSurfaceVariant),
      );
    }

    if (activity.status == 'Completed') {
      return IconButton(
        tooltip: 'Mark as reviewed',
        onPressed: () => _confirmMarkAsReviewed(activity),
        icon: const Icon(Icons.check_circle_outline, color: AppTheme.success),
      );
    }

    if (activity.status == 'Reviewed') {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Icon(Icons.verified_outlined, color: AppTheme.info),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildAssignedActivityCard(AssignedActivity activity) {
    final colors = Theme.of(context).colorScheme;
    final statusColor = _getStatusColor(activity.status);
    final statusIcon = _getStatusIcon(activity.status);

    return AppPanel(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          AppIconBox(
            icon: _getActivityIcon(activity.category),
            color: statusColor,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${activity.category} - Level ${activity.level}',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Due date: ${activity.dueDate}',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                if (activity.note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Note: ${activity.note}',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                AppStatusBadge(
                  label: activity.status,
                  color: statusColor,
                  icon: statusIcon,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildActionIcon(activity),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final colors = Theme.of(context).colorScheme;

    return AppPanel(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            color: colors.onSurfaceVariant,
            size: 52,
          ),
          const SizedBox(height: 14),
          Text(
            'No activities assigned to ${widget.studentName} yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Assign an activity now without going back to the student profile.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openAssignActivityScreen,
              icon: const Icon(Icons.add_task_outlined),
              label: const Text('Assign Activity'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 80),
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasAssignedActivities = assignedActivities.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Activities'),
        actions: [
          IconButton(
            tooltip: 'Refresh activities',
            onPressed: _loadAssignedActivities,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: hasAssignedActivities
          ? FloatingActionButton.extended(
              onPressed: _openAssignActivityScreen,
              icon: const Icon(Icons.add_task_outlined),
              label: const Text('Assign'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _loadAssignedActivities,
        color: AppTheme.brandRed,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppSectionHeader(
              title: widget.studentName,
              subtitle: 'Activities assigned to this student.',
            ),
            const SizedBox(height: 20),
            if (isLoading)
              _buildLoadingState()
            else if (!hasAssignedActivities)
              _buildEmptyState()
            else
              ...assignedActivities.map(_buildAssignedActivityCard),
          ],
        ),
      ),
    );
  }
}
