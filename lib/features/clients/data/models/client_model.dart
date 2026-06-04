class ClientModel {
  final String id;
  final String name;
  final String email;
  final String? company;
  final String? notes;
  final String emailLanguage;
  final String emailTone;
  final String emailTreatment;
  final String? senderName;
  final String? emailInstructions;
  final DateTime createdAt;

  const ClientModel({
    required this.id,
    required this.name,
    required this.email,
    this.company,
    this.notes,
    this.emailLanguage = 'es',
    this.emailTone = 'semi-formal',
    this.emailTreatment = 'nombre',
    this.senderName,
    this.emailInstructions,
    required this.createdAt,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      company: json['company']?.toString(),
      notes: json['notes']?.toString(),
      emailLanguage: json['email_language']?.toString() ?? 'es',
      emailTone: json['email_tone']?.toString() ?? 'semi-formal',
      emailTreatment: json['email_treatment']?.toString() ?? 'nombre',
      senderName: json['sender_name']?.toString(),
      emailInstructions: json['email_instructions']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'company': company,
    'notes': notes,
    'email_language': emailLanguage,
    'email_tone': emailTone,
    'email_treatment': emailTreatment,
    'sender_name': senderName,
    'email_instructions': emailInstructions,
    'created_at': createdAt.toIso8601String(),
  };

  ClientModel copyWith({
    String? id,
    String? name,
    String? email,
    String? company,
    String? notes,
    String? emailLanguage,
    String? emailTone,
    String? emailTreatment,
    String? senderName,
    String? emailInstructions,
    DateTime? createdAt,
  }) {
    return ClientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      company: company ?? this.company,
      notes: notes ?? this.notes,
      emailLanguage: emailLanguage ?? this.emailLanguage,
      emailTone: emailTone ?? this.emailTone,
      emailTreatment: emailTreatment ?? this.emailTreatment,
      senderName: senderName ?? this.senderName,
      emailInstructions: emailInstructions ?? this.emailInstructions,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
