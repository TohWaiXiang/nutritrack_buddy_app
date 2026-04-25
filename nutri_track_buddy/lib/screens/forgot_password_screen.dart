import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../widgets/app_scope.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  final answerController = TextEditingController();
  final newPasswordController = TextEditingController();
  UserProfile? foundUser;
  bool loading = false;

  @override
  void dispose() {
    emailController.dispose();
    answerController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _searchUser() async {
    final user = await AppScope.of(context).findUser(emailController.text);
    if (!mounted) return;
    setState(() => foundUser = user);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No account found for this email')));
    }
  }

  Future<void> _reset() async {
    setState(() => loading = true);
    final error = await AppScope.of(context).resetPassword(emailController.text,
        answerController.text, newPasswordController.text);
    if (!mounted) return;
    setState(() => loading = false);
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset successful')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Reset password securely',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 18),
                  TextField(
                      controller: emailController,
                      decoration:
                          const InputDecoration(labelText: 'Registered Email')),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                      onPressed: _searchUser,
                      child: const Text('Check Account')),
                  if (foundUser != null) ...[
                    const SizedBox(height: 18),
                    Text('Security question: ${foundUser!.securityQuestion}',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    TextField(
                        controller: answerController,
                        decoration:
                            const InputDecoration(labelText: 'Your Answer')),
                    const SizedBox(height: 12),
                    TextField(
                        controller: newPasswordController,
                        obscureText: true,
                        decoration:
                            const InputDecoration(labelText: 'New Password')),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                          onPressed: loading ? null : _reset,
                          child: Text(
                              loading ? 'Resetting...' : 'Reset Password')),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
