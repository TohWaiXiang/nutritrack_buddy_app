import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/app_models.dart';
import '../services/app_controller.dart';
import '../widgets/app_scope.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  DateTime selectedDate = DateTime.now();
  String generateMode = 'Daily';

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final user = app.currentUser!;
    final summary = app.summaryForDate(selectedDate);
    final meals = app.mealsForDate(selectedDate);

    return Scaffold(
      appBar: AppBar(title: const Text('Meal Planner Page')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          children: [
            const Text('Meal Planner 📅',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => setState(() => selectedDate =
                      selectedDate.subtract(const Duration(days: 1))),
                  icon: const Icon(Icons.chevron_left, size: 36),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF1EFF0),
                      borderRadius: BorderRadius.circular(22)),
                  child: Text(DateFormat('MMM d, yyyy').format(selectedDate),
                      style: const TextStyle(fontSize: 16)),
                ),
                IconButton(
                  onPressed: () => setState(() =>
                      selectedDate = selectedDate.add(const Duration(days: 1))),
                  icon: const Icon(Icons.chevron_right, size: 36),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Today's Total",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),
                  _line('Calories',
                      '${summary.calories}/${user.calorieGoal} kcal'),
                  _line(
                      'Protein', '${summary.protein}g / ${user.proteinGoal} g'),
                  _line('Carbs', '${summary.carbs}g / ${user.carbGoal} g'),
                  _line('Fat', '${summary.fat}g / ${user.fatGoal} g'),
                  const SizedBox(height: 18),
                  _bullet(
                      'You have ${(user.calorieGoal - summary.calories).clamp(0, 9999)} kcal remaining today.'),
                  _bullet(
                      'You still need ${(user.proteinGoal - summary.protein).clamp(0, 999)}g of protein to reach your goal.'),
                  _bullet(
                      '${(user.carbGoal - summary.carbs).clamp(0, 999)}g carbs and ${(user.fatGoal - summary.fat).clamp(0, 999)}g fat remaining.'),
                  _bullet(
                      'TDEE included: ${user.tdee} kcal | Goal: ${user.goalType} | Diet: ${user.dietPreference}'),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome),
                      SizedBox(width: 8),
                      Text('Generate Meal',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _modeButton('Daily'),
                      const SizedBox(width: 10),
                      _modeButton('Week'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (generateMode == 'Daily')
                    _dailyUI(user, summary)
                  else
                    _weekUI(user),
                ],
              ),
            ),
            const SizedBox(height: 18),
            ...['Breakfast', 'Lunch', 'Dinner', 'Snack'].map((category) {
              final list = meals.where((m) => m.category == category).toList();
              return _mealCard(context, app, category, list);
            }),
          ],
        ),
      ),
    );
  }

  Widget _modeButton(String mode) {
    final selected = generateMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => generateMode = mode),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF9A5570) : const Color(0xFFF1EFF0),
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.center,
          child: Text(mode,
              style: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _dailyUI(UserProfile user, DaySummary summary) {
    final leftProtein = (user.proteinGoal - summary.protein).clamp(0, 999);
    final leftCalories = (user.calorieGoal - summary.calories).clamp(0, 9999);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFFF7EEF1),
          borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${user.goalType} Weight | ${user.dietPreference}',
              style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
              'TDEE: ${user.tdee} kcal. Remaining today: $leftCalories kcal and $leftProtein g protein.',
              style: const TextStyle(height: 1.4)),
          const SizedBox(height: 10),
          Text(_dailyPlan(user), style: const TextStyle(height: 1.5)),
        ],
      ),
    );
  }

  String _dailyPlan(UserProfile user) {
    switch (user.dietPreference) {
      case 'Vegetarian':
        return 'Suggested daily meal: oatmeal with banana, tofu rice bowl, Greek yogurt, and lentil salad.';
      case 'Low Carb':
        return 'Suggested daily meal: eggs and avocado, grilled chicken salad, salmon with vegetables, and nuts.';
      case 'High Protein':
        return 'Suggested daily meal: protein yogurt, grilled chicken rice, tuna wrap, and eggs.';
      default:
        return 'Suggested daily meal: oatmeal with banana, grilled chicken rice, salmon salad, and yogurt snack.';
    }
  }

  Widget _weekUI(UserProfile user) {
    final plans = <String>[
      'Day 1  Oatmeal | Chicken rice | Yogurt | Salmon salad',
      'Day 2  Eggs | Tuna wrap | Fruit | Chicken bowl',
      'Day 3  Smoothie | Rice bowl | Nuts | Fish plate',
      'Day 4  Toast | Salad | Yogurt | Tofu bowl',
      'Day 5  Oats | Chicken salad | Milk | Shrimp rice',
      'Day 6  Porridge | Wrap | Fruit | Beef vegetables',
      'Day 7  Pancake | Rice bowl | Yogurt | Soup + protein',
    ];
    return Column(
      children: plans
          .map((e) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300)),
                child: Text(e),
              ))
          .toList(),
    );
  }

  Widget _mealCard(BuildContext context, AppController app, String category,
      List<MealEntry> items) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.grey.shade300)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(category,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          if (items.isEmpty)
            const Text('No meal added yet.')
          else
            ...items.map(
              (meal) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                          '${meal.name}  ${meal.calories} kcal\nP:${meal.protein}g  C:${meal.carbs}g  F:${meal.fat}g',
                          style: const TextStyle(fontSize: 15, height: 1.45)),
                    ),
                    IconButton(
                        onPressed: () => _openMealDialog(context, app, category,
                            existing: meal),
                        icon: const Icon(Icons.edit, color: Color(0xFF5B4A50))),
                  ],
                ),
              ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              decoration: BoxDecoration(
                  color: const Color(0xFFF1EFF0),
                  borderRadius: BorderRadius.circular(18)),
              child: TextButton(
                onPressed: () => _openMealDialog(context, app, category),
                child: Text('+ Add $category',
                    style: const TextStyle(color: Colors.black87)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openMealDialog(
      BuildContext context, AppController app, String category,
      {MealEntry? existing}) async {
    final name = TextEditingController(text: existing?.name ?? '');
    final cal =
        TextEditingController(text: existing?.calories.toString() ?? '');
    final protein =
        TextEditingController(text: existing?.protein.toString() ?? '');
    final carbs = TextEditingController(text: existing?.carbs.toString() ?? '');
    final fat = TextEditingController(text: existing?.fat.toString() ?? '');

    await showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 540,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
              color: const Color(0xFFF0E1E7),
              borderRadius: BorderRadius.circular(28)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$category Details',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w500)),
              const SizedBox(height: 16),
              _dialogField('Meal name', name),
              _dialogField('Calories (kcal)', cal, numeric: true),
              _dialogField('Protein (g)', protein, numeric: true),
              _dialogField('Carbs (g)', carbs, numeric: true),
              _dialogField('Fat (g)', fat, numeric: true),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (existing != null)
                    TextButton(
                      onPressed: () async {
                        await app.deleteMeal(selectedDate, existing.id);
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                      },
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.red)),
                    ),
                  TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancel',
                          style: TextStyle(color: Color(0xFF9A5570)))),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9A5570),
                        foregroundColor: Colors.white),
                    onPressed: () async {
                      await app.addOrUpdateMeal(
                        selectedDate,
                        MealEntry(
                          id: existing?.id ??
                              DateTime.now().microsecondsSinceEpoch.toString(),
                          category: category,
                          name: name.text.trim(),
                          calories: int.tryParse(cal.text) ?? 0,
                          protein: int.tryParse(protein.text) ?? 0,
                          carbs: int.tryParse(carbs.text) ?? 0,
                          fat: int.tryParse(fat.text) ?? 0,
                        ),
                      );
                      if (dialogContext.mounted) Navigator.pop(dialogContext);
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dialogField(String label, TextEditingController controller,
      {bool numeric = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label, fillColor: Colors.white),
      ),
    );
  }

  Widget _line(String left, String right) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
              width: 140,
              child: Text(left, style: const TextStyle(fontSize: 16))),
          Expanded(
              child: Text(':  $right', style: const TextStyle(fontSize: 16)))
        ],
      ),
    );
  }

  Widget _bullet(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text('• $text', style: const TextStyle(fontSize: 15)));

  Widget _panel({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.grey.shade300)),
        child: child,
      );
}
