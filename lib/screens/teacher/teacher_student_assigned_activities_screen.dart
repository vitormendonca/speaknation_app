import 'package:flutter/material.dart';

import '../../models/assigned_activity.dart';
import '../../services/assignment_service.dart';
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
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Remove assignment?',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to remove "${activity.title}" from ${widget.studentName}?',
            style: const TextStyle(color: Colors.white70, height: 1.4),
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
              child: const Text(
                'Remove',
                style: TextStyle(color: Colors.redAccent),
              ),
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Assigned activity removed.'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 1200),
      ),
    );

    await _loadAssignedActivities();
  }

  Future<void> _confirmMarkAsReviewed(AssignedActivity activity) async {
    final shouldReview = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Mark as reviewed?',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Do you want to mark "${activity.title}" as reviewed for ${widget.studentName}?',
            style: const TextStyle(color: Colors.white70, height: 1.4),
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
              child: const Text(
                'Mark as Reviewed',
                style: TextStyle(color: Colors.greenAccent),
              ),
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
      const SnackBar(
        content: Text('Assignment marked as reviewed.'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(milliseconds: 1200),
      ),
    );

    await _loadAssignedActivities();
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
      case 'Reviewed':
        return Colors.blueAccent;
      case 'Review Needed':
        return Colors.orangeAccent;
      case 'Pending':
      default:
        return Colors.amberAccent;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Completed':
        return Icons.check_circle;
      case 'Reviewed':
        return Icons.verified;
      case 'Review Needed':
        return Icons.info;
      case 'Pending':
      default:
        return Icons.hourglass_empty;
    }
  }

  Widget _buildActionIcon(AssignedActivity activity) {
    if (activity.status == 'Pending') {
      return IconButton(
        tooltip: 'Remove assignment',
        onPressed: () => _confirmDeleteAssignment(activity),
        icon: const Icon(Icons.delete_outline, color: Colors.white38),
      );
    }

    if (activity.status == 'Completed') {
      return IconButton(
        tooltip: 'Mark as reviewed',
        onPressed: () => _confirmMarkAsReviewed(activity),
        icon: const Icon(Icons.check_circle_outline, color: Colors.greenAccent),
      );
    }

    if (activity.status == 'Reviewed') {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Icon(Icons.verified, color: Colors.blueAccent),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildAssignedActivityCard(AssignedActivity activity) {
    final statusColor = _getStatusColor(activity.status);
    final statusIcon = _getStatusIcon(activity.status);

    return Card(
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
                    '${activity.category} • Level ${activity.level}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Due date: ${activity.dueDate}',
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  if (activity.status == 'Completed') ...[
                    const SizedBox(height: 6),
                    const Text(
                      'Waiting for teacher review.',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  if (activity.status == 'Reviewed') ...[
                    const SizedBox(height: 6),
                    const Text(
                      'Reviewed by teacher.',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  if (activity.note.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Note: ${activity.note}',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        activity.status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _buildActionIcon(activity),
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
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.assignment_outlined,
            color: Colors.white38,
            size: 54,
          ),
          const SizedBox(height: 16),
          Text(
            'No activities assigned to ${widget.studentName} yet',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Assign an activity now without going back to the student profile.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openAssignActivityScreen,
              icon: const Icon(Icons.add_task),
              label: const Text('Assign Activity'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6E59A5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
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
        child: CircularProgressIndicator(color: Color(0xFF6E59A5)),
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
        title: const Text('Student Activities'),
        actions: [
          IconButton(
            onPressed: _loadAssignedActivities,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: hasAssignedActivities
          ? FloatingActionButton.extended(
              onPressed: _openAssignActivityScreen,
              backgroundColor: const Color(0xFF6E59A5),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_task),
              label: const Text('Assign'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _loadAssignedActivities,
        color: const Color(0xFF6E59A5),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              widget.studentName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Activities assigned to this student.',
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
