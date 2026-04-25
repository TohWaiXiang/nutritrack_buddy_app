import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';

class LocalStore {
  static const _usersKey = 'users';
  static const _currentUserKey = 'current_user';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<Map<String, UserProfile>> _getUsers() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((key, value) =>
        MapEntry(key, UserProfile.fromMap(Map<String, dynamic>.from(value))));
  }

  Future<void> _saveUsers(Map<String, UserProfile> users) async {
    final prefs = await _prefs;
    final map = users.map((key, value) => MapEntry(key, value.toMap()));
    await prefs.setString(_usersKey, jsonEncode(map));
  }

  Future<bool> register(UserProfile user) async {
    final users = await _getUsers();
    if (users.containsKey(user.email.trim().toLowerCase())) return false;
    users[user.email.trim().toLowerCase()] =
        user.copyWith(email: user.email.trim().toLowerCase());
    await _saveUsers(users);
    await setCurrentUser(user.email.trim().toLowerCase());
    await seedDefaultsIfNeeded(user.email.trim().toLowerCase());
    return true;
  }

  Future<UserProfile?> login(String email, String password) async {
    final users = await _getUsers();
    final user = users[email.trim().toLowerCase()];
    if (user == null || user.password != password) return null;
    await setCurrentUser(user.email);
    await seedDefaultsIfNeeded(user.email);
    return user;
  }

  Future<UserProfile?> getCurrentUser() async {
    final prefs = await _prefs;
    final email = prefs.getString(_currentUserKey);
    if (email == null) return null;
    final users = await _getUsers();
    return users[email];
  }

  Future<void> setCurrentUser(String? email) async {
    final prefs = await _prefs;
    if (email == null) {
      await prefs.remove(_currentUserKey);
    } else {
      await prefs.setString(_currentUserKey, email);
    }
  }

  Future<void> logout() => setCurrentUser(null);

  Future<UserProfile?> findUser(String email) async {
    final users = await _getUsers();
    return users[email.trim().toLowerCase()];
  }

  Future<bool> resetPassword({
    required String email,
    required String answer,
    required String newPassword,
  }) async {
    final users = await _getUsers();
    final key = email.trim().toLowerCase();
    final user = users[key];
    if (user == null) return false;
    if (user.securityAnswer.trim().toLowerCase() != answer.trim().toLowerCase())
      return false;
    users[key] = user.copyWith(password: newPassword);
    await _saveUsers(users);
    return true;
  }

  Future<void> saveProfile(UserProfile profile) async {
    final users = await _getUsers();
    users[profile.email.trim().toLowerCase()] =
        profile.copyWith(email: profile.email.trim().toLowerCase());
    await _saveUsers(users);
  }

  String _mealsKey(String email) => 'meals_${email.toLowerCase()}';
  String _groceryKey(String email) => 'grocery_${email.toLowerCase()}';
  String _chatKey(String email) => 'chat_${email.toLowerCase()}';
  String _screenshotNotesKey(String email) =>
      'screenshot_notes_${email.toLowerCase()}';

  Future<Map<String, List<MealEntry>>> getMeals(String email) async {
    final prefs = await _prefs;
    final raw = prefs.getString(_mealsKey(email));
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(
          key,
          (value as List)
              .map((e) => MealEntry.fromMap(Map<String, dynamic>.from(e)))
              .toList(),
        ));
  }

  Future<void> saveMeals(
      String email, Map<String, List<MealEntry>> meals) async {
    final prefs = await _prefs;
    final encoded = meals.map(
        (key, value) => MapEntry(key, value.map((e) => e.toMap()).toList()));
    await prefs.setString(_mealsKey(email), jsonEncode(encoded));
  }

  Future<List<GroceryItem>> getGroceries(String email) async {
    final prefs = await _prefs;
    final raw = prefs.getString(_groceryKey(email));
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((e) => GroceryItem.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> saveGroceries(String email, List<GroceryItem> items) async {
    final prefs = await _prefs;
    await prefs.setString(
        _groceryKey(email), jsonEncode(items.map((e) => e.toMap()).toList()));
  }

  Future<List<ChatMessage>> getChat(String email) async {
    final prefs = await _prefs;
    final raw = prefs.getString(_chatKey(email));
    if (raw == null || raw.isEmpty) {
      return const [
        ChatMessage(
          isUser: false,
          text:
              'Hi Buddy! I can help you review meals, calories, protein, carbs, and fat. Ask me anything about your food.',
        ),
      ];
    }
    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((e) => ChatMessage.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> saveChat(String email, List<ChatMessage> chat) async {
    final prefs = await _prefs;
    await prefs.setString(
        _chatKey(email), jsonEncode(chat.map((e) => e.toMap()).toList()));
  }

  Future<List<ScreenshotNote>> getScreenshotNotes(String email) async {
    final prefs = await _prefs;
    final raw = prefs.getString(_screenshotNotesKey(email));
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((e) => ScreenshotNote.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> saveScreenshotNotes(
      String email, List<ScreenshotNote> notes) async {
    final prefs = await _prefs;
    await prefs.setString(_screenshotNotesKey(email),
        jsonEncode(notes.map((e) => e.toMap()).toList()));
  }

  Future<void> seedDefaultsIfNeeded(String email) async {
    final meals = await getMeals(email);
    if (meals.isEmpty) {
      final today = _dateKey(DateTime.now());
      meals[today] = [
        MealEntry(
          id: 'b1',
          category: 'Breakfast',
          name: 'Oatmeal with Banana',
          calories: 320,
          protein: 12,
          carbs: 52,
          fat: 8,
        ),
        MealEntry(
          id: 'l1',
          category: 'Lunch',
          name: 'Grilled Chicken Rice',
          calories: 550,
          protein: 32,
          carbs: 78,
          fat: 15,
        ),
        MealEntry(
          id: 'd1',
          category: 'Dinner',
          name: 'Salmon Salad Bowl',
          calories: 480,
          protein: 25,
          carbs: 40,
          fat: 18,
        ),
      ];
      await saveMeals(email, meals);
    }

    final groceries = await getGroceries(email);
    if (groceries.isEmpty) {
      await saveGroceries(email, [
        const GroceryItem(
            id: 'g1',
            category: 'Vegetables',
            name: 'Broccoli',
            quantity: '2 heads'),
        const GroceryItem(
            id: 'g2',
            category: 'Vegetables',
            name: 'Carrot',
            quantity: '500g',
            purchased: true),
        const GroceryItem(
            id: 'g3',
            category: 'Vegetables',
            name: 'Spinach',
            quantity: '1 pack'),
        const GroceryItem(
            id: 'g4',
            category: 'Protein',
            name: 'Chicken Breast',
            quantity: '500g',
            purchased: true),
        const GroceryItem(
            id: 'g5', category: 'Protein', name: 'Eggs', quantity: '12 pcs'),
        const GroceryItem(
            id: 'g6',
            category: 'Carbohydrates',
            name: 'Whole Wheat Bread',
            quantity: '1 loaf',
            purchased: true),
        const GroceryItem(
            id: 'g7',
            category: 'Carbohydrates',
            name: 'Brown Rice',
            quantity: '1 kg'),
      ]);
    }
  }

  static String dateKey(DateTime date) => _dateKey(date);

  static String _dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
