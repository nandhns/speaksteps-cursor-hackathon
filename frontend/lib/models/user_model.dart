enum UserRole {
  patient,
  therapist,
}

/// Available therapy modules
enum TherapyModule {
  writing,
  comprehension,
}

class UserModel {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final DateTime createdAt;
  // Patient-specific fields
  final String? diagnosis; // Type of aphasia
  final String? patientPhone; // Patient phone number
  final String? caregiverName;
  final String? caregiverPhone;
  final String? therapistId; // ID of the therapist who manages this patient
  final List<TherapyModule>? assignedModules; // Modules assigned by therapist
  final bool? onboardingEmailSent; // Track if onboarding email was sent
  final String? preferredLanguage; // Patient's preferred language ('en' or 'ms')
  final bool? mustChangePassword; // Require user to set a new password on first sign-in

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    this.diagnosis,
    this.patientPhone,
    this.caregiverName,
    this.caregiverPhone,
    this.therapistId,
    this.assignedModules,
    this.onboardingEmailSent,
    this.preferredLanguage,
    this.mustChangePassword,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.name,
      'createdAt': createdAt.toIso8601String(),
      'diagnosis': diagnosis,
      'patientPhone': patientPhone,
      'caregiverName': caregiverName,
      'caregiverPhone': caregiverPhone,
      'therapistId': therapistId,
      'assignedModules': assignedModules?.map((m) => m.name).toList(),
      'onboardingEmailSent': onboardingEmailSent,
      'preferredLanguage': preferredLanguage,
      'mustChangePassword': mustChangePassword,
    };
  }

  // Create from Map (from Firebase)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.patient,
      ),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      diagnosis: map['diagnosis'],
      patientPhone: map['patientPhone'],
      caregiverName: map['caregiverName'],
      caregiverPhone: map['caregiverPhone'],
      therapistId: map['therapistId'],
      assignedModules: (map['assignedModules'] as List<dynamic>?)
          ?.map((m) => TherapyModule.values.firstWhere(
                (e) => e.name == m,
                orElse: () => TherapyModule.writing,
              ))
          .toList(),
      onboardingEmailSent: map['onboardingEmailSent'],
      preferredLanguage: map['preferredLanguage'],
      mustChangePassword: map['mustChangePassword'],
    );
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    DateTime? createdAt,
    String? diagnosis,
    String? patientPhone,
    String? caregiverName,
    String? caregiverPhone,
    String? therapistId,
    List<TherapyModule>? assignedModules,
    bool? onboardingEmailSent,
    String? preferredLanguage,
    bool? mustChangePassword,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      diagnosis: diagnosis ?? this.diagnosis,
      patientPhone: patientPhone ?? this.patientPhone,
      caregiverName: caregiverName ?? this.caregiverName,
      caregiverPhone: caregiverPhone ?? this.caregiverPhone,
      therapistId: therapistId ?? this.therapistId,
      assignedModules: assignedModules ?? this.assignedModules,
      onboardingEmailSent: onboardingEmailSent ?? this.onboardingEmailSent,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
    );
  }
}

