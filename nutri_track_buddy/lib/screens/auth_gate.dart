import 'package:flutter/material.dart';

import '../widgets/app_scope.dart';
import 'login_screen.dart';
import 'main_shell.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    if (!controller.initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return controller.currentUser == null ? const LoginScreen() : const MainShell();
  }
}
