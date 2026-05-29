import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/students_data.dart';
import 'student/student_home_screen.dart';
import 'teacher/teacher_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController accessCodeController = TextEditingController();

  String? errorMessage;

  static const String teacherCode = 'teacher123';

  @override
  void dispose() {
    accessCodeController.dispose();
    super.dispose();
  }

  Future<void> _saveStudentSession(StudentData student) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('currentStudentId', student.id);
    await prefs.setString('currentStudentName', student.name);
    await prefs.setString('currentStudentLevel', student.level);
    await prefs.setString('currentStudentAccessCode', student.accessCode);
    await prefs.setString('currentUserRole', 'student');
  }

  Future<void> _saveTeacherSession() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.setString('currentUserRole', 'teacher');
  await prefs.setString('currentTeacherId', 'teacher_001');
  await prefs.setString('currentTeacherName', 'Teacher');

  await prefs.remove('currentStudentId');
  await prefs.remove('currentStudentName');
  await prefs.remove('currentStudentLevel');
  await prefs.remove('currentStudentAccessCode');
}

  Future<void> _loginWithCode() async {
    final String code = accessCodeController.text.trim().toLowerCase();

    if (code == teacherCode) {
      await _saveTeacherSession();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const TeacherHomeScreen(),
        ),
      );
      return;
    }

    StudentData? matchedStudent;

    for (final student in studentsData) {
      if (student.accessCode.toLowerCase() == code) {
        matchedStudent = student;
        break;
      }
    }

    if (matchedStudent != null) {
      await _saveStudentSession(matchedStudent);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const StudentHomeScreen(),
        ),
      );
      return;
    }

    setState(() {
      errorMessage = 'Invalid access code. Please check and try again.';
    });
  }

  void _fillDemoCode(String code) {
    setState(() {
      accessCodeController.text = code;
      errorMessage = null;
    });
  }

  Widget _buildDemoCodeButton({
    required String label,
    required String code,
  }) {
    return OutlinedButton(
      onPressed: () => _fillDemoCode(code),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.white24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('SpeakNation'),
        backgroundColor: const Color(0xFFB00020),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB00020).withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.language_rounded,
                    color: Color(0xFFB00020),
                    size: 46,
                  ),
                ),

                const SizedBox(height: 22),

                const Text(
                  'Welcome to SpeakNation',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 29,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Enter your access code to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 28),

                TextField(
                  controller: accessCodeController,
                  textCapitalization: TextCapitalization.none,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    letterSpacing: 1.2,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Access code',
                    labelStyle: const TextStyle(color: Colors.white70),
                    hintText: 'Example: joao123',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF121212),
                    prefixIcon: const Icon(
                      Icons.lock_rounded,
                      color: Colors.white54,
                    ),
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
                    errorText: errorMessage,
                  ),
                  onSubmitted: (_) => _loginWithCode(),
                  onChanged: (_) {
                    if (errorMessage != null) {
                      setState(() {
                        errorMessage = null;
                      });
                    }
                  },
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _loginWithCode,
                    icon: const Icon(
                      Icons.login_rounded,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Enter App',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB00020),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Demo access codes',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: _buildDemoCodeButton(
                              label: 'João',
                              code: 'joao123',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildDemoCodeButton(
                              label: 'Maria',
                              code: 'maria123',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: _buildDemoCodeButton(
                              label: 'Ana',
                              code: 'ana123',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildDemoCodeButton(
                              label: 'Teacher',
                              code: teacherCode,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'Students: joao123, maria123, ana123 • Teacher: teacher123',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'MVP version',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}