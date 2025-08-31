import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/default_habits_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  User? get user => _user;

  AuthProvider() {
    
    _user = _auth.currentUser;
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      notifyListeners();
      if (_user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', _user!.uid);
      }
    });
  }

  /// Register new user
  Future<String?> register({
    required String displayName,
    required String email,
    required String password,
    String? gender,
    Map<String, dynamic>? otherDetails,
  }) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      _user = cred.user;

      if (_user != null) {
        // Save additional user info in Firestore
        await _firestore.collection('users').doc(_user!.uid).set({
          'displayName': displayName.trim(),
          'email': email.trim(),
          'gender': gender ?? '',
          'otherDetails': otherDetails ?? {},
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Save locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', _user!.uid);

        notifyListeners();
      }
      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Registration failed";
    } catch (e) {
      return e.toString();
    }
  }

  /// Login user
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      _user = cred.user;

      if (_user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', _user!.uid);
        
        // Create default habits for new user
        await DefaultHabitsService.createDefaultHabits();
      }

      notifyListeners();
      return null; 
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Login failed";
    } catch (e) {
      return e.toString();
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      _user = null;
      notifyListeners();
    } catch (e) {
      debugPrint("Logout failed: $e");
    }
  }

  /// Check if user is already logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('userId');
  }
}
