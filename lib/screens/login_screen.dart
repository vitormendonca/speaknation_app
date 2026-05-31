import 'package:flutter/material.dart';

import '../models/app_session.dart';
import '../services/app_auth_service.dart';
import '../services/supabase_bootstrap.dart';
import 'student/student_home_screen.dart';
import 'teacher/teacher_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController accessCodeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? errorMessage;
  bool isLoading = false;

  @override
  void dispose() {
    accessCodeController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLoginResult(AppLoginResult result) async {
    if (!mounted) return;

    if (!result.isSuccess) {
      setState(() {
        isLoading = false;
        errorMessage = result.errorMessage;
      });
      return;
    }

    final session = result.session;
    if (session == null) return;

    setState(() {
      isLoading = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => session.isTeacher
            ? const TeacherHomeScreen()
            : const StudentHomeScreen(),
      ),
    );
  }

  Future<void> _loginWithEmail() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Enter email and password.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final result = await AppAuthService.signInWithEmail(
      email: email,
      password: password,
    );

    await _handleLoginResult(result);
  }

  Future<void> _loginWithCode() async {
    final code = accessCodeController.text.trim();

    if (code.isEmpty) {
      setState(() {
        errorMessage = 'Enter an access code.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final result = await AppAuthService.signInWithDemoCode(code);

    await _handleLoginResult(result);
  }

  void _fillDemoCode(String code) {
    setState(() {
      accessCodeController.text = code;
      errorMessage = null;
    });
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    void Function(String)? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: TextCapitalization.none,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF121212),
        prefixIcon: Icon(icon, color: Colors.white54),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFB00020)),
        ),
      ),
      onSubmitted: onSubmitted,
      onChanged: (_) {
        if (errorMessage != null) {
          setState(() {
            errorMessage = null;
          });
        }
      },
    );
  }

  Widget _buildDemoCodeButton({required String label, required String code}) {
    return OutlinedButton(
      onPressed: isLoading ? null : () => _fillDemoCode(code),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.white24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSupabaseConfigured = SupabaseBootstrap.isConfigured;

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
                  'Sign in with your account or use a demo access code.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                if (isSupabaseConfigured) ...[
                  _buildInput(
                    controller: emailController,
                    label: 'Email',
                    hint: 'you@example.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  _buildInput(
                    controller: passwordController,
                    label: 'Password',
                    hint: 'Your password',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    onSubmitted: (_) => _loginWithEmail(),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : _loginWithEmail,
                      icon: isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.login_rounded),
                      label: const Text(
                        'Sign In',
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
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 18),
                ],
                _buildInput(
                  controller: accessCodeController,
                  label: 'Demo access code',
                  hint: 'Example: joao123',
                  icon: Icons.vpn_key_outlined,
                  onSubmitted: (_) => _loginWithCode(),
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : _loginWithCode,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text(
                      'Enter Demo',
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
                              label: 'Joao',
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
                              code: AppAuthService.teacherCode,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Students: joao123, maria123, ana123 - Teacher: teacher123',
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  isSupabaseConfigured
                      ? 'Supabase connected - MVP version'
                      : 'Local demo mode - MVP version',
                  style: const TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
