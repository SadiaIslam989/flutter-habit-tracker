import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user's stats
  Stream<UserModel> getCurrentUserStats() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) => UserModel.fromMap(doc.data() ?? {}, doc.id));
  }

  // Update user's daily activities
  Future<void> updateDailyActivities(int completed, int total) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'dailyActivitiesCompleted': completed,
      'dailyActivitiesTotal': total,
    }, SetOptions(merge: true));
  }

  // Update user's streak
  Future<void> updateStreak(int streak) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'streak': streak,
    }, SetOptions(merge: true));
  }

  
  Future<void> updateTimeSpent(int minutes) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    final currentTimeSpent = doc.data()?['totalTimeSpent'] ?? 0;

    await _firestore.collection('users').doc(user.uid).set({
      'totalTimeSpent': currentTimeSpent + minutes,
    }, SetOptions(merge: true));
  }

  // Calculate and update confidence level
  Future<void> updateConfidenceLevel() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data() ?? {};
    
    
    final completed = data['dailyActivitiesCompleted'] ?? 0;
    final total = data['dailyActivitiesTotal'] ?? 0;
    final streak = data['streak'] ?? 0;
    
    
    double confidence = 0;
    if (total > 0) {
      confidence = ((completed / total) * 0.6);
    }
    confidence += ((streak > 10 ? 1 : streak / 10) * 0.4);
    confidence *= 100;

    await _firestore.collection('users').doc(user.uid).set({
      'confidenceLevel': confidence,
    }, SetOptions(merge: true));
  }
}
