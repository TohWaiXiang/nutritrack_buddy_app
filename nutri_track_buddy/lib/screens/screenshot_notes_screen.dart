import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/app_models.dart';
import '../widgets/app_scope.dart';

class ScreenshotNotesScreen extends StatelessWidget {
  const ScreenshotNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final notes = app.screenshotNotes;

    return Scaffold(
      appBar: AppBar(title: const Text('Page Screenshot Notes')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF9EEF3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Demonstration Screenshot Part',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  SizedBox(height: 8),
                  Text(
                    'Add a screenshot of the related page and write the paragraph that explains the function. This can help make the report demonstration clearer.',
                    style: TextStyle(fontSize: 15, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _showAddDialog(context),
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Add Screenshot Paragraph'),
              ),
            ),
            const SizedBox(height: 18),
            if (notes.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Text('No screenshot paragraph added yet.'),
              )
            else
              ...notes.map((note) => _NoteCard(note: note)),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final app = AppScope.of(context);
    final pageController = TextEditingController(text: 'Home Page');
    final paragraphController = TextEditingController();
    String? imageBase64;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Add Screenshot Paragraph',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: pageController.text,
                    decoration:
                        const InputDecoration(labelText: 'Related Page'),
                    items: const [
                      'Login Page',
                      'Home Page',
                      'Meal Planner Page',
                      'AI Chat Page',
                      'Grocery List Page',
                      'Profile Page'
                    ]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => pageController.text = v ?? 'Home Page',
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: paragraphController,
                    minLines: 4,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      labelText: 'Paragraph / Explanation',
                      hintText:
                          'Example: This page shows the user daily nutrition summary and meal history calendar.',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await ImagePicker().pickImage(
                          source: ImageSource.gallery, imageQuality: 75);
                      if (picked == null) return;
                      final bytes = await picked.readAsBytes();
                      setState(() => imageBase64 = base64Encode(bytes));
                    },
                    icon: const Icon(Icons.image_outlined),
                    label: Text(imageBase64 == null
                        ? 'Select Screenshot'
                        : 'Screenshot Selected'),
                  ),
                  if (imageBase64 != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.memory(base64Decode(imageBase64!),
                          height: 180, fit: BoxFit.cover),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Cancel')),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          if (paragraphController.text.trim().isEmpty ||
                              imageBase64 == null) return;
                          await app.addScreenshotNote(
                            ScreenshotNote(
                              id: DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                              pageName: pageController.text,
                              paragraph: paragraphController.text.trim(),
                              imageBase64: imageBase64!,
                              createdAt: DateTime.now(),
                            ),
                          );
                          if (dialogContext.mounted)
                            Navigator.pop(dialogContext);
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );

    pageController.dispose();
    paragraphController.dispose();
  }
}

class _NoteCard extends StatelessWidget {
  final ScreenshotNote note;
  const _NoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(note.pageName,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700))),
              IconButton(
                onPressed: () => app.deleteScreenshotNote(note.id),
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              ),
            ],
          ),
          Text(DateFormat('MMM d, yyyy h:mm a').format(note.createdAt),
              style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.memory(base64Decode(note.imageBase64),
                width: double.infinity, height: 260, fit: BoxFit.cover),
          ),
          const SizedBox(height: 12),
          Text(note.paragraph,
              style: const TextStyle(fontSize: 15, height: 1.45)),
        ],
      ),
    );
  }
}
