import 'package:flutter/material.dart';
import 'screens/auth_gate.dart';
import 'services/app_controller.dart';
import 'services/local_store.dart';
import 'widgets/app_scope.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NutriTrackApp());
}

class NutriTrackApp extends StatefulWidget {
  const NutriTrackApp({super.key});

  @override
  State<NutriTrackApp> createState() => _NutriTrackAppState();
}

class _NutriTrackAppState extends State<NutriTrackApp> {
  late final AppController controller;

  @override
  void initState() {
    super.initState();
    controller = AppController(LocalStore());
    controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: controller,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NutriTrack Buddy',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF9A5570)),
          scaffoldBackgroundColor: const Color(0xFFF7F5F6),
          useMaterial3: true,
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide:
                  const BorderSide(color: Color(0xFF9A5570), width: 1.4),
            ),
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
        home: const AuthGate(),
      ),
    );
  }
}
