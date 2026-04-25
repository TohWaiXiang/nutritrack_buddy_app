import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/app_models.dart';
import '../widgets/app_scope.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final controller = TextEditingController();
  final picker = ImagePicker();
  String? pickedImagePath;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final file = await picker.pickImage(source: source, imageQuality: 80);
    if (file != null) setState(() => pickedImagePath = file.path);
  }

  Future<void> _send([String? preset]) async {
    final text = (preset ?? controller.text).trim();
    if (text.isEmpty && pickedImagePath == null) return;
    final app = AppScope.of(context);
    final user = app.currentUser!;

    await app.addChatMessage(ChatMessage(
      isUser: true,
      text: text.isEmpty ? 'Hey Buddy! Is this healthy?' : text,
      imagePath: pickedImagePath,
    ));
    await app.addChatMessage(ChatMessage(isUser: false, text: _reply(user, text, pickedImagePath != null)));
    controller.clear();
    setState(() => pickedImagePath = null);
  }

  String _reply(UserProfile user, String text, bool hasImage) {
    final lower = text.toLowerCase();
    if (hasImage) {
      return '✅ Is It Healthy?\n\nGood points:\n• High protein✓\n\n• Not deep-fried✓\n\n• Has some vegetables✓\n\n• Balanced carbs + protein ✓\n\nLess healthy parts:\n• Sauce may contain sugar\n\n• Rice or skin can add extra fat\n\nThis can still fit your ${user.goalType.toLowerCase()} goal if portion is controlled.';
    }
    if (lower.contains('suggest') || lower.contains('meal')) {
      return 'AI food suggestion for ${user.dietPreference}: oatmeal, eggs, grilled chicken, tofu bowl, Greek yogurt, fruit, and salmon salad. These diet foods fit your TDEE of ${user.tdee} kcal.';
    }
    if (lower.contains('lose') || lower.contains('maintain') || lower.contains('gain')) {
      return 'For ${user.goalType.toLowerCase()} weight, keep meals simple: lean protein + vegetables + controlled carbs. Great options are chicken salad, tofu soup, eggs, yogurt, and fruit.';
    }
    return 'Hi Buddy! I can help with healthy food suggestions, AI food review, diet food, TDEE, and meal ideas. Upload a food photo or ask what you should eat today.';
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final messages = app.chat.isEmpty
        ? const [
            ChatMessage(
              isUser: false,
              text: 'Hi Buddy! I can help with healthy food suggestions, AI food review, diet food, TDEE, and meal ideas. Upload a food photo or ask what you should eat today.',
            )
          ]
        : app.chat;

    return Scaffold(
      appBar: AppBar(title: const Text('AI Chat')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
            child: const Column(
              children: [
                Text('AI Nutrition Assistant', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text('Scan or ask about your food'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(child: _chip('Healthy suggestion', () => _send('Give me a healthy suggestion.'))),
                const SizedBox(width: 8),
                Expanded(child: _chip('Diet food', () => _send('Suggest diet food for me.'))),
                const SizedBox(width: 8),
                Expanded(child: _chip('Food goal', () => _send('What should I eat for my goal?'))),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F0F1),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            if (msg.imagePath != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(File(msg.imagePath!), width: 210, height: 145, fit: BoxFit.cover),
                                ),
                              ),
                            if (!msg.isUser)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 6),
                                child: Row(children: [Icon(Icons.smart_toy_outlined), SizedBox(width: 8), Text('Buddy', style: TextStyle(fontWeight: FontWeight.w600))]),
                              ),
                            Text(msg.text, style: const TextStyle(fontSize: 15, height: 1.5)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (pickedImagePath != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(pickedImagePath!), width: 90, height: 90, fit: BoxFit.cover),
                ),
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 12),
              child: Row(
                children: [
                  IconButton(onPressed: () => _pick(ImageSource.gallery), icon: const Icon(Icons.image_outlined)),
                  IconButton(onPressed: () => _pick(ImageSource.camera), icon: const Icon(Icons.camera_alt_outlined)),
                  IconButton(onPressed: () => _send('I need a meal plan suggestion.'), icon: const Icon(Icons.mic_none_outlined)),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(hintText: 'Type your message...'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFE3E1E2),
                    child: IconButton(onPressed: _send, icon: const Icon(Icons.arrow_upward, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(color: const Color(0xFFF1EFF0), borderRadius: BorderRadius.circular(18)),
        alignment: Alignment.center,
        child: Text(text, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
      ),
    );
  }
}
