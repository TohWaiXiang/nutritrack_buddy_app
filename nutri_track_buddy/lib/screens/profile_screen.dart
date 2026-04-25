import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../widgets/app_scope.dart';
import 'screenshot_notes_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final user = app.currentUser!;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 138,
                  height: 138,
                  decoration: const BoxDecoration(
                      color: Color(0xFFD7C5EA), shape: BoxShape.circle),
                  child: const Icon(Icons.person_outline,
                      size: 74, color: Color(0xFF6B2E96)),
                ),
                const SizedBox(width: 22),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name.isEmpty ? 'Your Name' : user.name,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text(user.email, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    final updated = await showDialog<UserProfile>(
                        context: context,
                        builder: (_) => _EditProfileDialog(user: user));
                    if (updated != null) await app.saveProfile(updated);
                  },
                  style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24))),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Profile'),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _title('Personal Information'),
            _field('Name', user.name),
            _field('Age', '${user.age}'),
            _field('Gender', user.gender),
            const SizedBox(height: 18),
            _title('Body Measurements'),
            _field('Height', '${user.heightCm.toStringAsFixed(0)}cm'),
            _field('Weight', '${user.weightKg.toStringAsFixed(0)}kg'),
            _field('BMI', user.bmi.toStringAsFixed(1)),
            _field('TDEE', '${user.tdee} kcal'),
            const SizedBox(height: 18),
            _title('Goal & Diet Setup'),
            _field('Weight Goal', user.goalType),
            _field('Exercise Multiplier',
                user.activityMultiplier.toStringAsFixed(3)),
            _field('Diet Food', user.dietPreference),
            _field('Target Calories', '${user.calorieGoal} kcal'),
            _field('Target Protein', '${user.proteinGoal} g'),
            _field('Target Carbs', '${user.carbGoal} g'),
            _field('Target Fat', '${user.fatGoal} g'),
            const SizedBox(height: 18),
            _title('Health Information'),
            _field('Diseases', user.diseases),
            _field('Difficulties', user.difficulties),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ScreenshotNotesScreen()),
                ),
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Page Screenshot Notes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      );

  Widget _field(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          SizedBox(
              width: 112,
              child: Text(label, style: const TextStyle(fontSize: 16))),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade300)),
              child: Text(value.isEmpty ? '-' : value,
                  style: const TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditProfileDialog extends StatefulWidget {
  final UserProfile user;
  const _EditProfileDialog({required this.user});

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController nameController;
  late final TextEditingController ageController;
  late final TextEditingController heightController;
  late final TextEditingController weightController;
  late final TextEditingController diseasesController;
  late final TextEditingController difficultiesController;
  late final TextEditingController calorieController;
  late final TextEditingController proteinController;
  late final TextEditingController carbController;
  late final TextEditingController fatController;
  late String gender;
  late String goalType;
  late String dietPreference;
  late double activityMultiplier;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    nameController = TextEditingController(text: u.name);
    ageController = TextEditingController(text: '${u.age}');
    heightController =
        TextEditingController(text: '${u.heightCm.toStringAsFixed(0)}');
    weightController =
        TextEditingController(text: '${u.weightKg.toStringAsFixed(0)}');
    diseasesController = TextEditingController(text: u.diseases);
    difficultiesController = TextEditingController(text: u.difficulties);
    calorieController = TextEditingController(text: '${u.calorieGoal}');
    proteinController = TextEditingController(text: '${u.proteinGoal}');
    carbController = TextEditingController(text: '${u.carbGoal}');
    fatController = TextEditingController(text: '${u.fatGoal}');
    gender = u.gender;
    goalType = u.goalType;
    dietPreference = u.dietPreference;
    activityMultiplier = u.activityMultiplier;
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    diseasesController.dispose();
    difficultiesController.dispose();
    calorieController.dispose();
    proteinController.dispose();
    carbController.dispose();
    fatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final temp = widget.user.copyWith(
      age: int.tryParse(ageController.text) ?? widget.user.age,
      gender: gender,
      heightCm: double.tryParse(heightController.text) ?? widget.user.heightCm,
      weightKg: double.tryParse(weightController.text) ?? widget.user.weightKg,
      goalType: goalType,
      dietPreference: dietPreference,
      activityMultiplier: activityMultiplier,
    );

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Update Profile',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: TextField(
                        controller: ageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Age'))),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: gender,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: const ['Male', 'Female', 'Other']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => gender = v!),
                  ),
                )
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: TextField(
                        controller: heightController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Height (cm)'))),
                const SizedBox(width: 12),
                Expanded(
                    child: TextField(
                        controller: weightController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Weight (kg)'))),
              ]),
              const SizedBox(height: 12),
              DropdownButtonFormField<double>(
                value: activityMultiplier,
                decoration:
                    const InputDecoration(labelText: 'Exercise Multiplier'),
                items: const [
                  DropdownMenuItem(value: 1.2, child: Text('1.2 - Sedentary')),
                  DropdownMenuItem(
                      value: 1.375, child: Text('1.375 - Light exercise')),
                  DropdownMenuItem(
                      value: 1.55, child: Text('1.55 - Moderate exercise')),
                  DropdownMenuItem(
                      value: 1.725, child: Text('1.725 - Very active')),
                  DropdownMenuItem(value: 1.9, child: Text('1.9 - Athlete')),
                ],
                onChanged: (v) => setState(() => activityMultiplier = v!),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: goalType,
                    decoration: const InputDecoration(labelText: 'Weight Goal'),
                    items: const ['Lose', 'Maintain', 'Gain']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => goalType = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: dietPreference,
                    decoration: const InputDecoration(labelText: 'Diet Food'),
                    items: const [
                      'Balanced',
                      'High Protein',
                      'Low Carb',
                      'Vegetarian'
                    ]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => dietPreference = v!),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              Text('Estimated TDEE: ${temp.tdee} kcal',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              TextField(
                  controller: diseasesController,
                  decoration: const InputDecoration(labelText: 'Diseases')),
              const SizedBox(height: 12),
              TextField(
                  controller: difficultiesController,
                  decoration: const InputDecoration(
                      labelText: 'Difficulties / Allergies')),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: TextField(
                        controller: calorieController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: 'Calories Goal',
                            helperText:
                                'Suggested ${temp.targetCalories} kcal'))),
                const SizedBox(width: 12),
                Expanded(
                    child: TextField(
                        controller: proteinController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Protein Goal'))),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: TextField(
                        controller: carbController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Carb Goal'))),
                const SizedBox(width: 12),
                Expanded(
                    child: TextField(
                        controller: fatController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Fat Goal'))),
              ]),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      widget.user.copyWith(
                        name: nameController.text.trim(),
                        age:
                            int.tryParse(ageController.text) ?? widget.user.age,
                        gender: gender,
                        heightCm: double.tryParse(heightController.text) ??
                            widget.user.heightCm,
                        weightKg: double.tryParse(weightController.text) ??
                            widget.user.weightKg,
                        activityMultiplier: activityMultiplier,
                        goalType: goalType,
                        dietPreference: dietPreference,
                        diseases: diseasesController.text.trim(),
                        difficulties: difficultiesController.text.trim(),
                        calorieGoal: int.tryParse(calorieController.text) ??
                            widget.user.calorieGoal,
                        proteinGoal: int.tryParse(proteinController.text) ??
                            widget.user.proteinGoal,
                        carbGoal: int.tryParse(carbController.text) ??
                            widget.user.carbGoal,
                        fatGoal: int.tryParse(fatController.text) ??
                            widget.user.fatGoal,
                      ),
                    );
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
