import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getHabitStream() {
    if (user == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('habits')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Visualization'),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: getHabitStream(),
          builder: (context, habitSnapshot) {
            if (habitSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!habitSnapshot.hasData || habitSnapshot.data!.docs.isEmpty) {
              return const Center(
                  child: Text('No habit progress available.'));
            }

            final habitDocs = habitSnapshot.data!.docs;
            int totalHabits = habitDocs.length;
            int totalCompletionsLast7Days = 0;
            int longestStreak = 0;

            final now = DateTime.now();
            final last7Dates = List.generate(
              7,
              (i) => DateTime(now.year, now.month, now.day - (3 - i)),
            );

            Map<String, int> dailyCounts = {};
            for (var doc in habitDocs) {
              final habitData = doc.data();
              final history =
                  List<dynamic>.from(habitData['completionHistory'] ?? []);
              final currentStreak = habitData['currentStreak'] ?? 0;
              if (currentStreak > longestStreak) {
                longestStreak = currentStreak;
              }

              for (var date in history) {
                final dateStr = date is Timestamp
                    ? DateFormat('yyyy-MM-dd').format(date.toDate())
                    : date.toString();

                final completionDate =
                    date is Timestamp ? date.toDate() : DateTime.parse(date);
                if (last7Dates.any((d) =>
                    DateFormat('yyyy-MM-dd').format(d) ==
                    DateFormat('yyyy-MM-dd').format(completionDate))) {
                  totalCompletionsLast7Days++;
                }

                dailyCounts[dateStr] = (dailyCounts[dateStr] ?? 0) + 1;
              }
            }

            double completionRate =
                totalHabits > 0 ? (totalCompletionsLast7Days / (totalHabits * 7)) * 100 : 0;
            int skippedDays = (totalHabits * 7) - totalCompletionsLast7Days;

            return Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Progress Visualization (Last 7 Days)",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 250,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: (totalHabits + 1).toDouble(),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                int idx = value.toInt();
                                if (idx >= 0 && idx < last7Dates.length) {
                                  return Text(
                                    DateFormat('EEE').format(last7Dates[idx]),
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
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                if (value % 1 == 0) {
                                  return Text(value.toInt().toString(),
                                      style: const TextStyle(fontSize: 12));
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData:
                            FlGridData(show: true, drawVerticalLine: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: List.generate(7, (i) {
                              final dateKey = DateFormat('yyyy-MM-dd')
                                  .format(last7Dates[i]);
                              final count = dailyCounts[dateKey] ?? 0;
                              return FlSpot(i.toDouble(), count.toDouble());
                            }),
                            isCurved: true,
                            color: Colors.purple,
                            barWidth: 4,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.purple.withOpacity(0.3),
                            ),
                          )
                        ],
                        lineTouchData: LineTouchData(
                          handleBuiltInTouches: true,
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (touchedSpots) {
                              if (touchedSpots.isEmpty) return [];

                              return touchedSpots.map((touched) {
                                final count = touched.y.toInt();
                                return LineTooltipItem(
                                  "Completed: $count",
                                  TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }).toList();
                            },
                            getTooltipColor: (_)
                                => Colors.purple.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      _buildStatCard(
                        'Longest Streak',
                        '$longestStreak days',
                        Icons.local_fire_department,
                        Colors.orange,
                      ),
                      const SizedBox(height: 10),
                      _buildStatCard(
                        'Completion Rate',
                        '${completionRate.toStringAsFixed(1)}%',
                        Icons.check_circle,
                        Colors.green,
                      ),
                      const SizedBox(height: 10),
                      _buildStatCard(
                        'Skipped Days',
                        '$skippedDays days',
                        Icons.cancel,
                        Colors.red,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
