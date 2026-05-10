class AppUser {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool isOnboardingComplete;

  AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.isOnboardingComplete = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'isOnboardingComplete': isOnboardingComplete,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      isOnboardingComplete: json['isOnboardingComplete'] as bool? ?? false,
    );
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isOnboardingComplete,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
    );
  }
}
