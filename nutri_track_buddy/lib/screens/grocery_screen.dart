import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../widgets/app_scope.dart';

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({super.key});

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  String category = 'Vegetables';

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final items = app.groceries;
    final purchased = items.where((e) => e.purchased).length;
    final progress = items.isEmpty ? 0.0 : purchased / items.length;
    final groups = <String, List<GroceryItem>>{};
    for (final item in items) {
      groups.putIfAbsent(item.category, () => []).add(item);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Groceyr List Page')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          children: [
            const Text('Grocery List', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _box(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('$purchased / ${items.length} Items Purchased', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: progress, minHeight: 12, borderRadius: BorderRadius.circular(30)),
              ]),
            ),
            const SizedBox(height: 12),
            ...groups.entries.map(
              (entry) => _box(
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.key, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    ...entry.value.map(
                      (item) => Row(
                        children: [
                          Checkbox(value: item.purchased, onChanged: (v) => app.toggleGrocery(item.id, v ?? false)),
                          Expanded(child: Text(item.name, style: const TextStyle(fontSize: 16))),
                          Text(item.quantity, style: const TextStyle(fontSize: 16)),
                          IconButton(onPressed: () => app.removeGrocery(item.id), icon: const Icon(Icons.close)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _box(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ADD GROCERY ITEM', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Item Name'))),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: category,
                          decoration: const InputDecoration(labelText: 'Category'),
                          items: const ['Vegetables', 'Protein', 'Carbohydrates', 'Fruits', 'Others'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) => setState(() => category = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(width: 220, child: TextField(controller: quantityController, decoration: const InputDecoration(labelText: 'Quantity'))),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 114,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF3CAD7), foregroundColor: Colors.black87),
                          onPressed: () {
                            nameController.clear();
                            quantityController.clear();
                          },
                          child: const Text('Cancel'),
                        ),
                      ),
                      SizedBox(
                        width: 130,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF3CAD7), foregroundColor: Colors.black87),
                          onPressed: () async {
                            if (nameController.text.trim().isEmpty) return;
                            await app.addGrocery(GroceryItem(
                              id: DateTime.now().microsecondsSinceEpoch.toString(),
                              category: category,
                              name: nameController.text.trim(),
                              quantity: quantityController.text.trim(),
                            ));
                            nameController.clear();
                            quantityController.clear();
                          },
                          child: const Text('Add Item'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _box({required Widget child, EdgeInsetsGeometry? margin}) => Container(
        width: double.infinity,
        margin: margin,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), border: Border.all(color: Colors.grey.shade300)),
        child: child,
      );
}
