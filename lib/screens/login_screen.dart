import 'package:flutter/material.dart';

import '../models/app_session.dart';
import '../services/app_auth_service.dart';
import '../services/supabase_bootstrap.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import '../widgets/app_ui.dart';
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
    final colors = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: TextCapitalization.none,
      style: TextStyle(color: colors.onSurface, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: colors.onSurfaceVariant),
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
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSupabaseConfigured = SupabaseBootstrap.isConfigured;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SpeakNation'),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            icon: Icon(ThemeController.iconFor(context)),
            onPressed: () => ThemeController.toggle(context),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppPanel(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AppIconBox(
                        icon: Icons.language_rounded,
                        color: AppTheme.brandRed,
                        size: 72,
                        iconSize: 40,
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'Welcome to SpeakNation',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Sign in with your account or use a demo access code.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 15,
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
                          height: 48,
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
                            label: const Text('Sign In'),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Divider(color: Theme.of(context).dividerColor),
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
                              color: AppTheme.warning,
                              fontSize: 13,
                              height: 1.3,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : _loginWithCode,
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Enter Demo'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                AppPanel(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Demo access codes',
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
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
                      const SizedBox(height: 12),
                      Text(
                        'Students: joao123, maria123, ana123 - Teacher: teacher123',
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppStatusBadge(
                  label: isSupabaseConfigured
                      ? 'Supabase connected - MVP version'
                      : 'Local demo mode - MVP version',
                  color: isSupabaseConfigured
                      ? AppTheme.success
                      : AppTheme.info,
                  icon: isSupabaseConfigured
                      ? Icons.cloud_done_outlined
                      : Icons.storage_outlined,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
