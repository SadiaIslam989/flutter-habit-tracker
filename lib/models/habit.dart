class Habit {
  String id;
  String title;
  String category;
  String frequency;
  DateTime? startDate;
  String? notes;
  int completedCount;
  int targetCount;
  int timeSpentMinutes;
  List<DateTime> completionDates;
  DateTime? lastCompletedDate;

  Habit({
    required this.id,
    required this.title,
    required this.category,
    required this.frequency,
    this.startDate,
    this.notes,
    this.completedCount = 0,
    this.targetCount = 0,
    this.timeSpentMinutes = 0,
    List<DateTime>? completionDates,
    this.lastCompletedDate,
  }) : completionDates = completionDates ?? [];

  factory Habit.fromMap(Map<String, dynamic> data, String id) {
    return Habit(
      id: id,
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      frequency: data['frequency'] ?? '',
      startDate: data['startDate'] != null
          ? DateTime.parse(data['startDate'])
          : null,
      notes: data['notes'],
      completedCount: data['completedCount'] ?? 0,
      targetCount: data['targetCount'] ?? 0,
      timeSpentMinutes: data['timeSpentMinutes'] ?? 0,
      completionDates: (data['completionDates'] as List<dynamic>?)
          ?.map((date) => DateTime.parse(date))
          .toList() ?? [],
      lastCompletedDate: data['lastCompletedDate'] != null
          ? DateTime.parse(data['lastCompletedDate'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'frequency': frequency,
      'startDate': startDate?.toIso8601String(),
      'notes': notes,
      'completedCount': completedCount,
      'targetCount': targetCount,
      'timeSpentMinutes': timeSpentMinutes,
      'completionDates': completionDates.map((date) => date.toIso8601String()).toList(),
      'lastCompletedDate': lastCompletedDate?.toIso8601String(),
    };
  }

  bool get isCompletedToday {
    if (lastCompletedDate == null) return false;
    final now = DateTime.now();
    return lastCompletedDate!.year == now.year &&
           lastCompletedDate!.month == now.month &&
           lastCompletedDate!.day == now.day;
  }

  int get currentStreak {
    if (completionDates.isEmpty) return 0;
    
    completionDates.sort();
    int streak = 1;
    final now = DateTime.now();
    
    for (int i = completionDates.length - 2; i >= 0; i--) {
      final difference = completionDates[i + 1].difference(completionDates[i]).inDays;
      if (difference == 1) {
        streak++;
      } else {
        break;
      }
    }
    
    
    final lastDate = completionDates.last;
    final daysSinceLastCompletion = now.difference(lastDate).inDays;
    if (daysSinceLastCompletion > 1) {
      return 0;
    }
    
    return streak;
  }
}
