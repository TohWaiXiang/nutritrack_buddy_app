import 'package:flutter/material.dart';
import 'ai_chat_screen.dart';
import 'grocery_screen.dart';
import 'home_screen.dart';
import 'planner_screen.dart';
import 'profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      const PlannerScreen(),
      const AIChatScreen(),
      const GroceryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F5F6),
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_filled, 'Home'),
              _navItem(1, Icons.edit_calendar_outlined, 'Planner'),
              _navItem(2, Icons.smart_toy_outlined, 'AI'),
              _navItem(3, Icons.shopping_cart_outlined, 'Grocery'),
              _navItem(4, Icons.person_outline, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int itemIndex, IconData icon, String label) {
    final selected = index == itemIndex;
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: () => setState(() => index = itemIndex),
      child: SizedBox(
        width: 84,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFEDE9EB) : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, color: const Color(0xFF5B4A50), size: 28),
            ),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(fontSize: 13, color: Color(0xFF5B4A50))),
          ],
        ),
      ),
    );
  }
}
