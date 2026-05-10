class UserProfile {
  final String id;
  final String displayName;
  final int age;
  final double height;
  final double weight;
  final String gender;
  final String medicalConditions;
  final String goals;
  final int dailyCaloriesTarget;

  UserProfile({
    required this.id,
    required this.displayName,
    required this.age,
    required this.height,
    required this.weight,
    required this.gender,
    required this.medicalConditions,
    required this.goals,
    required this.dailyCaloriesTarget,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'age': age,
      'height': height,
      'weight': weight,
      'gender': gender,
      'medicalConditions': medicalConditions,
      'goals': goals,
      'dailyCaloriesTarget': dailyCaloriesTarget,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      displayName: json['displayName'] as String? ?? 'Korisnik',
      age: json['age'] as int? ?? 25,
      height: (json['height'] as num?)?.toDouble() ?? 170.0,
      weight: (json['weight'] as num?)?.toDouble() ?? 70.0,
      gender: json['gender'] as String? ?? 'Muško',
      medicalConditions: json['medicalConditions'] as String? ?? '',
      goals: json['goals'] as String? ?? 'Održavanje težine',
      dailyCaloriesTarget: json['dailyCaloriesTarget'] as int? ?? 2000,
    );
  }
}
