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
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // ===== graph =====
                const Text(
                  "Progress Visualization (Last 7 Days)",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(221, 97, 97, 97),
                  ),
                ),
                const SizedBox(height: 20),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: getHabitStream(),
                  builder: (context, habitSnapshot) {
                    if (habitSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!habitSnapshot.hasData ||
                        habitSnapshot.data!.docs.isEmpty) {
                      return const Center(
                          child: Text('No habit progress available.'));
                    }

                    final now = DateTime.now();
                    final last7Dates = List.generate(
                      7,
                      (i) => DateTime(now.year, now.month, now.day - (6 - i)),
                    );
                    final last7Labels = last7Dates
                        .map((d) => DateFormat('EEE').format(d))
                        .toList();

                    List<LineChartBarData> lineBars = [];
                    final habitDocs = habitSnapshot.data!.docs;

                    Map<int, Set<String>> tooltipMap = {};

                    for (var doc in habitDocs) {
                      final habitData = doc.data();
                      final history =
                          List<dynamic>.from(habitData['completionHistory'] ?? []);
                      final color = Color(habitData['color'] ?? 0xFFBA68C8);

                      List<FlSpot> spots = [];
                      for (int i = 0; i < last7Dates.length; i++) {
                        final dateKey =
                            DateFormat('yyyy-MM-dd').format(last7Dates[i]);
                        bool doneToday = history.any((date) {
                          final dateStr = date is Timestamp
                              ? DateFormat('yyyy-MM-dd').format(date.toDate())
                              : date.toString();
                          return dateStr == dateKey;
                        });

                        if (doneToday) {
                          tooltipMap.putIfAbsent(i, () => <String>{});
                          tooltipMap[i]!.add(doc.id);
                        }

                        spots.add(FlSpot(i.toDouble(), doneToday ? 1 : 0));
                      }

                      lineBars.add(LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: color,
                        barWidth: 4,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: color.withOpacity(0.3),
                        ),
                      ));
                    }

                    return SizedBox(
                      height: 250,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: LineChart(
                          LineChartData(
                            minY: 0,
                            maxY: 1.5,
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    int idx = value.toInt();
                                    if (idx >= 0 && idx < last7Labels.length) {
                                      return Text(
                                        last7Labels[idx],
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData:
                                FlGridData(show: true, drawVerticalLine: false),
                            borderData: FlBorderData(show: false),
                            lineBarsData: lineBars,
                            lineTouchData: LineTouchData(
                              handleBuiltInTouches: true,
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipItems: (touchedSpots) {
                                  if (touchedSpots.isEmpty) return [];

                                  return touchedSpots.map((touched) {
                                    final dayIndex = touched.x
                                        .round()
                                        .clamp(0, last7Dates.length - 1);
                                    final habitSet = tooltipMap[dayIndex] ?? <String>{};
                                    final count = habitSet.length;

                                    return LineTooltipItem(
                                      "Habits done: $count",
                                      const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }).toList();
                                },
                                getTooltipColor: (_) =>
                                    const Color.fromRGBO(156, 39, 176, 1)
                                        .withOpacity(0.8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
