import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ProfileViewScreen extends StatefulWidget {
  const ProfileViewScreen({super.key});

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserStream() {
    if (user == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getHabitStream() {
    if (user == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('habits')
        .snapshots();
  }

  Future<void> _editProfile(Map<String, dynamic> profileData) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(profileData: profileData),
      ),
    );
  }

  String? _getStringField(dynamic field) {
    if (field == null) return null;
    if (field is String) return field;
    if (field is Map) return field.toString(); 
    return field.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No user logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: getUserStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return const Center(child: Text('No profile data available.'));
          }

          final data = snapshot.data!.data()!;
          final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 14,
              );

          final displayName = _getStringField(data['displayName']) ?? 'User';
          final email = _getStringField(data['email']);
          final gender = _getStringField(data['gender']);
          final dateOfBirth = _getStringField(data['dateOfBirth']);
          final height = _getStringField(data['height']);
          final otherDetails = _getStringField(data['otherDetails']);
          final avatarUrl = _getStringField(data['avatarUrl']);

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Avatar
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 91, 91, 91)
                            .withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: (avatarUrl != null && avatarUrl.isNotEmpty)
                        ? Image.network(
                            avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return Container(
                                color: Colors.purple.shade100,
                                child: const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.purple,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.purple.shade100,
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.purple,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(221, 97, 97, 97),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (email != null && email.isNotEmpty)
                        Text("Email: $email", style: textStyle),
                      if (gender != null && gender.isNotEmpty)
                        Text("Gender: $gender", style: textStyle),
                      if (dateOfBirth != null && dateOfBirth.isNotEmpty)
                        Text("DOB: $dateOfBirth", style: textStyle),
                      if (height != null && height.isNotEmpty)
                        Text("Height: $height", style: textStyle),
                      if (otherDetails != null && otherDetails.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            otherDetails,
                            textAlign: TextAlign.center,
                            style: textStyle,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // Edit Profile Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: () async {
                      final doc = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user!.uid)
                          .get();
                      final profileData = doc.data() ?? {};
                      _editProfile({
                        'displayName': _getStringField(profileData['displayName']) ?? '',
                        'gender': _getStringField(profileData['gender']) ?? '',
                        'dateOfBirth': _getStringField(profileData['dateOfBirth']) ?? '',
                        'height': _getStringField(profileData['height']) ?? '',
                        'otherDetails': _getStringField(profileData['otherDetails']) ?? '',
                        'email': user!.email ?? '',
                        'avatarUrl': _getStringField(profileData['avatarUrl']) ?? '',
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(156, 39, 176, 1),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // ===== graph =====
                const SizedBox.shrink(),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
