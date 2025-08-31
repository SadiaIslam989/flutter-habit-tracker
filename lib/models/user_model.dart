class UserModel {
  final String id;
  final String displayName;
  final String? gender;
  final String? dateOfBirth;
  final String? height;
  final String? otherDetails;
  final String? avatarUrl;
  final int streak;
  final int dailyActivitiesCompleted;
  final int dailyActivitiesTotal;
  final int totalTimeSpent; 
  final double confidenceLevel; 
  UserModel({
    required this.id,
    required this.displayName,
    this.gender,
    this.dateOfBirth,
    this.height,
    this.otherDetails,
    this.avatarUrl,
    this.streak = 0,
    this.dailyActivitiesCompleted = 0,
    this.dailyActivitiesTotal = 0,
    this.totalTimeSpent = 0,
    this.confidenceLevel = 0,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      displayName: data['displayName'] ?? '',
      gender: data['gender'],
      dateOfBirth: data['dateOfBirth'],
      height: data['height'],
      otherDetails: data['otherDetails'],
      avatarUrl: data['avatarUrl'],
      streak: data['streak'] ?? 0,
      dailyActivitiesCompleted: data['dailyActivitiesCompleted'] ?? 0,
      dailyActivitiesTotal: data['dailyActivitiesTotal'] ?? 0,
      totalTimeSpent: data['totalTimeSpent'] ?? 0,
      confidenceLevel: (data['confidenceLevel'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'height': height,
      'otherDetails': otherDetails,
      'avatarUrl': avatarUrl,
      'streak': streak,
      'dailyActivitiesCompleted': dailyActivitiesCompleted,
      'dailyActivitiesTotal': dailyActivitiesTotal,
      'totalTimeSpent': totalTimeSpent,
      'confidenceLevel': confidenceLevel,
    };
  }

  UserModel copyWith({
    String? displayName,
    String? gender,
    String? dateOfBirth,
    String? height,
    String? otherDetails,
    String? avatarUrl,
    int? streak,
    int? dailyActivitiesCompleted,
    int? dailyActivitiesTotal,
    int? totalTimeSpent,
    double? confidenceLevel,
  }) {
    return UserModel(
      id: id,
      displayName: displayName ?? this.displayName,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      height: height ?? this.height,
      otherDetails: otherDetails ?? this.otherDetails,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      streak: streak ?? this.streak,
      dailyActivitiesCompleted: dailyActivitiesCompleted ?? this.dailyActivitiesCompleted,
      dailyActivitiesTotal: dailyActivitiesTotal ?? this.dailyActivitiesTotal,
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
      confidenceLevel: confidenceLevel ?? this.confidenceLevel,
    );
  }
}
