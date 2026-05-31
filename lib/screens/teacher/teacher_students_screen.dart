import 'package:flutter/material.dart';

import '../../services/teacher_students_service.dart';
import 'teacher_student_detail_screen.dart';

class TeacherStudentsScreen extends StatefulWidget {
  const TeacherStudentsScreen({super.key});

  @override
  State<TeacherStudentsScreen> createState() => _TeacherStudentsScreenState();
}

class _TeacherStudentsScreenState extends State<TeacherStudentsScreen> {
  List<TeacherStudentSummary> students = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final loadedStudents =
        await TeacherStudentsService.getStudentsForCurrentTeacher();

    if (!mounted) return;

    setState(() {
      students = loadedStudents;
      isLoading = false;
    });
  }

  Widget _buildStudentCard({
    required BuildContext context,
    required TeacherStudentSummary student,
  }) {
    return Card(
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeacherStudentDetailScreen(
                studentId: student.id,
                studentName: student.name,
                studentLevel: student.level,
                accessCode: student.accessCode,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFF6E59A5),
                child: Text(
                  student.name.isEmpty ? '?' : student.name[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Level: ${student.level}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    if (student.accessCode.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Access code: ${student.accessCode}',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
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

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.person_add_alt_1_outlined,
            color: Colors.white38,
            size: 54,
          ),
          SizedBox(height: 14),
          Text(
            'No linked students yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Link a student to this teacher in Supabase to manage real assignments.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: const Text('Students'),
        actions: [
          IconButton(
            tooltip: 'Refresh students',
            onPressed: _loadStudents,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStudents,
        color: const Color(0xFF6E59A5),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Your Students',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a student to assign activities or view progress.',
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              _buildLoadingState()
            else if (students.isEmpty)
              _buildEmptyState()
            else
              ...students.map(
                (student) =>
                    _buildStudentCard(context: context, student: student),
              ),
          ],
        ),
      ),
    );
  }
}
