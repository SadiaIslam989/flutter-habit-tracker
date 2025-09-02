import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:habit_tracker/models/habit_category.dart';
import 'add_edit_habit_screen.dart';

class HabitScreen extends StatefulWidget {
  const HabitScreen({super.key});

  @override
  State<HabitScreen> createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;

  late final Timer _timer;
  final List<String> _weekDays = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

  List<DateTime> get _weekDates {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  Future<void> _toggleHabitCompletion(
      String habitId, Map<String, dynamic> habitData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final selectedDay = DateFormat('yyyy-MM-dd').format(_selectedDate);

      if (today != selectedDay) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You can only mark habits for the current day'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final completionHistory =
          List<dynamic>.from(habitData['completionHistory'] ?? []);

      final alreadyCompletedToday = completionHistory.any((date) {
        final dateStr = date is Timestamp
            ? DateFormat('yyyy-MM-dd').format(date.toDate())
            : date.toString().substring(0, 10);
        return dateStr == today;
      });

      if (alreadyCompletedToday) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Habit already completed today!'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      completionHistory.add(DateTime.now());

      int currentStreak = (habitData['currentStreak'] ?? 0) + 1;

      if (currentStreak >= 7) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Congratulations! You\'ve completed this habit\'s 7-day goal! 🎉'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .doc(habitId)
          .update({
        'completionHistory': FieldValue.arrayUnion([DateTime.now()]),
        'currentStreak': currentStreak,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Habit completed! Keep it up!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _checkAndCreateDefaultHabits();

    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _checkAndCreateDefaultHabits() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final habitsRef =
        _firestore.collection('users').doc(user.uid).collection('habits');
    final habits = await habitsRef.get();

    if (habits.docs.isEmpty) {
      final defaultHabits = [
        {
          'title': 'Read',
          'category': 'Self Care',
          'frequency': 'Daily',
          'creationDate': FieldValue.serverTimestamp(),
          'currentStreak': 0,
          'notes': 'Read for at least 30 minutes',
          'completionHistory': [],
          'icon': '📚',
          'color': 0xFFBA68C8,
        },
        {
          'title': 'Brush & floss',
          'category': 'Health',
          'frequency': 'Daily',
          'creationDate': FieldValue.serverTimestamp(),
          'currentStreak': 0,
          'notes': 'Maintain dental hygiene',
          'completionHistory': [],
          'icon': '🦷',
          'color': 0xFF64B5F6,
        },
        {
          'title': 'Do morning exercises',
          'category': 'Fitness',
          'frequency': 'Daily',
          'creationDate': FieldValue.serverTimestamp(),
          'currentStreak': 0,
          'notes': '15 minutes of morning workout',
          'completionHistory': [],
          'icon': '💪',
          'color': 0xFFEF5350,
        },
        {
          'title': 'Drink water',
          'category': 'Health',
          'frequency': 'Daily',
          'creationDate': FieldValue.serverTimestamp(),
          'currentStreak': 0,
          'notes': 'Drink 8 glasses of water',
          'completionHistory': [],
          'icon': '💧',
          'color': 0xFF64B5F6,
        },
      ];

      for (var habit in defaultHabits) {
        await habitsRef.add(habit);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Habits",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _weekDates.map((date) {
                  final today = DateTime.now();
                  final isSelected = DateFormat('yyyy-MM-dd').format(date) ==
                      DateFormat('yyyy-MM-dd').format(_selectedDate);
                  final isToday = DateFormat('yyyy-MM-dd').format(date) ==
                      DateFormat('yyyy-MM-dd').format(today);

                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedDate = date),
                      child: Container(
                        width: 46,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : (isToday
                                  ? Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1)
                                  : null),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _weekDays[date.weekday % 7],
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? Colors.white
                                    : Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              date.day.toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                                color: isSelected
                                    ? Colors.white
                                    : Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Category Filter
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: _selectedCategory == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = null;
                      });
                    },
                  ),
                ),
                ...HabitCategory.predefinedCategories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(category.name),
                      selected: _selectedCategory == category.name,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedCategory = category.name;
                          }
                        });
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _selectedCategory == null
                  ? _firestore
                      .collection('users')
                      .doc(_auth.currentUser?.uid)
                      .collection('habits')
                      .snapshots()
                  : _firestore
                      .collection('users')
                      .doc(_auth.currentUser?.uid)
                      .collection('habits')
                      .where('category', isEqualTo: _selectedCategory)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_task, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _selectedCategory == null
                              ? 'No habits yet'
                              : 'No habits in this category',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddEditHabitScreen(),
                              ),
                            );
                          },
                          child: const Text('Add your first habit'),
                        ),
                      ],
                    ),
                  );
                }

                final habits = snapshot.data!.docs;
                final today = DateFormat('yyyy-MM-dd').format(_selectedDate);

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    final habit = habits[index];
                    final habitData = habit.data() as Map<String, dynamic>;
                    final completionHistory =
                        List<dynamic>.from(habitData['completionHistory'] ?? []);

                    final isCompletedToday = completionHistory.any((date) {
                      final dateStr = date is Timestamp
                          ? DateFormat('yyyy-MM-dd').format(date.toDate())
                          : date.toString().substring(0, 10);
                      return dateStr == today;
                    });

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditHabitScreen(
                              habit: {
                                'id': habit.id,
                                ...habitData,
                              },
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Color(habitData['color'] ?? 0xFF64B5F6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      habitData['icon'] ?? '📝',
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                  ),
                                ),
                                if (index != habits.length - 1)
                                  Container(
                                    width: 2,
                                    height: 60,
                                    color: Colors.grey.shade400,
                                  ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    habitData['title'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      decoration: isCompletedToday
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Category: ${habitData['category']}",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  if ((habitData['notes'] ?? '').isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      habitData['notes'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _toggleHabitCompletion(
                                  habit.id,
                                  habitData,
                                );
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isCompletedToday
                                      ? Colors.green
                                      : Colors.grey.shade300,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditHabitScreen(),
            ),
          );
        },
        backgroundColor: const Color.fromARGB(255, 156, 65, 184),
        child: const Icon(Icons.add),
      ),
    );
  }
}