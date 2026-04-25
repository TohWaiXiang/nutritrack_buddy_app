import 'dart:convert';

class UserProfile {
  final String email;
  final String password;
  final String securityQuestion;
  final String securityAnswer;
  final String name;
  final int age;
  final String gender;
  final double heightCm;
  final double weightKg;
  final String diseases;
  final String difficulties;
  final int calorieGoal;
  final int proteinGoal;
  final int carbGoal;
  final int fatGoal;
  final double activityMultiplier;
  final String goalType;
  final String dietPreference;

  const UserProfile({
    required this.email,
    required this.password,
    required this.securityQuestion,
    required this.securityAnswer,
    this.name = '',
    this.age = 25,
    this.gender = 'Male',
    this.heightCm = 170,
    this.weightKg = 65,
    this.diseases = 'None',
    this.difficulties = 'None',
    this.calorieGoal = 1800,
    this.proteinGoal = 100,
    this.carbGoal = 250,
    this.fatGoal = 70,
    this.activityMultiplier = 1.55,
    this.goalType = 'Maintain',
    this.dietPreference = 'Balanced',
  });

  double get bmi {
    final meters = heightCm / 100;
    if (meters <= 0) return 0;
    return weightKg / (meters * meters);
  }

  double get bmr {
    final s = gender.toLowerCase() == 'female' ? -161 : 5;
    return (10 * weightKg) + (6.25 * heightCm) - (5 * age) + s;
  }

  int get tdee => (bmr * activityMultiplier).round();

  int get targetCalories {
    switch (goalType) {
      case 'Lose':
        return (tdee - 400).clamp(1200, 6000).toInt();
      case 'Gain':
        return (tdee + 300).clamp(1200, 6000).toInt();
      default:
        return tdee.clamp(1200, 6000).toInt();
    }
  }

  int get effectiveCalorieGoal => calorieGoal > 0 ? calorieGoal : targetCalories;

  UserProfile copyWith({
    String? email,
    String? password,
    String? securityQuestion,
    String? securityAnswer,
    String? name,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? diseases,
    String? difficulties,
    int? calorieGoal,
    int? proteinGoal,
    int? carbGoal,
    int? fatGoal,
    double? activityMultiplier,
    String? goalType,
    String? dietPreference,
  }) {
    return UserProfile(
      email: email ?? this.email,
      password: password ?? this.password,
      securityQuestion: securityQuestion ?? this.securityQuestion,
      securityAnswer: securityAnswer ?? this.securityAnswer,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      diseases: diseases ?? this.diseases,
      difficulties: difficulties ?? this.difficulties,
      calorieGoal: calorieGoal ?? this.calorieGoal,
      proteinGoal: proteinGoal ?? this.proteinGoal,
      carbGoal: carbGoal ?? this.carbGoal,
      fatGoal: fatGoal ?? this.fatGoal,
      activityMultiplier: activityMultiplier ?? this.activityMultiplier,
      goalType: goalType ?? this.goalType,
      dietPreference: dietPreference ?? this.dietPreference,
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'password': password,
        'securityQuestion': securityQuestion,
        'securityAnswer': securityAnswer,
        'name': name,
        'age': age,
        'gender': gender,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'diseases': diseases,
        'difficulties': difficulties,
        'calorieGoal': calorieGoal,
        'proteinGoal': proteinGoal,
        'carbGoal': carbGoal,
        'fatGoal': fatGoal,
        'activityMultiplier': activityMultiplier,
        'goalType': goalType,
        'dietPreference': dietPreference,
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        email: map['email'] ?? '',
        password: map['password'] ?? '',
        securityQuestion: map['securityQuestion'] ?? 'What is your favorite food?',
        securityAnswer: map['securityAnswer'] ?? '',
        name: map['name'] ?? '',
        age: map['age'] ?? 25,
        gender: map['gender'] ?? 'Male',
        heightCm: (map['heightCm'] ?? 170).toDouble(),
        weightKg: (map['weightKg'] ?? 65).toDouble(),
        diseases: map['diseases'] ?? 'None',
        difficulties: map['difficulties'] ?? 'None',
        calorieGoal: map['calorieGoal'] ?? 1800,
        proteinGoal: map['proteinGoal'] ?? 100,
        carbGoal: map['carbGoal'] ?? 250,
        fatGoal: map['fatGoal'] ?? 70,
        activityMultiplier: (map['activityMultiplier'] ?? 1.55).toDouble(),
        goalType: map['goalType'] ?? 'Maintain',
        dietPreference: map['dietPreference'] ?? 'Balanced',
      );

  String toJson() => jsonEncode(toMap());
  factory UserProfile.fromJson(String source) => UserProfile.fromMap(jsonDecode(source));
}

class MealEntry {
  final String id;
  final String category;
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  const MealEntry({
    required this.id,
    required this.category,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  MealEntry copyWith({
    String? id,
    String? category,
    String? name,
    int? calories,
    int? protein,
    int? carbs,
    int? fat,
  }) {
    return MealEntry(
      id: id ?? this.id,
      category: category ?? this.category,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'category': category,
        'name': name,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      };

  factory MealEntry.fromMap(Map<String, dynamic> map) => MealEntry(
        id: map['id'] ?? '',
        category: map['category'] ?? 'Breakfast',
        name: map['name'] ?? '',
        calories: map['calories'] ?? 0,
        protein: map['protein'] ?? 0,
        carbs: map['carbs'] ?? 0,
        fat: map['fat'] ?? 0,
      );
}

class GroceryItem {
  final String id;
  final String category;
  final String name;
  final String quantity;
  final bool purchased;

  const GroceryItem({
    required this.id,
    required this.category,
    required this.name,
    required this.quantity,
    this.purchased = false,
  });

  GroceryItem copyWith({
    String? id,
    String? category,
    String? name,
    String? quantity,
    bool? purchased,
  }) {
    return GroceryItem(
      id: id ?? this.id,
      category: category ?? this.category,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      purchased: purchased ?? this.purchased,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'category': category,
        'name': name,
        'quantity': quantity,
        'purchased': purchased,
      };

  factory GroceryItem.fromMap(Map<String, dynamic> map) => GroceryItem(
        id: map['id'] ?? '',
        category: map['category'] ?? 'Vegetables',
        name: map['name'] ?? '',
        quantity: map['quantity'] ?? '',
        purchased: map['purchased'] ?? false,
      );
}

class ChatMessage {
  final String text;
  final bool isUser;
  final String? imagePath;

  const ChatMessage({required this.text, required this.isUser, this.imagePath});

  Map<String, dynamic> toMap() => {
        'text': text,
        'isUser': isUser,
        'imagePath': imagePath,
      };

  factory ChatMessage.fromMap(Map<String, dynamic> map) => ChatMessage(
        text: map['text'] ?? '',
        isUser: map['isUser'] ?? false,
        imagePath: map['imagePath'],
      );
}

class ScreenshotNote {
  final String id;
  final String pageName;
  final String paragraph;
  final String imageBase64;
  final DateTime createdAt;

  const ScreenshotNote({
    required this.id,
    required this.pageName,
    required this.paragraph,
    required this.imageBase64,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        "id": id,
        "pageName": pageName,
        "paragraph": paragraph,
        "imageBase64": imageBase64,
        "createdAt": createdAt.toIso8601String(),
      };

  factory ScreenshotNote.fromMap(Map<String, dynamic> map) => ScreenshotNote(
        id: map["id"] ?? "",
        pageName: map["pageName"] ?? "Home Page",
        paragraph: map["paragraph"] ?? "",
        imageBase64: map["imageBase64"] ?? "",
        createdAt: DateTime.tryParse(map["createdAt"] ?? "") ?? DateTime.now(),
      );
}

class DaySummary {
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  const DaySummary({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}
