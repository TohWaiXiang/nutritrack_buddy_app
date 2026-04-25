import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/app_models.dart';
import '../widgets/app_scope.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final user = app.currentUser!;
    final summary = app.summaryForDate(selectedDate);

    return Scaffold(
      appBar: AppBar(title: const Text('Main Page')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back, ${user.name.trim().isEmpty ? 'Buddy' : user.name}👋',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 22),
            const Text('MEAL HISTORY',
                style: TextStyle(fontSize: 16, letterSpacing: 0.5)),
            const SizedBox(height: 14),
            _card(
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() => selectedDate = DateTime(
                            selectedDate.year,
                            selectedDate.month - 1,
                            selectedDate.day)),
                        icon: const Icon(Icons.chevron_left, size: 36),
                      ),
                      const Spacer(),
                      _pillWithArrow(DateFormat('MMM').format(selectedDate)),
                      const SizedBox(width: 12),
                      _pillWithArrow('${selectedDate.year}'),
                      const Spacer(),
                      IconButton(
                        onPressed: () => setState(() => selectedDate = DateTime(
                            selectedDate.year,
                            selectedDate.month + 1,
                            selectedDate.day)),
                        icon: const Icon(Icons.chevron_right, size: 36),
                      ),
                    ],
                  ),
                  Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: Theme.of(context).colorScheme.copyWith(
                          primary: Colors.black, onPrimary: Colors.white),
                    ),
                    child: CalendarDatePicker(
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                      currentDate: DateTime.now(),
                      onDateChanged: (d) => setState(() => selectedDate = d),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TARGET TODAY',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text('Calories', style: TextStyle(fontSize: 16)),
                      const Spacer(),
                      Text('${summary.calories}/${user.calorieGoal} kcal',
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: user.calorieGoal == 0
                          ? 0
                          : (summary.calories / user.calorieGoal)
                              .clamp(0, 1)
                              .toDouble(),
                      minHeight: 10,
                      valueColor:
                          const AlwaysStoppedAnimation(Color(0xFF9A5570)),
                      backgroundColor: const Color(0xFFF1CAD7),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                          child: _macro('Fat', summary.fat, user.fatGoal,
                              const Color(0xFFF5C000))),
                      Expanded(
                          child: _macro('Protein', summary.protein,
                              user.proteinGoal, const Color(0xFF2C8AE8))),
                      Expanded(
                          child: _macro('Carb', summary.carbs, user.carbGoal,
                              const Color(0xFFFF9D00))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('AI FOOD SUGGESTION',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 10),
                        Text(_suggestion(user, summary),
                            style: const TextStyle(height: 1.45)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _suggestion(UserProfile user, DaySummary summary) {
    final proteinLeft = (user.proteinGoal - summary.protein).clamp(0, 999);
    final caloriesLeft = (user.calorieGoal - summary.calories).clamp(0, 9999);
    final goal = user.goalType.toLowerCase();
    final diet = user.dietPreference;
    if (diet == 'Vegetarian') {
      return 'TDEE ${user.tdee} kcal. For your $goal goal, try tofu bowl, Greek yogurt, oats, tempeh, beans, and fruit. You still have $caloriesLeft kcal and about $proteinLeft g protein left today.';
    }
    if (diet == 'Low Carb') {
      return 'TDEE ${user.tdee} kcal. For your $goal goal, choose eggs, grilled chicken salad, salmon, tofu, avocado, and vegetables. Keep carbs lighter for the rest of the day.';
    }
    if (diet == 'High Protein') {
      return 'TDEE ${user.tdee} kcal. Since you still need around $proteinLeft g protein, choose chicken breast, tuna, eggs, tofu, and protein yogurt. These diet foods fit your current target well.';
    }
    return 'TDEE ${user.tdee} kcal. Balanced suggestion: oatmeal banana breakfast, grilled chicken rice lunch, salmon salad dinner, and yogurt snack. This suits a $goal plan and keeps nutrition balanced.';
  }

  Widget _pillWithArrow(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      decoration: BoxDecoration(
          color: const Color(0xFFF1EFF0),
          borderRadius: BorderRadius.circular(18)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          const Icon(Icons.keyboard_arrow_down)
        ],
      ),
    );
  }

  Widget _macro(String title, int value, int goal, Color color) {
    final progress = goal == 0 ? 0.0 : (value / goal).clamp(0, 1).toDouble();
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 15)),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text('${value}g/${goal}g', style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: child,
    );
  }
}
