import 'package:flutter/material.dart';

class HabitCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const HabitCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  static final List<HabitCategory> predefinedCategories = [
    HabitCategory(
      id: 'health',
      name: 'Health',
      icon: Icons.favorite,
      color: Colors.blue,
    ),
    HabitCategory(
      id: 'fitness',
      name: 'Fitness',
      icon: Icons.fitness_center,
      color: Colors.red,
    ),
    HabitCategory(
      id: 'mental_health',
      name: 'Mental Health',
      icon: Icons.self_improvement,
      color: Colors.purple,
    ),
    HabitCategory(
      id: 'education',
      name: 'Education',
      icon: Icons.school,
      color: Colors.orange,
    ),
    HabitCategory(
      id: 'home',
      name: 'Home',
      icon: Icons.home,
      color: Colors.indigo,
    ),
    HabitCategory(
      id: 'pets',
      name: 'Pets',
      icon: Icons.pets,
      color: Colors.green,
    ),
    HabitCategory(
      id: 'self_care',
      name: 'Self Care',
      icon: Icons.spa,
      color: Colors.pink,
    ),
    HabitCategory(
      id: 'productivity',
      name: 'Productivity',
      icon: Icons.work,
      color: Colors.teal,
    ),
  ];

  static HabitCategory getById(String id) {
    return predefinedCategories.firstWhere(
      (category) => category.id == id,
      orElse: () => predefinedCategories.first,
    );
  }
}
