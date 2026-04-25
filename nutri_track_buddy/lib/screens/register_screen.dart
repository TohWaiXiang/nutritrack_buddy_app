import 'package:flutter/material.dart';
import '../widgets/app_scope.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final answerController = TextEditingController();
  final questions = const [
    'What is your favorite food?',
    'What is your childhood nickname?',
    'What city were you born in?',
  ];
  String question = 'What is your favorite food?';
  bool loading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    answerController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (passwordController.text != confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')));
      return;
    }
    if (answerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please set a security answer')));
      return;
    }
    setState(() => loading = true);
    final error = await AppScope.of(context).register(
      email: emailController.text,
      password: passwordController.text,
      securityQuestion: question,
      securityAnswer: answerController.text,
    );
    if (!mounted) return;
    setState(() => loading = false);
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Create your NutriTrack Buddy account',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 24),
                  TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email')),
                  const SizedBox(height: 16),
                  TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password')),
                  const SizedBox(height: 16),
                  TextField(
                      controller: confirmController,
                      obscureText: true,
                      decoration:
                          const InputDecoration(labelText: 'Confirm Password')),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: question,
                    items: questions
                        .map((q) => DropdownMenuItem(value: q, child: Text(q)))
                        .toList(),
                    onChanged: (v) => setState(() => question = v!),
                    decoration:
                        const InputDecoration(labelText: 'Security Question'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                      controller: answerController,
                      decoration:
                          const InputDecoration(labelText: 'Security Answer')),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton(
                        onPressed: loading ? null : _register,
                        child: Text(
                            loading ? 'Please wait...' : 'Create Account')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
