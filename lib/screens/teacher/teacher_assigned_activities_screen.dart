import 'package:flutter/material.dart';

import '../../models/assigned_activity.dart';
import '../../services/assignment_service.dart';

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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Assigned activity removed.'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );

    await _loadAssignedActivities();
  }

  void _showAssignInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('To assign an activity, open a student profile first.'),
        backgroundColor: Colors.blueGrey,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  IconData _getActivityIcon(String category) {
    switch (category) {
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.greenAccent;
      case 'Review Needed':
        return Colors.orangeAccent;
      case 'Pending':
      default:
        return Colors.amberAccent;
    }
  }

  Widget _buildAssignedActivityCard(AssignedActivity activity) {
    final statusColor = _getStatusColor(activity.status);

    return Card(
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF6E59A5).withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _getActivityIcon(activity.category),
                color: const Color(0xFFD3E4FD),
                size: 28,
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
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${activity.assignedToType}: ${activity.assignedToName}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${activity.category} • Level ${activity.level}',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Due date: ${activity.dueDate}',
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    activity.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                IconButton(
                  onPressed: () => _deleteAssignment(activity.id),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.assignment_outlined,
            color: Colors.white38,
            size: 54,
          ),
          const SizedBox(height: 16),
          const Text(
            'No assigned activities yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'To assign an activity, go to Students, choose a student and tap Assign Activity.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: _showAssignInfo,
            icon: const Icon(Icons.info_outline),
            label: const Text('How to assign'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6E59A5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
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
        child: CircularProgressIndicator(
          color: Color(0xFF6E59A5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasAssignedActivities = assignedActivities.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: const Text('Assigned Activities'),
        actions: [
          IconButton(
            onPressed: _loadAssignedActivities,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAssignInfo,
        backgroundColor: const Color(0xFF6E59A5),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_task),
        label: const Text('Assign'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadAssignedActivities,
        color: const Color(0xFF6E59A5),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Assigned Activities',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'View activities that have already been assigned to students.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

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