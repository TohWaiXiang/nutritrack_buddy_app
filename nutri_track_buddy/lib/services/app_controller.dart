import 'package:flutter/material.dart';
import '../models/app_models.dart';
import 'local_store.dart';

class AppController extends ChangeNotifier {
  final LocalStore store;
  AppController(this.store);

  bool initialized = false;
  UserProfile? currentUser;
  Map<String, List<MealEntry>> mealsByDate = {};
  List<GroceryItem> groceries = [];
  List<ChatMessage> chat = [];
  List<ScreenshotNote> screenshotNotes = [];

  Future<void> initialize() async {
    currentUser = await store.getCurrentUser();
    if (currentUser != null) {
      mealsByDate = await store.getMeals(currentUser!.email);
      groceries = await store.getGroceries(currentUser!.email);
      chat = await store.getChat(currentUser!.email);
      screenshotNotes = await store.getScreenshotNotes(currentUser!.email);
      await _ensureWelcomeMessage();
    }
    initialized = true;
    notifyListeners();
  }

  Future<void> _ensureWelcomeMessage() async {
    if (currentUser == null) return;
    if (chat.isEmpty) {
      chat = [
        ChatMessage(
          isUser: false,
          text:
              'Hi Buddy! I can help with healthy food suggestions, diet meals, calorie targets, and quick food reviews. Upload a food photo or ask me what to eat today.',
        ),
      ];
      await store.saveChat(currentUser!.email, chat);
    }
  }

  Future<String?> register({
    required String email,
    required String password,
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      return 'Email and password are required.';
    }
    final user = UserProfile(
      email: email.trim().toLowerCase(),
      password: password,
      securityQuestion: securityQuestion,
      securityAnswer: securityAnswer.trim(),
    );
    final ok = await store.register(user);
    if (!ok) return 'This email is already registered.';
    currentUser = await store.getCurrentUser();
    mealsByDate = await store.getMeals(currentUser!.email);
    groceries = await store.getGroceries(currentUser!.email);
    chat = await store.getChat(currentUser!.email);
    screenshotNotes = await store.getScreenshotNotes(currentUser!.email);
    await _ensureWelcomeMessage();
    notifyListeners();
    return null;
  }

  Future<String?> login(String email, String password) async {
    final user = await store.login(email, password);
    if (user == null) return 'Invalid email or password.';
    currentUser = user;
    mealsByDate = await store.getMeals(currentUser!.email);
    groceries = await store.getGroceries(currentUser!.email);
    chat = await store.getChat(currentUser!.email);
    screenshotNotes = await store.getScreenshotNotes(currentUser!.email);
    await _ensureWelcomeMessage();
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    await store.logout();
    currentUser = null;
    mealsByDate = {};
    groceries = [];
    chat = [];
    screenshotNotes = [];
    notifyListeners();
  }

  Future<void> saveProfile(UserProfile profile) async {
    currentUser = profile;
    await store.saveProfile(profile);
    notifyListeners();
  }

  Future<String?> resetPassword(
      String email, String answer, String newPassword) async {
    final ok = await store.resetPassword(
        email: email, answer: answer, newPassword: newPassword);
    return ok
        ? null
        : 'Failed to reset password. Check your email and security answer.';
  }

  Future<UserProfile?> findUser(String email) => store.findUser(email);

  List<MealEntry> mealsForDate(DateTime date) =>
      mealsByDate[LocalStore.dateKey(date)] ?? [];

  DaySummary summaryForDate(DateTime date) {
    final meals = mealsForDate(date);
    return DaySummary(
      calories: meals.fold(0, (sum, item) => sum + item.calories),
      protein: meals.fold(0, (sum, item) => sum + item.protein),
      carbs: meals.fold(0, (sum, item) => sum + item.carbs),
      fat: meals.fold(0, (sum, item) => sum + item.fat),
    );
  }

  Future<void> addOrUpdateMeal(DateTime date, MealEntry meal) async {
    final key = LocalStore.dateKey(date);
    final list = List<MealEntry>.from(mealsByDate[key] ?? []);
    final index = list.indexWhere((e) => e.id == meal.id);
    if (index >= 0) {
      list[index] = meal;
    } else {
      list.add(meal);
    }
    mealsByDate[key] = list;
    await store.saveMeals(currentUser!.email, mealsByDate);
    notifyListeners();
  }

  Future<void> deleteMeal(DateTime date, String id) async {
    final key = LocalStore.dateKey(date);
    final list = List<MealEntry>.from(mealsByDate[key] ?? []);
    list.removeWhere((e) => e.id == id);
    mealsByDate[key] = list;
    await store.saveMeals(currentUser!.email, mealsByDate);
    notifyListeners();
  }

  Future<void> addGrocery(GroceryItem item) async {
    groceries = [...groceries, item];
    await store.saveGroceries(currentUser!.email, groceries);
    notifyListeners();
  }

  Future<void> toggleGrocery(String id, bool value) async {
    groceries = groceries
        .map((e) => e.id == id ? e.copyWith(purchased: value) : e)
        .toList();
    await store.saveGroceries(currentUser!.email, groceries);
    notifyListeners();
  }

  Future<void> removeGrocery(String id) async {
    groceries = groceries.where((e) => e.id != id).toList();
    await store.saveGroceries(currentUser!.email, groceries);
    notifyListeners();
  }

  Future<void> addChatMessage(ChatMessage message) async {
    chat = [...chat, message];
    await store.saveChat(currentUser!.email, chat);
    notifyListeners();
  }

  Future<void> replaceChat(List<ChatMessage> messages) async {
    chat = messages;
    await store.saveChat(currentUser!.email, chat);
    notifyListeners();
  }

  Future<void> addScreenshotNote(ScreenshotNote note) async {
    screenshotNotes = [...screenshotNotes, note];
    await store.saveScreenshotNotes(currentUser!.email, screenshotNotes);
    notifyListeners();
  }

  Future<void> deleteScreenshotNote(String id) async {
    screenshotNotes = screenshotNotes.where((e) => e.id != id).toList();
    await store.saveScreenshotNotes(currentUser!.email, screenshotNotes);
    notifyListeners();
  }
}
