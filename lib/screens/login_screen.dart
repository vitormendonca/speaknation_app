import 'package:flutter/material.dart';

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

  static const String studentCode = 'ALUNO123';
  static const String teacherCode = 'TEACHER123';

  @override
  void dispose() {
    accessCodeController.dispose();
    super.dispose();
  }

  void _loginWithCode() {
    final String code = accessCodeController.text.trim().toUpperCase();

    if (code == studentCode) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const StudentHomeScreen(),
        ),
      );
    } else if (code == teacherCode) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const TeacherHomeScreen(),
        ),
      );
    } else {
      setState(() {
        errorMessage = 'Invalid access code. Please check and try again.';
      });
    }
  }

  void _fillDemoCode(String code) {
    setState(() {
      accessCodeController.text = code;
      errorMessage = null;
    });
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
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    letterSpacing: 1.2,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Access code',
                    labelStyle: const TextStyle(color: Colors.white70),
                    hintText: 'Example: ALUNO123',
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
                            child: OutlinedButton(
                              onPressed: () => _fillDemoCode(studentCode),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Student',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _fillDemoCode(teacherCode),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Teacher',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Student: ALUNO123 • Teacher: TEACHER123',
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