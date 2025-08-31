import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const EditProfileScreen({super.key, required this.profileData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _heightController;
  late TextEditingController _otherDetailsController;
  String? _selectedAvatar;
  String? _gender;

  final List<Map<String, String>> _avatarOptions = [
    {'name': 'Avatar 1', 'asset': 'assets/images/icon1.jpg'},
    {'name': 'Avatar 2', 'asset': 'assets/images/icon2.jpg'},
    {'name': 'Avatar 3', 'asset': 'assets/images/icon3.jpg'},
    {'name': 'Avatar 4', 'asset': 'assets/images/icon4.jpg'},
    {'name': 'Avatar 5', 'asset': 'assets/images/icon5.jpg'},
  ];

  late String _email;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _email = user?.email ?? '';

    _nameController = TextEditingController(text: widget.profileData['displayName'] ?? '');
    _dobController = TextEditingController(text: widget.profileData['dateOfBirth'] ?? '');
    _heightController = TextEditingController(text: widget.profileData['height'] ?? '');
    _otherDetailsController = TextEditingController(text: widget.profileData['otherDetails'] ?? '');
    _gender = widget.profileData['gender'];
    _selectedAvatar = widget.profileData['avatarUrl'];
  }

  void _showAvatarPicker() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose Your Avatar',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _avatarOptions.map((avatar) => GestureDetector(
                  onTap: () {
                    setState(() => _selectedAvatar = avatar['asset']);
                    Navigator.pop(context);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedAvatar == avatar['asset'] 
                                ? Colors.purple 
                                : Colors.transparent,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(37),
                          child: Image.asset(
                            avatar['asset']!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        avatar['name']!,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final currentData = doc.data() ?? {};

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'displayName': _nameController.text,
        'gender': _gender,
        'dateOfBirth': _dobController.text,
        'height': _heightController.text,
        'otherDetails': _otherDetailsController.text,
        'avatarUrl': _selectedAvatar,
        'streak': currentData['streak'] ?? 0,
        'dailyActivitiesCompleted': currentData['dailyActivitiesCompleted'] ?? 0,
        'dailyActivitiesTotal': currentData['dailyActivitiesTotal'] ?? 0,
        'totalTimeSpent': currentData['totalTimeSpent'] ?? 0,
        'confidenceLevel': currentData['confidenceLevel'] ?? 0,
      }, SetOptions(merge: true));

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    }
  }

  InputDecoration _buildInputDecoration(String label, {IconData? icon}) {
    final theme = Theme.of(context);
    final iconColor = theme.brightness == Brightness.dark ? Colors.purple : theme.primaryColor;

    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: iconColor, size: 22) : null,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture Section
                Center(
                  child: GestureDetector(
                    onTap: _showAvatarPicker,
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.purple.shade100,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: _selectedAvatar != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.asset(_selectedAvatar!, fit: BoxFit.cover),
                                )
                              : const Icon(Icons.person, size: 50, color: Colors.purple),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.purple,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, size: 20, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                _buildSectionTitle("Basic Info"),
                const SizedBox(height: 15),

                TextFormField(
                  initialValue: _email,
                  readOnly: true,
                  decoration: _buildInputDecoration("Email", icon: Icons.email_outlined),
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 15),

                TextFormField(
                  controller: _nameController,
                  decoration: _buildInputDecoration("Display Name", icon: Icons.person_outline),
                  validator: (value) => value!.isEmpty ? "Name cannot be empty" : null,
                ),
                const SizedBox(height: 15),

                DropdownButtonFormField<String>(
                  value: _gender,
                  items: [
                    DropdownMenuItem(
                      value: "Male",
                      child: Row(
                        children: [
                          Icon(Icons.male, color: Colors.blue[400], size: 20),
                          const SizedBox(width: 10),
                          const Text("Male"),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: "Female",
                      child: Row(
                        children: [
                          Icon(Icons.female, color: Colors.pink[400], size: 20),
                          const SizedBox(width: 10),
                          const Text("Female"),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: "Other",
                      child: Row(
                        children: [
                          Icon(Icons.people, color: Colors.purple[400], size: 20),
                          const SizedBox(width: 10),
                          const Text("Other"),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _gender = value),
                  decoration: _buildInputDecoration("Gender", icon: Icons.people_outline),
                ),
                const SizedBox(height: 15),

                _buildSectionTitle("Personal Details"),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _dobController,
                  decoration: _buildInputDecoration("Date of Birth (DD/MM/YYYY)", icon: Icons.calendar_today),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _heightController,
                  decoration: _buildInputDecoration("Height (e.g., 170 cm)", icon: Icons.height),
                ),
                const SizedBox(height: 25),

                _buildSectionTitle("Other Details"),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _otherDetailsController,
                  maxLines: 4,
                  decoration: _buildInputDecoration("Write something about yourself...")
                      .copyWith(
                        alignLabelWithHint: true,
                        contentPadding: const EdgeInsets.all(15),
                      ),
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Save Profile",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }
}
