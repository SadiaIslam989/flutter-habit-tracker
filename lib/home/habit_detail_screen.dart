import 'package:flutter/material.dart';
import '../models/habit.dart';
import 'package:uuid/uuid.dart'; 

class HabitDetailScreen extends StatefulWidget {
  final Habit? habit;

  const HabitDetailScreen({super.key, this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String category = 'Health';
  String frequency = 'Daily';
  DateTime? startDate;
  final _notesController = TextEditingController();

  final categories = ['Health', 'Study', 'Fitness', 'Productivity'];
  final frequencies = ['Daily', 'Weekly'];

  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
      _titleController.text = widget.habit!.title;
      category = widget.habit!.category;
      frequency = widget.habit!.frequency;
      startDate = widget.habit!.startDate;
      _notesController.text = widget.habit!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveHabit() {
    if (!_formKey.currentState!.validate()) return;

    final habit = Habit(
      id: widget.habit?.id ?? const Uuid().v4(),
      title: _titleController.text,
      category: category,
      frequency: frequency,
      startDate: startDate,
      notes: _notesController.text,
    );

    Navigator.pop(context, habit); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit != null ? 'Edit Habit' : 'New Habit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Title required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => category = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: frequency,
                decoration: const InputDecoration(labelText: 'Frequency'),
                items: frequencies
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (v) => setState(() => frequency = v!),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(startDate != null
                    ? 'Start Date: ${startDate!.toLocal().toString().split(' ')[0]}'
                    : 'Start Date'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: startDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => startDate = picked);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveHabit,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
