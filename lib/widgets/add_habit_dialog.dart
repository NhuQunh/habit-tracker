import 'package:flutter/material.dart';
import 'package:habit_tracker/controllers/habit_controller.dart';
import 'package:habit_tracker/controllers/localization_provider.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:provider/provider.dart';

class AddHabitDialog extends StatefulWidget {
  const AddHabitDialog({super.key});

  @override
  State<AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<AddHabitDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final newHabit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      streak: 0,
      completedToday: false,
      category: _selectedCategory!,
      startDate: _selectedDate,
    );

    await context.read<HabitController>().addHabit(newHabit);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final localizationProvider = context.watch<LocalizationProvider>();
    final lightBlue = Colors.lightBlue.shade100;
    final bluePrimary = Colors.lightBlue.shade700;
    final categories = [
      localizationProvider.translate('category_health'),
      localizationProvider.translate('category_learning'),
      localizationProvider.translate('category_productivity'),
      localizationProvider.translate('category_mindfulness'),
    ];

    return AlertDialog(
      backgroundColor: Colors.lightBlue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.add_task_rounded, color: bluePrimary),
          const SizedBox(width: 8),
          Text(
            localizationProvider.translate('add_habit_title'),
            style: TextStyle(color: bluePrimary, fontWeight: FontWeight.w700),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: localizationProvider.translate('habit_name'),
                  hintText: localizationProvider.translate('habit_name_hint'),
                  filled: true,
                  fillColor: lightBlue.withValues(alpha: 0.35),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return localizationProvider.translate('habit_name_required');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: localizationProvider.translate('start_date'),
                    filled: true,
                    fillColor: lightBlue.withValues(alpha: 0.35),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: Icon(
                      Icons.calendar_month_rounded,
                      color: bluePrimary,
                    ),
                  ),
                  child: Text(_formatDate(_selectedDate)),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: localizationProvider.translate('category'),
                  filled: true,
                  fillColor: lightBlue.withValues(alpha: 0.35),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: categories
                    .map(
                      (category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizationProvider.translate('category_required');
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            localizationProvider.translate('cancel'),
            style: TextStyle(color: Colors.blueGrey.shade700),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _saveHabit,
          icon: const Icon(Icons.save_rounded, size: 18),
          label: Text(localizationProvider.translate('save')),
          style: ElevatedButton.styleFrom(
            backgroundColor: bluePrimary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
