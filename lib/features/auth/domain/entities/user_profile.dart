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

  // Harris-Benedict Formula za BMR
  double get bmr {
    if (gender.toLowerCase() == 'žensko') {
      return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    } else {
      return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    }
  }

  // Pretpostavljamo umjerenu aktivnost (1.55) ako nije drugačije definirano
  // Ovdje koristimo dailyCaloriesTarget kao glavni izvor istine, 
  // ali možemo izračunati i preporučene makrose na temelju toga.
  
  double get proteinTarget => (dailyCaloriesTarget * 0.30) / 4; // 30% kalorija iz proteina
  double get carbsTarget => (dailyCaloriesTarget * 0.40) / 4;   // 40% kalorija iz ugljikohidrata
  double get fatTarget => (dailyCaloriesTarget * 0.30) / 9;     // 30% kalorija iz masti

  double get sugarTarget => (dailyCaloriesTarget * 0.10) / 4; 
  double get fiberTarget => (dailyCaloriesTarget / 1000) * 14;
  double get sodiumTarget => 2300.0;
  double get saturatedFatTarget => (dailyCaloriesTarget * 0.10) / 9;
  double get cholesterolTarget => 300.0;
  double get transFatTarget => 0.0;

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
