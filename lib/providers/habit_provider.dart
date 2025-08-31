import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/habit.dart';

class HabitProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String? _error;
  List<Habit> _habits = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Habit> get habits => _habits;

  Future<void> addHabit(Habit habit) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) throw Exception('No authenticated user found');

      final docRef = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .add(habit.toMap());

      final newHabit = Habit(
        id: docRef.id,
        title: habit.title,
        category: habit.category,
        frequency: habit.frequency,
        startDate: habit.startDate,
        notes: habit.notes,
        completedCount: habit.completedCount,
        targetCount: habit.targetCount,
        timeSpentMinutes: habit.timeSpentMinutes,
        completionDates: habit.completionDates,
        lastCompletedDate: habit.lastCompletedDate,
      );

      _habits.add(newHabit);
    } catch (e) {
      _error = e.toString();
      print('Error adding habit: $e');
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateHabit(Habit habit) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) throw Exception('No authenticated user found');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .doc(habit.id)
          .update(habit.toMap());

      final index = _habits.indexWhere((h) => h.id == habit.id);
      if (index != -1) {
        _habits[index] = habit;
      }
    } catch (e) {
      _error = e.toString();
      print('Error updating habit: $e');
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteHabit(String habitId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) throw Exception('No authenticated user found');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .doc(habitId)
          .delete();

      _habits.removeWhere((h) => h.id == habitId);
    } catch (e) {
      _error = e.toString();
      print('Error deleting habit: $e');
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadHabits() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) throw Exception('No authenticated user found');

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .get();

      _habits = snapshot.docs.map((doc) => Habit.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      _error = e.toString();
      print('Error loading habits: $e');
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleHabitCompletion(String habitId, DateTime date) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) throw Exception('No authenticated user found');

      final habitDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .doc(habitId)
          .get();

      if (!habitDoc.exists) throw Exception('Habit not found');

  
      final existingHabit = Habit.fromMap(habitDoc.data()!, habitDoc.id);
      final completionDates = List<DateTime>.from(existingHabit.completionDates);
      
     
      final dateString = date.toString().split(' ')[0];
      final existingIndex = completionDates.indexWhere(
        (d) => d.toString().split(' ')[0] == dateString
      );

      if (existingIndex != -1) {
        completionDates.removeAt(existingIndex);
      } else {
        completionDates.add(date);
      }

      completionDates.sort();
      final lastCompletedDate = completionDates.isNotEmpty ? completionDates.last : null;
      final completedCount = completionDates.length;

      // habit
      final updatedHabit = Habit(
        id: existingHabit.id,
        title: existingHabit.title,
        category: existingHabit.category,
        frequency: existingHabit.frequency,
        startDate: existingHabit.startDate,
        notes: existingHabit.notes,
        completedCount: completedCount,
        targetCount: existingHabit.targetCount,
        timeSpentMinutes: existingHabit.timeSpentMinutes,
        completionDates: completionDates,
        lastCompletedDate: lastCompletedDate,
      );

      await habitDoc.reference.update(updatedHabit.toMap());

      
      final index = _habits.indexWhere((h) => h.id == habitId);
      if (index != -1) {
        _habits[index] = updatedHabit;
      }
    } catch (e) {
      _error = e.toString();
      print('Error toggling habit completion: $e');
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
