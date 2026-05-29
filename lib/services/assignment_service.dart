import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/assigned_activity.dart';

class AssignmentService {
  static const String _assignedActivitiesKey = 'assigned_activities';

  static Future<List<AssignedActivity>> getAllAssignedActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_assignedActivitiesKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    final decodedData = jsonDecode(jsonString);

    if (decodedData is! List) {
      return [];
    }

    return decodedData
        .map(
          (item) => AssignedActivity.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  static Future<bool> assignActivityToStudent({
    required String studentName,
    required String title,
    required String category,
    required String level,
    String dueDate = 'No due date',
    String note = '',
  }) async {
    final currentAssignments = await getAllAssignedActivities();

    final alreadyAssigned = currentAssignments.any(
      (assignment) =>
          assignment.assignedToType == 'Student' &&
          assignment.assignedToName == studentName &&
          assignment.title == title &&
          assignment.category == category &&
          assignment.status != 'Reviewed',
    );

    if (alreadyAssigned) {
      return false;
    }

    final newAssignment = AssignedActivity(
      id: 'assignment_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      category: category,
      level: level,
      assignedToName: studentName,
      assignedToType: 'Student',
      dueDate: dueDate,
      status: 'Pending',
      note: note,
    );

    currentAssignments.add(newAssignment);

    await _saveAssignments(currentAssignments);

    return true;
  }

  static Future<bool> assignActivityToClass({
    required String className,
    required String title,
    required String category,
    required String level,
    String dueDate = 'No due date',
    String note = '',
  }) async {
    final currentAssignments = await getAllAssignedActivities();

    final alreadyAssigned = currentAssignments.any(
      (assignment) =>
          assignment.assignedToType == 'Class' &&
          assignment.assignedToName == className &&
          assignment.title == title &&
          assignment.category == category &&
          assignment.status != 'Reviewed',
    );

    if (alreadyAssigned) {
      return false;
    }

    final newAssignment = AssignedActivity(
      id: 'assignment_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      category: category,
      level: level,
      assignedToName: className,
      assignedToType: 'Class',
      dueDate: dueDate,
      status: 'Pending',
      note: note,
    );

    currentAssignments.add(newAssignment);

    await _saveAssignments(currentAssignments);

    return true;
  }

  static Future<List<AssignedActivity>> getAssignedActivitiesByStudentName(
    String studentName,
  ) async {
    final allAssignments = await getAllAssignedActivities();

    return allAssignments
        .where(
          (assignment) =>
              assignment.assignedToType == 'Student' &&
              assignment.assignedToName == studentName,
        )
        .toList();
  }

  static Future<List<AssignedActivity>> getActiveAssignedActivitiesByStudentName(
    String studentName,
  ) async {
    final allAssignments = await getAllAssignedActivities();

    return allAssignments
        .where(
          (assignment) =>
              assignment.assignedToType == 'Student' &&
              assignment.assignedToName == studentName &&
              assignment.status != 'Reviewed',
        )
        .toList();
  }

  static Future<List<AssignedActivity>>
      getReviewedAssignedActivitiesByStudentName(
    String studentName,
  ) async {
    final allAssignments = await getAllAssignedActivities();

    return allAssignments
        .where(
          (assignment) =>
              assignment.assignedToType == 'Student' &&
              assignment.assignedToName == studentName &&
              assignment.status == 'Reviewed',
        )
        .toList();
  }

  static Future<List<AssignedActivity>> getAssignedActivitiesByClassName(
    String className,
  ) async {
    final allAssignments = await getAllAssignedActivities();

    return allAssignments
        .where(
          (assignment) =>
              assignment.assignedToType == 'Class' &&
              assignment.assignedToName == className,
        )
        .toList();
  }

  static Future<AssignedActivity?> getStudentAssignmentByTitleAndCategory({
    required String studentName,
    required String title,
    required String category,
  }) async {
    final assignments = await getAssignedActivitiesByStudentName(studentName);

    for (final assignment in assignments) {
      if (assignment.title == title &&
          assignment.category == category &&
          assignment.status != 'Reviewed') {
        return assignment;
      }
    }

    return null;
  }

  static Future<void> updateAssignmentStatus({
    required String assignmentId,
    required String newStatus,
  }) async {
    final currentAssignments = await getAllAssignedActivities();

    final updatedAssignments = currentAssignments.map((assignment) {
      if (assignment.id == assignmentId) {
        return AssignedActivity(
          id: assignment.id,
          title: assignment.title,
          category: assignment.category,
          level: assignment.level,
          assignedToName: assignment.assignedToName,
          assignedToType: assignment.assignedToType,
          dueDate: assignment.dueDate,
          status: newStatus,
          note: assignment.note,
        );
      }

      return assignment;
    }).toList();

    await _saveAssignments(updatedAssignments);
  }

  static Future<void> markAssignmentAsReviewed(String assignmentId) async {
    await updateAssignmentStatus(
      assignmentId: assignmentId,
      newStatus: 'Reviewed',
    );
  }

  static Future<bool> markStudentAssignmentAsCompleted({
    required String studentName,
    required String title,
    required String category,
  }) async {
    return _updateStudentAssignmentStatus(
      studentName: studentName,
      title: title,
      category: category,
      newStatus: 'Completed',
    );
  }

  static Future<bool> markStudentAssignmentAsReviewNeeded({
    required String studentName,
    required String title,
    required String category,
  }) async {
    return _updateStudentAssignmentStatus(
      studentName: studentName,
      title: title,
      category: category,
      newStatus: 'Review Needed',
    );
  }

  static Future<bool> _updateStudentAssignmentStatus({
    required String studentName,
    required String title,
    required String category,
    required String newStatus,
  }) async {
    final currentAssignments = await getAllAssignedActivities();

    bool wasUpdated = false;

    final updatedAssignments = currentAssignments.map((assignment) {
      final bool isTargetAssignment =
          assignment.assignedToType == 'Student' &&
          assignment.assignedToName == studentName &&
          assignment.title == title &&
          assignment.category == category &&
          assignment.status != 'Reviewed';

      if (isTargetAssignment && !wasUpdated) {
        wasUpdated = true;

        return AssignedActivity(
          id: assignment.id,
          title: assignment.title,
          category: assignment.category,
          level: assignment.level,
          assignedToName: assignment.assignedToName,
          assignedToType: assignment.assignedToType,
          dueDate: assignment.dueDate,
          status: newStatus,
          note: assignment.note,
        );
      }

      return assignment;
    }).toList();

    if (!wasUpdated) {
      return false;
    }

    await _saveAssignments(updatedAssignments);

    return true;
  }

  static Future<void> deleteAssignment(String assignmentId) async {
    final currentAssignments = await getAllAssignedActivities();

    final updatedAssignments = currentAssignments
        .where((assignment) => assignment.id != assignmentId)
        .toList();

    await _saveAssignments(updatedAssignments);
  }

  static Future<void> clearAllAssignments() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_assignedActivitiesKey);
  }

  static Future<void> _saveAssignments(
    List<AssignedActivity> assignments,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final encodedData = jsonEncode(
      assignments.map((assignment) => assignment.toJson()).toList(),
    );

    await prefs.setString(_assignedActivitiesKey, encodedData);
  }
}