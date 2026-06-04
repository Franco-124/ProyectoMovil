class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String plan;
  final bool isTrial;
  final DateTime? trialEndsAt;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.plan,
    this.isTrial = false,
    this.trialEndsAt,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      plan: json['plan']?.toString() ?? 'free',
      isTrial: json['is_trial'] as bool? ?? false,
      trialEndsAt: json['trial_ends_at'] != null 
          ? DateTime.tryParse(json['trial_ends_at'] as String) 
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'full_name': fullName,
    'plan': plan,
    'is_trial': isTrial,
    'trial_ends_at': trialEndsAt?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
  };

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? plan,
    bool? isTrial,
    DateTime? trialEndsAt,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      plan: plan ?? this.plan,
      isTrial: isTrial ?? this.isTrial,
      trialEndsAt: trialEndsAt ?? this.trialEndsAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
