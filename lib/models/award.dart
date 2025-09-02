import 'package:flutter/material.dart';

class Award {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool earned;

  Award({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.earned = false,
  });
}
