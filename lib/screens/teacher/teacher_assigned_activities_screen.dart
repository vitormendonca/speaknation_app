import 'package:flutter/material.dart';

import '../../models/assigned_activity.dart';
import '../../services/assignment_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_ui.dart';

class TeacherAssignedActivitiesScreen extends StatefulWidget {
  const TeacherAssignedActivitiesScreen({super.key});

  @override
  State<TeacherAssignedActivitiesScreen> createState() =>
      _TeacherAssignedActivitiesScreenState();
}

class _TeacherAssignedActivitiesScreenState
    extends State<TeacherAssignedActivitiesScreen> {
  List<AssignedActivity> assignedActivities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssignedActivities();
  }

  Future<void> _loadAssignedActivities() async {
    final activities = await AssignmentService.getAllAssignedActivities();

    if (!mounted) return;

    setState(() {
      assignedActivities = activities.reversed.toList();
      isLoading = false;
    });
  }

  Future<void> _deleteAssignment(String assignmentId) async {
    await AssignmentService.deleteAssignment(assignmentId);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Assigned activity removed.')));

    await _loadAssignedActivities();
  }

  void _showAssignInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('To assign an activity, open a student profile first.'),
      ),
    );
  }

  IconData _getActivityIcon(String category) {
    switch (category) {
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return AppTheme.success;
      case 'Review Needed':
        return AppTheme.warning;
      case 'Reviewed':
        return AppTheme.info;
      case 'Pending':
      default:
        return AppTheme.warning;
    }
  }

  Widget _buildAssignedActivityCard(AssignedActivity activity) {
    final colors = Theme.of(context).colorScheme;
    final statusColor = _getStatusColor(activity.status);

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
                  '${activity.assignedToType}: ${activity.assignedToName}',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${activity.category} - Level ${activity.level}',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Due date: ${activity.dueDate}',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                AppStatusBadge(label: activity.status, color: statusColor),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Remove assignment',
            onPressed: () => _deleteAssignment(activity.id),
            icon: Icon(Icons.delete_outline, color: colors.onSurfaceVariant),
          ),
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
            'No assigned activities yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'To assign an activity, go to Students, choose a student and tap Assign Activity.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: _showAssignInfo,
            icon: const Icon(Icons.info_outline),
            label: const Text('How to assign'),
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
        title: const Text('Assigned Activities'),
        actions: [
          IconButton(
            tooltip: 'Refresh activities',
            onPressed: _loadAssignedActivities,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAssignInfo,
        icon: const Icon(Icons.add_task_outlined),
        label: const Text('Assign'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadAssignedActivities,
        color: AppTheme.brandRed,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const AppSectionHeader(
              title: 'Assigned Activities',
              subtitle:
                  'View activities that have already been assigned to students.',
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
