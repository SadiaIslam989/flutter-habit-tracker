import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DefaultHabitsService {
  static final _defaultHabits = [
    {
      'title': 'Drink water',
      'category': 'Health',
      'frequency': 'Daily',
      'icon': '💧',
      'notes': 'Drink 8 glasses of water daily',
      'color': 0xFF64B5F6, 
      'currentStreak': 0,
      'completionHistory': [],
      'creationDate': FieldValue.serverTimestamp(),
    },
    {
      'title': 'Journaling',
      'category': 'Mental Health',
      'frequency': 'Daily',
      'icon': '📔',
      'notes': 'Write about your day',
      'target': 1,
      'color': 0xFF9575CD, 
      'streak': 0,
      'completionHistory': [],
      'startDate': DateTime.now(),
      'isArchived': false
    },
    {
      'title': 'Workout',
      'category': 'Fitness',
      'frequency': 'Daily',
      'icon': '💪',
      'notes': '30 minutes exercise',
      'target': 30,
      'color': 0xFFEF5350, 
      'streak': 0,
      'completionHistory': [],
      'startDate': DateTime.now(),
      'isArchived': false
    },
    {
      'title': 'Reading',
      'category': 'Education',
      'frequency': 'Daily',
      'icon': '📚',
      'notes': 'Read for 30 minutes',
      'target': 30,
      'color': 0xFFFFB74D, 
      'streak': 0,
      'completionHistory': [],
      'startDate': DateTime.now(),
      'isArchived': false
    },
    {
      'title': 'Eat Healthy',
      'category': 'Health',
      'frequency': 'Daily',
      'icon': '�',
      'notes': 'Eat balanced meals',
      'target': 3,
      'color': 0xFF81C784, 
      'streak': 0,
      'completionHistory': [],
      'startDate': DateTime.now(),
      'isArchived': false
    },
    {
      'title': 'Cleaning',
      'category': 'Home',
      'frequency': 'Weekly',
      'icon': '🧹',
      'notes': 'Keep your space tidy',
      'target': 1,
      'color': 0xFF7986CB, 
      'streak': 0,
      'completionHistory': [],
      'startDate': DateTime.now(),
      'isArchived': false
    },
    {
      'title': 'Walk dog',
      'category': 'Pets',
      'frequency': 'Daily',
      'icon': '🐕',
      'notes': '20 minutes walk',
      'target': 20,
      'color': 0xFFFFB74D, 
      'streak': 0,
      'completionHistory': [],
      'startDate': DateTime.now(),
      'isArchived': false
    },
    {
      'title': 'Cooking',
      'category': 'Home',
      'frequency': 'Weekly',
      'icon': '�‍🍳',
      'notes': 'Cook healthy meals',
      'target': 2,
      'color': 0xFFFF8A65, 
      'streak': 0,
      'completionHistory': [],
      'startDate': DateTime.now(),
      'isArchived': false
    }
  ];

  static Future<void> createDefaultHabits() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final habitsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('habits');

      
      final existingHabits = await habitsRef.limit(1).get();
      if (existingHabits.docs.isNotEmpty) return;

      // Create default habits
      final batch = FirebaseFirestore.instance.batch();
      
      for (final habit in _defaultHabits) {
        final docRef = habitsRef.doc(); 
        batch.set(docRef, {
          'title': habit['title'],
          'category': habit['category'],
          'frequency': habit['frequency'],
          'creationDate': FieldValue.serverTimestamp(),
          'currentStreak': 0,
          'completionHistory': [],
          'notes': habit['notes'],
        });
      }

      
      await batch.commit();
    } catch (e) {
      print('Error creating default habits: $e');
      rethrow;
    }
  }
}
